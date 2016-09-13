# https://github.com/tensorflow/tensorflow/tree/master/tensorflow/tools/docker

# FROM ubuntu:wily
FROM nvidia/cuda:8.0-cudnn5-runtime

# http://layer0.authentise.com/docker-4-useful-tips-you-may-not-know-about.html
# pick a mirror for apt-get
RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    DEBIAN_FRONTEND=noninteractive apt-get update

# cache apt-get requests locally. 
# Requires: docker run -d -p 3142:3142 --name apt_cacher_run apt_cacher
# https://docs.docker.com/engine/examples/apt-cacher-ng/
# docker build --build-arg APT_PROXY=http://$(ipconfig getifaddr en0):3142 . -t coreindustries/digits-tensorflow .
RUN  echo 'Acquire::http { Proxy "http://192.168.150.50:3142"; };' >> /etc/apt/apt.conf.d/01proxy
# RUN  echo 'Acquire::http { Proxy "'+HTTP_PROXY+'"; };' >> /etc/apt/apt.conf.d/01proxy

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
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

RUN pip --no-cache-dir install \
        ipykernel \
        jupyter \
        matplotlib \
        numpy \
        scipy \
        && \
    python -m ipykernel.kernelspec

ENV TENSORFLOW_VERSION 0.10.0rc0
RUN pip install --upgrade pip
RUN pip install -U protobuf==3.0.0b2 asciitree numpy

ENV PYTHON_BIN_PATH /usr/bin/python

# install bazel
# http://bazel.io/docs/install.html
# RUN wget https://github.com/bazelbuild/bazel/releases/download/0.2.2/bazel-0.2.2-installer-linux-x86_64.sh
RUN wget https://github.com/bazelbuild/bazel/releases/download/0.3.0/bazel-0.3.0-installer-linux-x86_64.sh
RUN chmod +x bazel-0.3.0-installer-linux-x86_64.sh
RUN ./bazel-0.3.0-installer-linux-x86_64.sh --user

ENV TENSORFLOW_VERSION 0.10.0rc0

# --- DO NOT EDIT OR DELETE BETWEEN THE LINES --- #
# These lines will be edited automatically by parameterized_docker_build.sh. #
# COPY _PIP_FILE_ /
# RUN pip --no-cache-dir install /_PIP_FILE_
# RUN rm -f /_PIP_FILE_

# Install TensorFlow GPU version.
RUN pip --no-cache-dir install \
    http://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-${TENSORFLOW_VERSION}-cp27-none-linux_x86_64.whl
# --- ~ DO NOT EDIT OR DELETE BETWEEN THE LINES --- #

# SET UP OUR ENTRY POINT
# ADD setup.sh /setup.sh
# RUN chmod +x /setup.sh
# CMD /setup.sh

# Set up our notebook config.
COPY jupyter_notebook_config.py /root/.jupyter/

# Copy sample notebooks.
COPY notebooks /notebooks

# Jupyter has issues with being run directly:
#   https://github.com/ipython/ipython/issues/7062
# We just add a little wrapper script.
COPY run_jupyter.sh /

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

WORKDIR "/notebooks"

CMD ["/run_jupyter.sh"]
