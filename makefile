deploy:
	deploy-zeuspol
	deploy-hermes

deploy-local:
	deploy-zeuspol-local
	deploy-hemers-local

undeploy:
	undeploy-zeuspol
	undeploy-hermes

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

deploy-themis:
	