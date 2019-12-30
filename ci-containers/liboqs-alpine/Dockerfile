From alpine

MAINTAINER MIB (mib@zurich.ibm.com)

ENV DEBIAN_FRONTEND noninteractive

RUN apk update

RUN apk upgrade 

RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
      rm -r /root/.cache

RUN apk add openssl make build-base linux-headers openssl-dev autoconf automake git libtool unzip wget docker

RUN pip3 install -U pytest-xdist nose rednose

CMD ["/bin/sh"]
