SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

help:
	@printf "Usage: make [target] [VARIABLE=value]\nTargets:\n"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

hooks: ## Setup pre commit.
	@pre-commit install
	@pre-commit gc

validate: ## Validate files with pre-commit hooks
	@pre-commit run --all-files

boxes: ## Vagrant boxes
	@vagrant box list

packer-init: ## Packer init
	@packer init -upgrade vagrant.pkr.hcl
	@packer init -upgrade docker.pkr.hcl

packer-vgr: ## Packer build vm with vagrant
	@packer build vagrant.pkr.hcl

packer-docker: ## Packer build vm with docker
	@packer build docker.pkr.hcl
