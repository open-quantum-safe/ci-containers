FROM centos:7

RUN yum -y update && yum -y install gcc git autoconf automake libtool perl-core zlib-devel make yum-utils wget unzip doxygen graphviz xsltproc python3 python3-pip  && yum check-update

RUN pip3 install -U pytest nose rednose pytest-xdist 

RUN cd /root && curl -fsSL https://get.docker.com/ | sh

# Upgrade to OpenSSL 1.1.1
ADD build-openssl111d.sh /root/build-openssl111d.sh 
RUN /root/build-openssl111d.sh

ADD entrypoint.sh /root/entrypoint.sh

# liboqs requires better gcc than default 4.8:
RUN yum -y remove gcc 
RUN yum -y install centos-release-scl 
RUN yum -y install devtoolset-8-gcc* 
RUN yum -y install libtool
RUN echo "source /opt/rh/devtoolset-8/enable" >> /root/.bashrc


LABEL com.circleci.preserve-entrypoint=true

#ENTRYPOINT /usr/local/ssl/bin/openssl
#ENTRYPOINT bash
ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["bash"]

