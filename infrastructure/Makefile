SHELL=/bin/bash
.EXPORT_ALL_VARIABLES:
.ONESHELL:
.SHELLFLAGS = -uec
.PHONY: deploy

default:
	echo "No make target"

plan:
	terraform plan

deploy:
	terraform apply -auto-approve