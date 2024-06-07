# ABSTRACT: Tasks do NX
#
# make help
#

.PHONY: all run_pd run_dev run_test post_install push_image push deploy deploy_test commit help

CONTAINER ?= nx

APP_ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# target: all - Executa o container de producao
all: run_dev


# target: run_pd - Executa o container, type=pd, image=nx:latest, mem=20, name=nx
run_pd:
	exec $(APP_ROOT_DIR)/scripts/host/run_container.sh -t pd -m 20 -i nx:latest -n nx


# target: run_dev - Executa o container, type=dev, image=nx:latest, mem=20, name=nx
run_dev:
	exec $(APP_ROOT_DIR)/scripts/host/run_container.sh -t dev -m 20 -i nx:latest -n nx


# target: run_test - Executa o container, type=test, image=nx:latest, mem=20, name=nx
run_test:
	exec $(APP_ROOT_DIR)/scripts/host/run_container.sh -t test -m 20 -i nx:latest -n nx


# target: post_install - Executa os scripts pos criacao da imagem
post_install:
	docker exec $(CONTAINER) $(APP_ROOT_DIR)/scripts/container/set_timezone.sh


# target: push_image - Copia a imagem para um host remoto
push_image: guard-user guard-host
	rsync -v /home/circuibras/images/nx.tar.gz $(user)@$(host):/home/circuibras/images/


# target: deploy - Copia o conteudo relevante do diretorio APP_ROOT_DIR para um host remoto
deploy: guard-user guard-host
	$(APP_ROOT_DIR)/scripts/host/deploy_app.sh -u $(user) -h $(host)


# target: push - Push para os repositorios remotos do Git
push:
	git push local $(branch)
	git push github $(branch)

# target: commit - Executa 'git add .', 'git commit -a', 'make push'
commit:
	git add .
	git commit -a
	git push local $(branch)
	git push github $(branch)
	git status

# Aborta se a variavel especificada nao estiver definida
guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Variavel $* indefinida"; \
		exit 1; \
	fi


# target: help - Mostra os targets que sao executaveis
help:
	@egrep "^# target:" [Mm]akefile

# EOF

