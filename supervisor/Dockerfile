FROM node:14-stretch

WORKDIR /build

# RUN apt-get update && apt-get install -y build-essential libssl-dev

# RUN wget https://github.com/yao-pkg/pkg-binaries/releases/download/node14/fetched-v14.4.0-linux-armv6 -O fetched-v14.17.6-linux-armv6

# RUN mkdir -p ~/.pkg-cache/v3.2 && mv fetched-v14.17.6-linux-armv6 ~/.pkg-cache/v3.2

RUN npm config set unsafe-perm true && npm install -g pkg

COPY package.json .

RUN npm i --silent

COPY . .

# COPY dummy.js /build/

# RUN node -v

# RUN pkg -d --targets "latest-linuxstatic-armv7" dummy.js

# RUN pkg -t node14-linux-armv7 dummy.js

RUN pkg ./src/indaba-supervisor.js --targets "node14-linux-armv6"

# CMD cd src && pkg indaba-supervisor.js --targets "node14-linuxstatic-armv7"