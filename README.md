OQS Integration Testing
===============================

liboqs integration with OpenSSH and OpenSSL can be tested through the scripts provided under the integration directory.
Please follow the README for details, under the respective directories, on how to run the tests.

Dependencies
------------

### APT (UBUNTU):
  Please install following packages before proceeding with running any tests.
  - sudo apt update
  - sudo apt install build-essential
  - sudo apt install autotools-dev
  - sudo apt install autoconf
  - sudo apt install libtool
  - sudo apt install zlib1g-dev
  - sudo apt install zip
  - sudo apt install xsltproc


### YUM (CENTOS):
  Please install following packages before proceeding with running any tests.

  - sudo yum groupinstall 'Development Tools'
  - sudo yum install centos-release-scl
  - sudo yum install devtoolset-7-gcc-c++
  - sudo scl enable devtoolset-7 bash  (IMPORTANT: Make sure to enable the toolset)
  - sudo yum install libtool

### YUM (Amazon Linux 2):
  Please install following packages before proceeding with running any tests.

  - sudo yum install gcc-c++
  - sudo yum install automake
  - sudo yum install libtool
  - sudo yum install libxslt
  - sudo yum install git
  - sudo yum install zlib-devel
