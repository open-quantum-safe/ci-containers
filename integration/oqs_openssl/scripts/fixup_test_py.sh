#!/bin/bash

# Obtain openssl master testfile and change suitably:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo $DIR
cd /tmp
wget https://raw.githubusercontent.com/open-quantum-safe/openssl/OQS-OpenSSL_1_1_1-stable/oqs_test/tests/test_openssl.py
sed -e "s/os.path.join('..')/os.path.join('tmp','openssl')/g" test_openssl.py > $DIR/../tests/test_openssl.py
rm test_openssl.py
