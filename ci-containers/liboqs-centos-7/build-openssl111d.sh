#!/bin/bash

cd /root
curl -O -L https://github.com/openssl/openssl/archive/OpenSSL_1_1_1d.tar.gz
tar xzvf OpenSSL_1_1_1d.tar.gz
cd openssl-OpenSSL_1_1_1d
./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib
make
make install
echo '/usr/local/ssl/lib' > /etc/ld.so.conf.d/openssl-1.1.1d.conf
ldconfig -v
echo "export PATH=/usr/local/ssl/bin:$PATH" >> /root/.bashrc
