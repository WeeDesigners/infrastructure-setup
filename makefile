# * The values here can be overriden by passing a variable to the make command
# * f.eg. make deplloy THEMIS_NAMESPACE=my-custom-themis-namespace
# ! IMPORTANT: These values should match the actual values for themis deployment
# ! These values can be found in helm chart definition under themis-executor/chart/values.yaml
THEMIS_NAMESPACE ?= themis-executor
THEMIS_K8S_SECRET_NAME ?= themis-secrets-k8s
THEMIS_OPENSTACK_SECRET_NAME ?= themis-secrects-openstack

CLUSTER_NAME ?= kubernetes
CLUSTER_USER ?= kubernetes-admin

deploy: check-secret
	helm install nfs-ganesha nfs-ganesha-server-and-external-provisioner/nfs-server-provisioner
	make deploy-monitoring
	make deploy-hephaestus
	make deploy-database
	make deploy-hermes
	make deploy-zeuspol
	make deploy-themis

deploy-local: check-secret
	make deploy-monitoring
	make deploy-hephaestus
	make deploy-database
	make deploy-hermes-local
	make deploy-zeuspol-local
	make deploy-themis

undeploy:
	helm uninstall nfs-ganesha
	make undeploy-zeuspol || true
	make undeploy-hermes || true
	make undeploy-themis || true
	make undeploy-hephaestus || true
	make undeploy-monitoring || true
	make undeploy-database

deploy-zeuspol:
	helm install zeuspol ./helm-charts/zeuspol

deploy-zeuspol-local:
	helm install zeuspol ./helm-charts/zeuspol --set zeuspol.container.image_pull_policy="Never"
	
undeploy-zeuspol:
	helm uninstall zeuspol

deploy-hermes:
	helm install hermes ./helm-charts/hermes

deploy-hermes-local:
	helm install hermes ./helm-charts/hermes --set hermes.container.image_pull_policy="Never"

undeploy-hermes:
	helm uninstall hermes

deploy-themis: check-secret
	helm install themis ./helm-charts/themis-executor

undeploy-themis:
	helm uninstall themis

deploy-hephaestus:
	helm install hephaestus ./helm-charts/hephaestus-metrics \
	--namespace hephaestus \
	--create-namespace

undeploy-hephaestus:
	helm uninstall hephaestus -n hephaestus

deploy-monitoring:
	helm install monitoring prometheus-community/kube-prometheus-stack \
	--namespace monitoring \
	--create-namespace

undeploy-monitoring:
	helm uninstall monitoring -n monitoring

deploy-database:
	helm install mysql \
	--set auth.username=hermes \
	--set auth.password=hermes \
	--set auth.database=pandora_box_db \
	--set namespaceOverride=mysql \
	--namespace mysql \
	--create-namespace \
	oci://registry-1.docker.io/bitnamicharts/mysql

undeploy-database:
	helm uninstall mysql -n mysql

# ! Themis will not be able to interact with kubernetes and openstack API without these secrets set 
check-secret:
	@kubectl get secret $(THEMIS_K8S_SECRET_NAME) -n $(THEMIS_NAMESPACE) >/dev/null 2>&1 && \
		echo "Using themis configuration from secret: $(THEMIS_K8S_SECRET_NAME)" || \
		( echo "No secret with name: $(THEMIS_K8S_SECRET_NAME) found. aborting deploy" && exit 1)

prepare-helm-repo:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add nfs-ganesha-server-and-external-provisioner https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/
	helm repo update

prepare-themis-secrets-minikube:
	./scripts/generate_themis_k8s_secrets.sh \
	minikube minikube $(THEMIS_K8S_SECRET_NAME) $(THEMIS_NAMESPACE)

prepare-themis-secrets:
	./scripts/generate_themis_k8s_secrets.sh \
	$(CLUSTER_NAME) $(CLUSTER_USER) $(THEMIS_K8S_SECRET_NAME) $(THEMIS_NAMESPACE)

	./scripts/generate_themis_openstack_secrets.sh

reset-minikube:
	minikube stop
	minikube delete
	minikube start

get-minikube-info:
	minikube service list

deploy-test-app:
	kubectl apply -f deployment/TestApp

undeploy-test-app:
	kubectl delete -f deployment/TestApp --ignore-not-found=true