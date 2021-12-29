# QT5.15.0 compilation for jetson nano with X option for ubuntu 18.04

This guide is tested with only xcb platform for widget applications

On Linux, the xcb QPA (Qt Platform Abstraction) platform plugin is used. It provides the basic functionality needed by Qt GUI and Qt Widgets to run against X11.
https://doc.qt.io/qt-5/linux-requirements.html

you can watch also Youtube video:

[![Youtube video link](https://img.youtube.com/vi/PY41CP13p3k/0.jpg)](//www.youtube.com/watch?v=PY41CP13p3k&t=0s "ulas dikme")

Qt Configuration on jetson nano
Plese watch the video carefully. :)

## jetson nano

Update and upgrade the ubuntu(jetpack 4.6)

```bash
sudo apt update
sudo apt upgrade
```

Install qt5-default for xcb option
```bash
sudo apt-get build-dep qt5-default
```

If you see an error like this:
```bash
E: You must put some 'source' URIs in your sources.list
```
Then you will need to enable the "Source code" option in Software and Updates > Ubuntu Software under the "Downloadable from the Internet" section. This setting can also be found by running software-properties-gtk.

otherwise after configuration you will see like this:

ERROR: Feature 'xcb' was enabled, but the pre-condition 'features.thread && libs.xcb && tests.xcb_syslibs && features.xkbcommon-x11' failed.


Install dependencies

```bash
sudo apt install ^libxcb.*-dev and libx11-xcb-dev
sudo apt install '.*libxcb.*' libxrender-dev libxi-dev libfontconfig1-dev libudev-dev libgles2-mesa-dev libgl1-mesa-dev gcc git bison python gperf pkg-config make libclang-dev build-essential
sudo apt install libfontconfig1-dev libudev-dev libegl1-mesa-dev libgbm-dev libgles2-mesa-dev mesa-common-dev libxcomposite1 libx11-xcb-dev libxcb-keysyms1 libxcb-keysyms1-dev libxcb-image0 libxrender-dev libxss-dev libxtst-dev libxrandr-dev
```

## Host
update and upgrade the ubuntu(18.04.6)

```bash
sudo apt update
sudo apt upgrade
```

For fullscreen to insert guest additions
for this restart can be needed after update and upgrade
```bash
sudo apt install build-essential dkms linux-headers-$(uname -r)
```

run sudo bash.
If you do not want to run sudo, be careful about the permissions

```bash
apt install gcc git bison python gperf pkg-config
apt install make libclang-dev build-essential
```

Create a directory under opt for building
```bash
mkdir /opt/qt5jnano
chown jnanoqt:jnanoqt /opt/qt5jnano
cd /opt/qt5jnano/
```

Install linaro toolchain

```bash
wget https://releases.linaro.org/components/toolchain/binaries/latest-5/aarch64-linux-gnu/gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz
tar xf gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz 
export PATH=$PATH:/opt/qt5jnano/gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu/bin

```
Download qt base 5.15.

```bash
wget https://download.qt.io/archive/qt/5.15/5.15.0/submodules/qtbase-everywhere-src-5.15.0.tar.xz
tar xf qtbase-everywhere-src-5.15.0.tar.xz 
```

Get the related dependencies for sysroot from nano hardware.
Becareful about the slashes.

```bash
rsync -avz root@192.168.16.24:/lib sysroot
rsync -avz root@192.168.16.24:/usr/include sysroot/usr
rsync -avz root@192.168.16.24:/usr/lib sysroot/usr
wget https://raw.githubusercontent.com/Kukkimonsuta/rpi-buildqt/master/scripts/utils/sysroot-relativelinks.py
chmod +x sysroot-relativelinks.py
./sysroot-relativelinks.py sysroot
```

Replace the qmake.conf file with the one in the repo
```bash
cp -r qt-everywhere-src-5.15.0/qtbase/mkspecs/devices/linux-jetson-tk1-g++/ qt-everywhere-src-5.15.0/qtbase/mkspecs/devices/linux-jetson-nano
gedit qt-everywhere-src-5.15.0/qtbase/mkspecs/devices/linux-jetson-nano/qmake.conf
```

Create a directory for building binaries and configure qt 

```bash
mkdir qt5buid && cd qt5build
../qtbase-everywhere-src-5.15.0/configure -opengl desktop -xcb -xcb-xlib -device linux-jetson-nano -device-option CROSS_COMPILE=/opt/qt5jnano/gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu- -sysroot /opt/qt5jnano/sysroot -prefix /usr/local/qt5jnano -opensource -confirm-license -force-debug-info -nomake examples -nomake tests -make libs -no-use-gold-linker -v
```
After Configuration done you should see like this:
```bash
Configure summary:

Building on: linux-g++ (x86_64, CPU features: mmx sse sse2)
Building for: devices/linux-jetson-nano (arm64, CPU features: neon crc32)
Target compiler: gcc 5.5.0
Configuration: cross_compile compile_examples enable_new_dtags force_debug_info largefile neon precompile_header shared shared rpath release c++11 c++14 concurrent dbus no-pkg-config reduce_exports stl
Build options:
  Mode ................................... release (with debug info)
  Optimize release build for size ........ no
  Building shared libraries .............. yes
  Using C standard ....................... C11
  Using C++ standard ..................... C++14
  Using ccache ........................... no
  Using new DTAGS ........................ yes
  Generating GDB index ................... no
  Relocatable ............................ yes
  Using precompiled headers .............. yes
  Using LTCG ............................. no
  Target compiler supports:
    NEON ................................. yes
  Build parts ............................ libs
Qt modules and options:
  Qt Concurrent .......................... yes
  Qt D-Bus ............................... yes
  Qt D-Bus directly linked to libdbus .... no
  Qt Gui ................................. yes
  Qt Network ............................. yes
  Qt Sql ................................. yes
  Qt Testlib ............................. yes
  Qt Widgets ............................. yes
  Qt Xml ................................. yes
Support enabled for:
  Using pkg-config ....................... no
  udev ................................... yes
  Using system zlib ...................... yes
  Zstandard support ...................... no
Qt Core:
  DoubleConversion ....................... yes
    Using system DoubleConversion ........ yes
  GLib ................................... no
  iconv .................................. no
  ICU .................................... yes
  Built-in copy of the MIME database ..... yes
  Tracing backend ........................ <none>
  Logging backends:
    journald ............................. no
    syslog ............................... no
    slog2 ................................ no
  PCRE2 .................................. yes
    Using system PCRE2 ................... no
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
Qt Gui:
  Accessibility .......................... yes
  FreeType ............................... yes
    Using system FreeType ................ yes
  HarfBuzz ............................... yes
    Using system HarfBuzz ................ yes
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
QPA backends:
  DirectFB ............................... no
  EGLFS .................................. yes
  EGLFS details:
    EGLFS OpenWFD ........................ no
    EGLFS i.Mx6 .......................... no
    EGLFS i.Mx6 Wayland .................. no
    EGLFS RCAR ........................... no
    EGLFS EGLDevice ...................... no
    EGLFS GBM ............................ no
    EGLFS VSP2 ........................... no
    EGLFS Mali ........................... no
    EGLFS Raspberry Pi ................... no
    EGLFS X11 ............................ yes
  LinuxFB ................................ yes
  VNC .................................... yes
  XCB:
    Using system-provided xcb-xinput ..... yes
    Native painting (experimental) ....... no
    GL integrations:
      GLX Plugin ......................... yes
        XCB GLX .......................... yes
      EGL-X11 Plugin ..................... yes
Qt Sql:
  SQL item models ........................ yes
Qt Widgets:
  GTK+ ................................... no
  Styles ................................. Fusion Windows
Qt PrintSupport:
  CUPS ................................... yes
Qt Sql Drivers:
  DB2 (IBM) .............................. no
  InterBase .............................. no
  MySql .................................. no
  OCI (Oracle) ........................... no
  ODBC ................................... yes
  PostgreSQL ............................. no
  SQLite2 ................................ no
  SQLite ................................. yes
    Using system provided SQLite ......... no
  TDS (Sybase) ........................... yes
Qt Testlib:
  Tester for item models ................. yes

Note: Also available for Linux: linux-clang linux-icc

Note: Disabling X11 Accessibility Bridge: D-Bus or AT-SPI is missing.

Qt is now configured for building. Just run 'make'.
Once everything is built, you must run 'make install'.
Qt will be installed into '/opt/qt5jnano/sysroot/usr/local/qt5jnano'.

Prior to reconfiguration, make sure you remove any leftovers from
the previous build.
```
Do not worry about the notes. This is for only base module.


After configuration compile the base.
```bash
make -j4
make install
```

Send compiled binaries to jetson nano

```bash
rsync -avz sysroot/usr/local/qt5jnano root@192.168.16.24:/usr/local
```
