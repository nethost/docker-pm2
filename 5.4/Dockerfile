FROM alpine:3.21 AS latest
LABEL maintainer="hi@billgo.me"

RUN apk add -U bash nano tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && apk del tzdata

ENV NODE_VERSION=22.12.0

RUN addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node \
    && apk add --no-cache \
        libstdc++ \
    && apk add --no-cache --virtual .build-deps \
        curl \
    && ARCH= OPENSSL_ARCH='linux*' && alpineArch="$(apk --print-arch)" \
      && case "${alpineArch##*-}" in \
        x86_64) ARCH='x64' CHECKSUM="43532120bad06cdea17c2ffba81ebfcff4611532a3569ef996faa39aadcbc759" OPENSSL_ARCH=linux-x86_64;; \
        x86) OPENSSL_ARCH=linux-elf;; \
        aarch64) OPENSSL_ARCH=linux-aarch64;; \
        arm*) OPENSSL_ARCH=linux-armv4;; \
        ppc64le) OPENSSL_ARCH=linux-ppc64le;; \
        s390x) OPENSSL_ARCH=linux-s390x;; \
        *) ;; \
      esac \
  && if [ -n "${CHECKSUM}" ]; then \
    set -eu; \
    curl -fsSLO --compressed "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz"; \
    echo "$CHECKSUM  node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" | sha256sum -c - \
      && tar -xJf "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
      && ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
  else \
    echo "Building from source" \
    # backup build
    && apk add --no-cache --virtual .build-deps-full \
        binutils-gold \
        g++ \
        gcc \
        gnupg \
        libgcc \
        linux-headers \
        make \
        python3 \
        py-setuptools \
    # use pre-existing gpg directory, see https://github.com/nodejs/docker-node/pull/1895#issuecomment-1550389150
    && export GNUPGHOME="$(mktemp -d)" \
    # gpg keys listed at https://github.com/nodejs/node#release-keys
    && for key in \
      C0D6248439F1D5604AAFFB4021D900FFDB233756 \
      DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
      CC68F5A3106FF448322E48ED27F5E38D5B0A215F \
      8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
      890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
      C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
      108F52B48DB57BB0CC439B2997B01419BD92F80A \
      A363A499291CBBC940DD62E41F10027AF002F8B0 \
    ; do \
      gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
      gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
    done \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xf "node-v$NODE_VERSION.tar.xz" \
    && cd "node-v$NODE_VERSION" \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) V= \
    && make install \
    && apk del .build-deps-full \
    && cd .. \
    && rm -Rf "node-v$NODE_VERSION" \
    && rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt; \
  fi \
  && rm -f "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" \
  # Remove unused OpenSSL headers to save ~34MB. See this NodeJS issue: https://github.com/nodejs/node/issues/46451
  && find /usr/local/include/node/openssl/archs -mindepth 1 -maxdepth 1 ! -name "$OPENSSL_ARCH" -exec rm -rf {} \; \
  && apk del .build-deps \
  # smoke tests
  && npm install pm2@5.4.1 -g \
  && node --version \
  && npm --version

# https://github.com/sgerrand/alpine-pkg-glibc/releases
ARG GLIBC_VERSION=2.34-r0

# https://github.com/oven-sh/bun/issues/5545#issuecomment-1722461083
ARG GLIBC_VERSION_AARCH64=2.26-r1

RUN apk --no-cache add \
    ca-certificates \
    curl \
    wget \
    dirmngr \
    gpg \
    gpg-agent \
    unzip \
    && arch="$(apk --print-arch)" \
    && case "${arch##*-}" in \
    x86_64) curl "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" \
    -fsSLO \
    --compressed \
    --retry 5 \
    || (echo "error: failed to download: glibc v${GLIBC_VERSION}" && exit 1) \
    && mv "glibc-${GLIBC_VERSION}.apk" glibc.apk && apk --force-overwrite --allow-untrusted add glibc.apk \
    && curl "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" \
    -fsSLO \
    --compressed \
    --retry 5 \
    || (echo "error: failed to download: glibc-bin v${GLIBC_VERSION}" && exit 1) \
    && mv "glibc-bin-${GLIBC_VERSION}.apk" glibc-bin.apk && apk --force-overwrite --allow-untrusted add glibc-bin.apk ;; \
    aarch64) curl "https://raw.githubusercontent.com/squishyu/alpine-pkg-glibc-aarch64-bin/master/glibc-${GLIBC_VERSION_AARCH64}.apk" \
    -fsSLO \
    --compressed \
    --retry 5 \
    || (echo "error: failed to download: glibc v${GLIBC_VERSION_AARCH64}" && exit 1) \
    && mv "glibc-${GLIBC_VERSION_AARCH64}.apk" glibc.apk && apk --force-overwrite --allow-untrusted add glibc.apk \
    && curl "https://raw.githubusercontent.com/squishyu/alpine-pkg-glibc-aarch64-bin/master/glibc-bin-${GLIBC_VERSION_AARCH64}.apk" \
    -fsSLO \
    --compressed \
    --retry 5 \
    || (echo "error: failed to download: glibc-bin v${GLIBC_VERSION_AARCH64}" && exit 1) \
    && mv "glibc-bin-${GLIBC_VERSION_AARCH64}.apk" glibc-bin.apk && apk --force-overwrite --allow-untrusted add glibc-bin.apk ;; \
    *) echo "error: unsupported architecture '$arch'"; exit 1 ;; \
    esac

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD [ "node" ]
