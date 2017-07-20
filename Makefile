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

define PORT_INFO
form subprocess import check_output

output = check_output('')

endef
export PORT_INFO

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT


IMAGE_NAME = coreemu_vnc

help:	## Imprime ayuda
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)


build:  ## Build image
	@docker ps --format '{{.Image}}' | grep $(IMAGE_NAME) && \
		docker kill /$(IMAGE_NAME) && docker rm -f $(IMAGE_NAME) || true
	docker build -t $(IMAGE_NAME) .

run_local: run_dev ## Runs locally

run_dev:
	docker ps --format '{{.Image}}' | grep $(IMAGE_NAME) && \
		echo "Ya en funcioanmiento!" || \
	docker run \
		--cap-add SYS_ADMIN \
		--cap-add NET_ADMIN \
		--name $(IMAGE_NAME) \
		-d \
		-p 8080:8080 -p 6080:6080 -p 2121:2121 -p 2222:2222 -p 80:80 -p 9091:9091\
		-v $$(pwd)/extra:/extra \
		-v $$(pwd)/var/www/html:/var/www/html \
		$(IMAGE_NAME)
	@$(MAKE) logs

logs:
	docker logs -f $(IMAGE_NAME)

vnclogs:
	@-docker exec -ti $(IMAGE_NAME) cat /root/.vnc/*.log
shell:   ## Lauches a shell inside the container
	@-docker exec -ti $(IMAGE_NAME) bash

supervisorctl:   ## Lauches a shell inside the container
	@docker exec -ti $(IMAGE_NAME) supervisorctl

stop:
	@echo "Detener la máquina virtual puede tomar hasta 10s"
	@-docker stop $(IMAGE_NAME) && docker rm $(IMAGE_NAME)

status:		## Muestra el estado de los servicios
	@-docker ps --format '{{.Image}}' 2>/dev/null --filter name=$(IMAGE_NAME) \
		2>/dev/null 1>/dev/null || exit 1
	@docker exec -ti $(IMAGE_NAME) supervisorctl status

kill:  ## Kills container
	@docker ps --format '{{.Image}}' | grep $(IMAGE_NAME) && \
		docker kill /$(IMAGE_NAME) || \
		echo "No en ejecucion"

# rm: kill
# 	@-docker rm /$(IMAGE_NAME) 2>/dev/null || echo "No existe"

ps:		## Muestra contenedores en ejecucion
	docker ps

re: stop build run_local

killre: kill build run_local

ports:
	@docker ps --filter name=$(IMAGE_NAME) --format '{{.Ports}}'

nginxlogs:
	@docker exec -ti $(IMAGE_NAME) bash -c "tail -fn0 /var/log/nginx/*.log"