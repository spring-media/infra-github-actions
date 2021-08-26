# https://hub.docker.com/_/alpine
FROM spring-docker.jfrog.io/alpine:latest

RUN apk update
RUN apk --no-cache add curl
RUN apk add jq

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]
