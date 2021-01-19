SHELL=/bin/bash
.EXPORT_ALL_VARIABLES:
.ONESHELL:
.SHELLFLAGS = -uec
.PHONY: deploy_infrastructure deploy_function test

default:
	echo "No make target"

deploy_infrastructure:
	make -C infrastructure deploy

plan_infrastructure:
	make -C infrastructure plan

login-ecr:
	aws ecr get-login-password --region us-east-1 \
   | docker login --username AWS --password-stdin \
   ${AWS_ACCOUNT}.dkr.ecr.us-east-1.amazonaws.com

push-image:
	pushd ./app
	docker build -t qldb-demo .
	docker tag qldb-demo ${AWS_ACCOUNT}.dkr.ecr.us-east-1.amazonaws.com/lambda-container-demo-repo:qldb-latest
	docker push ${AWS_ACCOUNT}.dkr.ecr.us-east-1.amazonaws.com/lambda-container-demo-repo:qldb-latest
	popd