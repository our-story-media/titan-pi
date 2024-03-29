#!/bin/bash

VERSION=`cat ./VERSION`

FILENAME=indaba-rpi-$VERSION.zip

echo $VERSION > indaba-rpi.version

curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"

export PATH=~/bin:$PATH

aws s3 cp ./sdcard/$FILENAME s3://ourstory-v2-live/titan/

aws s3 cp s3://ourstory-v2-live/titan/$FILENAME s3://ourstory-v2-live/titan/indaba-rpi.zip

echo "Uploading Version"

aws s3 cp indaba-rpi.version s3://ourstory-v2-live/titan/