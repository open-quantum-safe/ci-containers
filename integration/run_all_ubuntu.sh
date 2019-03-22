# Configuration to bootstrap Ubuntu Xenial VM for liboqs integration testing
#
# Usage:
# $ cd <your-working-dir>
# $ git clone git@github.com:open-quantum-safe/testing.git
# $ cd testing/integration
# $ bash run_all_ubuntu.sh
#
# To disable the OpenSSH or OpenSSL tests from being executed, create an empty
# flag file to instruct the script to ignore specific tests:
#
# $ cd <your-working-dir>/testing/integration
# $ touch DISABLE_OPENSSH_TESTS
# # or
# $ touch DISABLE_OPENSSL_TESTS

set -eo pipefail

# updates
if lsb_release -a 2>/dev/null | grep -q "Ubuntu 14."
then
  sudo add-apt-repository ppa:ubuntu-toolchain-r/test
  sudo apt-get -y update
  sudo apt-get -y install gcc-5
fi

alias apt="apt-get -y"  # if 'apt' used by accident...
sudo apt-get -y update
sudo apt-get -y install gcc build-essential autotools-dev autoconf automake git libssl-dev libtool xsltproc zlib1g-dev zip

# config for openssh-portable

# create required empty dir
EMPTY_DIR=/var/empty

if [ ! -d $EMPTY_DIR ]
  then sudo mkdir -p -m 0755 $EMPTY_DIR
fi

# privsep user
if ! grep -e "^sshd:" /etc/group
  then sudo groupadd sshd
fi

if ! getent passwd | grep -e "^sshd:"
  then sudo useradd -g sshd -c 'sshd privsep' -d $EMPTY_DIR -s /bin/false sshd
fi

# UI tweaks: make host bold red in prompt/visual aid to indicate VM prompt
PS1_CODE='export PS1="\u@\[\033[1;31m\]\h\033[0m\]:\w $ "'

if ! grep -e "export PS1=" $HOME/.bashrc
  then echo $PS1_CODE >> $HOME/.bashrc
fi

# run openssh tests
DISABLE_OPENSSH_TESTS=$PWD/DISABLE_OPENSSH_TESTS

if [ ! -e $DISABLE_OPENSSH_TESTS ]
  then
    cd oqs_openssh
    time ./run_all.sh | tee `date "+%Y%m%d-%Hh%Mm%Ss-openssh.log.txt"`
    cd ..
  else
    echo "Skipping OpenSSH test script"
fi

# run openssl tests
DISABLE_OPENSSL_TESTS=$PWD/DISABLE_OPENSSL_TESTS

if [ ! -e $DISABLE_OPENSSL_TESTS ]
  then
    cd oqs_openssl
    time ./run_all.sh | tee `date "+%Y%m%d-%Hh%Mm%Ss-openssl.log.txt"`
  else
    echo "Skipping OpenSSL test script"
fi
