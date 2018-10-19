oqs openssl integration testing
===============================

run script tests openssl with liboqs master and nist-branch branches.
Curently,  following versions of openssl are being tested:

OQS-OpenSSL_1_0_2-stable 
OQS-OpenSSL_1_1_1-stable

Following cipher suites are being tested with oqs openssl builds as shown below
matrix:

OQSKEM-DEFAULT-RSA-AES128-GCM-SHA256
OQSKEM-DEFAULT-RSA-AES256-GCM-SHA384
OQSKEM-DEFAULT-ECDHE-RSA-AES128-GCM-SHA256
OQSKEM-DEFAULT-ECDHE-RSA-AES256-GCM-SHA384
OQSKEM-DEFAULT-ECDSA-AES128-GCM-SHA256
OQSKEM-DEFAULT-ECDSA-AES256-GCM-SHA384
OQSKEM-DEFAULT-ECDHE-ECDSA-AES128-GCM-SHA256
OQSKEM-DEFAULT-ECDHE-ECDSA-AES256-GCM-SHA384

Testing matrix and finalr esults are shown as follows after the run besides
other informations:

                     +---------------------------+---------------------------+
                     | OQS-OpenSSL_1_0_2-stable  |  OQS-OpenSSL_1_1_1-stable |
 +-------------------+---------------------------+---------------------------+
 | liboqs master     |        success            |      success              |
 +-------------------+---------------------------+---------------------------+
 | liboqs nist-branch|        success            |             success       |
 +-------------------+---------------------------+---------------------------+


Run
===

1. Create a testing directory e.g.
   mkdir test_oqs_openssl
2. Copy the run script there.
3. chmod +x run
4. ./run
 
A file named 'logs' is created under the direcory created above showing
detailed output not shown in stdout or stderr for debugging purposes.  





