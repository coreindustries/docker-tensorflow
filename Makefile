
# ENV = -S us2.ethpool.org:3333 -O 0x81cF9c570739B7473013Fc19b11c0577Fb78caB9.DEEPLEARNING
ENV =
NS = coreindustries
VERSION ?= latest
REPO = docker-tensorflow
NAME = tensorflow
INSTANCE = default
PORTS = p 8888:8888 -p 6006:6006 
VOLUMES = /mnt/raid/projects:/projects

.PHONY: build push shell run start stop rm release

build:
	docker build -t $(NS)/$(REPO):$(VERSION) .

push:
	docker push $(NS)/$(REPO):$(VERSION)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION) /bin/bash

run:
	-make stop
	-make rm
	nvidia-docker run -it --name $(NAME) --network host $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

# run as a deamon
start:
	docker run -d --restart always --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

stop:
	docker stop $(NAME)

rm:
	docker rm $(NAME)

debug:
	make build
	make run

attach:
	docker exec -it $(NAME) /bin/bash

logs:
	docker logs $(NAME)

release: build
	make push -e VERSION=$(VERSION)

test:
	make build;make run

default: build

default: build

