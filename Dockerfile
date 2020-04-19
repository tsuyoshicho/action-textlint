FROM node:current-alpine

ENV REVIEWDOG_VERSION=v0.9.17
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}
RUN apk --update add git && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*

COPY package.json /package.json
COPY package-lock.json /package-lock.json
COPY entrypoint.sh /entrypoint.sh

WORKDIR /

ENTRYPOINT ["/entrypoint.sh"]
