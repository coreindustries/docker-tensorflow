# FROM ubuntu:wily
FROM nvidia/cuda:8.0-cudnn5-runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential \
	g++ \
	git \
	libssl-dev \
	zlib1g-dev \
	default-jre \
	default-jdk \
	pkg-config \
	python-pip \
	python-dev \
	python-numpy \
	wget \
	swig \
	unzip \
	zip \
	zlib1g-dev \
	&& rm -rf /var/lib/apt/lists/*

# PIP
RUN pip install --upgrade pip
RUN pip install -U protobuf==3.0.0b2 asciitree numpy

ENV PYTHON_BIN_PATH /usr/bin/python

# install bazel
# http://bazel.io/docs/install.html
# RUN wget https://github.com/bazelbuild/bazel/releases/download/0.2.2/bazel-0.2.2-installer-linux-x86_64.sh
RUN wget https://github.com/bazelbuild/bazel/releases/download/0.3.0/bazel-0.3.0-installer-linux-x86_64.sh
RUN chmod +x bazel-0.3.0-installer-linux-x86_64.sh && ./bazel-0.3.0-installer-linux-x86_64.sh --user


# SET UP OUR ENTRY POINT
ADD setup.sh /setup.sh
RUN chmod +x /setup.sh
CMD /setup.sh
