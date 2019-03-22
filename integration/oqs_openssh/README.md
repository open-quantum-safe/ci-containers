OQS-OpenSSH Integration Testing
===============================

This directory contains a script for testing the OQS fork of OpenSSH with liboqs.

Testing on Linux and macOS
--------------------------

Currently, the following combinations are tested:

- liboqs master branch with OpenSSH OQS-master, with OpenSSL and with PQ authentication
- liboqs master branch with OpenSSH OQS-master, with OpenSSL and without PQ authentication
- liboqs master branch with OpenSSH OQS-master, without OpenSSL and with PQ authentication
- liboqs master branch with OpenSSH OQS-master, without OpenSSL and without PQ authentication
- liboqs nist branch with OpenSSH OQS-master, with OpenSSL
- liboqs nist branch with OpenSSH OQS-master, without OpenSSL

The scripts have been tested on macOS 10.14, Debian 10 (Buster), Ubuntu 14.04, and Ubuntu 16.04.

Currently the integration testing script does not run on Ubuntu 18.04 (but the OQS-OpenSSH integration does run on Ubuntu 18.04, see special build instructions in the OQS-OpenSSL README.md).

### Running directly

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
	./run_all.sh

### Running using CircleCI

You can locally run any of the integration tests that CircleCI runs.  First, you need to install CircleCI's local command line interface as indicated in the [installation instructions](https://circleci.com/docs/2.0/local-cli/).  Then:

	git clone https://github.com/open-quantum-safe/testing.git
	cd testing
	circleci local execute --job <jobname>

where `<jobname>` is one of the following:

- `ssh-x86_64-xenial-liboqs-master-with-openssl-with-pqauth`
- `ssh-x86_64-xenial-liboqs-master-with-openssl-no-pqauth`
- `ssh-x86_64-xenial-liboqs-master-no-openssl-with-pqauth`
- `ssh-x86_64-xenial-liboqs-master-no-openssl-no-pqauth`
- `ssh-x86_64-xenial-liboqs-nist-with-openssl`
- `ssh-x86_64-xenial-liboqs-nist-no-openssl`

By default, these jobs will use the current Github versions of liboqs and OQS-OpenSSH, and build with OpenSSL and PQ authentication enabled.  You can override these by passing environment variables to CircleCI:

	circleci local execute --job <jobname> --env <NAME>=<VALUE> --env <NAME>=<VALUE> ...

where `<NAME>` is one of the following:

- `LIBOQS_MASTER_REPO`: which repo to check out from, default `https://github.com/open-quantum-safe/liboqs.git`
- `LIBOQS_MASTER_BRANCH`: which branch to check out, default `master`
- `LIBOQS_NIST_REPO`: which repo to check out from, default `https://github.com/open-quantum-safe/liboqs.git`
- `LIBOQS_NIST_BRANCH`: which branch to check out, default `nist-branch`
- `OPENSSH_REPO`: which repo to check out from, default `https://github.com/open-quantum-safe/openssh-portable.git`
- `OPENSSH_BRANCH`: which branch to check out, default `OQS-master`
- `WITH_OPENSSL`: build OpenSSH with (`true`, default) or without (`false`) OpenSSL
- `WITH_PQAUTH`: build OpenSSH with (`true`, default) or without (`false`) post-quantum authentication
