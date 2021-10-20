#!/bin/bash
# DOCKER_BUILDKIT=1

echo "Building Indaba Supervisor ARM7"

# ,linux/amd64,linux/arm64, linux/arm/v7
docker build --platform linux/arm/v7 -t bootlegger/indaba-supervisor --load .
# docker buildx build --platform=linux/arm/v7 -t bootlegger/indaba-supervisor --load .

# docker run --mount type=bind,source="$(pwd)"/src,target=/build/src --name indaba-supervisor bootlegger/indaba-supervisor

docker run -it bootlegger/indaba-supervisor bash

# docker create --platform linux/arm/v7 -ti --name indaba-supervisor bootlegger/indaba-supervisor bash
# docker cp indaba-supervisor:/build/indaba-supervisor ./build/indaba-supervisor
# docker rm -f indaba-supervisor