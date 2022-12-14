FROM ubuntu:22.04
LABEL maintainer="Jochen Issing <c.333+github@nesono.com> (@jochenissing)"

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update &&  \
    apt-get install -y --no-install-recommends  \
    bash  \
    postfix  \
    postfix-mysql  \
    supervisor  \
    netcat  \
    && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -g 1000 vmail && \
    useradd -u 1000 -g 1000 vmail -d /srv/vmail && \
    passwd -l vmail && \
    mkdir /srv/mail && \
    chown vmail:vmail /srv/mail

EXPOSE 587
EXPOSE 25

VOLUME [ "/var/mail", "/var/spool/postfix", "/etc/postfix", "/etc/opendkim/keys" ]

COPY scripts/* /scripts/
COPY configs/* /etc/
RUN chmod +x /scripts/*

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD printf "EHLO healthcheck\n" | nc 127.0.0.1 587 | grep -qE "^220.*ESMTP Postfix"

CMD [ "/bin/bash", "-c", "/scripts/run.sh" ]