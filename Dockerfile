FROM node:lts as build

RUN apt-get update \
  && apt-get install -y build-essential python perl-modules

RUN deluser --remove-home node \
  && useradd --gid 0 --uid 1000 --shell /bin/bash --create-home nodered

USER 1000

RUN mkdir -p /data

WORKDIR /data

COPY ./package.json /data/
RUN npm install

## Release image
FROM node:lts-slim

RUN apt-get update && apt-get install -y perl-modules && rm -rf /var/lib/apt/lists/*

RUN deluser --remove-home node \
  && useradd --gid 0 --uid 1000 --shell /bin/bash --create-home nodered

USER 1000

RUN mkdir -p /data

COPY ./server.js /data/
COPY ./settings.js /data/
COPY ./flows.json /data/
COPY ./flows_cred.json /data/
COPY ./package.json /data/
COPY --from=build /data/node_modules /data/node_modules

USER 0

RUN chgrp -R 0 /data \
  && chmod -R g=u /data

USER 1000

WORKDIR /data

ENV PORT 1880
ENV NODE_ENV=production
ENV NODE_PATH=/data/node_modules
EXPOSE 1880

CMD ["node", "/data/server.js", "/data/flows.json"]
