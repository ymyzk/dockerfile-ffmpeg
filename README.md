# Dockerfile for building ffmpeg
Dockerfile for building statically linked ffmpeg

## How to use?
Run `./build.sh`

### Advanced
```console
$ CFLAGS='-march=sandybridge -mtune=sandybridge' \
  CPPFLAGS='-march=sandybridge -mtune=sandybridge' \
  NUM_PROC=2 \
  ./build.sh
```
