FROM centos:7

RUN yum -y update 

RUN useradd -ms /bin/bash oqssl
 
ADD oqssl /opt/oqssl

# Default command to run
USER oqssl
WORKDIR /home/oqssl
CMD ["/bin/bash"]

