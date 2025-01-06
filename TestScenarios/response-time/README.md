# Test Scenerio Idea
In this sceneria we will tests the **Latency** metric

## Important notes

This scenario is inteded to run in the linux environment. We cannot guarantee that it work under WSL. It may requiere some additional configuration.
Scenario was tested on Linux Fedora 41 and minikube 1.33.1.

## Infrastructure

In order to conduct this scenerio we decided to use local  minikube with an Ingress Contoller as a testbed.

1. AMoCNA stack ( hephaestus, hermes, zeuspol, themis )
2. Example-flask-app 
3. Monitoring with prometheus enabled
4. Ingress with Nginx Ingress Controller
    1. purpose - get the request duration metric for requests to our app

## Test execution

1. Hey tool is used to make requests
2. Ingress handles the requests and forwards them to the example-application
3. zeus is measuring the latency of the request. When the latency exceedes a certain value the deployment is scaled


## Metrics

### Prometheus:

```
sum(rate(nginx_ingress_controller_request_duration_seconds_sum{exported_service="response-time-app-svc"}[2m])) / sum(rate(nginx_ingress_controller_request_duration_seconds_count{exported_service="response-time-app-svc"}[2m]))
```


## How to perform

1. To start with a clean environment run: `make restart-minikube`
    
    NOTE: make sure you do not have anything valuable on the minikube cluster, as this command will wipe out everything.
    
    NOTE: You can adjust the values of memory and cpu for your needs. In order to do that, change the values in makefile, or run the commands on your own
2. Run `minikube tunnel` in separate terminal to allow ingress to receive an ip address. THIS IS MANDATORY, because scripts are based on that ip
3. Run `make test-scenario-minikube`. This will deploy:
    - the complete amocna stack as helm charts ( including hephaestus, themis, hermes, zeuspol )
    - prometheus monitoring stack with graphana dashboards ( using prometheus operator helm charts )
    - ingress rules for this scenario
    - the test application using manifests files
4. If everything went well, following resources should be available in your browser:
    - grafana -> http://grafana
    - prometheus -> http://prometheus
    - test app endpoint, that should return `{"message":"Request processed successfully"}` -> http://response-time-app/process
5. In order to see prepared metrics import the dashboards for grafana provided in the `grafana-dashboards` folder
6. Install hey, run the following command to generate some load on the ap and observe the grafana dashboards to see if the requests are reaching our app. Hey will start 10 concurrent clients that will constantly send requests and wait for response for a maximum of 60s. Request rate will not exceed 10 Req/s. After 60000 messages sent hey will terminate ( Normally one pod is handling ~2 Req/s). Command to execute: `hey -q 10 -n 60000 -c 10 -t 60 http://response-time-test/process`

7. We have everything set up, now let's see the power of zeus in the amocna framework
8. Go to the http://< your minikube ip address >:31122 ( or http://hephaestus ) in order to access hephaestus ( minikube ip can be obtained by running: `minikube ip`)
9. Go to Custom metrics, and enter this metric:
    - name: `response-time`
    - value: `sum(rate(nginx_ingress_controller_request_duration_seconds_sum{exported_service="response-time-app-svc"}[2m])) / 
    sum(rate(nginx_ingress_controller_request_duration_seconds_count{exported_service="response-time-app-svc"}[2m]))`
10. This metric should already be visualized in the grafana dashboard. Check if it is diplaying correctly
11. Now we need to interact with hermes and load a sample SLA and Policies. Use Postman or other tool to send these requests: 
    ```
    PUT http://<<your minikube ip>>:31234/sla
    body: 
    {
        "type": "SAAS",
        "clientId": "1234",
        "applicationId": "56789",
        "slaRules": [
            {
                "valueType": "RESPONSE_TIME",
                "conditions": [
                    {"metric":"response-time", "relation":"LT", "value":10.0}
                ]
            }
        ]
    }

    PUT http://<< your minikube ip>:31234/policies
    body:
    {
        "name": "Scale Deployment when response time > 5",
        "conditions": [
            {"metric":"response-time", "relation":"LT", "value":1.5}
        ],
        "action": {
        "collectionName": "kubernetes",
            "actionName": "HorizontalScalingAction",
            "params": {
                "resourceType": "Deployment",
                "resourceName": "response-time-app",
                "namespace": "default",
                "replicas": "1"
            }
        }
    }

    PUT http://<your minikube ip>:31234/policies/active/<< policy id >>
    ```
    ! IMPORTANT: make sure to replace << you minikube ip >> with the real ip of your minikube cluster and << policy id >> with the id received as a reposnse from `PUT http://<< your minikube ip>:31234/policies` request

    NOTE: If running on linux you can replace `http://<< your minikube ip>:31234` with `http://hermes`
12. Start Zeuspol app:
    ```
    POST http://<< your minikube ip >>:32137/app/start
    ```

    NOTE: On linux you can also use `http://zeuspol/app/start
13. Zeuspol should be up and running
14. Now you can generete more load to the cluster, and see if Zeuspol is preventing the sla breach