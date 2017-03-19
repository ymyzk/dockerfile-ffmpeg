#!/bin/bash
cd $(dirname $0)
set -ex

container_name=ffmpeg_copy
image_name=ymyzk/ffmpeg:sandybridge

docker build \
    --build-arg CFLAGS="$CFLAGS" \
    --build-arg CPPFLAGS="$CPPFLAGS" \
    --build-arg NUM_PROC=1 \
    -t $image_name .
docker run --name $container_name $image_name ls /app/bin/ffmpeg
docker cp $container_name:/app/bin/ffmpeg ./
docker rm $container_name
