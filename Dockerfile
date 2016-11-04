
FROM nvidia/cuda:8.0-cudnn5-devel
# FROM nvidia/cuda:8.0-cudnn5-runtime


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



RUN apt-get update && apt-get install -y --no-install-recommends \
        bzip2 \
        unzip \
        xz-utils \
        software-properties-common \
        python-software-properties \
        build-essential \
        curl \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python \
        python-dev \
        rsync \
        unzip \
        libcurl3-dev \
        git \
        vim \
        swig \
    && rm -rf /var/lib/apt/lists/*

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8


# INSTALL JAVA
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN sudo add-apt-repository ppa:webupd8team/java && \
    sudo apt-get update && \
    sudo apt-get install -y oracle-java8-installer


# INSTALL BAZEL
RUN echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
RUN curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
RUN sudo apt-get update && sudo apt-get install -y bazel


# INSTALL PIP
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py


# INSTALL PYTHON TOOLS
RUN pip --no-cache-dir install \
        ipykernel \
        jupyter \
        matplotlib \
        numpy \
        scipy \
        && \
    python -m ipykernel.kernelspec

ENV TENSORFLOW_VERSION 0.10.0rc0



ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH


# set up Tensor Flow and SyntaxNet
RUN git clone https://github.com/google/re2.git && \
    cd re2 && \
    make && \
    make install

RUN git clone --recursive https://github.com/tensorflow/models.git && \
    cd models/syntaxnet/tensorflow && \
    export PYTHON_BIN_PATH=/usr/bin/python && \
    export TF_NEED_CUDA=1 && \
    ./configure && \
    cd ..

#bazel test syntaxnet/... util/utf8/... --ignore_unsupported_sandboxing
ENV BAZEL="${BASE}/binary/bazel --bazelrc=${BASE}/bin/bazel.bazelrc --batch"
RUN ${BAZEL} test --genrule_strategy=standalone --spawn_strategy=standalone //...


# Set up our notebook config.
COPY jupyter_notebook_config.py /root/.jupyter/

# Copy sample notebooks.
COPY notebooks /notebooks


# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

COPY run_jupyter.sh /

WORKDIR "/notebooks"
CMD ["/run_jupyter.sh"]

# I tensorflow/stream_executor/dso_loader.cc:108] successfully opened CUDA library libcublas.so locally
# I tensorflow/stream_executor/dso_loader.cc:102] Couldn't open CUDA library libcudnn.so. LD_LIBRARY_PATH: /usr/local/cuda/lib64:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:
# I tensorflow/stream_executor/cuda/cuda_dnn.cc:2259] Unable to load cuDNN DSO


