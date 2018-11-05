OQS Integration Testing
===============================

liboqs integration with OpenSSH and OpenSSL can be tested through the scripts provided under the integration directory.
Please follow the README for details, under the respective directories, on how to run the tests.

Dependencies
------------

### APT (UBUNTU):
Please run and install following packages before proceeding with running any tests.

```bash
sudo apt update
sudo apt install build-essential autotools-dev autoconf libtool \
                 zlib1g-dev zip xsltproc
```

### YUM (CENTOS):
Please install following packages before proceeding with running any tests.

```bash
sudo yum groupinstall 'Development Tools'
sudo yum install centos-release-scl devtoolset-7-gcc-c++
sudo scl enable devtoolset-7 bash # IMPORTANT: ensure toolset is enabled!
sudo yum install libtool
```

### YUM (Amazon Linux 2):
Please install following packages before proceeding with running any tests.

```bash
sudo yum install gcc-c++ automake libtool libxslt git zlib-devel
```
