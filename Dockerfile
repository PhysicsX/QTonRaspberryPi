# Use Debian 12 (Bookworm) as the base image
FROM debian:bookworm

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

ARG BUILD_OPENCV=FALSE

# Update and install necessary packages
RUN { \
    set -e && \
    apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    make \
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
    libpq-dev \
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
    gettext  \
    gcc-12-aarch64-linux-gnu \
    g++-12-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    libc6-arm64-cross \
    libc6-dev-arm64-cross \
    glibc-source; \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*; \
} 2>&1 | tee -a /build.log

# Set the working directory to /build
WORKDIR /build

# Build and install CMake from source
RUN ( \
    echo "Building CMake from source" && \
    mkdir cmakeBuild && cd cmakeBuild && \
    git clone https://github.com/Kitware/CMake.git && \
    cd CMake && \
    ./bootstrap && make -j$(nproc) && make install && \
    echo "CMake build completed"; \
 ) 2>&1 | tee -a /build.log

# Create sysroot directory
RUN mkdir sysroot sysroot/usr sysroot/opt

# Copy Raspberry Pi sysroot tarball (if available)
COPY rasp.tar.gz /build/rasp.tar.gz
RUN tar xvfz /build/rasp.tar.gz -C /build/sysroot

# Copy the toolchain file
COPY opencvToolchain.cmake /build/

RUN set -e && \
    echo "Fix symbolic link" && \
    wget https://raw.githubusercontent.com/riscv/riscv-poky/master/scripts/sysroot-relativelinks.py && \
    chmod +x sysroot-relativelinks.py && \
    python3 sysroot-relativelinks.py /build/sysroot 2>&1 | tee -a /build.log


ARG BUILD_OPENCV

# Build Opencv
RUN if [ "$BUILD_OPENCV" = "ON" ]; then \
    set -e && \
    echo "Cross Compile Opencv from source" && \
    mkdir -p /build/opencvBuild && \
    git clone --branch 4.9.0 --depth=1 https://github.com/opencv/opencv.git && \
    git clone --branch 4.9.0 --depth=1 https://github.com/opencv/opencv_contrib.git && \
    mkdir -p /build/opencv/build && \
    cd /build/opencv/build && \
    cmake \
          -G "Unix Makefiles" \ 
          -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_INSTALL_PREFIX=/build/opencvBuild \
          -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
          -D CMAKE_TOOLCHAIN_FILE=/build/opencvToolchain.cmake \
          -D OPENCV_ENABLE_NONFREE=ON \
          -D WITH_GSTREAMER=ON \
          -D WITH_FFMPEG=ON \
          -D WITH_V4L=ON \
          -D WITH_OPENGL=ON \
          -D WITH_GTK=OFF \     
          -D WITH_QT=OFF \
          -D WITH_X11=ON \
          -D OPENCV_PYTHON3_INSTALL_PATH=OFF \       
          -D BUILD_opencv_highgui=ON \
          -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          -D BUILD_EXAMPLES=OFF \
          .. && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Cross Compile Opencv completed" && \
    cd /build && \
    tar -czvf opencv-binaries.tar.gz -C /build/opencvBuild . \
; fi 2>&1 | tee -a /build.log

# Copy the toolchain file
COPY toolchain.cmake /build/

RUN { \
    set -e && \
    mkdir -p qt6 qt6/host qt6/pi qt6/host-build qt6/pi-build qt6/src && \
    cd qt6/src && \
    wget https://download.qt.io/official_releases/qt/6.8/6.8.1/submodules/qtbase-everywhere-src-6.8.1.tar.xz && \
    wget https://download.qt.io/official_releases/qt/6.8/6.8.1/submodules/qtshadertools-everywhere-src-6.8.1.tar.xz && \
    wget https://download.qt.io/official_releases/qt/6.8/6.8.1/submodules/qtdeclarative-everywhere-src-6.8.1.tar.xz && \
    cd ../host-build && \
    tar xf ../src/qtbase-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtshadertools-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtdeclarative-everywhere-src-6.8.1.tar.xz && \
    echo "Compile qtbase for host" && \
    cd qtbase-everywhere-src-6.8.1 && \
    cmake -GNinja -DCMAKE_BUILD_TYPE=Release \
        -DQT_BUILD_EXAMPLES=OFF \
        -DQT_BUILD_TESTS=OFF \
        -DCMAKE_INSTALL_PREFIX=/build/qt6/host && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile shader for host" && \
    cd ../qtshadertools-everywhere-src-6.8.1 && \
    /build/qt6/host/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile declerative for host" && \
    cd ../qtdeclarative-everywhere-src-6.8.1 && \
    /build/qt6/host/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    cd ../../pi-build && \
    tar xf ../src/qtbase-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtshadertools-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtdeclarative-everywhere-src-6.8.1.tar.xz && \
    echo "Compile qtbase for rasp" && \
    cd qtbase-everywhere-src-6.8.1 && \
    cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DINPUT_opengl=es2 \
        -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF \
        -DQT_HOST_PATH=/build/qt6/host \
        -DCMAKE_STAGING_PREFIX=/build/qt6/pi \
        -DCMAKE_INSTALL_PREFIX=/usr/local/qt6 \
        -DCMAKE_TOOLCHAIN_FILE=/build/toolchain.cmake \
        -DQT_FEATURE_xcb=ON -DFEATURE_xcb_xlib=ON \
        -DFEATURE_sql_psql=ON \
        -DQT_FEATURE_xlib=ON && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile shader for rasp" && \
    cd ../qtshadertools-everywhere-src-6.8.1 && \
    /build/qt6/pi/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile declerative for rasp" && \
    cd ../qtdeclarative-everywhere-src-6.8.1 && \
    /build/qt6/pi/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compilation is finished"; \
} 2>&1 | tee -a /build.log

RUN tar -czvf qt-host-binaries.tar.gz -C /build/qt6/host .
RUN tar -czvf qt-pi-binaries.tar.gz -C /build/qt6/pi .

# Set up project directory
RUN mkdir /build/project
COPY project /build/project

# Build the project using Qt for Raspberry Pi
RUN { \
    cd /build/project && \
    /build/qt6/pi/bin/qt-cmake . && \
    cmake --build .; \
} 2>&1 | tee -a /build.log

# Set up QtOpencvExample directory
RUN mkdir /build/QtOpencvExample
COPY QtOpencvExample /build/QtOpencvExample

ARG BUILD_OPENCV
# Build the project using Qt and Opencv for Raspberry Pi
RUN if [ "$BUILD_OPENCV" = "ON" ]; then { \
    cd /build/QtOpencvExample && \
    mkdir build && cd build && \
    cmake -DCMAKE_TOOLCHAIN_FILE=/build/QtOpencvExample/toolchain.cmake .. && \
    make ; \
} 2>&1 | tee -a /build.log; fi
