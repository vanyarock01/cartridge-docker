FROM centos:8
MAINTAINER mail@knazarov.com


RUN groupadd tarantool \
    && adduser -g tarantool tarantool


RUN yum -y install epel-release && \
    yum -y update && \
    yum -y clean all


ENV TARANTOOL_DOWNLOAD_URL https://github.com/tarantool/tarantool.git
ENV CARTRIDGE_DOWNLOAD_URL https://github.com/tarantool/cartridge.git
ENV CARTRIDGE_CLI_DOWNLOAD_URL https://github.com/tarantool/cartridge-cli.git


ENV TARANTOOL_VERSION 2.1.2
ENV CARTRIDGE_VERSION 1.0.0
ENV CARTRIDGE_CLI_VERSION 1.0.0


RUN set -x \
    && yum -y install \
        libstdc++ \
        readline \
        openssl \
        lz4 \
        binutils \
        ncurses \
        libgomp \
        lua \
        tar \
        zip \
        unzip \
        libunwind \
        libicu \
        libcurl-minimal \
        git-core \
        gcc \
        cmake \
        make \
    && yum -y install \
        gcc-c++ \
        readline-devel \
        openssl-devel \
        lz4-devel \
        binutils-devel \
        ncurses-devel \
        readline-devel \
        libunwind-devel \
        autoconf \
        automake \
        libtool \
        wget \
        libicu-devel \
        libcurl-devel \
    && : "---------- basic git setup ----------" \
    && git config --global user.email "you@example.com" \
    && git config --global user.name "Example User" \
    && : "---------- tarantool ----------" \
    && mkdir -p /usr/src/tarantool \
    && git clone "$TARANTOOL_DOWNLOAD_URL" /usr/src/tarantool \
    && (cd /usr/src/tarantool; git checkout "$TARANTOOL_VERSION";) \
    && (cd /usr/src/tarantool; git submodule update --init --recursive;) \
    && (cd /usr/src/tarantool; \
       cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo\
             -DENABLE_BUNDLED_LIBYAML:BOOL=OFF\
             -DENABLE_BACKTRACE:BOOL=ON\
             -DENABLE_DIST:BOOL=ON\
             -DENABLE_BUNDLED_LIBYAML=ON\
             .) \
    && make -C /usr/src/tarantool -j\
    && make -C /usr/src/tarantool install \
    && make -C /usr/src/tarantool clean \
    && : "---------- small ----------" \
    && (cd /usr/src/tarantool/src/lib/small; \
        cmake -DCMAKE_INSTALL_PREFIX=/usr \
              -DCMAKE_INSTALL_LIBDIR=lib \
              -DCMAKE_BUILD_TYPE=RelWithDebInfo \
              .) \
    && make -C /usr/src/tarantool/src/lib/small \
    && make -C /usr/src/tarantool/src/lib/small install \
    && make -C /usr/src/tarantool/src/lib/small clean \
    && : "---------- msgpuck ----------" \
    && (cd /usr/src/tarantool/src/lib/msgpuck; \
        cmake -DCMAKE_INSTALL_PREFIX=/usr \
              -DCMAKE_INSTALL_LIBDIR=lib \
              -DCMAKE_BUILD_TYPE=RelWithDebInfo \
              .) \
    && make -C /usr/src/tarantool/src/lib/msgpuck \
    && make -C /usr/src/tarantool/src/lib/msgpuck install \
    && make -C /usr/src/tarantool/src/lib/msgpuck clean \
    && : "---------- remove build deps ----------" \
    && yum -y remove \
        perl \
        gcc-c++ \
        readline-devel \
        openssl-devel \
        libyaml-devel \
        lz4-devel \
        binutils-devel \
        ncurses-devel \
        lua-devel \
        libunwind-devel \
        autoconf \
        automake \
        libtool \
        wget \
        perl \
        curl-devel \
        libicu-devel \
    && rm -rf /var/cache/yum


 RUN set -x \
     && : "---------- cartridge cli ----------" \
    && (cd / && tarantoolctl rocks install cartridge-cli "$CARTRIDGE_CLI_VERSION-1") \
    && ln -s /.rocks/bin/cartridge /usr/bin/cartridge \
    && : "---------- cartridge ----------" \
    && (cd / && tarantoolctl rocks install cartridge "$CARTRIDGE_VERSION-1")


VOLUME /var/lib/tarantool
WORKDIR /opt/tarantool
