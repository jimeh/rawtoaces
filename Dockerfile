FROM ubuntu:20.04 as builder

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install --no-install-recommends \
    ca-certificates \
    curl \
    libatlas-base-dev \
    libboost-all-dev \
    libeigen3-dev \
    libgflags-dev \
    libgoogle-glog-dev \
    libilmbase-dev \
    libraw-dev \
    libsuitesparse-dev \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get -y install --no-install-recommends \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

ARG ACES_CONTAINER_GIT_REF=feature/windowsBuildSupport
RUN mkdir -p /opt/src/aces_container && cd /opt/src/aces_container \
    && curl -L -o aces_container.tar.gz \
    "https://github.com/miaoqi/aces_container/tarball/${ACES_CONTAINER_GIT_REF}" \
    && tar -xzvf aces_container.tar.gz --strip-components=1 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make -j 4 \
    && make install

ARG CERES_SOLVER_GIT_REF=1.14.0
RUN mkdir -p /opt/src/ceres-solver && cd /opt/src/ceres-solver \
    && curl -L -o ceres-solver.tar.gz \
    "https://github.com/ceres-solver/ceres-solver/tarball/${CERES_SOLVER_GIT_REF}" \
    && tar -xzvf ceres-solver.tar.gz --strip-components=1 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make -j 4 \
    && make install

RUN mkdir -p /opt/rawtoaces
WORKDIR /opt/rawtoaces

COPY . .

RUN mkdir build && cd build \
    && cmake .. \
    && make \
    && make install

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install --no-install-recommends \
    ca-certificates \
    curl \
    libatlas-base-dev \
    libboost-all-dev \
    libeigen3-dev \
    libgflags-dev \
    libgoogle-glog-dev \
    libilmbase-dev \
    libraw-dev \
    libsuitesparse-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local /usr/local
COPY ./docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
