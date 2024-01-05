# Stage 1: Setting up the environment and copying necessary files from Raspberry Pi OS
FROM --platform=linux/arm64 arm64v8/debian:bookworm as rasp

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Create a log file
RUN touch /build.log

# Update the package list and install necessary packages
RUN { \
    echo "deb http://deb.debian.org/debian bookworm main contrib non-free" > /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian bookworm main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get full-upgrade -y && \
    apt-get install -y \
    libboost-all-dev libudev-dev libinput-dev libts-dev libmtdev-dev \
    libjpeg-dev libfontconfig1-dev libssl-dev libdbus-1-dev libglib2.0-dev \
    libxkbcommon-dev libegl1-mesa-dev libgbm-dev libgles2-mesa-dev \
    mesa-common-dev libasound2-dev libpulse-dev gstreamer1.0-omx \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-alsa \
    libvpx-dev libsrtp2-dev libsnappy-dev libnss3-dev "^libxcb.*" \
    flex bison libxslt-dev ruby gperf libbz2-dev libcups2-dev \
    libatkmm-1.6-dev libxi6 libxcomposite1 libfreetype6-dev libicu-dev \
    libsqlite3-dev libxslt1-dev libavcodec-dev libavformat-dev libswscale-dev \
    libx11-dev freetds-dev libpq-dev libiodbc2-dev firebird-dev \
    libxext-dev libxcb1 libxcb1-dev libx11-xcb1 libx11-xcb-dev \
    libxcb-keysyms1 libxcb-keysyms1-dev libxcb-image0 libxcb-image0-dev \
    libxcb-shm0 libxcb-shm0-dev libxcb-icccm4 libxcb-icccm4-dev \
    libxcb-sync1 libxcb-sync-dev libxcb-render-util0 libxcb-render-util0-dev \
    libxcb-xfixes0-dev libxrender-dev libxcb-shape0-dev libxcb-randr0-dev \
    libxcb-glx0-dev libxi-dev libdrm-dev libxcb-xinerama0 libxcb-xinerama0-dev \
    libatspi2.0-dev libxcursor-dev libxcomposite-dev libxdamage-dev \
    libxss-dev libxtst-dev libpci-dev libcap-dev libxrandr-dev \
    libdirectfb-dev libaudio-dev libxkbcommon-x11-dev gdbserver; \
} 2>&1 | tee -a /build.log

# Stage 2: Building the cross-compiler and tools
# Start from the Ubuntu Focal Fossa (20.04) image
FROM ubuntu:20.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install some necessary packages
RUN { \
    apt-get update && apt-get install -y \
    git \
    build-essential \
    make \
    cmake \
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
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*; \
} 2>&1 | tee -a /build.log

# Set the working directory to /build
WORKDIR /build
 
RUN mkdir sysroot sysroot/usr sysroot/opt

# Copy the necessary files from the 'rasp' stage or image
COPY --from=rasp /lib/ /sysroot/lib/
COPY --from=rasp /usr/include/ /sysroot/usr/include/
COPY --from=rasp /usr/lib/ /sysroot/usr/lib/

# Clone the Raspberry Pi firmware repository
RUN git clone --depth=1 https://github.com/raspberrypi/firmware firmware 2>&1 | tee -a /build.log

# Copy the opt directory from the cloned repository to sysroot/opt
RUN mkdir -p /sysroot/opt && \
    cp -r firmware/opt /sysroot/opt 2>&1 | tee -a /build.log

# Create a directory for the tools and change into it
RUN mkdir /crossTools && cd /crossTools 2>&1 | tee -a /build.log

# Download the necessary tar files
RUN wget https://mirror.lyrahosting.com/gnu/binutils/binutils-2.40.tar.gz && \
    wget https://ftp.nluug.nl/pub/gnu/glibc/glibc-2.36.tar.gz && \
    wget https://ftp.nluug.nl/pub/gnu/gcc/gcc-12.2.0/gcc-12.2.0.tar.gz && \
    git clone --depth=1 https://github.com/raspberrypi/linux 2>&1 | tee -a /build.log

# Extract the tar files
RUN tar xf /crossTools/binutils-2.40.tar.gz && \
    tar xf /crossTools/glibc-2.36.tar.gz && \
    tar xf /crossTools/gcc-12.2.0.tar.gz 2>&1 | tee -a /build.log

RUN mkdir -p /opt/cross-pi-gcc 2>&1 | tee -a /build.log

# Set the PATH environment variable
ENV PATH=/opt/cross-pi-gcc/bin:$PATH

# Create directories, download, extract, and compile everything in one RUN command
RUN { \
    cd linux/ && \
    make ARCH=arm64 INSTALL_HDR_PATH=/opt/cross-pi-gcc/aarch64-linux-gnu headers_install && \
    cd ../ && \
    mkdir build-binutils && cd build-binutils && \
    ../binutils-2.40/configure --prefix=/opt/cross-pi-gcc --target=aarch64-linux-gnu --with-arch=armv8 --disable-multilib && \
    make -j$(nproc) && \
    make install && \
    cd ../ && \
    mkdir build-gcc && cd build-gcc && \
    ../gcc-12.2.0/configure --prefix=/opt/cross-pi-gcc --target=aarch64-linux-gnu --enable-languages=c,c++ --disable-multilib && \
    make -j$(nproc) all-gcc && \
    make install-gcc && \
    cd ../ && \
    mkdir build-glibc && cd build-glibc && \
    ../glibc-2.36/configure --prefix=/opt/cross-pi-gcc/aarch64-linux-gnu --build=$MACHTYPE --host=aarch64-linux-gnu --target=aarch64-linux-gnu --with-headers=/opt/cross-pi-gcc/aarch64-linux-gnu/include --disable-multilib libc_cv_forced_unwind=yes && \
    make install-bootstrap-headers=yes install-headers && \
    make -j$(nproc) csu/subdir_lib && \
    install csu/crt1.o csu/crti.o csu/crtn.o /opt/cross-pi-gcc/aarch64-linux-gnu/lib && \
    aarch64-linux-gnu-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o /opt/cross-pi-gcc/aarch64-linux-gnu/lib/libc.so && \
    touch /opt/cross-pi-gcc/aarch64-linux-gnu/include/gnu/stubs.h && \
    cd ../build-gcc/ && \
    make -j$(nproc) all-target-libgcc && \
    make install-target-libgcc && \
    cd ../build-glibc/ && \
    make -j$(nproc) && \
    make install && \
    cd ../build-gcc/ && \
    make -j$(nproc) && \
    make install \
} 2>&1 | tee -a /build.log


