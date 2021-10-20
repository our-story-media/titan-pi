FROM node:12-stretch

WORKDIR /build

RUN npm config set unsafe-perm true && npm install -g pkg

COPY package.json .

RUN npm i --silent

COPY . .

# COPY dummy.js /build/

# RUN node -v

# RUN pkg -d --targets "latest-linuxstatic-armv7" dummy.js

# RUN pkg -t node14-linux-armv7 dummy.js

RUN pkg ./src/indaba-supervisor.js --targets "node12-linuxstatic-armv7"

# CMD cd src && pkg indaba-supervisor.js --targets "node14-linuxstatic-armv7"