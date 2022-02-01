#!/bin/bash

echo "Working in $(pwd)"

if [ -d "pi-gen" ]; then
    echo "pi-gen already cloned"
else
    git clone https://github.com/RPi-Distro/pi-gen.git
    cd ./pi-gen && git checkout 2021-05-07-raspbian-buster && cd ..
fi

cp config ./pi-gen/config

cp -R ../supervisor ./pi-gen/stage2/01-sys-tweaks/files/supervisor

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

## DEBUG!
# touch ./pi-gen/stage2/01-sys-tweaks/files/indaba-update.tar
# echo "test-version" > VERSION

if [ -f "./pi-gen/stage2/01-sys-tweaks/files/indaba-update.tar" ]; then
  echo "tar already exists"
else
  echo "downloading docker tar file"
  curl -SL https://download.indaba.dev/indaba-update.version --output ./VERSION
  curl -SL https://download.indaba.dev/indaba-update.tar --output ./pi-gen/stage2/01-sys-tweaks/files/indaba-update.tar
fi

touch ./pi-gen/stage3/SKIP ./pi-gen/stage4/SKIP ./pi-gen/stage5/SKIP
touch ./pi-gen/stage4/SKIP_IMAGES ./pi-gen/stage5/SKIP_IMAGES

cd pi-gen

# docker-compose up -d

# Uncomment the following line to speed up building
# touch ./stage0/SKIP ./stage1/SKIP

set -e

DOCKER_BUILDKIT=1 CLEAN=1 CONTINUE=1 ./build-docker.sh

cd ..

# echo "${pwd}"

mkdir -p ./sdcard

VERSION=`cat ./VERSION`

FILENAME=indaba-rpi-$VERSION.zip

## DEBUG!
# mkdir -p ./pi-gen/deploy
# touch ./pi-gen/deploy/deploy.zip

echo "Copying file from deploy to sdcard"

cp $(ls -Art ./pi-gen/deploy/*.zip | tail -n 1) ./sdcard/$FILENAME