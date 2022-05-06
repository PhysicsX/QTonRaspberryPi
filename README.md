# Cross compilation of Qt6.2.4 on Raspberry pi 4
This page representes the related steps to compile Qt6.3.0 crossly for raspberry pi 4. 
This instructions for only Qt6.3.0 base, for other modules, page will be updated.

Youtube video: (this is old one, will be updated )

[![Youtube video link](https://img.youtube.com/vi/TmtN3Rmx9Rk/0.jpg)](//www.youtube.com/watch?v=TmtN3Rmx9Rk?t=0s "ulas dikme")

# Prepare Raspberry pi 4
My raspberry pi image is : 2022-04-04-raspios-bullseye-armhf

When you update the your raspberry pi, firmware version can be different.
If you want, you can make it same with mine.
For this instructions, mine firmware version:
```bash
ulas@raspberrypi:~ $ cat /boot/.firmware_revision
6db8c1cdd3da2f070866d2149c956ce86a4ccdd5
```
To do that instead of empty rpi-update(no argument), just run rpi-update 6db8c1cdd3da2f070866d2149c956ce86a4ccdd5
But it is up to you.

Update raspberry pi
```bash
$ sudo apt update
$ sudo apt full-upgrade
$ sudo reboot
$ sudo rpi-update
$ sudo reboot
```

Install the dependencies

```bash
$ sudo apt-get install -y libboost1.71-all-dev libudev-dev libinput-dev libts-dev \
libmtdev-dev libjpeg-dev libfontconfig1-dev libssl-dev libdbus-1-dev libglib2.0-dev \
libxkbcommon-dev libegl1-mesa-dev libgbm-dev libgles2-mesa-dev mesa-common-dev \
libasound2-dev libpulse-dev gstreamer1.0-omx libgstreamer1.0-dev \
libgstreamer-plugins-base1.0-dev  gstreamer1.0-alsa libvpx-dev libsrtp0-dev libsnappy-dev \
libnss3-dev "^libxcb.*" flex bison libxslt-dev ruby gperf libbz2-dev libcups2-dev \
libatkmm-1.6-dev libxi6 libxcomposite1 libfreetype6-dev libicu-dev libsqlite3-dev libxslt1-dev

$ sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev \
libx11-dev freetds-dev libsqlite0-dev libpq-dev libiodbc2-dev firebird-dev \
libgst-dev libxext-dev libxcb1 libxcb1-dev libx11-xcb1 libx11-xcb-dev \
libxcb-keysyms1 libxcb-keysyms1-dev libxcb-image0 libxcb-image0-dev libxcb-shm0 libxcb-shm0-dev \
libxcb-icccm4 libxcb-icccm4-dev libxcb-sync1 libxcb-sync-dev libxcb-render-util0 \
libxcb-render-util0-dev libxcb-xfixes0-dev libxrender-dev libxcb-shape0-dev libxcb-randr0-dev \
libxcb-glx0-dev libxi-dev libdrm-dev libxcb-xinerama0 libxcb-xinerama0-dev libatspi2.0-dev \
libxcursor-dev libxcomposite-dev libxdamage-dev libxss-dev libxtst-dev libpci-dev libcap-dev \
libxrandr-dev libdirectfb-dev libaudio-dev libxkbcommon-x11-dev

sudo apt remove libzstd-dev libharfbuzz-bin libharfbuzz-dev
```
Create a directory for binaries.Give enough permission for your user.

```bash
$ sudo mkdir /usr/local/qt6pi
$ sudo chown ulas:ulas /usr/local/qt6pi
```

# Prepare Ubuntu
Ubuntu version is 22.04 ( ubuntu-22.04-desktop-amd64 ). 
```bash
$ ulas@ulas:~/qtCrossExample$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 22.04 LTS
Release:	22.04
Codename:	jammy
$ ulas@ulas:~/qtCrossExample$ uname -a
Linux ulas 5.15.0-27-generic #28-Ubuntu SMP Thu Apr 14 04:55:28 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux
```

Update the ubuntu
```bash
$ sudo apt-get update
$ sudo apt-get upgrade
```
Install dependencies
```bash
$ sudo apt-get install make build-essential libclang-dev ninja-build gcc git bison \
python3 gperf pkg-config libfontconfig1-dev libfreetype6-dev libx11-dev libx11-xcb-dev \
libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev libxcb-glx0-dev \
libxcb-keysyms1-dev libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync-dev \
libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev libxcb-render-util0-dev \
libxcb-util-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev \
libatspi2.0-dev libgl1-mesa-dev libglu1-mesa-dev freeglut3-dev
```

## Build CMake from source
During compilation I see a lot of dependency problems because of cmake. Then I simply compiled it from source.
Latest version is better. My version is:
```bash
ulas@ulas:~/qt-cross/qtbase-everywhere-src-6.3.0$ cmake --version
cmake version 3.23.20220428-g90d5d42

CMake suite maintained and supported by Kitware (kitware.com/cmake).
```
Compilation of CMake is easy:
```bash
$ sudo apt install libssl-dev
$ git clone https://github.com/Kitware/CMake.git
$ ./bootstrap && make && sudo make install
```

## Build the qt6 for host
Qt6 is different then Qt5. If you checked my old videos, you can see that, I installed qt5-default on target. But not anymore.
We need to build Qt6 on the host then we will pass the path of installation to the cmake which is used to cross compile.
As I see host version should be same with the cross one.
All the directories are in the home directory except toolchain. ( so check paths about it. )
```bash
$ cd ~
$ wget https://download.qt.io/official_releases/qt/6.3/6.3.0/submodules/qtbase-everywhere-src-6.3.0.tar.xz
$ mkdir qt6HostBuild
$ cd !$
$ tar xf ../qtbase-everywhere-src-6.3.0.tar.xz
$ cd qtbase-everywhere-src-6.3.0
$ cmake -GNinja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DINPUT_opengl=es2 -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/home/ulas/qt6Host
$ cmake --build . --parallel 4
$ cmake --install .
```
Test the host qt6

```bash
cd ..
$ mkdir QtHostExample
$ cd !$
 
$ cat<<EOF > main.cpp 
#include <QCoreApplication>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    qDebug()<<"Hello world";
    return a.exec();
}
EOF
 
$ cat<<EOF > CMakeLists.txt
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
./HelloQt6
```

Get toolchain
toolchain must be extracted under /opt/rpi/

```bash
$ mkdir /opt/rpi
$ cd !$
$ sudo wget www.ulasdikme.com/yedek/rpi-gcc-8.3.0_linux.tar.xz
$ tar xf rpi-gcc-8.3.0_linux.tar.xz 


ulas@ulas:/opt/rpi$ ls -l | grep rpi-gcc-8.3.0
drwxr-xr-x 8 ulas ulas      4096 sep  4  2019 rpi-gcc-8.3.0
-rw-r--r-- 1 root root 200056952 apr 29 12:47 rpi-gcc-8.3.0_linux.tar.xz

```

Install sysroot from raspberry pi target device. ( be sure it is in the same network. Just ping )
Update the user name and the ip adress of yours.
```bash
$ cd $HOME
$ mkdir qt6pi 
$ cd qt6pi

$ rsync -avz --rsync-path="sudo rsync" ulas@192.168.16.20:/usr/include sysroot/usr
$ rsync -avz --rsync-path="sudo rsync" ulas@192.168.16.20:/lib sysroot
$ rsync -avz --rsync-path="sudo rsync" ulas@192.168.16.20:/usr/lib sysroot/usr 
$ rsync -avz --rsync-path="sudo rsync" ulas@192.168.16.20:/opt/vc sysroot/opt

$ wget https://raw.githubusercontent.com/riscv/riscv-poky/master/scripts/sysroot-relativelinks.py
$ chmod +x sysroot-relativelinks.py 
$ python3 sysroot-relativelinks.py sysroot
```

## Compile the Qt6.3.0
lets create qt-cross directory where we can compile qt.

```bash
$ cd ..
$ mkdir qt-cross
$ cd !$
```
Because of cmake we need a toolcain.cmake file(name can be different) which is used to give the some paths for sysroot and compiler flags. This can be different according to your need. This file will be passed to cmake as an argument. 
Update the sysroot path TARGET_SYSROOT with user name. Cross compiler path must be same.

```bash
$ cat<<EOF > toolchain.cmake
cmake_minimum_required(VERSION 3.16)
include_guard(GLOBAL)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(TARGET_SYSROOT /home/ulas/rpi-sdk/sysroot)

set(CROSS_COMPILER /opt/rpi/rpi-gcc-8.3.0/bin/arm-linux-gnueabihf)

set(CMAKE_SYSROOT ${TARGET_SYSROOT})

set(CMAKE_C_COMPILER ${CROSS_COMPILER}-gcc)
set(CMAKE_CXX_COMPILER ${CROSS_COMPILER}-g++)

set(CMAKE_LIBRARY_ARCHITECTURE arm-linux-gnueabihf)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fPIC -Wl,-rpath-link,${CMAKE_SYSROOT}/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE} -L${CMAKE_SYSROOT}/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}")

set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -Wl,-rpath-link,${CMAKE_SYSROOT}/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE} -L${CMAKE_SYSROOT}/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -Wl,-rpath-link,${CMAKE_SYSROOT}/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE} -L${CMAKE_SYSROOT}/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}")

set(QT_COMPILER_FLAGS "-march=armv8-a -mfpu=crypto-neon-fp-armv8 -mtune=cortex-a72 -mfloat-abi=hard")
set(QT_COMPILER_FLAGS_RELEASE "-O2 -pipe")
set(QT_LINKER_FLAGS "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(CMAKE_THREAD_LIBS_INIT "-lpthread")
set(CMAKE_HAVE_THREADS_LIBRARY 1)
set(CMAKE_USE_WIN32_THREADS_INIT 0)
set(CMAKE_USE_PTHREADS_INIT 1)
set(THREADS_PREFER_PTHREAD_FLAG ON)
EOF
```
We can use the same qtbase src tar file for cross compilation. If you check closely, there are DQT_HOST_PATH, DCMAKE_STAGING_PREFIX, DCMAKE_INSTALL_PREFIX, DCMAKE_PREFIX_PATH, DCMAKE_TOOLCHAIN_FILE paths. Please update these according to yours (Change user name). 

```bash
$ tar xf ../qtbase-everywhere-src-6.3.0.tar.xz

$cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DQT_FEATURE_eglfs_egldevice=ON -DQT_FEATURE_eglfs_gbm=ON \
-DQT_BUILD_TOOLS_WHEN_CROSSCOMPILING=ON  -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF \
-DQT_HOST_PATH=/home/ulas/qt6Host -DCMAKE_STAGING_PREFIX=/home/ulas/qt6rpi \
-DCMAKE_INSTALL_PREFIX=/home/ulas/qt6crosspi -DCMAKE_PREFIX_PATH=/home/ulas/rpi-sdk/sysroot/usr/lib/ \
-DCMAKE_TOOLCHAIN_FILE=/home/ulas/qt-cross/toolchain.cmake /home/ulas/qt-cross/qtbase-everywhere-src-6.3.0/
```
After this you should see like this (If it is configured successfully):

```bash

Configure summary:

Building for: linux-g++ (arm, CPU features: )
Compiler: gcc 8.3.0
Build options:
  Mode ................................... release
  Optimize release build for size ........ no
  Fully optimize release builds (-O3) .... no
  Building shared libraries .............. yes
  Using C standard ....................... C11
  Using C++ standard ..................... C++17
  Using ccache ........................... no
  Using new DTAGS ........................ yes
  Relocatable ............................ yes
  Using precompiled headers .............. yes
  Using LTCG ............................. no
  Target compiler supports:
    Extensions ........................... <none>
  Sanitizers:
    Addresses ............................ no
    Threads .............................. no
    Memory ............................... no
    Fuzzer (instrumentation only) ........ no
    Undefined ............................ no
  Build parts ............................ libs tools
Qt modules and options:
  Qt Concurrent .......................... yes
  Qt D-Bus ............................... yes
  Qt D-Bus directly linked to libdbus .... yes
  Qt Gui ................................. yes
  Qt Network ............................. yes
  Qt PrintSupport ........................ yes
  Qt Sql ................................. yes
  Qt Testlib ............................. yes
  Qt Widgets ............................. yes
  Qt Xml ................................. yes
Support enabled for:
  Using pkg-config ....................... yes
  udev ................................... no
  Using system zlib ...................... yes
  Zstandard support ...................... no
  Thread support ......................... yes
Common build options:
  Linker can resolve circular dependencies  yes
Qt Core:
  backtrace .............................. yes
  DoubleConversion ....................... yes
    Using system DoubleConversion ........ no
  GLib ................................... yes
  ICU .................................... yes
  Using system libb2 ..................... no
  Built-in copy of the MIME database ..... yes
  cpp/winrt base ......................... no
  Tracing backend ........................ <none>
  Logging backends:
    journald ............................. no
    syslog ............................... no
    slog2 ................................ no
  PCRE2 .................................. yes
    Using system PCRE2 ................... yes
  CLONE_PIDFD support in forkfd .......... yes
Qt Sql:
  SQL item models ........................ yes
Qt Network:
  getifaddrs() ........................... yes
  IPv6 ifname ............................ yes
  libproxy ............................... no
  Linux AF_NETLINK ....................... yes
  OpenSSL ................................ yes
    Qt directly linked to OpenSSL ........ no
  OpenSSL 1.1 ............................ yes
  DTLS ................................... yes
  OCSP-stapling .......................... yes
  SCTP ................................... no
  Use system proxies ..................... yes
  GSSAPI ................................. no
  Brotli Decompression Support ........... yes
Qt Gui:
  Accessibility .......................... yes
  FreeType ............................... yes
    Using system FreeType ................ yes
  HarfBuzz ............................... yes
    Using system HarfBuzz ................ no
  Fontconfig ............................. yes
  Image formats:
    GIF .................................. yes
    ICO .................................. yes
    JPEG ................................. yes
      Using system libjpeg ............... yes
    PNG .................................. yes
      Using system libpng ................ yes
  Text formats:
    HtmlParser ........................... yes
    CssParser ............................ yes
    OdfWriter ............................ yes
    MarkdownReader ....................... yes
      Using system libmd4c ............... no
    MarkdownWriter ....................... yes
  EGL .................................... yes
  OpenVG ................................. no
  OpenGL:
    Desktop OpenGL ....................... yes
    OpenGL ES 2.0 ........................ no
    OpenGL ES 3.0 ........................ no
    OpenGL ES 3.1 ........................ no
    OpenGL ES 3.2 ........................ no
  Vulkan ................................. no
  Session Management ..................... yes
Features used by QPA backends:
  evdev .................................. yes
  libinput ............................... no
  INTEGRITY HID .......................... no
  mtdev .................................. no
  tslib .................................. no
  xkbcommon .............................. yes
  X11 specific:
    XLib ................................. yes
    XCB Xlib ............................. yes
    EGL on X11 ........................... yes
    xkbcommon-x11 ........................ yes
    xcb-sm ............................... no
QPA backends:
  DirectFB ............................... no
  EGLFS .................................. yes
  EGLFS details:
    EGLFS OpenWFD ........................ no
    EGLFS i.Mx6 .......................... no
    EGLFS i.Mx6 Wayland .................. no
    EGLFS RCAR ........................... no
    eglfs_egldevice ...................... yes
    eglfs_gbm ............................ yes
    EGLFS VSP2 ........................... no
    EGLFS Mali ........................... no
    EGLFS Raspberry Pi ................... no
    EGLFS X11 ............................ yes
  LinuxFB ................................ yes
  VNC .................................... yes
  VK_KHR_display ......................... no
  QNX:
    lgmon ................................ no
    IMF .................................. no
  XCB:
    Using system-provided xcb-xinput ..... yes
    GL integrations:
      GLX Plugin ......................... yes
        XCB GLX .......................... yes
      EGL-X11 Plugin ..................... yes
  Windows:
    Direct 2D ............................ no
    Direct 2D 1.1 ........................ no
    DirectWrite .......................... no
    DirectWrite 3 ........................ no
Qt Widgets:
  GTK+ ................................... no
  Styles ................................. Fusion Windows
Qt Testlib:
  Tester for item models ................. yes
Qt PrintSupport:
  CUPS ................................... yes
Qt Sql Drivers:
  DB2 (IBM) .............................. no
  InterBase .............................. yes
  MySql .................................. no
  OCI (Oracle) ........................... no
  ODBC ................................... no
  PostgreSQL ............................. yes
  SQLite ................................. yes
    Using system provided SQLite ......... no
Core tools:
  qmake tool ............................. yes

Qt is now configured for building. Just run 'cmake --build . --parallel'

Once everything is built, you must run 'cmake --install .'
Qt will be installed into '/home/ulas/qt6crosspi'

To configure and build other Qt modules, you can use the following convenience script:
        /home/ulas/qt6rpi/bin/qt-configure-module

If reconfiguration fails for some reason, try to remove 'CMakeCache.txt' from the build directory 

-- Configuring done
-- Generating done
-- Build files have been written to: /home/ulas/qt-cross/qtbase-everywhere-src-6.3.0
```

Lets start to build and install. Binaries will be in qt6rpi directory. 
```bash
cmake --build . --parallel 4
cmake --install .
```

Send binaries to raspberry pi.
```bash
rsync -avz --rsync-path="sudo rsync" /home/ulas/qt6rpi ulas@192.168.16.20:/usr/local
```

I reccommend you to do not move these directories. There are relative links that script files can work.
When you compile the modules, helper scripts assume directory is in the same path.
## Test compilation
Lets create hello world application
We need simple main.cpp and CMakeLists.txt, main.cpp is same with above.
We need to add CMAKE_C_FLAGS and CMAKE_CXX_FLAGS to our cross compile cmake.
```bash
$ cd ..
$ mkdir qtCrossExample
$ cd !$

$ cat<<EOF > main.cpp 
#include <QCoreApplication>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    qDebug()<<"Hello world";
    return a.exec();
}
EOF
 
$ cat<<EOF > CMakeLists.txt
cmake_minimum_required(VERSION 3.5)

project(HelloQt6 LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6Core)

set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -Wl,-rpath-link, ${CMAKE_SYSROOT}/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE} -L${CMAKE_SYSROOT}/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -Wl,-rpath-link,${CMAKE_SYSROOT}/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE} -L${CMAKE_SYSROOT}/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}")

add_executable(HelloQt6 main.cpp)

target_link_libraries(HelloQt6 Qt6::Core)
EOF
```
Compile the binary, we need qt-cmake file which is created after compilation of the Qt6.3.0 .
It should be in the installation folder.
qt-cmake file creates makefile.
```bash
/home/ulas/qt6rpi/bin/qt-cmake
cmake --build .
$ file HelloQt6
HelloQt6: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-armhf.so.3, for GNU/Linux 3.2.0, with debug_info, not stripped
```

then send the HelloQt6 binary to raspberry pi
```bash
ulas@ulas:~/qtCrossExample$ scp HelloQt6 ulas@192.168.16.20:/home/ulas/
ulas@192.168.16.20's password: 
HelloQt6                                      100%   12KB   3.2MB/s   00:00 
```
Go to raspberry pi or connect via ssh then run:
(We need to export the path for libraries.
When you check the dependecies with ldd, you should not see any non-found ones.) 
```bash
$ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/qt6rpi/lib/
$ cd $HOME
ulas@raspberrypi:~ $ ldd HelloQt6                                                       linux-vdso.so.1 (0xbeeea000)
        /usr/lib/arm-linux-gnueabihf/libarmmem-${PLATFORM}.so => /usr/lib/arm-linux-gnueabihf/libarmmem-v7l.so (0xb6f4b000)
        libdl.so.2 => /lib/arm-linux-gnueabihf/libdl.so.2 (0xb6f1d000)
        libQt6Core.so.6 => /usr/local/qt6rpi/lib/libQt6Core.so.6 (0xb6b0d000)
        libstdc++.so.6 => /lib/arm-linux-gnueabihf/libstdc++.so.6 (0xb6985000)
        libm.so.6 => /lib/arm-linux-gnueabihf/libm.so.6 (0xb6916000)
        libgcc_s.so.1 => /lib/arm-linux-gnueabihf/libgcc_s.so.1 (0xb68e9000)
        libpthread.so.0 => /lib/arm-linux-gnueabihf/libpthread.so.0 (0xb68bd000)
        libc.so.6 => /lib/arm-linux-gnueabihf/libc.so.6 (0xb6769000)
        /lib/ld-linux-armhf.so.3 (0xb6f60000)
        libicui18n.so.67 => /lib/arm-linux-gnueabihf/libicui18n.so.67 (0xb64f1000)
        libicuuc.so.67 => /lib/arm-linux-gnueabihf/libicuuc.so.67 (0xb6353000)
        libicudata.so.67 => /lib/arm-linux-gnueabihf/libicudata.so.67 (0xb482d000)
        libglib-2.0.so.0 => /lib/arm-linux-gnueabihf/libglib-2.0.so.0 (0xb470a000)
        libz.so.1 => /lib/arm-linux-gnueabihf/libz.so.1 (0xb46e2000)
        libpcre2-16.so.0 => /lib/arm-linux-gnueabihf/libpcre2-16.so.0 (0xb4656000)
        libgthread-2.0.so.0 => /lib/arm-linux-gnueabihf/libgthread-2.0.so.0 (0xb4644000)
        librt.so.1 => /lib/arm-linux-gnueabihf/librt.so.1 (0xb462c000)
        libpcre.so.3 => /lib/arm-linux-gnueabihf/libpcre.so.3 (0xb45b5000)
        
ulas@raspberrypi:~ $ ./HelloQt6
Hello world
```

voila  !! You have cross compiled Qt6.3.0 for Raspberry pi !

We can play more with Qt Base. For instance there is a gui library inside base.
Go to host ( ubuntu virtual machine )
```bash
$ cd $HOME
$ mkdir qtCrossExampleGui
$ cd !$

$ cat<<EOF > main.cpp 
#include <QApplication>
#include <QLabel>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    QImage myImage;
    myImage.load("/home/ulas/test.jpg");

    QLabel myLabel;
    myLabel.setPixmap(QPixmap::fromImage(myImage));

    myLabel.show();

    return a.exec();
}
EOF
```
For CMakeLists.txt
```bash
$ cat<<EOF > CMakeLists.txt
cmake_minimum_required(VERSION 3.5)

project(qtGui LANGUAGES CXX)
message("CMAKE_SYSROOT " ${CMAKE_SYSROOT})
message("CMAKE_LIBRARY_ARCHITECTURE " ${CMAKE_LIBRARY_ARCHITECTURE})
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets)

set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -Wl,-rpath-link, ${CMAKE_SYSROOT}/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE} -L${CMAKE_SYSROOT}/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -Wl,-rpath-link,${CMAKE_SYSROOT}/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE} -L${CMAKE_SYSROOT}/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}")

#include_directories(/home/ulas/qt6rpi/include/)

add_executable(qtGui main.cpp)

target_link_libraries(qtGui Qt6::Core Qt6::Gui Qt6::Widgets)
EOF
```

Update the path in the main.cpp (  "/home/ulas/test.jpg") according to target. You can use whichever image. (not all extension is supported but jpg and png are fine.)
Send the binary like before example and run, then:

![alt text](https://github.com/PhysicsX/QTonRaspberryPi/blob/main/voila.png?raw=true)
