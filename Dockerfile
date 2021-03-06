FROM ubuntu:18.04

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        autoconf \
        automake \
        ca-certificates \
        clang \
        cmake \
        gcc \
        git \
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

ENV NASM_VER 2.13.03
RUN wget -O nasm.tar.gz http://www.nasm.us/pub/nasm/releasebuilds/$NASM_VER/nasm-$NASM_VER.tar.xz && \
    tar xf nasm.tar.gz && \
    rm nasm.tar.gz && \
    cd nasm* && \
    ./configure --prefix="$BUILD_DIR" --bindir="$BIN_DIR" && \
    make "-j$NUM_PROC" && \
    make install && \
    make distclean && \
    cd .. && \
    rm -rf nasm*

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

ENV FDK_AAC_VER e45ae429b9ca8f234eb861338a75b2d89cde206a
RUN git clone https://github.com/mstorsjo/fdk-aac.git && \
    cd fdk-aac && \
    git checkout $FDK_AAC_VER && \
    pwd && \
    ls && \
    autoreconf -fiv && \
    ./configure --prefix="$BUILD_DIR" --disable-shared --with-pic=yes && \
    make "-j$NUM_PROC" && \
    make install && \
    make distclean && \
    cd $SRC_DIR && \
    rm -rf fdk-aac

ENV LAME_VER 3.100
RUN wget -O lame.tar.gz http://downloads.sourceforge.net/project/lame/lame/$(echo -n $LAME_VER | sed -e "s/\.[0-9]\+//2")/lame-$LAME_VER.tar.gz && \
    tar xf lame.tar.gz && \
    rm lame.tar.gz && \
    cd lame-* && \
    ./configure --prefix="$BUILD_DIR" --enable-nasm --with-pic=yes --disable-shared && \
    make "-j$NUM_PROC" && \
    make install && \
    make distclean && \
    cd .. && \
    rm -rf lame-*

ENV LIBOGG_VER 1.3.3
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

ENV LIBVORBIS_VER 1.3.6
RUN wget -O libvorbis.tar.xz "http://downloads.xiph.org/releases/vorbis/libvorbis-$LIBVORBIS_VER.tar.xz" && \
    tar xf libvorbis.tar.xz && \
    rm libvorbis.tar.xz && \
    cd libvorbis* && \
    ./configure --prefix="$BUILD_DIR" --disable-shared --with-pic=yes && \
    make "-j$NUM_PROC" && \
    make install && \
    make clean && \
    cd .. && \
    rm -rf libvorbis*

ENV LIBVPX_VER 1.7.0
RUN wget -O libvpx.tar.gz "https://github.com/webmproject/libvpx/archive/v$LIBVPX_VER.tar.gz" && \
    tar xf libvpx.tar.gz && \
    rm libvpx.tar.gz && \
    cd "libvpx-$LIBVPX_VER" && \
    ./configure --prefix="$BUILD_DIR" --disable-examples --disable-unit-tests && \
    make "-j$NUM_PROC" && \
    make install && \
    make clean && \
    cd .. && \
    rm -rf libvpx-*

ENV X265_VER 2.9
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

ENV X264_VER 20180926-2245
RUN wget -O x264.tar.bz2 https://download.videolan.org/pub/x264/snapshots/x264-snapshot-$X264_VER.tar.bz2 && \
    tar xf x264.tar.bz2 && \
    rm x264.tar.bz2 && \
    cd x264* && \
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
    rm -rf x264*

ENV NV_CODEC_VER d098cb44f6103a03476d16ac2bbe14ecbc9e1175
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git && \
    cd nv-codec-headers && \
    git checkout $NV_CODEC_VER && \
    PREFIX="$BUILD_DIR" make install

ENV FFMPEG_VER 4.0.2
RUN wget -O ffmpeg.tar.bz2 https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VER.tar.bz2 && \
    tar xf ffmpeg.tar.bz2 && \
    rm ffmpeg.tar.bz2 && \
    cd ffmpeg* && \
    ./configure \
      --prefix="$BUILD_DIR" \
      --pkg-config-flags="--static" \
      --extra-cflags="-I$BUILD_DIR/include" \
      --extra-ldflags="-L$BUILD_DIR/lib" \
      --extra-ldexeflags="-Bstatic" \
      # TODO: https://bitbucket.org/multicoreware/x265/issues/371
      --extra-libs=-lpthread \
      --bindir="$BIN_DIR" \
      --cc="$CC" \
      --cxx="$CXX" \
      --disable-debug \
      --disable-shared \
      --enable-pic \
      --enable-static \
      --enable-gpl \
      --enable-libfdk-aac \
      --enable-libmp3lame \
      --enable-libvpx \
      --enable-libvorbis \
      --enable-libx264 \
      --enable-libx265 \
      --enable-nvenc \
      --enable-nonfree && \
    make -j$NUM_PROC && \
    make install && \
    make distclean && \
    cd .. && \
    rm -rf ffmpeg*
      # Temporary for nvenc
      # --extra-cflags="-I$BUILD_DIR/include --static" \
      # --extra-ldflags="-L$BUILD_DIR/lib -static" \
