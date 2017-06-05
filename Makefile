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


IMAGE_NAME = coreemu_vnc

help:	## Imprime ayuda
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)


build:
	docker build -t $(IMAGE_NAME) .

run_local: build
	docker run \
		-P \
		--cap-add SYS_ADMIN \
		--cap-add NET_ADMIN \
		$(IMAGE_NAME)

shell:
	@docker-compose exec vnc bash

stop:
	@docker stop $(IMAGE_NAME)
	@docker rm $(IMAGE_NAME)

kill:
	@-docker kill $(IMAGE_NAME)
	@docker rm $(IMAGE_NAME)
