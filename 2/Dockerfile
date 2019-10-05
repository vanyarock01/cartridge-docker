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


ENV TARANTOOL_VERSION 2.3.0
ENV CARTRIDGE_VERSION 1.1.0
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

RUN set -x \
    && : "---------- gosu ----------" \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys \
       B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL \
       "https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL \
       "https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64.asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && rm -rf /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu

RUN mkdir /opt/cartridge-init
COPY init.lua /opt/cartridge-init
COPY cartridge-init-scm-1.rockspec /opt/cartridge-init
COPY docker-entrypoint.sh /usr/local/bin/

RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

RUN mkdir -p /var/lib/tarantool \
    && chown tarantool:tarantool /var/lib/tarantool \
    && mkdir -p /opt/tarantool \
    && mkdir -p /var/run/tarantool \
    && chown tarantool:tarantool /var/run/tarantool


VOLUME /var/lib/tarantool
WORKDIR /opt/tarantool

ENV TARANTOOL_WORK_DIR=/var/lib/tarantool \
    TARANTOOL_WORKDIR=/var/lib/tarantool

CMD [ "tarantool", "/opt/tarantool/init.lua" ]
