# Local environment cluster K8S.
## The objective is test applications and integrations on local cluster k8s and send data to datadog.

## What will be done
- Create a K8S runtime with 3 local machines.
- Datadog-agent installed to collect all data from K8S
- Install the integration Rabbitmq on datadog trial account.
- Deploy the applications to test traces, logs and metrics.

### Requirements:
- Git Installed
- Make installed
- Helm installed
- Kind Installed
- Kubectl installed
- ApiKey from Datadog account trial

## Procedure

#### **Clone the repository**
``` 
git clone https://github.com/kayketeixeira/k8s-local
```

#### **Export your variable DATADOG_API_KEY**
```
export DATADOG_API_KEY=<YOUR-APIKEY-HERE>
```

#### **Go into to the folder use this command to create everything**
``` 
make create-cluster 
```

**Once you create everything you will have:**
- K8S created (kind) with 1 control-plane and 3 workers
- Rabbitmq integrated
- Applications deployed

#### You can test traces from dotnet application for example
```
kubectl port forward svc/dotnet-app 8081 -n default
```

#### Send the traces that are configured in the populate.sh file, access the application/dotnet/ folder
```
./populate.sh
```

#### Check out on datadog account