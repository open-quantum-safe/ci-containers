OQS-OpenSSL Integration Testing
===============================

This directory contains a script for testing the OQS fork(s) of OpenSSL with liboqs.

Currently, the following combinations are tested:

- liboqs master branch with OQS-OpenSSL\_1\_0\_2-stable
- liboqs nist branch with OQS-OpenSSL\_1\_0\_2-stable
- liboqs master branch with OQS-OpenSSL\_1\_1\_1-stable
- liboqs nist branch with OQS-OpenSSL\_1\_1\_1-stable

The scripts have been tested on macOS 10.14.

Running
-------

First make sure you have installed the dependencies as indicated in the [top-level testing README](https://github.com/open-quantum-safe/testing/blob/master/README.md).

Then run:

	git clone https://github.com/open-quantum-safe/testing.git
	cd testing/integration/oqs_openssl
	./run.sh 2>/dev/null

A file named 'logs' is created under the direcory created above showing detailed output not shown in stdout or stderr for debugging purposes.  

OQS developers should record their test results on the OQS [test coverage wiki page](https://github.com/open-quantum-safe/testing/wiki/Configurations-test-coverage).
