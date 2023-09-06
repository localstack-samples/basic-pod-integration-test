VENV_BIN ?= python3 -m venv
# Default virtual env dir
VENV_DIR ?= .venv
VENV_REQS_FILE ?= ./devops-tooling/requirements.txt

PIP_CMD ?= pip3
ifeq ($(OS), Windows_NT)
	VENV_ACTIVATE = ./$(VENV_DIR)/Scripts/activate
else
	VENV_ACTIVATE = ./$(VENV_DIR)/bin/activate
endif

VENV_RUN = . $(VENV_ACTIVATE)
$(VENV_ACTIVATE):
	test -d $(VENV_DIR) || $(VENV_BIN) $(VENV_DIR)
	$(VENV_RUN); $(PIP_CMD) install --upgrade pip
	$(VENV_RUN); $(PIP_CMD) install $(PIP_OPTS) -r ./devops-tooling/requirements.txt
	touch $(VENV_ACTIVATE)


venv-pulumi-pip-install:
	$(VENV_RUN); $(PIP_CMD) install $(PIP_OPTS) -r ./devops-tooling/requirements-pulumi.txt

venv: $(VENV_ACTIVATE)    ## Create a virtual environment
venv-pulumi: $(VENV_ACTIVATE) venv-pulumi-pip-install  ## Create a virtual environment

freeze:                   ## Run pip freeze -l in the virtual environment
	@$(VENV_RUN); pip freeze -l


# default localhost env vars
export LOCALSTACK_ENDPOINT=http://host.docker.internal:4566
export APP_NAME = lspod
