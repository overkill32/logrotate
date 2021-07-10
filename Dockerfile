FROM alpine
MAINTAINER overkill32@protonmail.com

# logrotate version (e.g. 3.9.1-r0)
ARG LOGROTATE_VERSION=latest
# permissions
ARG CONTAINER_UID=1000
ARG CONTAINER_GID=1000

# install dev tools
RUN export CONTAINER_USER=logrotate && \
    export CONTAINER_GROUP=logrotate && \
    addgroup -g $CONTAINER_GID logrotate && \
    adduser -u $CONTAINER_UID -G logrotate -h /usr/bin/logrotate.d -s /bin/bash -S logrotate && \
    apk add --update \
      tar \
      bash \
      su-exec \
      tini \
      curl \
      gzip \
      tzdata && \
    if  [ "${LOGROTATE_VERSION}" = "latest" ]; \
      then apk add logrotate ; \
      else apk add "logrotate=${LOGROTATE_VERSION}" ; \
    fi && \
    mkdir -p /usr/bin/logrotate.d && \
    rm -rf /var/cache/apk/* && rm -rf /tmp/*

# environment variable for this container
ENV LOGROTATE_OLDDIR= \
    LOGROTATE_COMPRESSION= \
    LOGROTATE_INTERVAL= \
    LOGROTATE_COPIES= \
    LOGROTATE_SIZE= \
    LOGS_DIRECTORIES= \
    LOG_FILE_ENDINGS= \
    LOGROTATE_LOGFILE= \
    LOGROTATE_CRONSCHEDULE= \
    LOGROTATE_PARAMETERS= \
    LOGROTATE_STATUSFILE= \
    LOG_FILE=

COPY docker-entrypoint.sh /usr/bin/logrotate.d/docker-entrypoint.sh
COPY update-logrotate.sh /usr/bin/logrotate.d/update-logrotate.sh
COPY logrotate.sh /usr/bin/logrotate.d/logrotate.sh
COPY logrotateConf.sh /usr/bin/logrotate.d/logrotateConf.sh
COPY logrotate.conf /logrotate-status/logrotate.conf
COPY logrotateCreateConf.sh /usr/bin/logrotate.d/logrotateCreateConf.sh
COPY logrotate.cron /etc/periodic/daily/logrotate

ENTRYPOINT ["/sbin/tini","--","/usr/bin/logrotate.d/docker-entrypoint.sh"]
VOLUME ["/logrotate-status"]
CMD ["cron"]
