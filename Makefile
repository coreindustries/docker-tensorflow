
# ENV =
ENV = -e PASSWORD=pass
NS = tensorflow
#VERSION ?= latest
VERSION ?= latest-gpu
REPO = tensorflow
NAME = tensorflow
INSTANCE = default
PORTS = -p 8888:8888/tcp
VOLUMES = -v ~/projects:/projects -v `pwd`/notebooks:/notebooks

# FOR GPU RUNS:
# nvidia-docker

.PHONY: build push shell run start stop rm release

build:
	# PULL FROM GITHUB
	# docker build -t quantopian/zipline git@github.com:quantopian/zipline.git

push:
	docker push $(NS)/$(REPO):$(VERSION)

shell:
	-make stop
	-make rm
	nvidia-docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION) /bin/bash

run:
	-make stop
	-make rm
	# docker run -it --name $(NAME) --network host $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)
	nvidia-docker run -it --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

# run as a deamon
start:
	nvidia-docker run -d --restart always --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

stop:
	nvidia-docker stop $(NAME)

rm:
	nvidia-docker rm $(NAME)

debug:
	make build
	make run

attach:
	nvidia-docker exec -it $(NAME) /bin/bash

logs:
	nvidia-docker logs $(NAME)

release: build
	make push -e VERSION=$(VERSION)

test:
	make build;make run

default: build

default: build

