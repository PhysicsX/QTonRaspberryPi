FROM ubuntu:24.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install some necessary packages
RUN { \
    set -e && \
    apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    make \
    cmake \
    rsync \
    sed \
    libclang-dev \
    ninja-build \
    gcc \
    bison \
    python3 \
    gperf \
    pkg-config \
    libfontconfig1-dev \
    libfreetype6-dev \
    libx11-dev \
    libx11-xcb-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxrender-dev \
    libxcb1-dev \
    libxcb-glx0-dev \
    libxcb-keysyms1-dev \
    libxcb-image0-dev \
    libxcb-shm0-dev \
    libxcb-icccm4-dev \
    libxcb-sync-dev \
    libxcb-xfixes0-dev \
    libxcb-shape0-dev \
    libxcb-randr0-dev \
    libxcb-render-util0-dev \
    libxcb-util-dev \
    libxcb-xinerama0-dev \
    libxcb-xkb-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libatspi2.0-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    freeglut3-dev \
    libssl-dev \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    flex \
    gawk \
    texinfo \
    libisl-dev \
    zlib1g-dev \
    libtool \
    autoconf \
    automake \
    libgdbm-dev \
    libdb-dev \
    libbz2-dev \
    libreadline-dev \
    libexpat1-dev \
    liblzma-dev \
    libffi-dev \
    libsqlite3-dev \
    libbsd-dev \
    perl \
    patch \
    m4 \
    libncurses5-dev \
    gettext && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*; \
} 2>&1 | tee -a /build.log

# Set the working directory to /build
WORKDIR /build

# Create a directory for the tools and change into it
RUN mkdir crossTools && cd crossTools 2>&1 | tee -a /build.log

# Download the necessary tar files
# check version on raspberry pi - according to version build process can vary
# gcc --version gcc version
# ld --version binutils version
# ldd --version glibc version
RUN cd crossTools && \
    wget https://mirror.lyrahosting.com/gnu/binutils/binutils-2.40.tar.gz && \
    wget https://ftp.nluug.nl/pub/gnu/glibc/glibc-2.36.tar.gz && \
    wget https://ftp.nluug.nl/pub/gnu/gcc/gcc-12.2.0/gcc-12.2.0.tar.gz && \
    git clone --depth=1 https://github.com/raspberrypi/linux 2>&1 | tee -a /build.log


# Extract the tar files
RUN cd crossTools && \
    tar xf binutils-2.40.tar.gz && \
    tar xf glibc-2.36.tar.gz && \
    tar xf gcc-12.2.0.tar.gz 2>&1 | tee -a /build.log

RUN mkdir -p /opt/cross-pi-gcc 2>&1 | tee -a /build.log

# Set the PATH environment variable
ENV PATH=/opt/cross-pi-gcc/bin:$PATH

# Compile toolchain - Reference https://docs.slackware.com/howtos:hardware:arm:gcc-10.x_aarch64_cross-compiler
RUN { \
    set -e && \
    cd /build/crossTools/linux/ && \
    KERNEL=kernel8 && \
    make ARCH=arm64 INSTALL_HDR_PATH=/opt/cross-pi-gcc/aarch64-linux-gnu headers_install && \
    cd ../ && \
    mkdir build-binutils && cd build-binutils && \
    ../binutils-2.40/configure --prefix=/opt/cross-pi-gcc --target=aarch64-linux-gnu --with-arch=armv8 --disable-multilib && \
    make -j4 && \
    make install && \
    echo "Binutils done" && \
    cd ../ && \
    sed -i '66a #ifndef PATH_MAX\n#define PATH_MAX 4096\n#endif' /build/crossTools/gcc-12.2.0/libsanitizer/asan/asan_linux.cpp && \
    mkdir build-gcc && cd build-gcc && \
    ../gcc-12.2.0/configure --prefix=/opt/cross-pi-gcc --target=aarch64-linux-gnu --enable-languages=c,c++ --disable-multilib && \
    make -j4 all-gcc && \
    make install-gcc && \
    echo "Compile glibc partly" && \
    cd ../ && \
    mkdir build-glibc && cd build-glibc && \
    ../glibc-2.36/configure \
        --prefix=/opt/cross-pi-gcc/aarch64-linux-gnu \
        --build=$MACHTYPE \
        --host=aarch64-linux-gnu \
        --target=aarch64-linux-gnu \
        --with-headers=/opt/cross-pi-gcc/aarch64-linux-gnu/include \
        --disable-multilib \
        libc_cv_forced_unwind=yes && \
    make install-bootstrap-headers=yes install-headers && \
    make -j4 csu/subdir_lib && \
    install csu/crt1.o csu/crti.o csu/crtn.o /opt/cross-pi-gcc/aarch64-linux-gnu/lib && \
    aarch64-linux-gnu-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o /opt/cross-pi-gcc/aarch64-linux-gnu/lib/libc.so && \
    touch /opt/cross-pi-gcc/aarch64-linux-gnu/include/gnu/stubs.h && \
    echo "Build gcc partly" && \
    cd ../build-gcc/ && \
    make -j4 all-target-libgcc && \
    make install-target-libgcc && \
    echo "build complete glibc" && \
    cd ../build-glibc/ && \
    make -j4 && \
    make install && \
    echo "build complete gcc" && \
    cd ../build-gcc/ && \
    make -j4 && \
    make install && \
    echo "Is finished"; \
} 2>&1 | tee -a /build.log


