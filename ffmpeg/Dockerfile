FROM ubuntu:17.04

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        autoconf \
        automake \
        ca-certificates \
        clang \
        cmake \
        gcc \
        g++ \
        libtool \
        make \
        pkg-config \
        wget && \
    rm -rf /var/lib/apt/lists/*

ENV ROOT_DIR /app
ENV BIN_DIR "$ROOT_DIR/bin"
ENV BUILD_DIR "$ROOT_DIR/build"
ENV SRC_DIR "$ROOT_DIR/src"
ENV PATH="$BIN_DIR:$PATH"
ENV PKG_CONFIG_PATH "$BUILD_DIR/lib/pkgconfig"

RUN mkdir -p $SRC_DIR
WORKDIR $SRC_DIR

ARG CC=clang
ARG CXX=clang++
ARG CFLAGS=""
ARG CPPFLAGS=""
ARG NUM_PROC=1

ENV FFMPEG_VER 3.3
ENV LIBOGG_VER 1.3.2
ENV LIBVPX_VER 1.6.1
ENV LIBVORBIS_VER 1.3.5
ENV X265_VER 2.3
ENV YASM_VER 1.3.0

RUN wget -O yasm.tar.gz http://www.tortall.net/projects/yasm/releases/yasm-$YASM_VER.tar.gz && \
    tar xf yasm.tar.gz && \
    rm yasm.tar.gz && \
    cd yasm-$YASM_VER && \
    ./configure --prefix="$BUILD_DIR" --bindir="$BIN_DIR" && \
    make "-j$NUM_PROC" && \
    make install && \
    make distclean && \
    cd .. && \
    rm -rf yasm-$YASM_VER

RUN wget https://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2 && \
    tar xf last_x264.tar.bz2 && \
    rm last_x264.tar.bz2 && \
    cd x264-snapshot* && \
    ./configure \
        --prefix="$BUILD_DIR" \
        --bindir="$BIN_DIR" \
        --enable-static \
        --enable-pic \
        --disable-opencl && \
    make "-j$NUM_PROC" && \
    make install && \
    make distclean && \
    cd .. && \
    rm -rf x264-snapshot*

# TODO: should specidy build path on cmake instead of `ln -s ...`
RUN wget -O x265.tar.gz https://bitbucket.org/multicoreware/x265/get/$X265_VER.tar.gz && \
    tar xf x265.tar.gz && \
    rm x265.tar.gz && \
    cd multicoreware*/build/linux && \
    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$BUILD_DIR" -DENABLE_SHARED:bool=off ../../source && \
    make "-j$NUM_PROC" && \
    make install && \
    cd $ROOT_DIR && \
    ln -s ./build/bin/x265 ./bin/x265 && \
    cd $SRC_DIR && \
    rm -rf multicoreware*

RUN wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master && \
    tar xf fdk-aac.tar.gz && \
    rm fdk-aac.tar.gz && \
    cd mstorsjo-fdk-aac* && \
    autoreconf -fiv && \
    ./configure --prefix="$BUILD_DIR" --disable-shared && \
    make "-j$NUM_PROC" && \
    make install && \
    make distclean && \
    cd $SRC_DIR && \
    rm -rf mstorsjo-fdk-aac*

RUN wget -O lame.tar.gz http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz && \
    tar xf lame.tar.gz && \
    rm lame.tar.gz && \
    cd lame-3.99.5 && \
    ./configure --prefix="$BUILD_DIR" --enable-nasm --disable-shared && \
    make "-j$NUM_PROC" && \
    make install && \
    make distclean && \
    cd .. && \
    rm -rf lame-*

RUN wget -O libogg.tar.xz "http://downloads.xiph.org/releases/ogg/libogg-$LIBOGG_VER.tar.xz" && \
    tar xf libogg.tar.xz && \
    rm libogg.tar.xz && \
    cd libogg* && \
    ./configure --prefix="$BUILD_DIR" --disable-shared && \
    make "-j$NUM_PROC" && \
    make install && \
    make clean && \
    cd .. && \
    rm -rf libogg*

RUN wget -O libvpx.tar.bz2 "http://storage.googleapis.com/downloads.webmproject.org/releases/webm/libvpx-$LIBVPX_VER.tar.bz2" && \
    tar xf libvpx.tar.bz2 && \
    rm libvpx.tar.bz2 && \
    cd "libvpx-$LIBVPX_VER" && \
    ./configure --prefix="$BUILD_DIR" --disable-examples --disable-unit-tests && \
    make "-j$NUM_PROC" && \
    make install && \
    make clean && \
    cd .. && \
    rm -rf libvpx-*

RUN wget -O libvorbis.tar.xz "http://downloads.xiph.org/releases/vorbis/libvorbis-$LIBVORBIS_VER.tar.xz" && \
    tar xf libvorbis.tar.xz && \
    rm libvorbis.tar.xz && \
    cd libvorbis* && \
    ./configure --prefix="$BUILD_DIR" --disable-shared && \
    make "-j$NUM_PROC" && \
    make install && \
    make clean && \
    cd .. && \
    rm -rf libvorbis*

RUN wget -O ffmpeg.tar.bz2 https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VER.tar.bz2 && \
    tar xf ffmpeg.tar.bz2 && \
    rm ffmpeg.tar.bz2 && \
    cd ffmpeg* && \
    ./configure \
      --prefix="$BUILD_DIR" \
      --pkg-config-flags="--static" \
      --extra-cflags="-I$BUILD_DIR/include --static" \
      --extra-ldflags="-L$BUILD_DIR/lib -static" \
      --bindir="$BIN_DIR" \
      --cc="$CC" \
      --cxx="$CXX" \
      --disable-debug \
      --disable-ffserver \
      --disable-shared \
      --enable-static \
      --enable-gpl \
      --enable-libfdk-aac \
      --enable-libmp3lame \
      --enable-libvpx \
      --enable-libvorbis \
      --enable-libx264 \
      --enable-libx265 \
      --enable-nonfree && \
    make -j$NUM_PROC && \
    make install && \
    make distclean && \
    cd .. && \
    rm -rf ffmpeg*
