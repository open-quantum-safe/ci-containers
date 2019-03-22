OQS-OpenSSL Integration Testing
===============================

This directory contains scripts for testing the OQS forks of OpenSSL with liboqs, using all supported algorithms. The README.md files for the OQS-OpenSSL forks ([1.0.2](https://github.com/open-quantum-safe/openssl/blob/OQS-OpenSSL_1_0_2-stable/README.md), [1.1.1](https://github.com/open-quantum-safe/openssl/blob/OQS-OpenSSL_1_1_1-stable/README.md)) describe the various key exchange and authentication mechanisms supported by each configuration.

The script `run_all.sh` runs on Linux and macOS, and the PowerShell script `winrun.ps1` runs on Windows. First make sure you have **installed the dependencies** for the target OS as indicated in the [top-level testing README](https://github.com/open-quantum-safe/testing/blob/master/README.md).

Testing on Linux and macOS
--------------------------

Currently, the following combinations are tested:

- liboqs master branch with OQS-OpenSSL\_1\_0\_2-stable
- liboqs nist branch with OQS-OpenSSL\_1\_0\_2-stable
- liboqs master branch with OQS-OpenSSL\_1\_1\_1-stable
- liboqs nist branch with OQS-OpenSSL\_1\_1\_1-stable

The scripts have been tested on macOS 10.14, Debian 10 (Buster), Ubuntu 14.04, Ubuntu 16.04, and Ubuntu 18.04.

### Running directly

Run:

	git clone https://github.com/open-quantum-safe/testing.git
	cd testing/integration/oqs_openssl
	./run_all.sh

Alternatively, to log the run.sh output while following live, try:

    ./run_all.sh | tee `date "+%Y%m%d-%Hh%Mm%Ss-openssl.log.txt"`
	
### Running using CircleCI

You can locally run any of the integration tests that CircleCI runs.  First, you need to install CircleCI's local command line interface as indicated in the [installation instructions](https://circleci.com/docs/2.0/local-cli/).  Then:

	git clone https://github.com/open-quantum-safe/testing.git
	cd testing
	circleci local execute --job <jobname>

where `<jobname>` is one of the following:

- `ssl-amd64-buster-liboqs-master-openssl-111`
- `ssl-amd64-buster-liboqs-master-openssl-102`
- `ssl-amd64-buster-liboqs-nist-openssl-111`
- `ssl-amd64-buster-liboqs-nist-openssl-102`
- `ssl-x86_64-xenial-liboqs-master-openssl-111`
- `ssl-x86_64-xenial-liboqs-master-openssl-102`
- `ssl-x86_64-xenial-liboqs-nist-openssl-111`
- `ssl-x86_64-xenial-liboqs-nist-openssl-102`

By default, these jobs will use the current Github versions of liboqs and OQS-OpenSSL.  You can override these by passing environment variables to CircleCI:

	circleci local execute --job <jobname> --env <NAME>=<VALUE> --env <NAME>=<VALUE> ...

where `<NAME>` is one of the following:

- `OPENSSL_102_REPO`: which repo to check out from, default `https://github.com/open-quantum-safe/openssl.git`
- `OPENSSL_102_BRANCH`: which branch to check out, default `OQS-OpenSSL_1_0_2-stable`
- `OPENSSL_111_REPO`: which repo to check out from, default `https://github.com/open-quantum-safe/openssl.git`
- `OPENSSL_111_BRANCH`: which branch to check out, default `OQS-OpenSSL_1_1_1-stable`
- `LIBOQS_MASTER_REPO`: which repo to check out from, default `https://github.com/open-quantum-safe/liboqs.git`
- `LIBOQS_MASTER_BRANCH`: which branch to check out, default `master`
- `LIBOQS_NIST_REPO`: which repo to check out from, default `https://github.com/open-quantum-safe/liboqs.git`
- `LIBOQS_NIST_BRANCH`: which branch to check out, default `nist-branch`

Testing on Windows
------------------

Currently, the following combinations are tested:

- liboqs master branch with OQS-OpenSSL\_1\_0\_2-stable (static and DLL targets)
- liboqs master branch with OQS-OpenSSL\_1\_1\_1-stable

The scripts have been tested on Windows 10 with PowerShell 5.

### Running

Run:

	git clone https://github.com/open-quantum-safe/testing.git
	cd testing/integration/oqs_openssl
	powershell -File winrun.ps1
