From ubuntu:18.04

MAINTAINER MIB (mib@zurich.ibm.com)

ENV DEBIAN_FRONTEND noninteractive

# Keep environment fresh:
RUN apt-get update -y && apt-get upgrade -y

# Add Openssl binaries, libraries and includes:
ADD openssl /usr/local/openssl/bin/openssl
ADD include /usr/local/openssl/include
ADD lib /usr/local/openssl/lib

# Prepare non-root environment:
RUN useradd -ms /bin/bash oqssl
RUN echo "export PATH=/usr/local/openssl/bin:$PATH" >> /home/oqssl/.bashrc

# For K8S operations without root rights:
USER oqssl
WORKDIR /home/oqssl
CMD ["/bin/bash"]
