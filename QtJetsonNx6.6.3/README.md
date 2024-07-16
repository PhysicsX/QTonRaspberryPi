# Cross compilation of Qt6.6.3 Jetson Orin/Nx/Nano with Docker(Base and QML packages) and Remote Debugging with Vscode
In this content, you will find a way to cross-compile Qt 6.6.3 for Jetson Orin/Nx/Nano(ubuntu os) hardware using Docker isolation.
This is a complete tutorial that you can learn how to debug the application with vscode.

The primary advantage of Docker is its ability to isolate the build environment. This means you can build Qt without needing a Jetson Development Boards (real hardware) and regardless of your host OS type, as long as you can run Docker (along with QEMU). Additionally, you won’t need to handle dependencies anymore (and I’m not kidding). This approach is easier and less painful.

Watch the video for more details (This is for raspberry pi, for the jetson will be uploaded):

[![Youtube video link](https://img.youtube.com/vi/5XvQ_fLuBX0/0.jpg)](//www.youtube.com/watch?v=5XvQ_fLuBX0?t=0s "ulas dikme")

For remote debugging and follow up [click](https://www.youtube.com/watch?v=RWNWAMT5UkM?t=0s).

I tested this on Ubuntu 22 and 20(as host). Regardless of the version, Qt is successfully cross-compiled and builds a 'Hello World' application (with QML) for Jetson Orin/Nx/Nano.

The steps will show you how to prepare your build environment (in this case, Ubuntu) and run the Docker commands to build Qt 6.6.3. But as I mentioned, you don't need to use Ubuntu; as long as you can run the Docker engine and QEMU, you should achieve the same result on any platform.

If you want to check with virtual machine you can find tutorial [Here](https://github.com/PhysicsX/QTonRaspberryPi/tree/main/QtRaspberryPi6.6.1). Steps are quite same, for this case you need raspberry pi. It is classical way that you can find in this repository. Or If you want more infromation, check old videos about it.
If you want to understand theory for cross complation of Qt for rasppberry pi without Docker in detail, you can watch this [video](https://www.youtube.com/watch?v=oWpomXg9yj0?t=0s) which shows how to compile Qt 6.3.0 for raspberry pi(only toolchain is not compiled).

# Install Docker
NOTE: If you see error during installation, then search on the internet how to install docker and qemu for your os. During time this steps can be different as you expect.

I have ubuntu 22
```bash
ulas@ulas:~$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 22.04.3 LTS
Release:	22.04
Codename:	jammy

```
But I tested also with ubuntu 20
```bash
ulas@ulas:~$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 20.04.6 LTS
Release:	20.04
Codename:	focal

```
Lets install dependencies.

```bash
$ sudo apt update
$ sudo apt install apt-transport-https ca-certificates curl software-properties-common

$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

```
Set up stable repository for docker
```bash
$ echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

$ sudo apt update  
```
Install related packages for Docker

```bash
sudo apt install docker-ce docker-ce-cli containerd.io
```
Verify installation with hello-world image

```bash
$ sudo docker run hello-world
```

Lets manage user permission for Docker. Docker uses UDS so permission is needed.
```bash
$ sudo usermod -aG docker ${USER}
$ su - ${USER}
$ sudo systemctl enable docker
```

We also need to install QEMU, with it, it is possible to emulate/run raspbian os like it is on real raspberry pi 4 hardware

```bash
$ sudo apt-get install qemu qemu-user-static qemu-user binfmt-support
$ docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```
Update the config.json file to enable experimental feature.

```bash
nano ~/.docker/config.json
```

```bash
{
  "experimental": "enabled"
}
```

It is a good idea to restart Docker
```bash
sudo systemctl restart docker
```

# Compile Qt 6.6.3 with Docker

When I experimented with this idea, I expected to create a single Dockerfile with different stages, allowing me to switch between them even if they involved different hardware architectures. However, it didn't work as expected, so I ended up creating two separate Dockerfiles.

First, we will create a ubuntu  20 environment and emulate it. Then, we need to copy the relevant headers and libraries for later compilation

Run the command to create ubuntu image.
```bash
$ docker buildx build --platform linux/arm64 --load -f DockerFileNx -t nximage .
```
When it finishes, you will find a file named 'nxSysroot.tar.gz' in the '/' directory within the image.
Let's copy it to the same location where the Dockerfile exists. 

To copy the file, you need to create a temporary container using the 'create' command. You can delete this temporary container later if you wish
```bash
$ docker create --name temp-arm nximage
$ docker cp temp-arm:/nxSysroot.tar.gz ./nxSysroot.tar.gz
```
This nxSysroot.tar.gz file will be copied by the another image that is why location of the tar file is important. You do not need to extract it. Do not touch it.

Now it is time to create ubuntu 22 image and compile the Qt 6.6.3.
In one of the previous commands you used DockerFileNx, this file is written for Jetson boards, now we are going to use only Dockerfile which is default name that means we do not need to specify path or name explicitly. But if  you want you can change the name, you already now how you can pass the file name (with -f)

```bash
$ docker build -t qtcrossbuild .
```

As you see there is no buildx in this command because buildx uses qemu and we do not need qemu for x86 ubuntu. After some time, (I tested with 16GB RAM and it took around couple of hours) you see that image will be created without an error. After this, you can find HelloQt6 binary which is ready to run on Jetson board, in the /project directory in the image. So lets copy it. As we did before, you need to create temporary container to copy it.

```bash
$ docker create --name tmpbuild qtcrossbuild
$ docker cp tmpbuild:/project/HelloQt6 ./HelloQt6
```

As you see, example application is compiled for arm.
```bash
ulas@ulas:~/QtJetsonNx$ file HelloQt6 
HelloQt6: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 3.7.0, with debug_info, not stripped
```

To test the hello world, you need to copy and send the compiled qt binaries in the image.
```bash
$ docker cp tmpbuild:/qt-nx-binaries.tar.gz ./qt-nx-binaries.tar.gz
$ scp qt-nx-binaries.tar.gz ulas@192.168.16.20:/home/ulas/
$ ssh ulas@192.168.16.25
$ ulas@jetson:~ sudo mkdir /usr/local/qt6
$ ulas@jetson:~ sudo tar -xvf qt-nx-binaries.tar.gz -C /usr/local/qt6
$ ulas@jetson:~ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/qt6/lib/
```
Extract it under /usr/local or wherever you want and do not forget to add the path to LD_LIBRARY_PATH in case of path is not in the list.

```bash
ulas@Jetson:~ $ ./HelloQt6
Hello world
```

# Debugging of compilation
Nothing is free! Okay now we find a nice way to compile or build Qt applications but there is a tradeoff. Debugging is really hard. So If you want to change Dockerfile then first you sould build or test the steps on VM to be sure. If you know what you are doing then do not worry.

Each RUN commands output are printed in Build.log file that you can find in the build directory of image.

```bash
docker cp tmpbuild:/build.log ./build.log
```

# Cross Development and Remote Debugging of Application with vscode ( this is tested with rasp but you can adjust it accordingly)

Detailed information:

[![Youtube video link](https://img.youtube.com/vi/RWNWAMT5UkM/0.jpg)](//www.youtube.com/watch?v=RWNWAMT5UkM?t=0s "ulas dikme")

Now, you can build your application by simply adding your files to the project directory and running the command:

```bash
$ docker build -t qtcrossbuild .
```

If you do not modify the Dockerfile, the above command will only compile the code. However, even if you don't alter the Dockerfile, if there is any update to Ubuntu, Docker will rebuild the image starting from the Ubuntu layer. This means it will take more time. To compile the Qt application you wish to develop, this is not necessary. There is another Dockerfile, Dockerfile.app, which allows you to compile only the application. If you examine the contents of this file, you will find:

```bash
FROM qtcrossbuild:latest
```
This indicates that if you build an image with Dockerfile.app, it will utilize the qtcrossbuild image. There's no need to run qtcrossbuild again. 

If you run:

```bash
$ docker build -f Dockerfile.app -t final-app .
```
With the final-app image, you can create a container solely for compilation purposes. Docker caches the previous commands, so when you run this command, it will not start from scratch but only execute the latest command where you wish to compile your application. The compilation process will begin in the image, then, as before, create a temporary container and copy your binary:

```bash
$ docker create --name tmpapp final-app
$ docker cp tmpapp:/projectPath/HelloQt6 ./HelloQt6
```
If you do not want to use the cache, or if you want to start building the same image anew, use:
```bash
$ docker build -t qtcrossbuild . --no-cache
```

~~However, if you prefer not to follow these steps, I have shared the tar files that I compiled for the Raspberry Pi, along with the related sysroot and toolchain. You can download them. In this case, you will need to have the correct dependencies. It's your choice.~~

I assume you have vscode already, we need some dependencies on the host for remote debugging with vscode.
```bash
$ sudo apt-get install sshpass gdb-multiarch
```
sshpass is needed to start gdbserver on the target remotely, and gdb-multiarch is the debugger itself for the cross-compiled binary.

In VS Code, you will need the "C/C++ IntelliSense, debugging, and code browsing" extension.

![Qml Remote Debugging with vscode](https://ulasdikme.com/yedek/installedExtensions.png)

On the target, install gdbserver.
```bash
$ sudo apt-get install gdbserver
```

To debug the cross-compiled application, which was compiled in the container, we can use VS Code. The steps are simple:

1. Compile the application using Dockerfile.app.
2. Copy the binary of the application to the target.
3. Run gdbserver on the target before debug process.
4. Connect to the server from the host using VS Code, then start debugging.

There are multiple ways to implement these steps. I have created a bash script called helperTasks.sh. This script contains commands to compile the application, send the binary to the target, and start gdbserver. The script acts as an intermediary between VS Code and the user. When you want to call one of these functionalities, VS Code may access them through tasks.json. As mentioned, there are many ways to do this; you can directly update tasks.json as well. Tasks.json is located under .vscode in the repository. If you start VS Code directly in the root of the repository, it will automatically detect related files, and everything will be ready to go.

For debugging itself, VS Code needs a launch.json configuration file. In this file, you need to specify the path of the application and other related options. However, be careful; the paths for the binary should be on the host, so a copy of the binary must also exist on the host.

One trick to note is the importance of the checkout path. When you compile the application in the container (with project and projectQml as ready-to-use examples), the binary contains information about the absolute path of the project files, which were copied from the host to the container. It has the path in the container, and when you copy it to the host, it doesn't recognize that the path has changed. Therefore, you need to copy the binary to the exact same location on the host, or you need to change the path in the container. That's why I created a variable for the path in both Dockerfile.app and helperTasks.sh. Please check and update them accordingly.

![Qml Remote Debugging with vscode](https://ulasdikme.com/yedek/qt6DebugVscodeScreenShot.png)

For more detalied information please watch the video about debugging.


Enjoy.

# Configuration parameters

For reference the qt is compiled with below parameters in this example 

```bash
-- Configure summary:

Building for: linux-g++ (arm64, CPU features: cx16 neon)
Compiler: gcc 9.4.0
Build options:
  Mode ................................... release
  Optimize release build for size ........ no
  Fully optimize release builds (-O3) .... no
  Building shared libraries .............. yes
  Using ccache ........................... no
  Unity Build ............................ no
  Using new DTAGS ........................ yes
  Relocatable ............................ yes
  Using precompiled headers .............. yes
  Using Link Time Optimization (LTCG) .... no
  Using Intel CET ........................ no
  Target compiler supports:
    ARM Extensions ....................... NEON
  Sanitizers:
    Addresses ............................ no
    Threads .............................. no
    Memory ............................... no
    Fuzzer (instrumentation only) ........ no
    Undefined ............................ no
  Build parts ............................ libs
  Install examples sources ............... no
Qt modules and options:
  Qt Concurrent .......................... yes
  Qt D-Bus ............................... yes
  Qt D-Bus directly linked to libdbus .... no
  Qt Gui ................................. yes
  Qt Network ............................. yes
  Qt PrintSupport ........................ yes
  Qt Sql ................................. yes
  Qt Testlib ............................. yes
  Qt Widgets ............................. yes
  Qt Xml ................................. yes
Support enabled for:
  Using pkg-config ....................... yes
  Using vcpkg ............................ no
  udev ................................... yes
  OpenSSL ................................ no
    Qt directly linked to OpenSSL ........ no
  OpenSSL 1.1 ............................ no
  OpenSSL 3.0 ............................ no
  Using system zlib ...................... yes
  Zstandard support ...................... no
  Thread support ......................... yes
Common build options:
  Linker can resolve circular dependencies  yes
Qt Core:
  backtrace .............................. yes
  DoubleConversion ....................... yes
    Using system DoubleConversion ........ no
  CLONE_PIDFD support in forkfd .......... yes
  GLib ................................... no
  ICU .................................... no
  Using system libb2 ..................... no
  Built-in copy of the MIME database ..... yes
  Application permissions ................ yes
  Defaulting legacy IPC to POSIX ......... no
  Tracing backend ........................ <none>
  OpenSSL based cryptographic hash ....... no
  Logging backends:
    journald ............................. no
    syslog ............................... no
    slog2 ................................ no
  PCRE2 .................................. yes
    Using system PCRE2 ................... no
Qt Sql:
  SQL item models ........................ yes
Qt Network:
  getifaddrs() ........................... yes
  IPv6 ifname ............................ yes
  libproxy ............................... no
  Linux AF_NETLINK ....................... yes
  DTLS ................................... no
  OCSP-stapling .......................... no
  SCTP ................................... no
  Use system proxies ..................... yes
  GSSAPI ................................. no
  Brotli Decompression Support ........... no
  qIsEffectiveTLD() ...................... yes
    Built-in publicsuffix database ....... yes
    System publicsuffix database ......... yes
Core tools:
  Android deployment tool ................ no
  macOS deployment tool .................. no
  Windows deployment tool ................ no
  qmake .................................. yes
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
      Using system libjpeg ............... no
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
    Desktop OpenGL ....................... no
    OpenGL ES 2.0 ........................ yes
    OpenGL ES 3.0 ........................ yes
    OpenGL ES 3.1 ........................ yes
    OpenGL ES 3.2 ........................ yes
  Vulkan ................................. no
  Session Management ..................... yes
Features used by QPA backends:
  evdev .................................. yes
  libinput ............................... no
  HiRes wheel support in libinput ........ no
  INTEGRITY HID .......................... no
  mtdev .................................. no
  tslib .................................. no
  xkbcommon .............................. yes
  X11 specific:
    xlib ................................. yes
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
    EGLFS EGLDevice ...................... yes
    EGLFS GBM ............................ yes
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
    Using system-provided xcb-xinput ..... no
    GL integrations:
      GLX Plugin ......................... no
        XCB GLX .......................... no
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
  Batch tests ............................ no
Qt PrintSupport:
  CUPS ................................... no
Qt Sql Drivers:
  DB2 (IBM) .............................. no
  InterBase .............................. no
  MySql .................................. no
  OCI (Oracle) ........................... no
  ODBC ................................... no
  PostgreSQL ............................. no
  SQLite ................................. yes
    Using system provided SQLite ......... no
  Mimer .................................. no
 

Note: Disabling X11 Accessibility Bridge: D-Bus or AT-SPI is missing.
Note: Due to CMAKE_STAGING_PREFIX usage and an unfixed CMake bug,
      to ensure correct build time rpaths, directory-level install
      rules like ninja src/gui/install will not work.
      Check QTBUG-102592 for further details.

-- 

Qt is now configured for building. Just run 'cmake --build . --parallel'

Once everything is built, you must run 'cmake --install .'
Qt will be installed into '/usr/local/qt6'


