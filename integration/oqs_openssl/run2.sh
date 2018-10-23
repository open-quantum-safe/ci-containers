#!/bin/bash

CC_OVERRIDE=`which clang`
if [ $? -eq 1 ] ; then
    CC_OVERRIDE=`which gcc-7`
    if [ $? -eq 1 ] ; then
        CC_OVERRIDE=`which gcc-6`
        if [ $? -eq 1 ] ; then
            CC_OVERRIDE=`which gcc-5`
            if [ $? -eq 1 ] ; then
                echo "Need gcc >= 5 to build liboqs-nist"
                exit 1
            fi
        fi
    fi
fi

set -e

mkdir -p tmp
cd tmp

BASEDIR=`pwd`
DATE=`date '+%Y-%m-%d-%H%M%S'`
LOGS="${BASEDIR}/log-${DATE}.txt"

echo "To follow along with the testing process:"
echo "   tail -f ${LOGS}"
echo ""

echo "=============================="
echo "Cloning openssl"
if [ ! -d "${BASEDIR}/openssl" ] ; then
    git clone https://github.com/open-quantum-safe/openssl "${BASEDIR}/openssl" >> $LOGS 2>&1
fi
cd "${BASEDIR}/openssl"
git clean -d -f -x >> $LOGS 2>&1
git checkout -- . >> $LOGS 2>&1

rm -rf "${BASEDIR}/openssl-1_0_2-master"
cp -pr "${BASEDIR}/openssl" "${BASEDIR}/openssl-1_0_2-master"
cd "${BASEDIR}/openssl-1_0_2-master"
git checkout OQS-OpenSSL_1_0_2-stable >> $LOGS 2>&1

rm -rf "${BASEDIR}/openssl-1_0_2-nist"
cp -pr "${BASEDIR}/openssl" "${BASEDIR}/openssl-1_0_2-nist"
cd "${BASEDIR}/openssl-1_0_2-nist"
git checkout OQS-OpenSSL_1_0_2-stable >> $LOGS 2>&1

rm -rf "${BASEDIR}/openssl-1_1_1-master"
cp -pr "${BASEDIR}/openssl" "${BASEDIR}/openssl-1_1_1-master"
cd "${BASEDIR}/openssl-1_1_1-master"
git checkout OQS-OpenSSL_1_1_1-stable >> $LOGS 2>&1

rm -rf "${BASEDIR}/openssl-1_1_1-nist"
cp -pr "${BASEDIR}/openssl" "${BASEDIR}/openssl-1_1_1-nist"
cd "${BASEDIR}/openssl-1_1_1-nist"
git checkout OQS-OpenSSL_1_1_1-stable >> $LOGS 2>&1

echo "=============================="
echo "Cloning liboqs-master"
if [ ! -d "${BASEDIR}/liboqs-master" ] ; then
    git clone --branch master https://github.com/open-quantum-safe/liboqs.git "${BASEDIR}/liboqs-master" >> $LOGS 2>&1
fi

echo "=============================="
echo "Building liboqs-master"
cd "${BASEDIR}/liboqs-master"
git clean -d -f -x >> $LOGS 2>&1
git checkout -- . >> $LOGS 2>&1
autoreconf -i >> $LOGS 2>&1
./configure --prefix="${BASEDIR}/openssl-1_0_2-master/oqs" --enable-shared=no >> $LOGS 2>&1
make clean >> $LOGS 2>&1
make -j >> $LOGS 2>&1
make install >> $LOGS 2>&1
./configure --prefix="${BASEDIR}/openssl-1_1_1-master/oqs" --enable-shared=no >> $LOGS 2>&1
make -j >> $LOGS 2>&1
make install >> $LOGS 2>&1

echo "=============================="
echo "Cloning liboqs-nist"
if [ ! -d "${BASEDIR}/liboqs-nist" ] ; then
    git clone --branch nist-branch https://github.com/open-quantum-safe/liboqs.git "${BASEDIR}/liboqs-nist" >> $LOGS 2>&1
fi

echo "=============================="
echo "Building liboqs-nist"
cd "${BASEDIR}/liboqs-nist"
git clean -d -f -x >> $LOGS 2>&1
git checkout -- . >> $LOGS 2>&1
make clean >> $LOGS 2>&1
make -j CC=${CC_OVERRIDE} >> $LOGS 2>&1
make install PREFIX="${BASEDIR}/openssl-1_0_2-nist/oqs" >> $LOGS 2>&1
make install PREFIX="${BASEDIR}/openssl-1_1_1-nist/oqs" >> $LOGS 2>&1

echo "=============================="
echo "Building OQS-OpenSSL_1_0_2-stable with liboqs-master"
cd "${BASEDIR}/openssl-1_0_2-master"
case "$OSTYPE" in
  darwin*)  ./Configure no-shared darwin64-x86_64-cc >> $LOGS 2>&1 ;;
  linux*)   ./Configure no-shared linux-x86_64 >> $LOGS 2>&1 ;;
  *)        echo "Unknown operating system: $OSTYPE" ; exit 1 ;;
