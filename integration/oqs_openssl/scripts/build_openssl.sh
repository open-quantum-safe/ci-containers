#!/bin/bash

###########
# Build OpenSSL
#
# Same script works for both OQS-OpenSSL_1_0_2-stable and OQS-OpenSSL_1_1_1-stable.
# Must be run after OQS has been installed inside the OpenSSL source code directory

# Environment variables:
#  - OPENSSL: version to be built (102 or 111)
#  - LINKTYPE: either static or dynamic (dynamic default)
#  - INSTALLDIR (optional): If given, determines install location; target folder must be writable
###########

set -exo pipefail

if [[ -z "$LINKTYPE" ]]; then
   export LINKTYPE="dynamic"
fi

OSTYPE=`uname`

# Default install directory:
if [[ -z "$INSTALLDIR" ]]; then
   OQSSLDIR=/opt/oqssa
else
   OQSSLDIR=$INSTALLDIR
fi

cd tmp/openssl
case "$OSTYPE-$LINKTYPE" in
    Darwin-static)  ./Configure --prefix=$OQSSLDIR --openssldir=$OQSSLDIR no-shared darwin64-x86_64-cc ;;
    Linux-static)   ./Configure --prefix=$OQSSLDIR --openssldir=$OQSSLDIR no-shared linux-x86_64 -lm  ;;
    Darwin-dynamic)  ./Configure --prefix=$OQSSLDIR --openssldir=$OQSSLDIR darwin64-x86_64-cc ;;
    Linux-dynamic)   ./Configure --prefix=$OQSSLDIR --openssldir=$OQSSLDIR -Wl,-rpath=$OQSSLDIR/lib linux-x86_64 -lm  ;;
    *)        echo "Unknown operating system-linktype combination: $OSTYPE-$LINKTYPE" ; exit 1 ;;
esac

# Modify version string to know what this is:
cp include/openssl/opensslv.h include/openssl/opensslv.h-orig
sed -e 's/OpenSSL 1.1.1d  10 Sep 2019/OpenSSL 1.1.1d  10 Sep 2019 with OQS support/g' include/openssl/opensslv.h-orig > include/openssl/opensslv.h


if [ "x${OPENSSL}" == "x102" ]; then
    make
else
    if [ "x${CIRCLECI}" == "xtrue" ] || [ "x${TRAVIS}" == "xtrue" ]; then
        make -j2
    else
        make -j
    fi
    if [ "$?" -eq 0 ]; then
       make install
       cp -R oqs/include/oqs $OQSSLDIR/include
       cd oqs/lib; tar -cvf - * | (cd $OQSSLDIR/lib; tar -xvf - ); cd -
    fi
fi
