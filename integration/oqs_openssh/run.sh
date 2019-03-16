#!/bin/bash

LIBOQS_MASTER_REPO="https://github.com/open-quantum-safe/liboqs.git"
LIBOQS_MASTER_BRANCH="master"
LIBOQS_NIST_BRANCH_REPO="https://github.com/open-quantum-safe/liboqs.git"
LIBOQS_NIST_BRANCH_BRANCH="nist-branch"
OPENSSH_REPO="https://github.com/open-quantum-safe/openssh-portable.git"
OPENSSH_BRANCH="OQS-master"

OKAY=1

HKEX='ecdh-nistp384-bike1-L1-sha384@openquantumsafe.org ecdh-nistp384-bike1-L3-sha384@openquantumsafe.org ecdh-nistp384-bike1-L5-sha384@openquantumsafe.org ecdh-nistp384-frodo-640-aes-sha384@openquantumsafe.org ecdh-nistp384-frodo-976-aes-sha384@openquantumsafe.org ecdh-nistp384-sike-503-sha384@openquantumsafe.org ecdh-nistp384-sike-751-sha384@openquantumsafe.org ecdh-nistp384-oqsdefault-sha384@openquantumsafe.org'

PQKEX='bike1-L1-sha384@openquantumsafe.org bike1-L3-sha384@openquantumsafe.org bike1-L5-sha384@openquantumsafe.org frodo-640-aes-sha384@openquantumsafe.org frodo-976-aes-sha384@openquantumsafe.org sike-503-sha384@openquantumsafe.org sike-751-sha384@openquantumsafe.org oqsdefault-sha384@openquantumsafe.org'

AUTH='ed25519 qteslai qteslaiiispeed qteslaiiisize picnicl1fs oqsdefault'

run_ssh_sshd() {
  echo
  echo  "$1"  2>&1 | tee -a $5
  echo  "$2"  2>&1 | tee -a $5
  for a in $3; do
    for b in $4; do
      echo "    - KEX: $a"  2>&1 | tee -a $5
      echo "    - AUTH: $b"  2>&1 | tee -a $5
      $BASEDIR/install/sbin/sshd -q -p 2222 -d \
        -f "$BASEDIR/install/sshd_config" \
        -o "KexAlgorithms=$a" \
        -o "AuthorizedKeysFile=${BASEDIR}/install/ssh_server/authorized_keys" \
        -o "HostKeyAlgorithms=ssh-${b}@openquantumsafe.org" \
        -o "PubkeyAcceptedKeyTypes=ssh-${b}@openquantumsafe.org" \
        -h "$BASEDIR/install/ssh_server/id_${b}" >> $5 2>&1 &
      $BASEDIR/install/bin/ssh -l ${USER} \
        -p 2222 ${HOST} \
        -F $BASEDIR/install/ssh_config \
        -o "KexAlgorithms=${a}" \
        -o "HostKeyAlgorithms=ssh-${B}@openquantumsafe.org" \
        -o "PubkeyAcceptedKeyTypes=ssh-${B}@openquantumsafe.org" \
        -o StrictHostKeyChecking=no \
        -i "${BASEDIR}/install/ssh_client/id_${b}" \
        "exit" >> $5 2>&1
      A=`cat $LOGS| grep SSH_CONNECTION`
      if [ $? -eq 0 ];then
        echo "    - Result: SUCCESS" 2>&1 | tee -a $5
      else
        echo "    - Result: FAILURE" 2>&1 | tee -a $5
        OKAY=0
      fi
      echo 2>&1 | tee -a $5
    done
  done
}

build_openssl() {
  echo "==============================" 2>&1 | tee -a $1
  echo "Building OpenSSL_1_0_2-stable"  2>&1 | tee -a $1
  cd "${BASEDIR}/openssl"
  case "$OSTYPE" in
    darwin*) env CFLAGS=-fPIC ./Configure shared darwin64-x86_64-cc --prefix=${BASEDIR}/install >> $1 2>&1 ;;
    linux*) CFLAGS=-fPIC  ./Configure shared linux-x86_64 --prefix=${BASEDIR}/install >> $1 2>&1 ;;
    *)        echo "Unknown operating system: $OSTYPE" ; exit 1 ;;
  esac
	make clean >> $1 2>&1
	make -j8 >> $1 2>&1
	make depend >> $1 2>&1
	make install>> $1 2>&1
}

build_liboqs_master() {
	echo "==============================" 2>&1 | tee -a $1
	echo "Building liboqs-master" 2>&1 | tee -a $1
	cd "${BASEDIR}/liboqs-master"
	git clean -d -f -x >> $1 2>&1
	git checkout -- . >> $1 2>&1
	autoreconf -i >> $1 2>&1
	./configure --prefix="${BASEDIR}/install" --with-pic=yes --enable-openssl --with-openssl-dir="${BASEDIR}/install" >> $1 2>&1
	make clean >> $1 2>&1
	make -j >> $1 2>&1
	make install >> $1 2>&1
}