esac
make clean >> $LOGS 2>&1
make >> $LOGS 2>&1
apps/openssl req -x509 -new -newkey rsa:2048 -keyout rsa.key -nodes -out rsa.cer -sha256 -days 365 -subj '/CN=oqstest' -config apps/openssl.cnf >> $LOGS 2>&1
for CIPHER in "OQSKEM-DEFAULT" "OQSKEM-DEFAULT-ECDHE" ; do
    echo "=============================="
    pwd | sed -e 's/.*\///'
    echo "${CIPHER}"
    apps/openssl s_server -cert rsa.cer -key rsa.key -tls1_2 -www >> $LOGS 2>&1 &
    sleep 1
    SERVER_PID=$!
    echo "GET /" | apps/openssl s_client -cipher "${CIPHER}" > s_client.out 2>/dev/null
    cat s_client.out | grep "Cipher is" | grep "${CIPHER}" > /dev/null
    kill ${SERVER_PID}
    echo "Success"
done

echo "=============================="
echo "Building OQS-OpenSSL_1_0_2-stable with liboqs-nist"
cd "${BASEDIR}/openssl-1_0_2-nist"
case "$OSTYPE" in
  darwin*)  ./Configure no-shared darwin64-x86_64-cc >> $LOGS 2>&1 ;;
  linux*)   ./Configure no-shared linux-x86_64 -lm >> $LOGS 2>&1 ;;
  *)        echo "Unknown operating system: $OSTYPE" ; exit 1 ;;
esac
make clean >> $LOGS 2>&1
make >> $LOGS 2>&1
apps/openssl req -x509 -new -newkey rsa:2048 -keyout rsa.key -nodes -out rsa.cer -sha256 -days 365 -subj '/CN=oqstest' -config apps/openssl.cnf >> $LOGS 2>&1
for CIPHER in "OQSKEM-DEFAULT" "OQSKEM-DEFAULT-ECDHE" ; do
    echo "=============================="
    pwd | sed -e 's/.*\///'
    echo "${CIPHER}"
    apps/openssl s_server -cert rsa.cer -key rsa.key -tls1_2 -www >> $LOGS 2>&1 &
    sleep 1
    SERVER_PID=$!
    echo "GET /" | apps/openssl s_client -cipher "${CIPHER}" > s_client.out 2>/dev/null
    cat s_client.out | grep "Cipher is" | grep "${CIPHER}" > /dev/null
    kill ${SERVER_PID}
    echo "Success"
done

echo "=============================="
echo "Building OQS-OpenSSL_1_1_1-stable with liboqs-master"
cd "${BASEDIR}/openssl-1_1_1-master"
case "$OSTYPE" in
  darwin*)  ./Configure no-shared darwin64-x86_64-cc >> $LOGS 2>&1 ;;
  linux*)   ./Configure no-shared linux-x86_64 >> $LOGS 2>&1 ;;
  *)        echo "Unknown operating system: $OSTYPE" ; exit 1 ;;
esac
make clean >> $LOGS 2>&1
make -j >> $LOGS 2>&1
for SIGALG in rsa ecdsa picnicl1fs qteslaI qteslaIIIsize qteslaIIIspeed ; do
    if [ "${SIGALG}" == "ecdsa" ] ; then
        apps/openssl req -x509 -new -newkey ec:<(apps/openssl ecparam -name secp384r1) -keyout ${SIGALG}.key -nodes -out ${SIGALG}.cer -days 365 -subj '/CN=oqstest' -config apps/openssl.cnf >> $LOGS 2>&1
    else
        apps/openssl req -x509 -new -newkey ${SIGALG} -keyout ${SIGALG}.key -nodes -out ${SIGALG}.cer -days 365 -subj '/CN=oqstest' -config apps/openssl.cnf >> $LOGS 2>&1
    fi
    for KEXALG in sike503 sike751 sidh503 sidh751 frodo640aes frodo640cshake frodo976aes frodo976cshake  newhope512cca newhope1024cca ; do
        echo "=============================="
        pwd | sed -e 's/.*\///'
        echo "sig=${SIGALG},kex=${KEXALG}"
        apps/openssl s_server -cert ${SIGALG}.cer -key ${SIGALG}.key -tls1_3 -www >> $LOGS 2>&1 &
        sleep 1
        SERVER_PID=$!
        echo "GET /" | apps/openssl s_client -curves "${KEXALG}" > s_client.out 2>/dev/null
        cat s_client.out | grep "Server Temp Key" | grep "${KEXALG}" > /dev/null
        kill ${SERVER_PID}
        echo "Success"
    done
done
