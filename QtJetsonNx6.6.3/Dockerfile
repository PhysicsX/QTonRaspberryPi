# Use an x86 Ubuntu base image with a specified version
ARG UBUNTU_VERSION=20.04
FROM ubuntu:${UBUNTU_VERSION}

# Avoid interactive prompts by setting the environment variable
ENV DEBIAN_FRONTEND=noninteractive

# Define build arguments for GCC version and other configurable packages
ARG GCC_VERSION=9

# Update system and install necessary libraries
RUN { \
    echo "deb http://archive.ubuntu.com/ubuntu/ $(lsb_release -sc) main universe restricted multiverse" > /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ $(lsb_release -sc)-updates main universe restricted multiverse" >> /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ $(lsb_release -sc)-security main universe restricted multiverse" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    '.*libxcb.*' \
    libxrender-dev \
    gcc-${GCC_VERSION} g++-${GCC_VERSION} \
    gcc-${GCC_VERSION}-aarch64-linux-gnu g++-${GCC_VERSION}-aarch64-linux-gnu \
    libxi-dev \
    libfontconfig1-dev \
    '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxkbcommon-dev libxkbcommon-x11-dev \
    libudev-dev \
    libgl1-mesa-dev \
    gcc \
    git \
    bison \
    python3 \
    gperf \
    pkg-config \
    make \
    libclang-dev \
    build-essential \
    libegl1-mesa-dev \
    libgbm-dev \
    libgles-dev \
    wget \
    ninja-build \
    rsync \
    sed \
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
    gettext \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean; \
 } 2>&1 | tee -a /build.log

# Reset the frontend variable to avoid affecting other software
ENV DEBIAN_FRONTEND=dialog

# Copy the sysroot tarball from the previous Docker image
COPY nxSysroot.tar.gz /tmp/nxSysroot.tar.gz

RUN { \
    apt list | grep wget; \
}

RUN { \
    echo "Cmake build" && \
    mkdir cmakeBuild && \
    cd cmakeBuild && \
    git clone https://github.com/Kitware/CMake.git && \
    cd CMake && \
    ./bootstrap && make -j8 && make install && \
    echo "Cmake build is finished"; \
} 2>&1 | tee -a /build.log

# Extract the sysroot
RUN mkdir -p /opt/sysroot && tar -xzf /tmp/nxSysroot.tar.gz -C /opt/sysroot | tee -a /build.log

# Download and prepare the sysroot-relativelinks.py script
RUN wget --no-check-certificate 'https://raw.githubusercontent.com/riscv/riscv-poky/master/scripts/sysroot-relativelinks.py' -O /usr/local/bin/sysroot-relativelinks.py \
 && chmod +x /usr/local/bin/sysroot-relativelinks.py \
 && python3 /usr/local/bin/sysroot-relativelinks.py /opt/sysroot | tee -a /build.log

# Create necessary directories and download Qt source
RUN mkdir -p /qt6/src /qt6/host-build /qt6/nx-build \
 && cd /qt6/src \
 && wget --no-check-certificate https://download.qt.io/official_releases/qt/6.8/6.8.0/submodules/qtbase-everywhere-src-6.8.0.tar.xz \
 && wget --no-check-certificate https://download.qt.io/official_releases/qt/6.8/6.8.0/submodules/qtshadertools-everywhere-src-6.8.0.tar.xz \
 && wget --no-check-certificate https://download.qt.io/official_releases/qt/6.8/6.8.0/submodules/qtdeclarative-everywhere-src-6.8.0.tar.xz \
 && tar xf qtbase-everywhere-src-6.8.0.tar.xz -C /qt6/host-build \
 && tar xf qtshadertools-everywhere-src-6.8.0.tar.xz -C /qt6/host-build \
 && tar xf qtdeclarative-everywhere-src-6.8.0.tar.xz -C /qt6/host-build | tee -a /build.log

# Compile Qt for the host
RUN { \
    cd /qt6/host-build/qtbase-everywhere-src-6.8.0 && \
    echo "Compile qtbase for host" | tee -a /build.log && \
    cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/qt6/host && \
    ninja && \
    ninja install; \
} 2>&1 | tee -a /build.log

RUN { \
    echo "Compile qtshadertools for host" | tee -a /build.log && \
    cd /qt6/host-build/qtshadertools-everywhere-src-6.8.0 && \
    /qt6/host/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install .; \
}  2>&1 | tee -a /build.log

RUN { \
    echo "Compile qtdeclarative for host" | tee -a /build.log && \
    cd /qt6/host-build/qtdeclarative-everywhere-src-6.8.0 && \
    /qt6/host/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install .; \
} 2>&1 | tee -a /build.log

# Copy the toolchain file into the Docker image
COPY toolchain.cmake /opt/toolchain.cmake

# Set environment variables for the cross-compiler
ENV CC=aarch64-linux-gnu-gcc-9
ENV CXX=aarch64-linux-gnu-g++-9
ENV SYSROOT=/opt/sysroot

# Compile Qt for the target
RUN cd /qt6/src && \
    tar xf qtbase-everywhere-src-6.8.0.tar.xz -C /qt6/nx-build && \
    tar xf qtshadertools-everywhere-src-6.8.0.tar.xz -C /qt6/nx-build && \
    tar xf qtdeclarative-everywhere-src-6.8.0.tar.xz -C /qt6/nx-build

ARG GCC_VERSION

# Build Qt for the target using the toolchain file
RUN { \
    echo "Compile qtbase for nx" | tee -a /build.log && \
    cd /qt6/nx-build/qtbase-everywhere-src-6.8.0 && \
    cmake -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DINPUT_opengl=es2 \
    -DQT_BUILD_EXAMPLES=OFF \
    -DQT_BUILD_TESTS=OFF \
    -DQT_HOST_PATH=/qt6/host \
    -DCMAKE_STAGING_PREFIX=/qt6/nx \
    -DCMAKE_INSTALL_PREFIX=/usr/local/qt6 \
    -DCMAKE_TOOLCHAIN_FILE=/opt/toolchain.cmake \
    -DGCC_VERSION=${GCC_VERSION} \ # Pass GCC version to the toolchain
    -DFEATURE_xcb_xlib=ON \
    -DQT_FEATURE_xlib=ON && \
    ninja && \
    ninja install; \
} 2>&1 | tee -a /build.log

RUN { \
    echo "Compile qtshadertools for nx" | tee -a /build.log && \
    cd /qt6/nx-build/qtshadertools-everywhere-src-6.8.0 && \
    /qt6/nx/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install .; \
}  2>&1 | tee -a /build.log

RUN { \
    echo "Compile qtdeclarative for nx" | tee -a /build.log && \
    cd /qt6/nx-build/qtdeclarative-everywhere-src-6.8.0 && \
    /qt6/nx/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install .; \
} 2>&1 | tee -a /build.log

# Create tarball of the compiled binaries
RUN tar -czvf qt-nx-binaries.tar.gz -C /qt6/nx . | tee -a /build.log

RUN mkdir /project

COPY projectQml /project

RUN { \
    cd project && \
    /qt6/nx/bin/qt-cmake && \
    cmake --build .; \
}