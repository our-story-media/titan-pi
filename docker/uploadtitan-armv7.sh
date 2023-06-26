#!/bin/bash

DOCKER_BUILDKIT=1

echo "Downloading latest tagged version"

docker pull --platform linux/arm/v7 bootlegger/titan-compact:latest

echo "Saving to tar file"

docker save -o indaba-update.tar bootlegger/titan-compact:latest

echo "Get Versions"

VERSION=$(docker run bootlegger/titan-compact:latest bash -c 'cd /ourstory-server && git describe --abbrev=0 && cd /ourstory-worker && git describe --abbrev=0')

VERSION=$(echo $VERSION | sed 's/ /-/g')

if [[ -z "$VERSION" ]]; then
    echo "NO VERSION FOUND"

    exit 1
fi

echo "Version is $VERSION"

echo $VERSION > indaba-update.version

echo "Upload to S3"

FILENAME=indaba-update-armv7-$VERSION.tar

echo "Renaming to $FILENAME"

mv indaba-update.tar $FILENAME

echo "Uploading $FILENAME"

aws s3 cp $FILENAME s3://ourstory-v2-live/titan/

echo "Uploading Version"

aws s3 cp indaba-update.version s3://ourstory-v2-live/titan/

echo "Copy to indaba-update.tar"

aws s3 cp s3://ourstory-v2-live/titan/$FILENAME s3://ourstory-v2-live/titan/indaba-update.tar