build_liboqs_nist() {
	echo "==============================" 2>&1 | tee -a $1
	echo "Building liboqs-nist" 2>&1 | tee -a $1
	cd "${BASEDIR}/liboqs-nist"
	git clean -d -f -x >> $1 2>&1
	git checkout -- . >> $1 2>&1
	make clean >> $1 2>&1
	make -j OPENSSL_INCLUDE_DIR="${BASEDIR}/install/include" OPENSSL_LIB_DIR="${BASEDIR}/install/lib" PREFIX="${BASEDIR}/install"  CC=${CC_OVERRIDE} >> $1 2>&1
	make install PREFIX="${BASEDIR}/install" >> $1 2>&1
}

build_openssh-portable() {
	echo "==============================" 2>&1 | tee -a $1
	echo "Building openssh-portable" 2>&1 | tee -a $1
	cd ${BASEDIR}/openssh-portable
	git clean -d -f -x >> $1 2>&1
	git checkout -- . >> $1 2>&1
	autoreconf -i >> $1 2>&1
	./configure --prefix="${BASEDIR}/install" --enable-pq-kex --enable-hybrid-kex --enable-pq-auth --with-ldflags="-Wl,-rpath -Wl,${BASEDIR}/install/lib" --with-libs=-lm --with-ssl-dir=${BASEDIR}/install/  --with-liboqs-dir="${BASEDIR}/install" --with-cflags=-I${BASEDIR}/install/include --sysconfdir="${BASEDIR}/install"  >> $1 2>&1
	make clean >> $1 2>&1
	make -j  >> $1 2>&1
	make install >> $1 2>&1
}

build_openssh-portable_nopqauth() {
	echo "==============================" 2>&1 | tee -a $1
	echo "Building openssh-portable without PQ authentication" 2>&1 | tee -a $1
	cd ${BASEDIR}/openssh-portable
	git clean -d -f -x >> $1 2>&1
	git checkout -- . >> $1 2>&1
	autoreconf -i >> $1 2>&1
	./configure --prefix="${BASEDIR}/install" --enable-pq-kex --enable-hybrid-kex --with-ldflags="-Wl,-rpath -Wl,${BASEDIR}/install/lib" --with-libs=-lm --with-ssl-dir=${BASEDIR}/install/  --with-liboqs-dir="${BASEDIR}/install" --with-cflags=-I${BASEDIR}/install/include --sysconfdir="${BASEDIR}/install"  >> $1 2>&1
	make clean >> $1 2>&1
	make -j  >> $1 2>&1
	make install >> $1 2>&1
}

build_openssh-portable_without_openssl() {
	echo "==============================" 2>&1 | tee -a $1
	echo "Building openssh-portable without OpenSSL" 2>&1 | tee -a $1
	cd ${BASEDIR}/openssh-portable
	git clean -d -f -x >> $1 2>&1
	git checkout -- . >> $1 2>&1
	autoreconf -i >> $1 2>&1
	./configure --prefix="${BASEDIR}/install" --enable-pq-kex --enable-hybrid-kex --enable-pq-auth --with-ldflags="-Wl,-rpath -Wl,${BASEDIR}/install/lib" --with-libs=-lm --without-openssl --with-liboqs-dir="${BASEDIR}/install" --with-cflags=-I${BASEDIR}/install/include --sysconfdir="${BASEDIR}/install"  >> $1 2>&1
	make clean >> $1 2>&1
	make -j  >> $1 2>&1
	make install >> $1 2>&1
}

