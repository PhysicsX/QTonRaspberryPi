# Use an x86 Ubuntu base image
FROM ubuntu:20.04

# Avoid interactive prompts by setting the environment variable
ENV DEBIAN_FRONTEND=noninteractive

# Update system and install necessary libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    '^libxcb.*-dev' \
    libx11-xcb-dev \
    '.*libxcb.*' \
    libxrender-dev \
    gcc-9 g++-9 \
    gcc-9-aarch64-linux-gnu g++-9-aarch64-linux-gnu \
    libxi-dev \
    libfontconfig1-dev \
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
    cmake \
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
    apt-get clean

# Reset the frontend variable to avoid affecting other software
ENV DEBIAN_FRONTEND=dialog

# Copy the sysroot tarball from the previous Docker image
COPY nxSysroot.tar.gz /tmp/nxSysroot.tar.gz

# Extract the sysroot
RUN mkdir -p /opt/sysroot && tar -xzf /tmp/nxSysroot.tar.gz -C /opt/sysroot

# Download and prepare the sysroot-relativelinks.py script
RUN wget --no-check-certificate 'https://raw.githubusercontent.com/riscv/riscv-poky/master/scripts/sysroot-relativelinks.py' -O /usr/local/bin/sysroot-relativelinks.py \
 && chmod +x /usr/local/bin/sysroot-relativelinks.py \
 && python3 /usr/local/bin/sysroot-relativelinks.py /opt/sysroot

# Create necessary directories and download Qt source
RUN mkdir -p /qt6/src /qt6/host-build /qt6/pi-build \
 && cd /qt6/src \
 && wget --no-check-certificate https://download.qt.io/official_releases/qt/6.6/6.6.3/submodules/qtbase-everywhere-src-6.6.3.tar.xz \
 && wget --no-check-certificate https://download.qt.io/official_releases/qt/6.6/6.6.3/submodules/qtshadertools-everywhere-src-6.6.3.tar.xz \
 && wget --no-check-certificate https://download.qt.io/official_releases/qt/6.6/6.6.3/submodules/qtdeclarative-everywhere-src-6.6.3.tar.xz \
 && tar xf qtbase-everywhere-src-6.6.3.tar.xz -C /qt6/host-build \
 && tar xf qtshadertools-everywhere-src-6.6.3.tar.xz -C /qt6/host-build \
 && tar xf qtdeclarative-everywhere-src-6.6.3.tar.xz -C /qt6/host-build


# Compile Qt for the host
RUN cd /qt6/host-build/qtbase-everywhere-src-6.6.3 \
 && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/qt6/host \
 && ninja \
 && ninja install

# Set environment variables for the cross-compiler
ENV CC=aarch64-linux-gnu-gcc-9
ENV CXX=aarch64-linux-gnu-g++-9
ENV SYSROOT=/opt/sysroot

# Additional steps to compile other modules like shader tools and declarative follow the same pattern
