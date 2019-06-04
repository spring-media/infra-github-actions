FROM alpine:latest

LABEL "com.github.actions.name"="git Actions"
LABEL "com.github.actions.description"="Run git commands"
LABEL "com.github.actions.icon"="mic"
LABEL "com.github.actions.color"="yellow"

RUN apk add --no-cache git bash git-subtree jq curl unzip ca-certificates bc

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]