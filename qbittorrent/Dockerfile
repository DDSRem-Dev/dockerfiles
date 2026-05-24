# ARG LIBTORRENT_VERSION=2
# FROM nevinee/libtorrent-rasterbar:${LIBTORRENT_VERSION} AS builder
FROM alpine AS builder
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk upgrade \
    && apk add --no-cache \
       boost-dev \
       cmake \
       curl \
       g++ \
       libtorrent-rasterbar-dev \
       openssl-dev \
       patch \
       qt6-qtbase-dev \
       qt6-qtbase-private-dev \
       qt6-qttools-dev \
       samurai \
       tar \
       zlib-dev \
    && rm -rf /tmp/* /var/cache/apk/*
ARG QBITTORRENT_VERSION
ARG NPROC=1
RUN mkdir -p /tmp/qbittorrent \
    && cd /tmp/qbittorrent \
    && curl -sSL https://github.com/qbittorrent/qBittorrent/archive/refs/tags/release-${QBITTORRENT_VERSION}.tar.gz | tar xz --strip-components 1 \
    && cmake \
       -D CMAKE_BUILD_TYPE=Release \
       -D GUI=OFF \
       -D WEBUI=ON \
       -D STACKTRACE=OFF \
       -B release \
       -G Ninja \
    && cmake --build release -j $NPROC \
    && cmake --install release \
    && ls -al /usr/local/bin/ \
    && qbittorrent-nox --help
RUN echo "Copy to /out" \
    && strip /usr/local/bin/qbittorrent-nox \
    && mkdir -p /out/usr/bin \
    && cp /usr/local/bin/qbittorrent-nox /out/usr/bin

FROM alpine:latest AS app
ENV QBT_PROFILE=/home/qbittorrent \
    TZ=Asia/Shanghai \
    PUID=1000 \
    PGID=100 \
    WEBUI_PORT=8080 \
    BT_PORT=34567 \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ "
RUN apk upgrade \
    && apk add --no-cache \
       bash \
       busybox-suid \
       curl \
       jq \
       libtorrent-rasterbar \
       openssl \
       qt6-qtbase \
       qt6-qtbase-sqlite \
       shadow \
       su-exec \
       tini \
       tzdata \
    && rm -rf /tmp/* /var/cache/apk/* \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && useradd qbittorrent -u ${PUID} -U -m -d ${QBT_PROFILE} -s /sbin/nologin \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
COPY --from=builder /out /
COPY root /
WORKDIR /data
VOLUME ["/data"]
ENTRYPOINT ["tini", "-g", "--", "entrypoint.sh"]
