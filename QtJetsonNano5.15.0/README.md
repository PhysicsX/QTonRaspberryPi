# QT5.15.0 compilation for jetson nano

Youtube video:

[![Youtube video link](https://img.youtube.com/vi/PY41CP13p3k/0.jpg)](//www.youtube.com/watch?v=PY41CP13p3k&t=0s "ulas dikme")

Qt Configuration on jetson nano

## jetson nano

Update and upgrade the ubuntu(jetpack)

```bash
sudo apt update
sudo apt upgrade
```

Install dependencies

```bash
apt install -y '.*libxcb.*' libxrender-dev libxi-dev libfontconfig1-dev libudev-dev libgles2-mesa-dev libgl1-mesa-dev gcc git bison python gperf pkg-config make libclang-dev build-essential
```

## Host
pdate and upgrade the ubuntu(20.04)

```bash
sudo apt update
sudo apt upgrade
```

run sudo bash.
If you do not want to run sudo, be carefuk about the permissions

```bash
apt install gcc git bison python gperf pkg-config
apt install make libclang-dev build-essential
```

Create a director under opt for building
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
Download qt single, or if you want to build only base then you can do also.

```bash
wget https://download.qt.io/official_releases/qt/5.15/5.15.0/single/qt-everywhere-src-5.15.0.tar.xz
tar xf qt-everywhere-src-5.15.0.tar.xz
``

Get the related dependencies for sysroot from nano hardware.
Becareful about the slashes.

```bash
rsync -avz root@192.168.16.24:/lib sysroot
rsync -avz root@192.168.16.24:/usr/include sysroot/usr
rsync -avz root@192.168.16.24:/usr/lib sysroot/usr
wget https://raw.githubusercontent.com/Kukkimonsuta/rpi-buildqt/master/scripts/utils/sysroot-relativelinks.py
chmod +x sysroot-relativelinks.py
./sysroot-relativelinks.py sysroot
``

Replace the qmake.conf file with the one in the repo
```bash
cp -r qt-everywhere-src-5.15.0/qtbase/mkspecs/devices/linux-jetson-tk1-g++/ qt-everywhere-src-5.15.0/qtbase/mkspecs/devices/linux-jetson-nano
gedit qt-everywhere-src-5.15.0/qtbase/mkspecs/devices/linux-jetson-nano/qmake.conf
``

Create a director for building binaries and configure qt 

```bash
mkdir qt5buid && cd qt5build
../qt-everywhere-src-5.15.0/configure -opengl es2 -device linux-jetson-nano -device-option CROSS_COMPILE=/opt/qt5jnano/gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu- -sysroot /opt/qt5jnano/sysroot -prefix /usr/local/qt5jnano -opensource -confirm-license -skip qtscript -skip wayland -skip qtwebengine -force-debug-info -skip qtdatavis3d -skip qtlocation -nomake examples -make libs -pkg-config -no-use-gold-linker -v
make -j4
make install
``
