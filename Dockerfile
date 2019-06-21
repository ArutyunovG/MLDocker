FROM nvidia/cuda:9.0-cudnn7-devel

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN \
apt-get update && \
apt-get install -yq \
    build-essential git cmake \
    python python-pip python-opencv \
    libopencv-dev

RUN python -m pip install pyyaml typing

RUN git clone --recursive https://github.com/ArutyunovG/pytorch
RUN cd pytorch && \
    git checkout ssd_infer && \
    git submodule update --recursive

RUN cd pytorch && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_PREFIX=install && \
    make -j$(nproc) install

RUN python -m pip install protobuf future

RUN cp pytorch/build/install/lib/libtorch.so \
    pytorch/build/install/lib/libc10.so \
    pytorch/build/install/lib/libc10_cuda.so \
    pytorch/build/install/lib/python2.7/dist-packages/caffe2/python/

RUN apt install -yq wget

RUN git clone https://github.com/weiliu89/caffe.git

RUN \
    apt install -yq \
        libprotobuf-dev \
        libleveldb-dev \
        libsnappy-dev \
        libopencv-dev \
        libhdf5-serial-dev \
        protobuf-compiler \
        libboost-all-dev \
        libatlas-base-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        liblmdb-dev

RUN cd caffe && git checkout ssd && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=install \
             -DCUDA_ARCH_NAME="Manual" \
             -DCUDA_ARCH_BIN="61" \
             -DCUDA_ARCH_PTX="61" \
             -DCPU_ONLY=OFF

RUN cd caffe/build && \
    make -j$(nproc) install

RUN python -m pip install 'networkx==2.2' 'matplotlib<3.0' 'scipy==0.17.0' 'scikit-image<0.15'

ENV PYTHONPATH=/pytorch/build/install/lib/python2.7/dist-packages:/caffe/build/install/python

RUN python -m pip install tensorflow-gpu==1.12

