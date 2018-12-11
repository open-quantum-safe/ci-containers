OQS-OpenSSL Integration Testing
===============================

This directory contains scripts for testing the OQS forks of OpenSSL with liboqs, using all supported algorithms. The README.md files for the OQS-OpenSSL forks ([1.0.2](https://github.com/open-quantum-safe/openssl/blob/OQS-OpenSSL_1_0_2-stable/README.md), [1.1.1](https://github.com/open-quantum-safe/openssl/blob/OQS-OpenSSL_1_1_1-stable/README.md)) describe the various key exchange and authentication mechanisms supported by each configuration.

The script `run.sh` runs on Linux and macOS, and the PowerShell script `winrun.ps1` runs on Windows. First make sure you have **installed the dependencies** for the target OS as indicated in the [top-level testing README](https://github.com/open-quantum-safe/testing/blob/master/README.md).

Testing on Linux and macOS
--------------------------

Currently, the following combinations are tested:

- liboqs master branch with OQS-OpenSSL\_1\_0\_2-stable
- liboqs nist branch with OQS-OpenSSL\_1\_0\_2-stable
- liboqs master branch with OQS-OpenSSL\_1\_1\_1-stable
- liboqs nist branch with OQS-OpenSSL\_1\_1\_1-stable

The scripts have been tested on macOS 10.14, Ubuntu 14.04, Ubuntu 16.04, and Ubuntu 18.04.

### Running

Run:

	git clone https://github.com/open-quantum-safe/testing.git
	cd testing/integration/oqs_openssl
	./run.sh 2> /dev/null

A file named 'logs' is created under the `tmp` directory showing detailed output not shown in stdout or stderr for debugging purposes.

Alternatively, to log the run.sh output while following live, try:

    ./run.sh | tee `date "+%Y%m%d-%Hh%Mm%Ss-openssl.log.txt"`

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

Reporting
---------

OQS developers should record their test results on the OQS [test coverage wiki page](https://github.com/open-quantum-safe/testing/wiki/Configurations-test-coverage).
