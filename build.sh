#!/bin/bash
cd $(dirname $0)
set -e

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
container=$(docker create $image_name)
docker cp $container:/app/bin/ffmpeg ./
docker rm $container
