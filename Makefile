JUMPHOST="" # Host where keys should be placed while being distributed
# Allow additional options to be passed to Ansible

help:
	@echo 'usage: make [target] [options]'
	@echo 'options:'
	@echo '  IDENTIFIER=meaningful-name'
	@echo '  VAULT_HOST=hostname'
	@echo 'IT IS IMPORTANT TO READ THE README to fully understand what this is doing.'
	@echo 'targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

check-host:
ifndef VAULT_HOST
	$(error VAULT_HOST is undefined)
endif

check-dc:
ifeq (,$(subst "",,$(IDENTIFIER)))
	$(error IDENTIFIER is undefined)
endif

store-key: check-dc ## Pull a key from jumphost and store it in local mac keychain
	ansible-playbook $(ANSIBLE_OPTIONS) -i ${JUMPHOST}, -e identifier=$(IDENTIFIER) store.yaml

unseal: check-host  ## Send your unseal key to the Vault API to unseal a host
	ansible-playbook $(ANSIBLE_OPTIONS) -e vault_host=$(VAULT_HOST) -e identifier=$(IDENTIFIER) unseal.yaml

distribute: check-dc  ## Send keys to each home directory of keyholders on jumphost
	ansible-playbook $(ANSIBLE_OPTIONS) -i ${JUMPHOST}, -e identifier=$(IDENTIFIER) distribute.yaml

distribute-clean: ## Remove your local copy of keyfile after distribution
	rm -rf ./keyfile

.DEFAULT_GOAL := help
.PHONY: help
