SHELL := /bin/bash

-include .env-gdc-local
-include ./devops-tooling/envs.makefile

PKG_SUB_DIRS := $(dir $(shell find . -type d -name node_modules -prune -o -type d -name "venv*" -prune -o -type f -name package.json -print))


update-deps: $(PKG_SUB_DIRS)
	for i in $(PKG_SUB_DIRS); do \
        pushd $$i && ncu -u && npm install && popd; \
    done

start-localstack:
	cd devops-tooling && docker compose -p $(APP_NAME) up

stop-localstack:
	cd devops-tooling && docker compose down


test-setup:
	aws s3 mb s3://testpod --profile localstack;
	echo "hello world" > ./hello-world.txt;
	aws s3 cp ./hello-world.txt s3://testpod/hello-world.txt --profile localstack;
	$(VENV_RUN) && localstack pod save file://$(PWD)/s3pod;
	rm -f ./hello-world.txt;

test-cleanup:
	aws s3 rm s3://testpod --recursive --profile localstack
	aws s3 rb s3://testpod --profile localstack

# Run the tests
test-python:
	$(VENV_RUN) && cd auto_tests/python && AWS_PROFILE=localstack pytest $(ARGS);

load-pod:
	$(VENV_RUN) && localstack pod load file://$(PWD)/s3pod;

test: load-pod test-python test-cleanup

pod-cleanup:
	rm -f ./s3pod
