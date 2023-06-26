# apt-get update && apt-get install -y git
WORKER_TAG=$(git ls-remote --tags --refs https://github.com/our-story-media/ourstory-worker | grep -o 'refs/tags/v[0-9]*\.[0-9]*\.[0-9]*' | sort -r -V | head -n 1 | grep -o '[^\/]*$')
SERVER_TAG=$(git ls-remote --tags --refs https://github.com/our-story-media/ourstory-server | grep -o 'refs/tags/v[0-9]*\.[0-9]*\.[0-9]*' | sort -r -V | head -n 1 | grep -o '[^\/]*$')
# TAG="latest,$SERVER_TAG-$WORKER_TAG"
VERSION=$SERVER_TAG-$WORKER_TAG
# echo -n "latest,$SERVER_TAG-$WORKER_TAG" > .tags
# cat .tags
DOCKER_BUILDKIT=1

docker build --platform=linux/arm/v7 --build-arg TARGETPLATFORM=linux/arm/v7 -t bootlegger/titan-compact:latest -t bootlegger/titan-compact:$VERSION .

apt-get update && apt-get install -y awscli

echo $VERSION > indaba-update.version

echo "Saving to tar file"

docker save -o indaba-update.tar bootlegger/titan-compact:latest

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