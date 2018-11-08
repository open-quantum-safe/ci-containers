#!/bin/bash

OPENSSL102_KEMS_MASTER="OQSKEM-DEFAULT OQSKEM-DEFAULT-ECDHE"
OPENSSL102_KEMS_NIST="OQSKEM-DEFAULT OQSKEM-DEFAULT-ECDHE"
OPENSSL111_KEMS_MASTER="oqs_kem_default bike1l1 bike1l3 bike1l5 bike2l1 bike2l3 bike2l5 bike3l1 bike3l3 bike3l5 frodo640aes frodo640cshake frodo976aes frodo976cshake newhope512cca newhope1024cca sidh503 sidh751 sike503 sike751"
OPENSSL111_KEMS_MASTER+=" p256-oqs_kem_default p256-bike1l1 p256-bike2l1 p256-bike3l1 p256-frodo640aes p256-frodo640cshake p256-newhope512cca p256-sidh503 p256-sike503"
OPENSSL111_SIGS_MASTER="rsa ecdsa picnicl1fs qteslaI qteslaIIIsize qteslaIIIspeed"
OPENSSL111_KEMS_NIST="oqs_kem_default bike1l1 bike1l3 bike1l5 bike2l1 bike2l3 bike2l5 bike3l1 bike3l3 bike3l5 frodo640aes frodo640cshake frodo976aes frodo976cshake newhope512cca newhope1024cca sike503 sike751"
OPENSSL111_KEMS_NIST+=" p256-oqs_kem_default p256-bike1l1 p256-bike2l1 p256-bike3l1 p256-frodo640aes p256-frodo640cshake p256-newhope512cca p256-sike503"
OPENSSL111_KEMS_NIST+=" kyber512 kyber768 kyber1024 ledakem_C1_N02 ledakem_C1_N03 ledakem_C1_N04 ledakem_C3_N02 ledakem_C3_N03 ledakem_C3_N04 ledakem_C5_N02 lima_2p_1024_cca lima_sp_1018_cca lima_sp_1306_cca lima_sp_1822_cca saber_light_saber saber_saber saber_fire_saber" # FIXMEOQS lima_2p_2048_cca failing on Ubuntu 14.04
OPENSSL111_KEMS_NIST+=" p256-kyber512 p256-ledakem_C1_N02 p256-ledakem_C1_N04 " # FIXMEOQS p256-ledakem_C1_N03 failing on Ubuntu 14.04
OPENSSL111_SIGS_NIST="rsa"

CC_OVERRIDE=`which clang`
if [ $? -eq 1 ] ; then
  CC_OVERRIDE=`which gcc-7`
  if [ $? -eq 1 ] ; then
    CC_OVERRIDE=`which gcc-6`
    if [ $? -eq 1 ] ; then
      CC_OVERRIDE=`which gcc-5`
      if [ $? -eq 1 ] ; then
        A=`gcc -dumpversion | cut -b 1`
        if [ $A -ge 5 ];then
          CC_OVERRIDE=`which gcc`
          echo "Found gcc >= 5 to build liboqs-nist" 2>&1 | tee -a $LOGS
        else
          echo "Need gcc >= 5 to build liboqs-nist"  2>&1 | tee -a $LOGS
          exit 1
        fi
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

if [ ! -d "${BASEDIR}/openssl_1_1_1-stable" ] ; then
	git clone -b OpenSSL_1_1_1-stable https://github.com/openssl/openssl.git "${BASEDIR}/openssl_1_1_1-stable" >> $LOGS 2>&1 
fi

cd "${BASEDIR}/openssl_1_1_1-stable"
case "$OSTYPE" in
  darwin*) CFLAGS=-fPIC  ./Configure shared --prefix="${BASEDIR}/install-openssl_1_1_1-stable" darwin64-x86_64-cc >> $LOGS 2>&1 ;;
  linux*)  CFLAGS=-fPIC  ./Configure shared --prefix="${BASEDIR}/install-openssl_1_1_1-stable" linux-x86_64 >> $LOGS 2>&1 ;;
  *)        echo "Unknown operating system: $OSTYPE" ; exit 1 ;;
esac
make clean >> $LOGS 2>&1
make -j >> $LOGS 2>&1
make install >> $LOGS 2>&1

rm -rf "${BASEDIR}/openssl_1_0_2-master"
cp -pr "${BASEDIR}/openssl" "${BASEDIR}/openssl_1_0_2-master"
cd "${BASEDIR}/openssl_1_0_2-master"
git checkout OQS-OpenSSL_1_0_2-stable >> $LOGS 2>&1
git pull >> $LOGS 2>&1

