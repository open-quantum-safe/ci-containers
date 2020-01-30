FROM centos:7

RUN yum -y update && \
    yum -y install \
        gcc \
        git \
        autoconf \
        automake \
        libtool \
        perl-core \
        make \
        yum-utils \
        wget \
        doxygen \
        xsltproc \
        python3 \
        python3-pip && \
    yum check-update && \
    yum -y install centos-release-scl-rh yum-utils

RUN pip3 install -U pytest nose rednose pytest-xdist

# pip3 has more recent versions of cmake and ninja
RUN pip3 install cmake ninja

# Install Docker for integrated docker-image generation
RUN cd /root && curl -fsSL https://get.docker.com/ | sh

# Upgrade to OpenSSL 1.1.1
ADD build-openssl111d.sh /root/build-openssl111d.sh
RUN /root/build-openssl111d.sh

# Install more current gcc for OQS building
RUN yum -y install centos-release-scl devtoolset-8-gcc* libtool && echo "source /opt/rh/devtoolset-8/enable" >> /root/.bashrc

LABEL com.circleci.preserve-entrypoint=true

# Ensure PATH is set correctly
ADD entrypoint.sh /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["/bin/bash"]
