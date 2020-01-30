FROM centos:8

RUN yum -y update && \
    yum -y install
        gcc \
        cmake ninja-build \
        autoconf automake git libssl-dev libtool make \
        doxygen xsltproc \
        python3 python3-nose python3-rednose python3-pytest \
        python3-pip && \
    yum check-update && \
    pip3 install pytest-xdist

RUN dnf config-manager --set-enabled PowerTools && \
    dnf -y \
        install \
        doxygen \
        doxygen-latex \
        doxygen-doxywizard

# Install Docker for integrated docker-image generation
RUN dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo && dnf install docker-ce --nobest -y

LABEL com.circleci.preserve-entrypoint=true

# Ensure PATH is set correctly
ADD entrypoint.sh /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["/bin/bash"]
