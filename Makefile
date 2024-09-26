# create k8s kind cluster
# 
# requirements:
# - docker
# - kind: https://kind.sigs.k8s.io/docs/user/quick-start/#installation
# 
# observations:
# ifneq is a make command. Therefore, we should not use TAB characters as the first characters in the line,
# as it would be passed to the shell, and the shell doesn't know anything about ifneq.
# the same is valid to comments and any make commands.

CLUSTER_NAME = $(shell echo local | tr '[:upper:]' '[:lower:]')
CLUSTER_EXISTS = $(shell kind get clusters -q | grep $(CLUSTER_NAME))

# DOCKER_SUBNET should be a valid ipv4 address.
IPV4_INDEX = $(shell docker network inspect -f '{{.EnableIPv6}}' kind)
ifeq ($(IPV4_INDEX), true)
	IPV4_INDEX = 1
else
	IPV4_INDEX = 0
endif
DOCKER_SUBNET = $(shell docker network inspect -f '{{(index .IPAM.Config $(IPV4_INDEX)).Subnet}}' kind)

install-metrics-server:
	helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
	helm upgrade --install metrics-server metrics-server/metrics-server --namespace kube-system --set args={--kubelet-insecure-tls}
	kubectl rollout -n kube-system status deployment metrics-server

install-datadog-agent:
ifndef DATADOG_API_KEY
	$(error DATADOG_API_KEY is undefined)
else
	helm upgrade --install datadog ./charts/datadog/ --namespace datadog --create-namespace --dependency-update -f ./charts/datadog/values.yaml --set datadog-agent.datadog.apiKey=$(DATADOG_API_KEY) --set datadog-agent.datadog.clusterName=kind-$(CLUSTER_NAME)
endif

install-rabbitmq:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm upgrade --install rabbitmq bitnami/rabbitmq --namespace kube-system -f ./charts/rabbitmq/values.yaml

install-dotnet-app:
	kubectl apply -f ./applications/dotnet/dotnet.yaml

install-java-app:
	kubectl apply -f ./applications/java/java.yaml

install-python-app:
	kubectl apply -f ./applications/python/python.yaml

install-dependencies: install-metrics-server install-datadog-agent install-rabbitmq install-dotnet-app install-java-app install-python-app

.create-cluster:
    # Check if the cluster exists
ifneq ($(CLUSTER_EXISTS), $(CLUSTER_NAME))
    # Ensure the creation of ipv4 network
	docker network inspect kind >/dev/null 2>&1 || docker network create kind
	kind create cluster --name $(CLUSTER_NAME) --config=kind/config.yaml --wait 10s
else
	kubectl cluster-info --context kind-$(CLUSTER_NAME)
endif
	sudo sysctl fs.inotify.max_user_watches=524288
	sudo sysctl fs.inotify.max_user_instances=512

create-cluster: .create-cluster install-dependencies

delete-cluster:
	kind delete clusters $(CLUSTER_NAME)