rm -rf "${BASEDIR}/openssl_1_0_2-nist"
cp -pr "${BASEDIR}/openssl" "${BASEDIR}/openssl_1_0_2-nist"
cd "${BASEDIR}/openssl_1_0_2-nist"
git checkout OQS-OpenSSL_1_0_2-stable >> $LOGS 2>&1
git pull >> $LOGS 2>&1

rm -rf "${BASEDIR}/openssl_1_1_1-master"
cp -pr "${BASEDIR}/openssl" "${BASEDIR}/openssl_1_1_1-master"
cd "${BASEDIR}/openssl_1_1_1-master"
git checkout OQS-OpenSSL_1_1_1-stable >> $LOGS 2>&1
git pull >> $LOGS 2>&1

rm -rf "${BASEDIR}/openssl_1_1_1-nist"
cp -pr "${BASEDIR}/openssl" "${BASEDIR}/openssl_1_1_1-nist"
cd "${BASEDIR}/openssl_1_1_1-nist"
git checkout OQS-OpenSSL_1_1_1-stable >> $LOGS 2>&1
git pull >> $LOGS 2>&1

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
git pull >> $LOGS 2>&1
autoreconf -i >> $LOGS 2>&1

case "$OSTYPE" in
  darwin*)  export DYLD_LIBRARY_PATH=.:./oqs/lib   ;;
  linux*)   export LD_LIBRARY_PATH=.:./oqs/lib ;;
  *)        echo "Unknown operating system: $OSTYPE" ; exit 1 ;;
esac

OPENSSL_DIR="${BASEDIR}/install-openssl_1_1_1-stable"

./configure --prefix="${BASEDIR}/openssl_1_0_2-master/oqs" --enable-openssl --with-openssl-dir=${OPENSSL_DIR} >> $LOGS 2>&1
make clean >> $LOGS 2>&1
make -j >> $LOGS 2>&1
make install >> $LOGS 2>&1
./configure --prefix="${BASEDIR}/openssl_1_1_1-master/oqs" --enable-openssl --with-openssl-dir=${OPENSSL_DIR} >> $LOGS 2>&1
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
git pull >> $LOGS 2>&1
make clean >> $LOGS 2>&1
make -j CC=${CC_OVERRIDE} OPENSSL_INCLUDE_DIR="${OPENSSL_DIR}/include" OPENSSL_LIB_DIR="${OPENSSL_DIR}/lib" >> $LOGS 2>&1
make install PREFIX="${BASEDIR}/openssl_1_0_2-nist/oqs" >> $LOGS 2>&1
make install PREFIX="${BASEDIR}/openssl_1_1_1-nist/oqs" >> $LOGS 2>&1


echo "=============================="
echo "Building OQS-OpenSSL_1_0_2-stable with liboqs-master"
cd "${BASEDIR}/openssl_1_0_2-master"
case "$OSTYPE" in
  darwin*) CFLAGS=-fPIC  ./Configure shared darwin64-x86_64-cc >> $LOGS 2>&1 ;;
  linux*)  CFLAGS=-fPIC  ./Configure shared linux-x86_64 >> $LOGS 2>&1 ;;
  *)        echo "Unknown operating system: $OSTYPE" ; exit 1 ;;
esac
make clean >> $LOGS 2>&1
make -j >> $LOGS 2>&1

apps/openssl req -x509 -new -newkey rsa:2048 -keyout rsa.key -nodes -out rsa.cer -sha256 -days 365 -subj '/CN=oqstest' -config apps/openssl.cnf >> $LOGS 2>&1
for CIPHER in ${OPENSSL102_KEMS_MASTER} ; do
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
cd "${BASEDIR}/openssl_1_0_2-nist"
case "$OSTYPE" in
  darwin*)  CFLAGS=-fPIC ./Configure shared darwin64-x86_64-cc >> $LOGS 2>&1 ;;
  linux*)   CFLAGS=-fPIC ./Configure shared linux-x86_64 -lm >> $LOGS 2>&1 ;;
  *)        echo "Unknown operating system: $OSTYPE" ; exit 1 ;;
esac
make clean >> $LOGS 2>&1
make -j >> $LOGS 2>&1

