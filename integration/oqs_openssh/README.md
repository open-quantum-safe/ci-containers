OQS-OpenSSH Integration Testing
===============================

This directory contains a script for testing the OQS fork of OpenSSH with liboqs.

Currently, the following combinations are tested:

- liboqs master branch with OQS-master
- liboqs nist branch with OQS-master

The scripts have been tested on Ubuntu 14.04 and Ubuntu 16.04.  Currently the integration testing script does not run on Ubuntu 18.04 (but the OQS-OpenSSH integration does run on Ubuntu 18.04, see special build instructions in the OQS-OpenSSL README.md).

The [README.md](https://github.com/open-quantum-safe/openssh-portable/blob/OQS-master/README.md) file for the OQS-OpenSSH fork describes the various key exchange mechanisms supported by each configuration.

Running
-------

First make sure you have **installed the dependencies** as indicated in the [top-level testing README](https://github.com/open-quantum-safe/testing/blob/master/README.md).

Before running the script on Linux, you may need to create directories and users for OpenSSH privilege separation.  (On some Linux installations this will already exist, on others you may need to create it.)  Please try the following:

1. Create the privilege separation directory:

		sudo mkdir -p -m 0755 /var/empty

2. Create the privilege separation user:

		sudo groupadd sshd
		sudo useradd -g sshd -c 'sshd privsep' -d /var/empty -s /bin/false sshd

Then run:

	git clone https://github.com/open-quantum-safe/testing.git
	cd testing/integration/oqs_openssh
	./run.sh

A file named 'logs' is created under the `tmp` direcory showing detailed output not shown in stdout or stderr for debugging purposes.  

OQS developers should record their test results on the OQS [test coverage wiki page](https://github.com/open-quantum-safe/testing/wiki/Configurations-test-coverage).
