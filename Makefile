.DEFAULT_GOAL := build

BASEIMAGE=$(shell head -n 1 Dockerfile | cut -f 2 -d " ")
VERSION=$(shell grep "SYNCTHING_VERSION=" Dockerfile | cut -f 2 -d "=")
IMAGE=funkyfuture/rpi-syncthing

.PHONY: build
build: pull-base
	docker build -t $(IMAGE) -t $(IMAGE):$(VERSION) .

.PHONY: pull-base
pull-base:
	docker pull $(BASEIMAGE)
