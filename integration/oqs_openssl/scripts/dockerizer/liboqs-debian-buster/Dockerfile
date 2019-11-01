FROM debian:buster

RUN apt-get update -qq
RUN apt-get upgrade -y

RUN useradd -ms /bin/bash oqssl
 
ADD oqssl /opt/oqssl
RUN echo 'export PATH=/opt/oqssl/bin:$PATH' >> /home/oqssl/.bashrc

# Default command to run
USER oqssl
WORKDIR /home/oqssl
CMD ["/bin/bash"]

