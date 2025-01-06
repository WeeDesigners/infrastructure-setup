# Invalid Policies for a slowly starting app

## Scenario overview

We are deploying a a test app that takes about 60 seconds to start. In real world we can imagine an application that needs to fetch certain data from remote servers or connect to multiple databases and sync some internal data, which is needed during application runtime.

The application performs very important computation, that needs to be delievered fast and with minimal downtime, thus client demanded, that the service should have a **mean response time lower than 2 seconds**,  **90% of the requests need to have a response time lower than 3s** and also that **service availabilty should be higher 0.999**.

Client agreed on the following SLA:
```json
{
    "type": "SAAS",
    "clientId": "1111",
    "applicationId": "slow-start-app-1111",
    "slaRules": [
        {
            "valueType": "RESPONSE_TIME",
            "conditions": [
                {"metric": "response-time-mean", "relation":"LT", "value":2.0},
                {"metric": "response-time-90-percentile", "relation": "LT", "value": 5.0 }
            ]
        },
        {
            "valueType": "AVAILABILITY",
            "conditions": [
                {
                    "metric": "availability", "relation": "GT", "value": 0.999
                }
            ]
        }
    ]   
}
```

SRE team observed that, the application sometimes violates SLA when receving high load

The first approach on fixing the issue was to increase the app resources when the response time goes too high, so they created policy that raises the cpu limits on the containers in the app deployment. And also another one to decrease the limits when the response_time goes down.

Team managed to develop the following policies to try to keep the system in accordance with SLA.
```json
{
    "name": "Change container limits when the app cpu usage is greater than 75",
    "conditions": [
        {"metric":"slow-start-app-cpu-usage", "relation":"GT", "value":75}
    ],
    "action": {
        "collectionName": "kubernetes",
        "actionName": "ChangeResourcesOfContainerWithinDeploymentAction",
        "params": {
            "namespace": "slow-start-app",
            "deploymentName": "slow-start-app",
            "containerName": "app",
            "limitsCpu": "1000m",
            "limitsMemory": "1Gi",
            "requestsCpu": "250m",
            "requestsMemory": "100Mi"
        }
    }
}

```

```json
{
    "name": "Change container limits when the mean response time is greater than 3s",
    "conditions": [
        {"metric":"response-time-mean", "relation":"GT", "value":3}
    ],
    "action": {
        "collectionName": "kubernetes",
        "actionName": "ChangeResourcesOfContainerWithinDeploymentAction",
        "params": {
            "namespace": "slow-start-app",
            "deploymentName": "slow-start-app",
            "containerName": "app",
            "limitsCpu": "1000m",
            "limitsMemory": "1Gi",
            "requestsCpu": "250m",
            "requestsMemory": "100Mi"
        }
    }
}
```

This approach is very bad, which we will observe in the moment