RUN mkdir sysroot sysroot/usr sysroot/opt

COPY rasp.tar.gz /build/rasp.tar.gz
RUN tar xvfz /build/rasp.tar.gz -C /build/sysroot

COPY toolchain.cmake /build/

RUN { \
    echo "Cmake build" && \
    mkdir cmakeBuild && \
    cd cmakeBuild && \
    git clone https://github.com/Kitware/CMake.git && \
    cd CMake && \
    ./bootstrap && make -j8 && make install && \
    echo "Cmake build is finished"; \
} 2>&1 | tee -a /build.log

RUN { \
    set -e && \
    echo "Fix symbollic link" && \
    wget https://raw.githubusercontent.com/riscv/riscv-poky/master/scripts/sysroot-relativelinks.py && \
    chmod +x sysroot-relativelinks.py && \
    python3 sysroot-relativelinks.py /build/sysroot && \
    mkdir -p qt6 qt6/host qt6/pi qt6/host-build qt6/pi-build qt6/src && \
    cd qt6/src && \
    wget https://download.qt.io/official_releases/qt/6.8/6.8.0/submodules/qtbase-everywhere-src-6.8.0.tar.xz && \
    wget https://download.qt.io/official_releases/qt/6.8/6.8.0/submodules/qtshadertools-everywhere-src-6.8.0.tar.xz && \
    wget https://download.qt.io/official_releases/qt/6.8/6.8.0/submodules/qtdeclarative-everywhere-src-6.8.0.tar.xz && \
    cd ../host-build && \
    tar xf ../src/qtbase-everywhere-src-6.8.0.tar.xz && \
    tar xf ../src/qtshadertools-everywhere-src-6.8.0.tar.xz && \
    tar xf ../src/qtdeclarative-everywhere-src-6.8.0.tar.xz && \
    echo "Compile qtbase for host" && \
    cd qtbase-everywhere-src-6.8.0 && \
    cmake -GNinja -DCMAKE_BUILD_TYPE=Release \
        -DQT_BUILD_EXAMPLES=OFF \
        -DQT_BUILD_TESTS=OFF \
        -DCMAKE_INSTALL_PREFIX=/build/qt6/host && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile shader for host" && \
    cd ../qtshadertools-everywhere-src-6.8.0 && \
    /build/qt6/host/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile declerative for host" && \
    cd ../qtdeclarative-everywhere-src-6.8.0 && \
    /build/qt6/host/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    cd ../../pi-build && \
    tar xf ../src/qtbase-everywhere-src-6.8.0.tar.xz && \
    tar xf ../src/qtshadertools-everywhere-src-6.8.0.tar.xz && \
    tar xf ../src/qtdeclarative-everywhere-src-6.8.0.tar.xz && \
    echo "Compile qtbase for rasp" && \
    cd qtbase-everywhere-src-6.8.0 && \
    cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DINPUT_opengl=es2 \
        -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF \
        -DQT_HOST_PATH=/build/qt6/host \
        -DCMAKE_STAGING_PREFIX=/build/qt6/pi \
        -DCMAKE_INSTALL_PREFIX=/usr/local/qt6 \
        -DCMAKE_TOOLCHAIN_FILE=/build/toolchain.cmake \
        -DQT_FEATURE_xcb=ON -DFEATURE_xcb_xlib=ON \
        -DQT_FEATURE_xlib=ON && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile shader for rasp" && \
    cd ../qtshadertools-everywhere-src-6.8.0 && \
    /build/qt6/pi/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile declerative for rasp" && \
    cd ../qtdeclarative-everywhere-src-6.8.0 && \
    /build/qt6/pi/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compilation is finished"; \
} 2>&1 | tee -a /build.log

RUN tar -czvf cross-pi-gcc.tar.gz -C /opt/cross-pi-gcc . 
RUN tar -czvf qt-host-binaries.tar.gz -C /build/qt6/host .
RUN tar -czvf qt-pi-binaries.tar.gz -C /build/qt6/pi .

RUN mkdir /build/project

COPY project /build/project

RUN { \
    cd project && \
    /build/qt6/pi/bin/qt-cmake && \
    cmake --build .; \
}