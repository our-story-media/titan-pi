FROM node:10-buster

ARG TARGETPLATFORM

RUN echo "BUILDING FOR $TARGETPLATFORM" && if [ "$TARGETPLATFORM" = "linux/arm/v7" ] ; then \
  wget --no-check-certificate https://andyfelong.com/downloads/mongodb_stretch_3_0_14_core.zip && wget --no-check-certificate https://andyfelong.com/downloads/mongodb_stretch_3_0_14_tools.zip && \
  unzip mongodb_stretch_3_0_14_core.zip && \
  unzip mongodb_stretch_3_0_14_tools.zip && \
  chmod 755 ./tools/* && \
  cp ./tools/* /usr/bin && \
  adduser --ingroup nogroup --shell /etc/false --disabled-password --gecos "" \
  --no-create-home mongodb && \
  cd core && \
  chown root:root mongo* && \
  chmod 755 mongo* && \
  strip mongo* && \
  cp -p mongo* /usr/bin && \
  cd .. && \
  rm -R core && \
  rm -R tools && \
  rm mongodb_stretch_3_0_14_tools.zip && \
  rm mongodb_stretch_3_0_14_core.zip ; \
  fi && \
  PACKAGES="" && \ 
  if [ ! "$TARGETPLATFORM" = "linux/arm/v7" ] ; then PACKAGES="mongodb" ; fi && \
  apt-get update -q && \
  apt-get install -q -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y nginx redis-server beanstalkd ffmpeg melt rsync xvfb $PACKAGES && \
  WORKER_TAG=$(git ls-remote --tags --refs https://github.com/our-story-media/ourstory-worker | grep -o 'refs/tags/v[0-9]*\.[0-9]*\.[0-9]*' | sort -r -V | head -n 1 | grep -o '[^\/]*$') && \
  SERVER_TAG=$(git ls-remote --tags --refs https://github.com/our-story-media/ourstory-server | grep -o 'refs/tags/v[0-9]*\.[0-9]*\.[0-9]*' | sort -r -V | head -n 1 | grep -o '[^\/]*$') && \
  git clone --branch $SERVER_TAG --depth=1 https://github.com/our-story-media/ourstory-server && git clone --branch $WORKER_TAG --depth=1 https://github.com/our-story-media/ourstory-worker

WORKDIR /ourstory-server

RUN npm install grunt-cli && \
  npm install --silent && \
  npm run buildgrunt && \
  mkdir -p ./upload/ && \
  rm -R ./assets/music/ && \
  rm ./Gruntfile.js && \
  rm -R ./tasks && \
  npm prune --production && \
  npm uninstall grunt-cli && \
  npm cache clean --force

WORKDIR /ourstory-worker

RUN npm i --silent && \
  mkdir ~/.fonts && cp -r ./fonts/* ~/.fonts && chmod -R 644 ~/.fonts && fc-cache && \
  mkdir -p /usr/src && \
  ln -s /ourstory-server /usr/src/app && \
  mkdir -p /etc/nginx/vhost.d && \
  rm /etc/nginx/sites-enabled/default && \
  ln -s /ourstory-server/docker/bootlegger.conf /etc/nginx/vhost.d/default && \
  ln -sb /ourstory-server/fallback/index.html /usr/share/nginx/html/index.html && \
  ln -s /ourstory-server/docker/server.local.conf /etc/nginx/conf.d/default.conf && \
  ln -s /ourstory-server/upload/ /ourstory-worker/ && \
  mkdir -p /data/db && \
  mkdir -p /redis && \
  mkdir -p /beanstlak &&

COPY "redirect.conf"  /etc/nginx/conf.d/redirect.conf

RUN sed -i '/resolver 127\.0\.0\.11 valid=30s;/d' /ourstory-server/docker/server.local.conf

RUN sed -i 's/set \$upstream http:\/\/web:1337;/set \$upstream http:\/\/127.0.0.1:1337;/' /ourstory-server/docker/server.local.conf

VOLUME /data/db

VOLUME /redis

VOLUME /beanstalk

COPY "entrypoint.sh" .

CMD [ "bash", "./entrypoint.sh" ]