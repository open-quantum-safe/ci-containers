OQS Integration Testing
=======================

[![CircleCI](https://circleci.com/gh/zrlmib/testing/tree/master.svg?style=svg)](https://circleci.com/gh/zrlmib/testing/tree/master)

The **Open Quantum Safe (OQS) project** has the goal of developing and prototyping quantum-resistant cryptography.  [liboqs](https://github.com/open-quantum-safe/liboqs) is an open source C library for post-quantum cryptographic algorithms.  The OQS project has developed forks of [OpenSSH](https://github.com/open-quantum-safe/openssh-portable) and [OpenSSL](https://github.com/open-quantum-safe/openssl) that integrate quantum-resistant algorithms into the SSH and TLS protocols.

This repository contains scripts for testing the integration of liboqs into OpenSSH and OpenSSL.

Please check the README.md files under the **integration/oqs-openssh** and **integration/oqs-openssl** directories for details on how to run the respective tests.

Continuous integration testing of this repository operates on for [Travis CI](https://travis-ci.org/open-quantum-safe/testing) for macOS builds and [CircleCI](https://circleci.com/gh/open-quantum-safe/testing) for Linux builds.

Quick Start using Docker and CircleCI
-------------------------------------

You can quickly get pre-built Debian 10 (Buster) or Ubuntu 16.04 (Xenial) Docker containers with dependencies installed for building liboqs and our integration tests:

	docker pull dstebila/liboqs:amd64-buster-0.0.1
	docker pull dstebila/liboqs:x86_64-xenial-0.0.2

Our Linux integration tests are run on CircleCI.  You can also run those same tests locally using CircleCI's local command-line interface.  First [install CircleCI Local CLI](https://circleci.com/docs/2.0/local-cli/).  Then use `circleci local execute --job <jobname>` to launch a job.  See the README.md files under integration/oqs-openssh and integration/oqs-openssl for details.

Quick Start on Ubuntu
---------------------

A "quick start" script is provided for Ubuntu VMs. This is intended for use in testing VMs as the script makes changes the PS1 command line prompt and other OS settings. The script automates the installation of dependencies and user/group changes, then runs the OpenSSH and OpenSSL integration test suites.

To use:

	git clone git@github.com:open-quantum-safe/testing.git
	cd testing/integration
	bash run_all_ubuntu.sh

To disable either the OpenSSH or OpenSSL tests from being executed, simply create an empty flag file to instruct the script to ignore specific tests:

	cd testing/integration
	touch DISABLE_OPENSSH_TESTS
	# or
	touch DISABLE_OPENSSL_TESTS

Dependencies
------------

If you are not using one of the quick start methods above, you must install the relevant dependencies before proceeding with running any tests.

**Debian/Ubuntu (apt)**

	sudo apt update
	sudo apt install build-essential autotools-dev autoconf git libssl-dev libtool xsltproc zlib1g-dev zip

On Ubuntu 14.04, you need to also:

	sudo add-apt-repository ppa:ubuntu-toolchain-r/test
	sudo apt update
	sudo apt install gcc-5

**Centos (yum)**

	sudo yum groupinstall 'Development Tools'
	sudo yum install centos-release-scl devtoolset-7-gcc-c++
	sudo scl enable devtoolset-7 bash
	sudo yum install libtool

**Amazon Linux 2 (yum)**

	sudo yum install automake gcc-c++ git libtool libxslt zlib-devel

**macOS (brew)**

	brew install autoconf automake libtool openssl wget

**Windows**

[Visual Studio](https://visualstudio.microsoft.com/vs/) and [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-6) must be installed.

Integration Docker Images
-------------------------

Upon successful completion of all internal tests, the current CircleCI integration creates several ready-to-use Docker images:

**Demonstration images**

The images available on [Docker Hub](https://hub.docker.com) in the project `openqssafe` with the extension `-run` are suitable for executing all supported `openssl` and `openssh` commands as known from the upstream projects. In other words, completely built-and-tested images for the presently supported operating systems are available for running out of the box. No need to install or build any software.

At minimum, all images can be started identically with `docker run -it openqsafe/liboqs-<platform>-run` providing a user shell with pre-set environments for running openssl and openssh. These are non-root images to facilitate use in restricted, e.g., Kubernetes, environments.

All images also provide convenience scripts meant to demonstrate (and measure) the performance of quantum safe crypto algorithms: These have the prefix `oqs-` (located in `/opt/oqssa`). So for example, by running `docker run -t openqsafe/liboqs-<platform>-run oqs-speedtest dilithium4 kyber1024` the TLS/SSL performance of this OQS Signature/KEM combination can be easily tested. 

**Integration images**

At the same location, a set of images with the extension `-dev` is available that contains all typically required tooling for building and integrating software that uses/consumes openssl and openssh, e.g., curl or nginx. These images are providing a root shell for maximum flexibility in building and extending them for any kind of integration task. Again, all OQS-applications, libaries and includes are located in the folder `/opt/oqssa`.

*** Example use case***

To build `curl` with OQS support, simply start the development image in docker, e.g., by running
```
docker run -it openqsafe/liboqs-ubuntu-bionic-dev
```
Within the image (on the command prompt), obtain the curl source code, build and install it, e.g., as follows:
```
cd ~ && wget -4 https://curl.haxx.se/download/curl-7.65.3.tar.gz && tar xzvf curl-7.65.3.tar.gz
cd curl-7.65.3 && CPPFLAGS="-I/opt/oqssa/include" LDFLAGS=-Wl,-R/opt/oqssa/lib ./configure --disable-libcurl-option --with-ssl=/opt/oqssa --prefix=/opt/oqssa 
make && make install
```

If you encounter an error message pointing to an EVP API mismatch between OpenSSL and OQS-enabled OpenSSL, simply run this script prior to retrying the `make` run:
```
cat lib/vtls/openssl.c | sed -e 's/\#define BACKEND connssl->backend/\#define BACKEND connssl->backend\n\# define EVP_MD_CTX_create()     EVP_MD_CTX_new()\n\# define EVP_MD_CTX_destroy(ctx) EVP_MD_CTX_free((ctx))/g' > lib/vtls/openssl.c-new && mv lib/vtls/openssl.c-new lib/vtls/openssl.c
```

**Supported platforms**

At this time the following platforms are supported (all x86_64):
* ubuntu-bionic (18.04)
* debian-buster (10)
* centos-7


License
-------

This repository is licensed under the MIT License; see [LICENSE.txt](https://github.com/open-quantum-safe/testing/blob/master/LICENSE.txt) for details.

Team
----

The Open Quantum Safe project is led by [Douglas Stebila](https://www.douglas.stebila.ca/research/) and [Michele Mosca](http://faculty.iqc.uwaterloo.ca/mmosca/) at the University of Waterloo.

### Contributors

Contributors to this testing repository include:

- Shravan Mishra (University of Waterloo)
- Christian Paquin (Microsoft Research)
- Douglas Stebila (University of Waterloo)
- Ben Davies (University of Waterloo)

### Support

Financial support for the development of Open Quantum Safe has been provided by Amazon Web Services and the Tutte Institute for Mathematics and Computing.

We'd like to make a special acknowledgement to the companies who have dedicated programmer time to contribute source code to OQS, including Amazon Web Services, evolutionQ, and Microsoft Research.

Research projects which developed specific components of OQS have been supported by various research grants, including funding from the Natural Sciences and Engineering Research Council of Canada (NSERC); see the source papers for funding acknowledgments.