apps/openssl req -x509 -new -newkey rsa:2048 -keyout rsa.key -nodes -out rsa.cer -sha256 -days 365 -subj '/CN=oqstest' -config apps/openssl.cnf >> $LOGS 2>&1
for CIPHER in ${OPENSSL102_KEMS_NIST} ; do
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
cd "${BASEDIR}/openssl_1_1_1-master"
case "$OSTYPE" in
  darwin*)  CFLAGS=-fPIC ./Configure shared darwin64-x86_64-cc >> $LOGS 2>&1 ;;
  linux*)   CFLAGS=-fPIC ./Configure shared linux-x86_64 -lm >> $LOGS 2>&1 ;;
  *)        echo "Unknown operating system: $OSTYPE" ; exit 1 ;;
esac
make clean >> $LOGS 2>&1
make -j >> $LOGS 2>&1

for SIGALG in ${OPENSSL111_SIGS_MASTER} ; do
    if [ "${SIGALG}" == "ecdsa" ] ; then
        apps/openssl req -x509 -new -newkey ec:<(apps/openssl ecparam -name secp384r1) -keyout ${SIGALG}.key -nodes -out ${SIGALG}.cer -days 365 -subj '/CN=oqstest' -config apps/openssl.cnf >> $LOGS 2>&1
    else
        apps/openssl req -x509 -new -newkey ${SIGALG} -keyout ${SIGALG}.key -nodes -out ${SIGALG}.cer -days 365 -subj '/CN=oqstest' -config apps/openssl.cnf >> $LOGS 2>&1
    fi
    for KEXALG in ${OPENSSL111_KEMS_MASTER} ; do
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

echo "=============================="
echo "Building OQS-OpenSSL_1_1_1-stable with liboqs-nist"
cd "${BASEDIR}/openssl_1_1_1-nist"
case "$OSTYPE" in
  darwin*)  CFLAGS=-fPIC ./Configure shared darwin64-x86_64-cc >> $LOGS 2>&1 ;;
  linux*)   CFLAGS=-fPIC ./Configure shared linux-x86_64 -lm >> $LOGS 2>&1 ;;
  *)        echo "Unknown operating system: $OSTYPE" ; exit 1 ;;
esac
make clean >> $LOGS 2>&1
make -j >> $LOGS 2>&1

for SIGALG in ${OPENSSL111_SIGS_NIST} ; do
    if [ "${SIGALG}" == "ecdsa" ] ; then
        apps/openssl req -x509 -new -newkey ec:<(apps/openssl ecparam -name secp384r1) -keyout ${SIGALG}.key -nodes -out ${SIGALG}.cer -days 365 -subj '/CN=oqstest' -config apps/openssl.cnf >> $LOGS 2>&1
    else
        apps/openssl req -x509 -new -newkey ${SIGALG} -keyout ${SIGALG}.key -nodes -out ${SIGALG}.cer -days 365 -subj '/CN=oqstest' -config apps/openssl.cnf >> $LOGS 2>&1
    fi
    for KEXALG in ${OPENSSL111_KEMS_NIST} ; do
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


echo ""
echo "=============================="
echo "All tests completed successfully."
echo ""
echo "    DATE: ${DATE}"
echo "    OSTYPE: ${OSTYPE}"
echo -n "    Compiler: ${CC_OVERRIDE} "
${CC_OVERRIDE} --version | head -n 1
echo -n "    liboqs-master "
cd "${BASEDIR}/liboqs-master"
git log | head -n 1
echo -n "    liboqs-nist "
cd "${BASEDIR}/liboqs-nist"
git log | head -n 1
echo -n "    OQS-OpenSSL_1_0_2 "
cd "${BASEDIR}/openssl_1_0_2-master"
git log | head -n 1
echo -n "    OQS-OpenSSL_1_1_1 "
cd "${BASEDIR}/openssl_1_1_1-master"
git log | head -n 1
echo "    OPENSSL102_KEMS_MASTER=${OPENSSL102_KEMS_MASTER}"
echo "    OPENSSL102_KEMS_NIST=${OPENSSL102_KEMS_NIST}"
echo "    OPENSSL111_KEMS_MASTER=${OPENSSL111_KEMS_MASTER}"
echo "    OPENSSL111_SIGS_MASTER=${OPENSSL111_SIGS_MASTER}"
echo "    OPENSSL111_KEMS_NIST=${OPENSSL111_KEMS_NIST}"
echo "    OPENSSL111_SIGS_NIST=${OPENSSL111_SIGS_NIST}"

