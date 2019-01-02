#!/bin/bash

LIBOQS_MASTER_REPO="https://github.com/open-quantum-safe/liboqs.git"
LIBOQS_MASTER_BRANCH="master"
LIBOQS_NIST_BRANCH_REPO="https://github.com/open-quantum-safe/liboqs.git"
LIBOQS_NIST_BRANCH_BRANCH="nist-branch"
OPENSSH_REPO="https://github.com/open-quantum-safe/openssh-portable.git"
OPENSSH_BRANCH="OQS-master"

OKAY=1

run_ssh_sshd() {
  echo
  echo  "$1"  2>&1 | tee -a $4
  echo  "$2"  2>&1 | tee -a $4
  for a in $3; do
  echo "    - KEX: $a"  2>&1 | tee -a $4
  $BASEDIR/install/sbin/sshd -q -p 2222  -d -o "KexAlgorithms=$a" -f $BASEDIR/install/sshd_config -h $BASEDIR/install/ssh_host_ed25519_key >> $4 2>&1 &
  $BASEDIR/install/bin/ssh   -l ${USER} -p 2222 -o "KexAlgorithms="$a"" ${HOST} -F $BASEDIR/install/ssh_config -o StrictHostKeyChecking=no "exit" >> $4 2>&1
  A=`cat $LOGS| grep SSH_CONNECTION`
  if [ $? -eq 0 ];then
    echo "    - Result: SUCCESS" 2>&1 | tee -a $4
  else
    echo "    - Result: FAILURE" 2>&1 | tee -a $4
    OKAY=0
  fi
  echo 2>&1 | tee -a $4
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
	./configure --prefix="${BASEDIR}/install" --enable-pq-kex --enable-hybrid-kex --with-ldflags="-Wl,-rpath -Wl,${BASEDIR}/install/lib" --with-libs=-lm --with-ssl-dir=${BASEDIR}/install/  --with-liboqs-dir="${BASEDIR}/install" --with-cflags=-I${BASEDIR}/install/include --sysconfdir="${BASEDIR}/install"  >> $1 2>&1
	make clean >> $1 2>&1
	make -j  >> $1 2>&1
	make install >> $1 2>&1
}

backup_keys() {
  if [ -d $HOME/.ssh/ ];then
    if [ ! -d $HOME/.ssh_oqs_bkup/ ];then
      mv $HOME/.ssh/ $HOME/.ssh_oqs_bkup
    fi
  fi
}

restore_keys() {
  if [ -d $HOME/.ssh_oqs_bkup/ ];then
    if [ -d $HOME/.ssh/ ];then
      rm -rf $HOME/.ssh/;
    fi
    mv $HOME/.ssh_oqs_bkup $HOME/.ssh/
  fi
}

generate_keys() {
  backup_keys
  mkdir $HOME/.ssh
  chmod 700  $HOME/.ssh
  ${BASEDIR}/install/bin/ssh-keygen -t ed25519 -N "" -f $HOME/.ssh/id_ed25519 >> $1 2>&1
  cat $HOME/.ssh/id_ed25519.pub >> $HOME/.ssh/authorized_keys
  chmod 640 $HOME/.ssh/authorized_keys
}

HKEX='ecdh-nistp384-bike1-L1-sha384@openquantumsafe.org ecdh-nistp384-bike1-L3-sha384@openquantumsafe.org ecdh-nistp384-bike1-L5-sha384@openquantumsafe.org ecdh-nistp384-frodo-640-aes-sha384@openquantumsafe.org ecdh-nistp384-frodo-976-aes-sha384@openquantumsafe.org ecdh-nistp384-sike-503-sha384@openquantumsafe.org ecdh-nistp384-sike-751-sha384@openquantumsafe.org ecdh-nistp384-oqsdefault-sha384@openquantumsafe.org'

PQKEX='bike1-L1-sha384@openquantumsafe.org bike1-L3-sha384@openquantumsafe.org bike1-L5-sha384@openquantumsafe.org frodo-640-aes-sha384@openquantumsafe.org frodo-976-aes-sha384@openquantumsafe.org sike-503-sha384@openquantumsafe.org sike-751-sha384@openquantumsafe.org oqsdefault-sha384@openquantumsafe.org'

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
    git clone -b OpenSSL_1_0_2-stable https://github.com/openssl/openssl.git >> $LOGS 2>&1
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
echo "Cloning OpenSSH OQS-master" 2>&1 | tee -a $LOGS
if [ ! -d "${BASEDIR}/openssh-portable" ] ; then
    git clone --branch ${OPENSSH_BRANCH} --single-branch ${OPENSSH_REPO} >> $LOGS 2>&1
fi

rm -rf ${BASEDIR}/install
build_openssl $LOGS
build_liboqs_master $LOGS
build_openssh-portable $LOGS
generate_keys $LOGS

echo 2>&1 | tee -a $LOGS
echo "Combination being tested: liboqs-master, OpenSSL_1_0_2-stable, openssh-portable (OQS-master) " 2>&1 | tee -a $LOGS
echo "=============================================================================================" 2>&1 | tee -a $LOGS
run_ssh_sshd "  SSH client and sever using hybrid key exchange methods" "  ======================================================" "$HKEX" $LOGS
run_ssh_sshd "  SSH client and sever using PQ only key exchange methods" "  =======================================================" "$PQKEX" $LOGS
restore_keys

rm -rf ${BASEDIR}/install
build_openssl $LOGS
build_liboqs_nist $LOGS
build_openssh-portable $LOGS
generate_keys $LOGS

echo "Combination being tested: liboqs-nist, OpenSSL_1_0_2-stable, openssh-portable (OQS-master) " 2>&1 | tee -a $LOGS
echo "=============================================================================================" 2>&1 | tee -a $LOGS
run_ssh_sshd "  SSH client and sever using hybrid key exchange methods" "  ======================================================" "$HKEX" $LOGS
run_ssh_sshd "  SSH client and sever using PQ only key exchange methods" "  =======================================================" "$PQKEX" $LOGS
restore_keys

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
echo -n "    liboqs-master "
cd "${BASEDIR}/liboqs-master"
git log | head -n 1
echo -n "    liboqs-nist "
cd "${BASEDIR}/liboqs-nist"
git log | head -n 1
echo -n "    OpenSSL "
cd "${BASEDIR}/openssl"
git log | head -n 1
echo "    PQKEX=${PQKEX}"
echo "    HKEX=${HKEX}"
