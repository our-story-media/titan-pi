FROM node:14-stretch

WORKDIR /build

RUN npm config set unsafe-perm true && npm install -g pkg

COPY package.json .

RUN npm i --silent

COPY . .

RUN pkg indaba-supervisor.js --targets armv7