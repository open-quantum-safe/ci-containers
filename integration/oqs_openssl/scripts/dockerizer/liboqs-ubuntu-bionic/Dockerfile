From ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt update -y
RUN apt upgrade -y

RUN useradd -ms /bin/bash oqssl

ADD oqssl /opt/oqssl
RUN echo "export PATH=/opt/oqssl/bin:$PATH" >> /home/oqssl/.bashrc

# Default command to run
USER oqssl
WORKDIR /home/oqssl
CMD ["/bin/bash"]
