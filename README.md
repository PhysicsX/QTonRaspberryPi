# How to build Qt6 on Raspberry pi 4

Youtube video:

will be updated
[![Youtube video link](https://img.youtube.com/vi/TmtN3Rmx9Rk/0.jpg)](//www.youtube.com/watch?v=TmtN3Rmx9Rk?t=0s "ulas dikme")

# Prepare Raspberry pi 4


Update raspberry pi
In the source list update the correct keyword
```bash

sudo vi /etc/apt/sources.list
sudo apt update
sudo apt full-upgrade
sudo reboot
sudo rpi-update
sudo reboot

```
Install the dependencies

```bash
sudo apt-get install -y libboost1.58-all-dev libudev-dev libinput-dev libts-dev \
libmtdev-dev libjpeg-dev libfontconfig1-dev libssl-dev libdbus-1-dev libglib2.0-dev \
libxkbcommon-dev libegl1-mesa-dev libgbm-dev libgles2-mesa-dev mesa-common-dev \
libasound2-dev libpulse-dev gstreamer1.0-omx libgstreamer1.0-dev \
libgstreamer-plugins-base1.0-dev  gstreamer1.0-alsa libvpx-dev libsrtp0-dev libsnappy-dev \
libnss3-dev "^libxcb.*" flex bison libxslt-dev ruby gperf libbz2-dev libcups2-dev \
libatkmm-1.6-dev libxi6 libxcomposite1 libfreetype6-dev libicu-dev libsqlite3-dev libxslt1-dev \
libavcodec-dev libavformat-dev libswscale-dev libgstreamer0.10-dev gstreamer-tools \ 
libraspberrypi-dev libx11-dev freetds-dev libsqlite0-dev libpq-dev libiodbc2-dev firebird-dev \
libjpeg9-dev libgst-dev libxext-dev libxcb1 libxcb1-dev libx11-xcb1 libx11-xcb-dev \
libxcb-keysyms1 libxcb-keysyms1-dev libxcb-image0 libxcb-image0-dev libxcb-shm0 libxcb-shm0-dev \
libxcb-icccm4 libxcb-icccm4-dev libxcb-sync1 libxcb-sync-dev libxcb-render-util0 \
libxcb-render-util0-dev libxcb-xfixes0-dev libxrender-dev libxcb-shape0-dev libxcb-randr0-dev \
libxcb-glx0-dev libxi-dev libdrm-dev libxcb-xinerama0 libxcb-xinerama0-dev libatspi-dev \
libxcursor-dev libxcomposite-dev libxdamage-dev libxss-dev libxtst-dev libpci-dev libcap-dev \
libxrandr-dev libdirectfb-dev libaudio-de

sudo apt remove libzstd-dev
```
Create a directory for binaries

```bash
sudo mkdir /usr/local/qt6pi
sudo chown pi:pi /usr/local/qt6pi
```
# Prepare Ubuntu
Update the ubuntu
```bash
  sudo apt-get update
  sudo apt-get upgrade
```
Install dependencies
```bash
  sudo apt-get install cmake make build-essential libclang-dev ninja-build gcc git bison \
  python3 gperf pkg-config libfontconfig1-dev libfreetype6-dev libx11-dev libx11-xcb-dev \
  libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev libxcb-glx0-dev \
  libxcb-keysyms1-dev libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync-dev \
  libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev libxcb-render-util0-dev \
  libxcb-util-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev \
  libatspi2.0-dev libgl1-mesa-dev libglu1-mesa-dev freeglut3-dev
```

# Build the qt6 for host
```bash
cd ~
wget https://download.qt.io/official_releases/qt/6.2/6.2.4/submodules/qtbase-everywhere-src-6.2.4.tar.xz
mkdir qt6HostBuild
cd !$
tar ../xf qtbase-everywhere-src-6.2.4.tar.xz
cd qtbase-everywhere-src-6.2.4
cmake -GNinja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DINPUT_opengl=es2 -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/home/ulas/qt6Host
cmake --build . --parallel 4
cmake --install .
```
Test the host qt6

```bash
cd ..
mkdir QtHostExample
cd !$
 
cat<<EOF > main.cpp 
#include <QCoreApplication>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    qDebug()<<"Hello world";
    return a.exec();
}
EOF
 
cat<<EOF > CMakeLists.txt
cmake_minimum_required(VERSION 3.5)

project(HelloQt6 LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6Core)

add_executable(HelloQt6 main.cpp)

target_link_libraries(HelloQt6 Qt6::Core)
EOF

/home/ulas/qt6Host/bin/qt-cmake
cmake --build .
```

Install sysroot from raspberry pi and get toolchain
```bash
cd ..
mkdir qt6pi # a toolchain and sysroot
cd qt6pi
wget https://releases.linaro.org/components/toolchain/binaries/latest-7/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz
tar xf gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz 
export PATH=$PATH:/home/ulas/qt5pi/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin
nano ~/.bashrc

rsync -avz --rsync-path="sudo rsync" pi@192.168.16.25:/usr/include sysroot/usr
rsync -avz --rsync-path="sudo rsync" pi@192.168.16.25:/lib sysroot
rsync -avz --rsync-path="sudo rsync" pi@192.168.16.25:/usr/lib sysroot/usr 
rsync -avz --rsync-path="sudo rsync" pi@192.168.16.25:/opt/vc sysroot/opt
```
Compile qt crossly

```bash
  # qtbase
  cd ..
  mkdir qt-cross # for cross qtbase
  cd !$ 
  tar xf ../qtbase-everywhere-src-6.2.4.tar.xz

cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DINPUT_opengl=es2 
  ########-DQT_BUILD_TOOLS_WHEN_CROSSCOMPILING 
  -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF	\
  -DQT_HOST_PATH=/home/ulas/qt6Host	\
  -DCMAKE_STAGING_PREFIX=/home/ulas/qt6pi	\
  -DCMAKE_INSTALL_PREFIX=/home/ulas/qt6crosspi	\
  -DCMAKE_TOOLCHAIN_FILE=$HOME/qt-cross/toolchain.cmake  \
  $HOME/qt-cross/qtbase
```

```bash
cat<<EOF > toolchain.cmake
cmake_minimum_required(VERSION 3.18)
include_guard(GLOBAL)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(TARGET_SYSROOT /opt/qt6pi/sysroot)
set(CROSS_COMPILER /home/user/rpi-sdk/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi)

set(CMAKE_SYSROOT ${TARGET_SYSROOT})

set(ENV{PKG_CONFIG_PATH} "")
set(ENV{PKG_CONFIG_LIBDIR} ${CMAKE_SYSROOT}/usr/lib/pkgconfig:${CMAKE_SYSROOT}/usr/share/pkgconfig)
set(ENV{PKG_CONFIG_SYSROOT_DIR} ${CMAKE_SYSROOT})

set(CMAKE_C_COMPILER ${CROSS_COMPILER}/arm-poky-linux-gnueabi-gcc)
set(CMAKE_CXX_COMPILER ${CROSS_COMPILER}/arm-poky-linux-gnueabi-g++)

set(QT_COMPILER_FLAGS "-march=armv7-a -mfpu=neon -mfloat-abi=hard")
set(QT_COMPILER_FLAGS_RELEASE "-O2 -pipe")
set(QT_LINKER_FLAGS "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

include(CMakeInitializeConfigs)

function(cmake_initialize_per_config_variable _PREFIX _DOCSTRING)
  if (_PREFIX MATCHES "CMAKE_(C|CXX|ASM)_FLAGS")
    set(CMAKE_${CMAKE_MATCH_1}_FLAGS_INIT "${QT_COMPILER_FLAGS}")

    foreach (config DEBUG RELEASE MINSIZEREL RELWITHDEBINFO)
      if (DEFINED QT_COMPILER_FLAGS_${config})
        set(CMAKE_${CMAKE_MATCH_1}_FLAGS_${config}_INIT "${QT_COMPILER_FLAGS_${config}}")
      endif()
    endforeach()
  endif()

  if (_PREFIX MATCHES "CMAKE_(SHARED|MODULE|EXE)_LINKER_FLAGS")
    foreach (config SHARED MODULE EXE)
      set(CMAKE_${config}_LINKER_FLAGS_INIT "${QT_LINKER_FLAGS}")
    endforeach()
  endif()

  _cmake_initialize_per_config_variable(${ARGV})
EOF
```


