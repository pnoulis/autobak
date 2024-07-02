#!/bin/make

SHELL := /bin/bash
.DEFAULT_GOAL := run
.DELETE_ON_ERROR:
.ONESHELL:

REMOTE_SERVER_IP=159.89.21.248
REMOTE_SERVER_HOSTNAME=localhost
REMOTE_SERVER_LOGIN=$(USER)
ifeq ($(REMOTE_SERVER_HOSTNAME), "")
REMOTE_SERVER_HOST=$(REMOTE_SERVER_IP)
else
REMOTE_SERVER_HOST=$(REMOTE_SERVER_HOSTNAME)
endif
REMOTE_SERVER_URI=${REMOTE_SERVER_LOGIN}@${REMOTE_SERVER_HOST}
REMOTE_SERVER_URI=$(REMOTE_SERVER_HOSTNAME)
AS_USER=root
AS_GROUP=root

build: puship pullip

install: build
	install -t ~/bin ./puship ./pullip

setup_remote:
	echo $(USER)
	id
	ssh -o "PasswordAuthentication no" $(REMOTE_SERVER_HOST) "id; if grep --quiet $(REMOTE_SERVER_LOGIN) /etc/passwd; then \
	echo $(REMOTE_SERVER_LOGIN) exists; \
	else \
	echo $(REMOTE_SERVER_LOGIN) does not exist; \
	fi
	"

uninstall:
	rm -f ~/bin/puship
	rm -f ~/bin/pullip

puship: puship.sh
	cat $< > $@
	chmod +x $@

pullip: pullip.sh
	cat $< > $@
	chmod +x $@
