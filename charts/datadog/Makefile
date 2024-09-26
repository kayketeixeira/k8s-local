CLUSTER_NAME = $(shell echo local | tr '[:upper:]' '[:lower:]')

help: ## Print help for each target
	$(info =============================)
	$(info Available commands:)
	@grep '^[[:alnum:]_-]*:.* ##' $(MAKEFILE_LIST) \
		| sort | awk 'BEGIN {FS=":.* ## "}; {printf "%-25s %s\n", $$1, $$2};'
	$(info =============================)

template: ## Template
	helm dependency update . && helm template . -f values.yaml --debug

install: ## Install
    ifndef DATADOG_API_KEY
		$(error DATADOG_API_KEY is undefined)
    else
		helm install datadog ./charts/datadog/ --namespace datadog --create-namespace --dependency-update -f ./charts/datadog/values.yaml --set datadog-agent.datadog.apiKey=$DATADOG_API_KEY --set datadog-agent.datadog.clusterName=kind-$(CLUSTER_NAME)
	endif

uninstall: ## Uninstall
	helm uninstall datadog --namespace datadog

