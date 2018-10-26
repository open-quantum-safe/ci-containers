OQS OpenSSH Integration Testing
===============================

run script tests openssh-portable (OQS-master) with liboqs master and nist-branch branches.
Curently,  following versions of openssl are being tested:

OQS-OpenSSL_1_0_2-stable

Please go through the README at https://github.com/open-quantum-safe/openssh-portable for detailed information about various key exchange methods supported and being tested through the run script.

IMPORTANT
---------
Before running the script, please do the following:

On Linux:

- Create the privilege separation directory:

      sudo mkdir -p -m 0755 /var/empty

- Create the privilege separation user:

      sudo groupadd sshd
      sudo useradd -g sshd -c 'sshd privsep' -d /var/empty -s /bin/false sshd




Run
===

In order to run the script:

./run.sh

A scratch directory called tmp is created where everything is checked out, built and tested. Every run of the script creates a log file which can be viewed for more detailed information.
