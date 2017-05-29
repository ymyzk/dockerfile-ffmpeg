#!/bin/bash
cd $(dirname $0)
set -e

container_name=ffmpeg_copy
image_name=ymyzk/ffmpeg

if [ -z ${NUM_PROC+x} ]; then
  echo '$NUM_PROC is unset, using default value: 2'
  NUM_PROC=2
fi

set -x
docker build \
    --build-arg CFLAGS="$CFLAGS" \
    --build-arg CPPFLAGS="$CPPFLAGS" \
    --build-arg NUM_PROC="$NUM_PROC" \
    -t $image_name .
docker run --name $container_name $image_name ls /app/bin/ffmpeg
docker cp $container_name:/app/bin/ffmpeg ./
docker rm $container_name
