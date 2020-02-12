#!/bin/bash
set -e

cd /root
#TODO: See if we can just download the official tarball
git clone --single-branch https://github.com/openssl/openssl.git
cd openssl
git checkout tags/OpenSSL_1_1_1d
./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl no-comp shared
make
make install_sw
echo '/usr/local/ssl/lib' > /etc/ld.so.conf.d/openssl-1.1.1d.conf
ldconfig -v
echo "export PATH=/usr/local/ssl/bin:$PATH" >> /root/.bashrc
