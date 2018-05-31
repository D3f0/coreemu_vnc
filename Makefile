.PHONY = run build help
.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys
if not sys.argv[1].startswith('http'):
	try:
		from urllib import pathname2url
	except:
		from urllib.request import pathname2url
	path = "file://" + pathname2url(os.path.abspath(sys.argv[1]))
else:
	path = sys.argv[1]

webbrowser.open(path)
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

# By default tag is the current branch
TAG = $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "latest")

ORG = d3f0
IMAGE_NAME = $(ORG)/coreemu_vnc
JUPYTER_PORT ?= 9999
NOVNC_PORT ?= 8080
VNC_PORT ?= 5901
HOSTNAME ?= coreemu_vnc
CONTAINER ?= $(HOSTNAME)

OPEN 				:=
ifeq ($(OS),Windows_NT)
	$(error "Windows not supported")
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		OPEN := "xdg-open"
	endif
	ifeq ($(UNAME_S),Darwin)
		OPEN := "open"
	endif
endif

help:	## Imprime ayuda
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

build:
	docker build -t $(IMAGE_NAME):$(TAG) .
	docker tag $(IMAGE_NAME):$(TAG) $(ORG)/$(IMAGE_NAME)

build_run: build rm run

run: ## Starts the container
	docker run \
		--publish $(JUPYTER_PORT):9999 \
		--publish $(NOVNC_PORT):8080 \
		--publish $(VNC_PORT):5900 \
		--cap-add SYS_ADMIN \
		--cap-add NET_ADMIN \
		--hostname=$(HOSTNAME) \
		--name=$(CONTAINER) \
		--volume $(shell pwd)/shared:/root/shared/ \
		--detach \
		$(IMAGE_NAME):$(TAG)

logs:   ## Show container log
	@echo "Control-C to stop showing logs"
	-docker logs -f $(CONTAINER)

start:
	docker start $(CONTAINER)
	
stop:
	docker stop $(CONTAINER)

shell:   ## Creates a shell inside container
	@docker-compose exec -ti $(CONTAINER) $(SHELL)

rm:
	-docker stop $(CONTAINER)
	-docker rm $(CONTAINER)

rebuild_relaunch: build restart ## Rebuilds and restarts containero

ps:
	docker ps -f=name=$(CONTAINER) $(ARGS)

running:
	docker ps -f=name=$(CONTAINER) | grep coreemu_vnc || $(MAKE) run

open_jupyterlab: running ## Opens system browser in jupyter 
	$(OPEN) http://localhost:$(JUPYTER_PORT)/lab

open_jupyter_notebook: running ## Opens system browser in jupyter 
	$(OPEN) http://localhost:$(JUPYTER_PORT)/tree

open_core_novnc: running  ## Opens system browser in noVNC
	$(OPEN) http://localhost:$(NOVNC_PORT)

open_core_vnc: running  ## Opens system VNC client (needs external program)
	$(OPEN) vnc://localhost:$(VNC_PORT)
	
