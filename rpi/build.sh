#!/bin/bash

echo "Working in $(pwd)"

if [ -d "pi-gen" ]; then
    echo "pi-gen already cloned"
else
    git clone https://github.com/RPi-Distro/pi-gen.git
fi

cp config ./pi-gen/config

cp ../supervisor/build/indaba-supervisor ./pi-gen/stage2/01-sys-tweaks/files

cp ../gettitan ./pi-gen/stage2/01-sys-tweaks/files

cp splash.png ./pi-gen/stage2/01-sys-tweaks/files

cp indaba.service ./pi-gen/stage2/01-sys-tweaks/files

cp indaba-supervisor.service ./pi-gen/stage2/01-sys-tweaks/files

cp splash.service ./pi-gen/stage2/01-sys-tweaks/files

cp 02-run.sh ./pi-gen/stage2/01-sys-tweaks/

chmod +x ./pi-gen/stage2/01-sys-tweaks/02-run.sh

rm ./pi-gen/stage2/EXPORT_NOOBS

# touch ./pi-gen/stage0/SKIP 
# touch ./pi-gen/stage1/SKIP

# rm ./pi-gen/stage0/SKIP
# rm ./pi-gen/stage1/SKIP

if [ -f "./pi-gen/stage2/01-sys-tweaks/files/indaba-update.tar" ]; then
  echo "tar already exists"
else
  echo "downloading docker tar file"
  curl -sSL https://d2co3wsaqlrb1k.cloudfront.net/indaba-update.version --output ./VERSION
  # curl -sSL https://d2co3wsaqlrb1k.cloudfront.net/indaba-update.tar --output ./pi-gen/stage2/01-sys-tweaks/files/indaba-update.tar
fi

touch ./pi-gen/stage3/SKIP ./pi-gen/stage4/SKIP ./pi-gen/stage5/SKIP
touch ./pi-gen/stage4/SKIP_IMAGES ./pi-gen/stage5/SKIP_IMAGES

# cd pi-gen
# docker-compose up -d

# Uncomment the following line to speed up building
# touch ./stage0/SKIP ./stage1/SKIP

# FOR DEBUG:
# DOCKER_BUILDKIT=1 CLEAN=1 CONTINUE=1 ./build-docker.sh

mkdir -p ./sdcard

mkdir -p ./pi-gen/deploy

VERSION=`cat ./VERSION`

FILENAME=indaba-rpi-$VERSION.zip

#for debug
touch ./pi-gen/deploy/deploy.zip

cp $(ls -Art ./pi-gen/deploy/*.zip | tail -n 1) ./sdcard/$FILENAME

curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
export PATH=~/bin:$PATH

aws s3 cp ./pi-gen/deploy/deploy.zip s3://ourstory-v2-live/titan/
aws s3 cp s3://ourstory-v2-live/titan/$FILENAME s3://ourstory-v2-live/titan/indaba-rpi.zip

# sleep 1

# echo "Final file is located at " `ls -Art ./deploy/*.zip | tail -n 1`