ARG PG_VERSION=13.2
ARG PG_MAJOR=14
ARG PATRONI=v2.1.0
ARG PGHOME=/home/postgres
ARG PGDATA=/var/data
ARG LC_ALL=C.UTF-8
ARG LANG=C.UTF-8
ARG PGDIRS="/var/data /var/log/postgres /home/postgres/.postgresql /home/postgres/.config/patroni"
ARG COMPRESS=true

FROM konotop-pc.l.postgrespro.ru:5000/ubuntu:20.04

ENV PG_MAJOR=14

RUN set -ex \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -y && apt-get install -y gnupg curl \
    && printf "APT::Install-Recommends '0';\nAPT::Install-Suggests '0';" > /etc/apt/apt.conf.d/01norecommend \
    && printf "deb [arch=amd64] http://localrepo.l.postgrespro.ru/dev/pgprosm-14/ubuntu/ focal main" > /etc/apt/sources.list.d/shardman.list \
    && curl -fsSL http://localrepo.l.postgrespro.ru/keys/postgrespro/GPG-KEY-POSTGRESPRO | apt-key add - \
    && apt-get update -y \
    && apt-get install -y postgrespro-sdm-${PG_MAJOR}-server postgrespro-sdm-${PG_MAJOR}-contrib postgrespro-sdm-${PG_MAJOR}-client postgrespro-sdm-${PG_MAJOR}-libs \
        shardman-services shardman-tools stolon-sdm \
        systemd-sysv libicu66 libldap-2.4-2 libpam0g libssl1.1 libxml2 tzdata \
    	  ssl-cert locales dbus-x11 less make libipc-run-perl \
	      libreadline8 pkg-config zlib1g git less openssh-client tar iproute2 \
    && systemctl enable shardman-bowl@cluster0 \
    && mkdir -p /etc/systemd/system/systemd-logind.service.d

COPY ./override.conf /etc/systemd/system/systemd-logind.service.d/override.conf
COPY ./bowl-cluster0.env /var/lib/pgpro/sdm-14/data/bowl-cluster0.env
COPY ./spec.json /var/lib/pgpro/sdm-14/data/spec.json
ENV PATH "/opt/pgpro/sdm-$PG_MAJOR/bin:${PATH}"

EXPOSE 5432
EXPOSE 5433
EXPOSE 5442
EXPOSE 5443
EXPOSE 8080
# USER postgres

# ENTRYPOINT ["/bin/sh","/entrypoint.sh"]
CMD ["/sbin/init"]

