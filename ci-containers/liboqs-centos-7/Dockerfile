FROM centos:7

RUN yum -y update && yum -y install gcc git autoconf automake libtool perl-core zlib-devel make yum-utils wget unzip doxygen graphviz xsltproc python3 python3-pip  && yum check-update

RUN pip3 install -U pytest nose rednose pytest-xdist 

RUN cd /root && curl -fsSL https://get.docker.com/ | sh

ADD build-openssl111d.sh /root/build-openssl111d.sh 
RUN /root/build-openssl111d.sh

LABEL com.circleci.preserve-entrypoint=true

ENTRYPOINT /usr/local/ssl/bin/openssl
