FROM centos:8

RUN yum -y update && yum -y install gcc git autoconf automake libtool perl-core zlib-devel make yum-utils wget unzip graphviz libxslt python3 python3-pip && yum check-update && yum -y install yum-utils openssl-devel
# xsltprox not found, trying libxslt
# centos-release-scl-rh not needed (?)

RUN dnf config-manager --set-enabled PowerTools && dnf -y install doxygen doxygen-latex doxygen-doxywizard


# Install Pytest for unit testing
RUN pip3 install -U pytest nose rednose pytest-xdist 

# Install Docker for integrated docker-image generation
#RUN cd /root && curl -fsSL https://get.docker.com/ | sh
RUN dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo && dnf install docker-ce --nobest -y

# Upgrade to OpenSSL 1.1.1
#ADD build-openssl111d.sh /root/build-openssl111d.sh 
#RUN /root/build-openssl111d.sh

# Install more current gcc for OQS building
#RUN yum -y install centos-release-scl devtoolset-8-gcc* libtool && echo "source /opt/rh/devtoolset-8/enable" >> /root/.bashrc

LABEL com.circleci.preserve-entrypoint=true

# Ensure PATH is set correctly
ADD entrypoint.sh /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["/bin/bash"]

