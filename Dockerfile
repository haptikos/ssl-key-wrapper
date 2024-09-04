from ubuntu as builder

COPY patch.txt /tmp/patch.txt

RUN apt-get update  && \
    apt-get install -y curl patch make gcc libfindbin-libs-perl && \
    mkdir /root/build && \
    mkdir -p /root/local/ssl && \
    cd /root/build && \ 
    curl -O https://www.openssl.org/source/openssl-1.1.1d.tar.gz && \
    tar -zxf openssl-1.1.1d.tar.gz && \
    cat /tmp/patch.txt | patch -d /root/build/ -p0 && \
    cd /root/build/openssl-1.1.1d/ && \
    ./config --prefix=/root/local --openssldir=/root/local/ssl && \
    make -j$(grep -c ^processor /proc/cpuinfo) && \
    make install && \
    cd /root/local/bin/ && \
    printf '#!/bin/bash \nenv LD_LIBRARY_PATH=/root/local/lib/ /root/local/bin/openssl "$@"' > ./openssl.sh && \
    chmod 755 ./openssl.sh && \
    /root/local/bin/openssl.sh version

from ubuntu
COPY wrap_key /usr/bin/wrap_key

RUN apt-get update  && \
    apt-get install -y bsdmainutils openssl && \ 
    mkdir -p /root/local/bin/ && \
    mkdir -p /root/local/lib/ && \
    mkdir -p /opt/wrap_key/ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /root/local/bin/ /root/local/bin/
COPY --from=builder /root/local/lib/ /root/local/lib/

WORKDIR /opt/wrap_key

ENTRYPOINT ["wrap_key"]
