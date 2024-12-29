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
	make deplloy-monitoring
	make deploy-hephaestus
	make deploy-zeuspol
	make deploy-hermes
	make deploy-themis

deploy-local: check-secret
	make deplloy-monitoring
	make deploy-hephaestus
	make deploy-zeuspol-local
	make deploy-hemers-local
	make deploy-themis

undeploy:
	make undeploy-zeuspol
	make undeploy-hermes
	make undeploy-themis
	make undeploy-hephaestus
	make undeploy-monitoring

deploy-zeuspol:
	helm install zeuspol /path/to/zeuspol/helm-chart

deploy-zeuspol-local:
	helm install zeuspol /path/to/zeuspol/helm-chart --set image_pull_policy="Never"
	
undeploy-zeuspol:
	helm uninstall zeuspol

deploy-hermes:
	helm install hermes /path/to/herme/helm-chart

deploy-hermes-local:
	helm install hermes /path/to/hermes/helm-chart --set image_pull_policy="Never"

undeploy-hermes:
	helm uninstall hermes

deploy-themis: check-secret
	helm install themis ./external-applications/themis-executor/chart

undeploy-themis:
	helm uninstall themis

deploy-hephaestus:
	helm install hephaestus ./external-applications/hephaestus-metrics/chart \
	--namespace hephaestus \
	--create-namespace

undeploy-hephaestus:
	helm uninstall hephaestus

deploy-monitoring:
	helm install monitoring prometheus-community/kube-prometheus-stack \
	--namespace monitoring \
	--create-namespace

undeploy-monitoring:
	helm uninstall monitoring
# ! Themis will not be able to interact with kubernetes and openstack API without these secrets set 
check-secret:
	@kubectl get secret $(THEMIS_SECRET_NAME) -n $(THEMIS_NAMESPACE) >/dev/null 2>&1 && \
		echo "Using themis configuration from secret: $(THEMIS_SECRET_NAME)" || \
		echo "No secret with name: $(THEMIS_SECRET_NAME) found. aborting deploy"

prepare-helm-repo:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update

prepare-themis-secrets-minikube:
	./external-applications/themis-executor/scripts/generate_themis_k8s_secrets.sh \
	minikube minikube $(THEMIS_K8S_SECRET_NAME) $(THEMIS_NAMESPACE)

prepare-themis-secrets:
	./external-applications/themis-executor/scripts/generate_themis_k8s_secrets.sh \
	$(CLUSTER_NAME) $(CLUSTER_USER) $(THEMIS_K8S_SECRET_NAME) $(THEMIS_NAMESPACE)

	./external-applications/themis-executor/scripts/generate_themis_openstack_secrets.sh