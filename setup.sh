#http://bazel.io/blog/2016/01/27/continuous-integration.html

# set up Tensor Flow and SyntaxNet
git clone https://github.com/google/re2.git
cd re2
make
make install

git clone --recursive https://github.com/tensorflow/models.git
cd models/syntaxnet/tensorflow
export PYTHON_BIN_PATH=/usr/bin/python
export TF_NEED_CUDA=0
./configure
cd ..
#bazel test syntaxnet/... util/utf8/... --ignore_unsupported_sandboxing
BAZEL="${BASE}/binary/bazel --bazelrc=${BASE}/bin/bazel.bazelrc --batch"
${BAZEL} test --genrule_strategy=standalone --spawn_strategy=standalone \
    //...