generate_keys() {
  mkdir ${BASEDIR}/install/ssh_client
  mkdir ${BASEDIR}/install/ssh_server
  chmod 700 ${BASEDIR}/install/ssh_server
  touch ${BASEDIR}/install/ssh_server/authorized_keys
  chmod 600 ${BASEDIR}/install/ssh_server/authorized_keys
  for a in ${AUTH}; do
    ${BASEDIR}/install/bin/ssh-keygen -t ${a} -N "" -f ${BASEDIR}/install/ssh_client/id_${a} >> $1 2>&1
    ${BASEDIR}/install/bin/ssh-keygen -t ${a} -N "" -f ${BASEDIR}/install/ssh_server/id_${a} >> $1 2>&1
  done
  cat ${BASEDIR}/install/ssh_client/*.pub >> ${BASEDIR}/install/ssh_server/authorized_keys
}

mkdir -p tmp
cd tmp
BASEDIR=`pwd`
DATE=`date '+%Y-%m-%d-%H%M%S'`
LOGS="${BASEDIR}/log-${DATE}.txt"
HOST=`hostname`
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


echo "To follow along with the testing process:" 2>&1 | tee -a $LOGS
echo "   tail -f ${LOGS}" 2>&1 | tee -a $LOGS
echo ""

echo "==============================" 2>&1 | tee -a $LOGS
echo "Cloning OpenSSL 1.0.2" 2>&1 | tee -a $LOGS
if [ ! -d "${BASEDIR}/openssl" ] ; then
    git clone --branch OpenSSL_1_0_2-stable --single-branch https://github.com/openssl/openssl.git >> $LOGS 2>&1
fi

echo "==============================" 2>&1 | tee -a $LOGS
echo "Cloning liboqs-master" 2>&1 | tee -a $LOGS
if [ ! -d "${BASEDIR}/liboqs-master" ] ; then
    git clone --branch ${LIBOQS_MASTER_BRANCH} --single-branch ${LIBOQS_MASTER_REPO} "${BASEDIR}/liboqs-master" >> $LOGS 2>&1
fi

echo "==============================" 2>&1 | tee -a $LOGS
echo "Cloning liboqs-nist" 2>&1 | tee -a $LOGS
if [ ! -d "${BASEDIR}/liboqs-nist" ] ; then
    git clone --branch ${LIBOQS_NIST_BRANCH_BRANCH} --single-branch ${LIBOQS_NIST_BRANCH_REPO} "${BASEDIR}/liboqs-nist" >> $LOGS 2>&1
fi

echo "==============================" 2>&1 | tee -a $LOGS
echo "Cloning OpenSSH" 2>&1 | tee -a $LOGS
if [ ! -d "${BASEDIR}/openssh-portable" ] ; then
    git clone --branch ${OPENSSH_BRANCH} --single-branch ${OPENSSH_REPO} >> $LOGS 2>&1
fi

rm -rf ${BASEDIR}/install
build_openssl $LOGS
build_liboqs_master $LOGS
build_openssh-portable $LOGS
generate_keys $LOGS

echo 2>&1 | tee -a $LOGS
echo "Combination being tested: liboqs-master, OpenSSL_1_0_2-stable, openssh-portable" 2>&1 | tee -a $LOGS
echo "===============================================================================" 2>&1 | tee -a $LOGS
run_ssh_sshd "  SSH client and sever using hybrid key exchange methods" "  ======================================================" "$HKEX" "$AUTH" $LOGS
run_ssh_sshd "  SSH client and sever using PQ only key exchange methods" "  =======================================================" "$PQKEX" "$AUTH" $LOGS

rm -rf ${BASEDIR}/install
build_openssl $LOGS
build_liboqs_master $LOGS
build_openssh-portable_without_openssl $LOGS
generate_keys $LOGS

echo 2>&1 | tee -a $LOGS
echo "Combination being tested: liboqs-master using OpenSSL_1_0_2-stable, openssh-portable without OpenSSL" 2>&1 | tee -a $LOGS
echo "====================================================================================================" 2>&1 | tee -a $LOGS
run_ssh_sshd "  SSH client and sever using hybrid key exchange methods" "  ======================================================" "$HKEX" "$AUTH" $LOGS
run_ssh_sshd "  SSH client and sever using PQ only key exchange methods" "  =======================================================" "$PQKEX" "$AUTH" $LOGS

rm -rf ${BASEDIR}/install
build_openssl $LOGS
build_liboqs_nist $LOGS
build_openssh-portable_nopqauth $LOGS
generate_keys $LOGS

echo "Combination being tested: liboqs-nist, OpenSSL_1_0_2-stable, openssh-portable" 2>&1 | tee -a $LOGS
echo "=============================================================================" 2>&1 | tee -a $LOGS
run_ssh_sshd "  SSH client and sever using hybrid key exchange methods" "  ======================================================" "$HKEX" "ed25519" $LOGS
run_ssh_sshd "  SSH client and sever using PQ only key exchange methods" "  =======================================================" "$PQKEX" "ed25519" $LOGS

echo ""
echo "=============================="
if [ ${OKAY} -eq 1 ] ; then
    echo "All tests completed successfully."
else
    echo "SOME TESTS FAILED."
fi
echo ""
echo "    DATE: ${DATE}"
echo "    OSTYPE: ${OSTYPE}"
echo -n "    Compiler: ${CC_OVERRIDE} "
${CC_OVERRIDE} --version | head -n 1
echo -n "    liboqs-master (${LIBOQS_MASTER_REPO} ${LIBOQS_MASTER_BRANCH}) "
cd "${BASEDIR}/liboqs-master"
git log | head -n 1
echo -n "    liboqs-nist (${LIBOQS_NIST_BRANCH_REPO} ${LIBOQS_NIST_BRANCH_BRANCH}) "
cd "${BASEDIR}/liboqs-nist"
git log | head -n 1
echo -n "    OpenSSL "
cd "${BASEDIR}/openssl"
git log | head -n 1
echo -n "    OpenSSH (${OPENSSH_REPO} ${OPENSSH_BRANCH}) "
cd "${BASEDIR}/openssh-portable"
git log | head -n 1
echo "    PQKEX=${PQKEX}"
echo "    HKEX=${HKEX}"
echo "    AUTH=${AUTH}"
