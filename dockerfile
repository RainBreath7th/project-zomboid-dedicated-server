FROM debian:13.3-slim

ARG LANG=en_US.UTF-8
ARG LC_ALL=en_US.UTF-8

ENV LANG=${LANG} \
    LC_ALL=${LC_ALL} \
    DEBIAN_FRONTEND="noninteractive"

WORKDIR /app

COPY entrypoint.sh /entrypoint.sh
COPY src/* /usr/local/bin/

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gosu \
        wget \
        lib32gcc-s1 \
        locales \
        dos2unix; \
    \
    sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen; \
    if [ "$LANG" != "en_US.UTF-8" ]; then \
        SAFE_LANG=$(echo $LANG | sed 's/\./\\./g'); \
        sed -i "s/^# *\($SAFE_LANG\)/\1/" /etc/locale.gen; \
    fi; \
    locale-gen; \
    \
    chmod +x /entrypoint.sh /usr/local/bin/*; \
    dos2unix /entrypoint.sh /usr/local/bin/*; \
    \
    mkdir -p /opt/steamcmd; \
    wget -qO- "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - -C /opt/steamcmd/; \
    \
    apt-get purge -y --auto-remove; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

EXPOSE 16261/udp
EXPOSE 16262/udp
EXPOSE 8766/udp
EXPOSE 8766/udp
EXPOSE 27015

VOLUME [ "/data" ]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["run.sh"]
