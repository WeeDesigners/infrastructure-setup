# * The values here can be overriden by passing a variable to the make command
# * f.eg. make deplloy THEMIS_NAMESPACE=my-custom-themis-namespace
# ! IMPORTANT: These values should match the actual values for themis deployment
# ! These values can be found in helm chart definition under themis-executor/chart/values.yaml
THEMIS_NAMESPACE ?= themis-executor
THEMIS_K8S_SECRET_NAME ?= themis-secrets-k8s
THEMIS_OPENSTACK_SECRET_NAME ?= themis-secrects-openstack

CLUSTER_NAME ?= kubernetes
CLUSTER_USER ?= kubernetes-admin

restart-minikube:
	minikube delete
	minikube start --cpus 4 --memory 4096
	minikube addons enable metrics-server

# ! IMPORTANT: in order for the test to run correctly run `minikube tunnel` in separate terminal
test-scenario-minikube:
	make prepare-helm-repo
	make deploy-monitoring
	make deploy-ingress	
	
	make deploy-amocna-stack	
	
	make deploy-response-time-test-app

deploy-amocna-stack:
	make deploy-hephaestus
	make deploy-database
	make deploy-hermes
	make prepare-themis-secrets-minikube
	make deploy-themis
	make deploy-zeuspol

clean-deploy-minikube:
	minikube stop
	minikube delete

	minikube start --memory 12288 --cpus 6
	minikube addons enable metrics-server
	make prepare-helm-repo
	make prepare-themis-secrets-minikube
	make deploy-monitoring
	make deploy-hephaestus
	make deploy-database
	make deploy-hermes
	make deploy-themis
	make deploy-zeuspol
	make deploy-example-app

deploy: check-secret
	make deploy-monitoring
	make deploy-hephaestus
	make deploy-database
	make deploy-hermes
	make deploy-zeuspol
	make deploy-themis
	make deploy-example-app

deploy-local: check-secret
	make deploy-monitoring
	make deploy-hephaestus
	make deploy-database
	make deploy-hermes-local
	make deploy-zeuspol-local
	make deploy-themis
	make deploy-example-app

undeploy:
	make undeploy-zeuspol || true
	make undeploy-hermes || true
	make undeploy-themis || true
	make undeploy-hephaestus || true
	make undeploy-monitoring || true
	make undeploy-database
	make undeploy-example-app

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
	helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
	--namespace monitoring  \
	--create-namespace \
	--set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
	--set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

undeploy-monitoring:
	helm uninstall monitoring -n monitoring
	kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
	kubectl delete crd alertmanagers.monitoring.coreos.com
	kubectl delete crd podmonitors.monitoring.coreos.com
	kubectl delete crd probes.monitoring.coreos.com
	kubectl delete crd prometheusagents.monitoring.coreos.com
	kubectl delete crd prometheuses.monitoring.coreos.com
	kubectl delete crd prometheusrules.monitoring.coreos.com
	kubectl delete crd scrapeconfigs.monitoring.coreos.com
	kubectl delete crd servicemonitors.monitoring.coreos.com
	kubectl delete crd thanosrulers.monitoring.coreos.com
	
deploy-ingress:
	helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
	--namespace ingress-nginx --create-namespace \
	--namespace ingress-nginx \
	--set controller.metrics.enabled=true \
	--set controller.metrics.serviceMonitor.enabled=true \
	--set controller.metrics.serviceMonitor.additionalLabels.release="monitoring"

undeploy-ingress:
	helm uninstall ingress-nginx -n ingress-nginx

deploy-metrics-server:
	helm install metrics-server bitnami/metrics-server --version 7.3.0 \
	--set apiService.create=true
	
undeploy-metrics-server:
	helm uninstall metrics-server bitnami/metrics-server --version 7.3.0
	
deploy-example-app:
	kubectl apply -f manifests/example-app

undeploy-example-app:
	kubectl delete -f manifests/example-app

deploy-response-time-test-app:
	kubectl apply -f TestScenarios/response-time/manifests
	./TestScenarios/response-time/scripts/update_hosts_file.sh

undeploy-response-time-test-app:
	kubectl delete -f TestScenarios/response-time/manifests

deploy-database:
	kubectl apply -f manifests/mysql

undeploy-database:
	kubectl delete -f manifests/mysql

# ! Themis will not be able to interact with kubernetes and openstack API without these secrets set 
check-secret:
	@kubectl get secret $(THEMIS_K8S_SECRET_NAME) -n $(THEMIS_NAMESPACE) >/dev/null 2>&1 && \
		echo "Using themis configuration from secret: $(THEMIS_K8S_SECRET_NAME)" || \
		( echo "No secret with name: $(THEMIS_K8S_SECRET_NAME) found. aborting deploy" && exit 1)

prepare-helm-repo:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add bitnami https://charts.bitnami.com/bitnami
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
	
check-reequirements:
	kubectl --version
	yq --version