FROM node:12-stretch

WORKDIR /build

# RUN apt-get update && apt-get install -y build-essential libssl-dev

# RUN wget https://github.com/yao-pkg/pkg-binaries/releases/download/node14/fetched-v14.4.0-linux-armv6 -O fetched-v14.17.6-linux-armv6

# RUN mkdir -p ~/.pkg-cache/v3.2 && mv fetched-v14.17.6-linux-armv6 ~/.pkg-cache/v3.2

RUN npm config set unsafe-perm true && npm install -g pkg@4.4.6

# COPY package.json .

# RUN npm i --silent

COPY . .

RUN mkdir -p /pkgcache/v2.6 && mv ./uploaded-v2.6-node-v12.2.0-linux-armv7 /pkgcache/v2.6/uploaded-v2.6-node-v12.18.1-linux-armv7

# COPY dummy.js /build/

# RUN node -v

# RUN pkg -d --targets "latest-linuxstatic-armv7" dummy.js

RUN PKG_CACHE_PATH=/pkgcache pkg -t "node12-linux-armv7" ./src/indaba-supervisor.js

# RUN pkg ./src/indaba-supervisor.js --targets "host"

# CMD cd src && pkg indaba-supervisor.js --targets "node14-linuxstatic-armv7"