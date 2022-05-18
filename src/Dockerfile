FROM python:3 as onboard-build

WORKDIR /usr/src/app
RUN git clone https://github.com/eduadiez/workshop.git 
WORKDIR /usr/src/app/workshop/tools/to_checksum_address
RUN python3 setup.py install && \
    pip3 install pyinstaller && \
    pyinstaller --noconfirm --clean to_checksum_address.spec
WORKDIR /usr/src/app/workshop/tools/onboarder 
RUN python3 setup.py install && \
    pip3 install pyinstaller && \
    pyinstaller --noconfirm --clean onboarder.spec

FROM alpine:latest

ENV LANG en_US.UTF-8
ENV RAIDEN_VERSION 0.100.3
ENV RAIDEN_ACCEPT_DISCLAIMER=True
ENV RAIDEN_ENVIRONMENT_TYPE=development
ENV RAIDEN_API_ADDRESS=0.0.0.0:80

COPY --from=onboard-build /usr/src/app/workshop/tools/onboarder/dist/onboarder /usr/bin/onboarder
COPY --from=onboard-build /usr/src/app/workshop/tools/to_checksum_address/dist/to_checksum_address /usr/bin/to_checksum_address

RUN apk update && apk add --no-cache wget bash

RUN wget https://github.com/raiden-network/raiden/releases/download/v${RAIDEN_VERSION}/raiden-v${RAIDEN_VERSION}-linux-x86_64.tar.gz \
    -qO- | tar -C /usr/bin -xzvf -
RUN mv /usr/bin/raiden-v${RAIDEN_VERSION}-linux-x86_64 /usr/bin/raiden

ARG ALPINE_GLIBC_PACKAGE_VERSION="2.29-r0"
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    wget \
        "https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub" \
        -O "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

RUN mkdir -p /home/.raiden
WORKDIR /root/.raiden

COPY init.sh /usr/bin
CMD ["init.sh"]
