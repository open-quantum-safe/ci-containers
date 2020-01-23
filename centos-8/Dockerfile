FROM centos:8

RUN yum -y update && yum -y install gcc git cmake ninja autoconf automake libtool perl-core zlib-devel make yum-utils wget unzip graphviz libxslt python3 python3-pip && yum check-update && yum -y install yum-utils openssl-devel

RUN dnf config-manager --set-enabled PowerTools && dnf -y install doxygen doxygen-latex doxygen-doxywizard

# Install Pytest for unit testing
RUN pip3 install -U pytest nose rednose pytest-xdist

# Install Docker for integrated docker-image generation
RUN dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo && dnf install docker-ce --nobest -y

LABEL com.circleci.preserve-entrypoint=true

# Ensure PATH is set correctly
ADD entrypoint.sh /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["/bin/bash"]
