ENVS := dev prod beta qa
env :=  dev
PREFIX := $(shell echo $(env) |shasum -a 256|cut -c 1-12)
KEY := $(shell pwd | xargs basename)
ROLE := $(shell cat .env.role_$(env))
FIRST := $(shell echo $(env) | head -c 1)
TF_ENV_VARS :=
AWS_ENV :=
S3_PATH :=

.PHONY: help
help:
        @echo "make (plan|apply|tf-init) [env=]"
        @echo "         e.g. make plan ENV=(`echo $(ENVS) | tr ' ' \|`) [default: $(env)]"
        @echo " "
        @fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'


tf_init:
ifeq ($(filter $(env),$(ENVS)),)
        $(error $(env) is not supported)
else
        $(if $(findstring deploy,$(KEY)), $(eval KEY := services/$(shell cd .. && pwd | xargs basename)))
        $(eval AWS_ENV = $(env))
        $(eval S3_PATH = $(KEY))
endif
        @echo "# PREFIX: $(PREFIX)"
        @echo "# AWS_ENV: $(AWS_ENV)"
        @if [ -e .terraform/terraform.tfstate ]; then rm .terraform/terraform.tfstate; fi;
        $(eval TF_ENV_VARS := $(TF_ENV_VARS) AWS_PROFILE=$(AWS_ENV) )
        @echo "# TF_ENV_VARS: $(TF_ENV_VARS)"
        $(TF_ENV_VARS) terraform init -backend-config="bucket=test-$(FIRST)-bucket-name"  -backend-config="key=shankar/$(S3_PATH)/terraform.tfstate" $(ROLE) -var  this_env=$(AWS_ENV) -var-file="var-file.$(AWS_ENV)"

tf_vars:
        $(eval TF_OPTIONS :=  $(TF_OPTIONS) -var aws-account=$(AWS_ENV))
        $(eval TF_OPTIONS :=  $(TF_OPTIONS) -var tf-statefile-prefix=$(PREFIX))
        $(if $(wildcard .env.$(env)), $(eval TF_OPTIONS :=  $(TF_OPTIONS) -var-file ".env.$(env)"))
        $(if $(wildcard .env), $(eval TF_OPTIONS :=  $(TF_OPTIONS) -var-file ".env"))
        @echo "# TF_OPTIONS= "$(TF_OPTIONS)

.PHONY: plan
plan: tf_init tf_vars
        $(TF_ENV_VARS) terraform plan $(TF_OPTIONS) -var-file="var-file.$(AWS_ENV)"

.PHONY: apply
apply: tf_init tf_vars
        $(TF_ENV_VARS) terraform apply $(TF_OPTIONS) -var-file="var-file.$(AWS_ENV)"


.PHONY: destroy
destroy: tf_init tf_vars
        $(TF_ENV_VARS) terraform destroy $(TF_OPTIONS)
        
.PHONY: autoapply
autoapply: tf_init tf_vars
        $(TF_ENV_VARS) terraform apply -auto-approve $(TF_OPTIONS) -var-file="var-file.$(AWS_ENV)"
