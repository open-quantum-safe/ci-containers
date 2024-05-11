FROM ubuntu:latest
LABEL version="1"
ARG ARCH

RUN DEBIAN_FRONTEND=noninteractive TZ=Europe/Zurich && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get update -qq && \
    apt-get dist-upgrade -y && \
    apt-get install -y cmake \
                       gcc \
                       git \
                       golang-go \
                       libunwind-dev \
                       ninja-build \
                       pkg-config \
                       python3 \
                       python3-psutil
