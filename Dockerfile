ARG BASE_IMAGE
ARG TARGET_HARDWARE

FROM ${BASE_IMAGE}

# Create a log file at the beginning
RUN touch /build.log

# Update os according to selection
RUN if [ "$BASE_IMAGE" = "ubuntu:24.04" ] && [ "$TARGET_HARDWARE" = "raspberrypi" ]; then \
        echo "Building qt in x86 OS for Raspberry Pi" >> /build.log 2>&1; \
        export DEBIAN_FRONTEND=noninteractive; \
        apt-get update >> /build.log 2>&1 && \
        apt-get install -y \
            wget git build-essential make cmake rsync sed \
            libclang-dev ninja-build gcc bison python3 gperf pkg-config \
            libfontconfig1-dev libfreetype6-dev libx11-dev libx11-xcb-dev \
            libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev \
            libxcb-glx0-dev libxcb-keysyms1-dev libxcb-image0-dev libxcb-shm0-dev \
            libxcb-icccm4-dev libxcb-sync-dev libxcb-xfixes0-dev libxcb-shape0-dev \
            libxcb-randr0-dev libxcb-render-util0-dev libxcb-util-dev libxcb-xinerama0-dev \
            libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev libatspi2.0-dev \
            libgl1-mesa-dev libglu1-mesa-dev freeglut3-dev libssl-dev \
            libgmp-dev libmpfr-dev libmpc-dev flex gawk texinfo \
            libisl-dev zlib1g-dev libtool autoconf automake \
            libgdbm-dev libdb-dev libbz2-dev libreadline-dev libexpat1-dev \
            liblzma-dev libffi-dev libsqlite3-dev libbsd-dev perl patch \
            m4 libncurses5-dev gettext >> /build.log 2>&1 && \
        apt-get clean >> /build.log 2>&1 && \
        rm -rf /var/lib/apt/lists/* >> /build.log 2>&1; \
    elif [ "$BASE_IMAGE" = "arm64v8/debian:bookworm" ] && [ "$TARGET_HARDWARE" = "raspberrypi" ]; then \
        echo "Setting up environment for Raspberry Pi on Debian ARM64" >> /build.log 2>&1; \
        export DEBIAN_FRONTEND=noninteractive; \
        echo "deb http://deb.debian.org/debian bookworm main contrib non-free" > /etc/apt/sources.list && \
        echo "deb-src http://deb.debian.org/debian bookworm main contrib non-free" >> /etc/apt/sources.list && \
        echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
        echo "deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
        apt-get update >> /build.log 2>&1 && \
        apt-get full-upgrade -y >> /build.log 2>&1 && \
        apt-get install -y \
            libboost-all-dev libudev-dev libinput-dev libts-dev \
            libmtdev-dev libjpeg-dev libfontconfig1-dev libssl-dev \
            libdbus-1-dev libglib2.0-dev libxkbcommon-dev libegl1-mesa-dev \
            libgbm-dev libgles2-mesa-dev mesa-common-dev libasound2-dev \
            libpulse-dev gstreamer1.0-omx libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
            gstreamer1.0-alsa libvpx-dev libsrtp2-dev libsnappy-dev \
            libnss3-dev "^libxcb.*" flex bison libxslt-dev ruby \
            gperf libbz2-dev libcups2-dev libatkmm-1.6-dev libxi6 \
            libxcomposite1 libfreetype6-dev libicu-dev libsqlite3-dev libxslt1-dev \
            libavcodec-dev libavformat-dev libswscale-dev libx11-dev freetds-dev \
            libpq-dev libiodbc2-dev firebird-dev libxext-dev libxcb1 \
            libxcb1-dev libx11-xcb1 libx11-xcb-dev libxcb-keysyms1 libxcb-keysyms1-dev \
            libxcb-image0 libxcb-image0-dev libxcb-shm0 libxcb-shm0-dev libxcb-icccm4 \
            libxcb-icccm4-dev libxcb-sync1 libxcb-sync-dev libxcb-render-util0 libxcb-render-util0-dev \
            libxcb-xfixes0-dev libxrender-dev libxcb-shape0-dev libxcb-randr0-dev \
            libxcb-glx0-dev libxi-dev libdrm-dev libxcb-xinerama0 libxcb-xinerama0-dev \
            libatspi2.0-dev libxcursor-dev libxcomposite-dev libxdamage-dev \
            libxss-dev libxtst-dev libpci-dev libcap-dev libxrandr-dev \
            libdirectfb-dev libaudio-dev libxkbcommon-x11-dev gdbserver >> /build.log 2>&1; \
        apt-get clean >> /build.log 2>&1 && \
        rm -rf /var/lib/apt/lists/* >> /build.log 2>&1; \
        echo "Environment setup complete for Raspberry Pi on Debian ARM64" >> /build.log 2>&1; \
        echo "Creating build directory and archiving system files" >> /build.log 2>&1; \
        mkdir -p /build >> /build.log 2>&1 && \
        tar cvfz /build/rasp.tar.gz -C / lib usr/include usr/lib >> /build.log 2>&1; \
    else \
        echo "Different hardware or base image detected, skipping the build." >> /build.log 2>&1; \
    fi

    # RUN block for creating directories and extracting files based on the first case
RUN if [ "$BASE_IMAGE" = "ubuntu:24.04" ] && [ "$TARGET_HARDWARE" = "raspberrypi" ]; then \
        echo "Creating sysroot directories and extracting rasp.tar.gz" >> /build.log 2>&1; \
        mkdir -p /build/sysroot/usr /build/sysroot/opt >> /build.log 2>&1 && \
        cp /build/rasp.tar.gz /build/rasp.tar.gz >> /build.log 2>&1 && \
        tar xvfz /build/rasp.tar.gz -C /build/sysroot >> /build.log 2>&1; \
    fi

# RUN block for cloning firmware and copying files based on the first case
RUN if [ "$BASE_IMAGE" = "ubuntu:24.04" ] && [ "$TARGET_HARDWARE" = "raspberrypi" ]; then \
        echo "Cloning the Raspberry Pi firmware repository" >> /build.log 2>&1; \
        git clone --depth=1 https://github.com/raspberrypi/firmware /build/firmware >> /build.log 2>&1; \
        echo "Copying the opt directory from the cloned firmware to sysroot/opt" >> /build.log 2>&1; \
        cp -r /build/firmware/opt /build/sysroot/opt >> /build.log 2>&1; \
        echo "Copying toolchain.cmake to /build" >> /build.log 2>&1; \
        cp /build/toolchain.cmake /build/toolchain.cmake >> /build.log 2>&1; \
    fi
            
# RUN block for building CMake based on the first case
RUN if [ "$BASE_IMAGE" = "ubuntu:24.04" ] && [ "$TARGET_HARDWARE" = "raspberrypi" ]; then \
        echo "Starting CMake build process" >> /build.log 2>&1; \
        mkdir -p /build/cmakeBuild >> /build.log 2>&1 && \
        cd /build/cmakeBuild >> /build.log 2>&1 && \
        git clone https://github.com/Kitware/CMake.git >> /build.log 2>&1 && \
        cd CMake >> /build.log 2>&1 && \
        ./bootstrap >> /build.log 2>&1 && \
        make -j8 >> /build.log 2>&1 && \
        make install >> /build.log 2>&1 && \
        echo "CMake build is finished" >> /build.log 2>&1; \
    fi

# RUN block for fixing symbolic links and building Qt based on the first case
RUN if [ "$BASE_IMAGE" = "ubuntu:24.04" ] && [ "$TARGET_HARDWARE" = "raspberrypi" ]; then \
        echo "Fixing symbolic links and preparing Qt build environment" >> /build.log 2>&1; \
        wget https://raw.githubusercontent.com/riscv/riscv-poky/master/scripts/sysroot-relativelinks.py >> /build.log 2>&1; \
        chmod +x sysroot-relativelinks.py >> /build.log 2>&1; \
        python3 sysroot-relativelinks.py /build/sysroot >> /build.log 2>&1; \
        mkdir -p /build/qt6/host /build/qt6/pi /build/qt6/host-build /build/qt6/pi-build /build/qt6/src >> /build.log 2>&1; \
        cd /build/qt6/src >> /build.log 2>&1; \
        wget https://download.qt.io/official_releases/qt/6.8/6.8.0/submodules/qtbase-everywhere-src-6.8.0.tar.xz >> /build.log 2>&1; \
        wget https://download.qt.io/official_releases/qt/6.8/6.8.0/submodules/qtshadertools-everywhere-src-6.8.0.tar.xz >> /build.log 2>&1; \
        wget https://download.qt.io/official_releases/qt/6.8/6.8.0/submodules/qtdeclarative-everywhere-src-6.8.0.tar.xz >> /build.log 2>&1; \
        cd ../host-build >> /build.log 2>&1; \
        tar xf ../src/qtbase-everywhere-src-6.8.0.tar.xz >> /build.log 2>&1; \
        tar xf ../src/qtshadertools-everywhere-src-6.8.0.tar.xz >> /build.log 2>&1; \
        tar xf ../src/qtdeclarative-everywhere-src-6.8.0.tar.xz >> /build.log 2>&1; \
        echo "Compiling qtbase for host" >> /build.log 2>&1; \
        cd qtbase-everywhere-src-6.8.0 >> /build.log 2>&1; \
        cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/build/qt6/host >> /build.log 2>&1; \
        cmake --build . --parallel 4 >> /build.log 2>&1; \
        cmake --install . >> /build.log 2>&1; \
        echo "Compiling shader for host" >> /build.log 2>&1; \
        cd ../qtshadertools-everywhere-src-6.8.0 >> /build.log 2>&1; \
        /build/qt6/host/bin/qt-configure-module . >> /build.log 2>&1; \
        cmake --build . --parallel 4 >> /build.log 2>&1; \
        cmake --install . >> /build.log 2>&1; \
        echo "Compiling declarative for host" >> /build.log 2>&1; \
        cd ../qtdeclarative-everywhere-src-6.8.0 >> /build.log 2>&1; \
        /build/qt6/host/bin/qt-configure-module . >> /build.log 2>&1; \
        cmake --build . --parallel 4 >> /build.log 2>&1; \
        cmake --install . >> /build.log 2>&1; \
        cd ../../pi-build >> /build.log 2>&1; \
        tar xf ../src/qtbase-everywhere-src-6.8.0.tar.xz >> /build.log 2>&1; \
        tar xf ../src/qtshadertools-everywhere-src-6.8.0.tar.xz >> /build.log 2>&1; \
        tar xf ../src/qtdeclarative-everywhere-src-6.8.0.tar.xz >> /build.log 2>&1; \
        echo "Compiling qtbase for Raspberry Pi" >> /build.log 2>&1; \
        cd qtbase-everywhere-src-6.8.0 >> /build.log 2>&1; \
        cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DINPUT_opengl=es2 -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF -DQT_HOST_PATH=/build/qt6/host -DCMAKE_STAGING_PREFIX=/build/qt6/pi -DCMAKE_INSTALL_PREFIX=/usr/local/qt6 -DCMAKE_TOOLCHAIN_FILE=/build/toolchain.cmake -DQT_FEATURE_xcb=ON -DFEATURE_xcb_xlib=ON -DQT_FEATURE_xlib=ON >> /build.log 2>&1; \
        cmake --build . --parallel 4 >> /build.log 2>&1; \
        cmake --install . >> /build.log 2>&1; \
        echo "Compiling shader for Raspberry Pi" >> /build.log 2>&1; \
        cd ../qtshadertools-everywhere-src-6.8.0 >> /build.log 2>&1; \
        /build/qt6/pi/bin/qt-configure-module . >> /build.log 2>&1; \
        cmake --build . --parallel 4 >> /build.log 2>&1; \
        cmake --install . >> /build.log 2>&1; \
        echo "Compiling declarative for Raspberry Pi" >> /build.log 2>&1; \
        cd ../qtdeclarative-everywhere-src-6.8.0 >> /build.log 2>&1; \
        /build/qt6/pi/bin/qt-configure-module . >> /build.log 2>&1; \
        cmake --build . --parallel 4 >> /build.log 2>&1; \
        cmake --install . >> /build.log 2>&1; \
        echo "Compilation is finished" >> /build.log 2>&1; \
    fi

# RUN block for archiving binaries based on the first case
RUN if [ "$BASE_IMAGE" = "ubuntu:24.04" ] && [ "$TARGET_HARDWARE" = "raspberrypi" ]; then \
        echo "Archiving cross-pi-gcc binaries" >> /build.log 2>&1; \
        tar -czvf /build/cross-pi-gcc.tar.gz -C /opt/cross-pi-gcc . >> /build.log 2>&1; \
        echo "Archiving qt-host binaries" >> /build.log 2>&1; \
        tar -czvf /build/qt-host-binaries.tar.gz -C /build/qt6/host . >> /build.log 2>&1; \
        echo "Archiving qt-pi binaries" >> /build.log 2>&1; \
        tar -czvf /build/qt-pi-binaries.tar.gz -C /build/qt6/pi . >> /build.log 2>&1; \
    fi

# RUN block for setting up and building the project based on the first case
RUN if [ "$BASE_IMAGE" = "ubuntu:24.04" ] && [ "$TARGET_HARDWARE" = "raspberrypi" ]; then \
        echo "Creating /build/project directory" >> /build.log 2>&1; \
        mkdir -p /build/project >> /build.log 2>&1; \
        echo "Copying project files to /build/project" >> /build.log 2>&1; \
        cp -r /build/project /build/project >> /build.log 2>&1; \
        echo "Configuring and building the project using qt-cmake" >> /build.log 2>&1; \
        cd /build/project >> /build.log 2>&1 && \
        /build/qt6/pi/bin/qt-cmake . >> /build.log 2>&1 && \
        cmake --build . >> /build.log 2>&1; \
    fi