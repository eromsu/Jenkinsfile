############################################################
# Dockerfile to build ATAG/DAFE Container
############################################################

# Base image
FROM centos

# Give root user a password
RUN echo "root:cisco" | chpasswd

# yum init
RUN yum --enablerepo=extras install -y epel-release
RUN yum -y update

# Install Packages
RUN yum install -y python2
RUN yum install -y python2-pip && yum clean all
RUN yum install -y curl
 

# Copy scripts
RUN mkdir /ATAG
RUN mkdir /DAFE
COPY atag/ /ATAG/
COPY dafe/ /DAFE/

# Install Python modules
RUN pip2 install -r /ATAG/atag/requirements.txt
