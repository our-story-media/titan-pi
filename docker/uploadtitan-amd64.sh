#!/bin/bash

echo "Downloading latest tagged version"

docker pull redis:alpine
docker pull mvertes/alpine-mongo
docker pull kusmierz/beanstalkd
docker pull bootlegger/ourstory-worker:v1.1.13
docker pull bootlegger/ourstory-server:v1.2.29
docker pull bootlegger/nginx-local:latest

# force latest tag, so that it will be loaded properly in the client
docker tag bootlegger/ourstory-server:v1.2.29 bootlegger/ourstory-server:latest 

docker tag bootlegger/ourstory-worker:v1.1.13 bootlegger/ourstory-worker:latest t

# echo "Exporting Images"
docker save redis:alpine mvertes/alpine-mongo kusmierz/beanstalkd bootlegger/nginx-local:latest bootlegger/ourstory-worker:latest bootlegger/ourstory-server:latest -o images.tar

echo "Get Versions"

VERSION=$(docker run bootlegger/ourstory-server:latest cat /usr/src/app/package.json | grep version | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | tr -d '[[:space:]]' && echo "" && docker run bootlegger/ourstory-worker:latest cat /usr/src/app/package.json | grep version | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | tr -d '[[:space:]]')

VERSION="v"$(echo $VERSION | sed 's/ /-v/g')

if [[ -z "$VERSION" ]]; then
    echo "NO VERSION FOUND"

    exit 1
fi

echo "Version is $VERSION"

echo $VERSION > indaba-stack.version

echo "Upload to S3"

FILENAME=indaba-stack-amd64-$VERSION.tar

mv images.tar $FILENAME

echo "Uploading $FILENAME"

aws s3 cp $FILENAME s3://ourstory-v2-live/titan/

echo "Uploading Version"

aws s3 cp indaba-stack.version s3://ourstory-v2-live/titan/

echo "Copy to images.tar"

aws s3 cp s3://ourstory-v2-live/titan/$FILENAME s3://ourstory-v2-live/titan/images.tar