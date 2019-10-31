FROM centos:7

RUN yum -y update 

RUN useradd -ms /bin/bash oqssl
 
ADD oqssl /opt/oqssl
RUN echo "export PATH=/opt/oqssl/bin:$PATH" >> /home/oqssl/.bashrc

# Default command to run
USER oqssl
WORKDIR /home/oqssl
CMD ["/bin/bash"]

