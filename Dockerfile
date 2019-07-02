FROM haproxy:alpine

LABEL maintainer="Nick Vissari <@nickadam>"

RUN apk update && apk add openssl dumb-init bash

COPY . /

ENTRYPOINT ["dumb-init", "/docker-entrypoint.sh"]
