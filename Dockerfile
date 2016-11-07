
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/docker/Dockerfile.gpu

# http://layer0.authentise.com/docker-4-useful-tips-you-may-not-know-about.html
# pick a mirror for apt-get
# RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse" > /etc/apt/sources.list && \
#     echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
#     echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse" >> /etc/apt/sources.list && \
#     DEBIAN_FRONTEND=noninteractive apt-get update

# cache apt-get requests locally. 
# Requires: docker run -d -p 3142:3142 --name apt_cacher_run apt_cacher
# https://docs.docker.com/engine/examples/apt-cacher-ng/
# RUN  echo 'Acquire::http { Proxy "http://192.168.150.50:3142"; };' >> /etc/apt/apt.conf.d/01proxy


FROM nvidia/cuda:8.0-cudnn5-devel

MAINTAINER Craig Citro <craigcitro@google.com>

# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python \
        python-dev \
        rsync \
        software-properties-common \
        unzip \
        libjpeg-dev \
        libpng12-dev \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

RUN pip --no-cache-dir install \
        --upgrade pip \
        ipykernel \
        jupyter \
        matplotlib \
        numpy \
        scipy \
        sklearn \
        && \
    python -m ipykernel.kernelspec

ENV TENSORFLOW_VERSION 0.11.0rc2

# --- DO NOT EDIT OR DELETE BETWEEN THE LINES --- #
# These lines will be edited automatically by parameterized_docker_build.sh. #
# COPY _PIP_FILE_ /
# RUN pip --no-cache-dir install /_PIP_FILE_
# RUN rm -f /_PIP_FILE_

# Install TensorFlow GPU version.
RUN pip --no-cache-dir install \
    http://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-${TENSORFLOW_VERSION}-cp27-none-linux_x86_64.whl
# --- ~ DO NOT EDIT OR DELETE BETWEEN THE LINES --- #



# Set up our notebook config.
COPY jupyter_notebook_config.py /root/.jupyter/

# Copy sample notebooks.
COPY notebooks /notebooks

# Jupyter has issues with being run directly:
#   https://github.com/ipython/ipython/issues/7062
# We just add a little wrapper script.
COPY run_jupyter.sh /

# add google cloud tools and samples
# https://cloud.google.com/ml/docs/how-tos/getting-set-up
WORKDIR /notebooks
RUN curl https://storage.googleapis.com/cloud-ml/scripts/setup_docker.sh | bash

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

WORKDIR "/notebooks"

CMD ["/run_jupyter.sh"]