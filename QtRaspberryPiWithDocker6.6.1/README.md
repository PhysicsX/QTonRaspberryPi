# Cross compilation of Qt6.6.1 on Raspberry pi 4 with Docker
In this content, you can find a way to make cross compilation Qt6.6.1 for Raspberry pi 4 hardware with Docker isolation.
The main advantage of the docker is to isolate the build environment, that means you can build the Qt without need of Raspberry pi (real hardware) and regardless of host software as long as you are able to run docker (and with QEMU) and you do not need to handle dependencies anymore (I am not kidding). It will be more easy and less painfull.

I tested on ubuntu 22 and 20, regardless of version, Qt is sucessfully compiled and build hello world application for raspberry pi.

The steps will show you how to make your host environment(in this case ubuntu) ready and run the docker comamnds to build Qt6.6.1. But as I told you, you do not need to use ubuntu, as long as you run the Docker engine and QEMU then you should have same result.

If you want to check with virtual machine you can find tutorial [Here](https://github.com/PhysicsX/QTonRaspberryPi/tree/main/QtRaspberryPi6.6.1). Steps are quite same, for this case you need raspberry pi. It is classical way that you can find in this repository. Or If you want more infromation, check old videos about it.
If you want to understand theory in detail, you can watch this [video](https://www.youtube.com/watch?v=oWpomXg9yj0?t=0s) which shows how to compile Qt 6.3.0 for raspberry pi(only toolchain is not compiled).

# Install Docker
NOTE: If you see error during installation, then search on the internet how to install docker and qemu for your os. During time this steps can be different as you expect.

I have ubuntu 22
```bash
ulas@ulas:~/QTonRaspberryPi/QtRaspberryPiWithDocker6.6.1$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 22.04.3 LTS
Release:	22.04
Codename:	jammy

```
But I tested also with ubuntu 20
```bash
ulas@ulas:~/QTonRaspberryPi/QtRaspberryPiWithDocker6.6.1$ lsb_release -a
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

# Compile Qt 6.6.1 with Docker

When I started this work, I was expecting that I can create single Dockerfile with different stages where I can switch between them even if they are emulated or not. But it did not work as I expected so I created two Dockerfiles seperately.

First we will create rasbian(debian) and emulate it then we need to copy related headers/libraries for later compilation. 
Run the command to create rasbian(debian) image.
```bash
$ docker buildx build --platform linux/arm64 -f DockerFileRasp -t raspimage .
```
When it will finish, you will find in the image there is a rasp.tar.gz file under /build directory. 
Lets copy it in the same location where Dockerfile is exist. Just copy where you pull branch.
To copy, it is needed to create temporary container with "create" command. You can delete this temporary container later if you like.
```bash
$ docker create --name temp-arm raspimage
$ docker cp temp-arm:/build/rasp.tar.gz ./rasp.tar.gz
```
This rasp.tar.gz file will be copied by the another image. Location is important. You do not need to extract it. Do not touch it.

Now it is time to create ubuntu 22 image and compile the Qt 6.6.1.
In one of the previous commands you used DockerFileRasp, this file is written for raspberry pi, now we are going to use only Dockerfile which is default name that means we do not need to specify path or name explicitly. But if  you want you can change the name, you already now how you can pass the file name (with -f)

```bash
$ docker build -t qtcrossbuild .
```

As you see there is no buildx in this command because buildx uses qemu for ubuntu22 we do not need qemu for x86 ubuntu. After some time, ( I tested with 16GB RAM and it took around couple of hours) you see that image will be created without an error. After this, you can find HelloQt6 binary which is ready to run on Raspberry pi, in the /build/project directory in the image. So lets copy it. As we did before, you need to create temporary container to copy it.

```bash
$ docker create --name tmpbuild qtcrossbuild
$ docker cp tmpbuild:/build/project/HelloQt6 ./HelloQt6
```

As you see, example application is compiled for arm.
```bash
ulas@ulas:~/QTonRaspberryPi/QtRaspberryPiWithDocker6.6.1$ file HelloQt6 
HelloQt6: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 3.7.0, with debug_info, not stripped
```

# Compile Qt 6.6.1 with Docker
Nothing is free! Okay now we find a nice way to compile or build Qt applications but there is a tradeoff. Debugging is really hard. So If you want to change Dockerfile then first you sould build or test the steps on VM to be sure. If you know what you are doing then do not worry.

Each RUN commands output are printed in Build.log file that you can find in the build directory of image.

```bash
docker cp tmpbuild:/build.log ./build.log
```

# What is next ?
So now, you can build your application just add your files under project directory and run the 
```bash
$ docker build -t qtcrossbuild .
```
Docker caches the previous commands so when you run this command it will not start from scratch. Only latest command where you want to compile your applicaiton. Compilation process will start in the image then like you did before create a temp container and copy your binary. 

if you do not want to cache, or start to build same image then:
```bash
$ docker build -t qtcrossbuild . --no-cache
```

But If you do not want to run these steps, I shared the tar files that I compiled for raspberry pi and related sysroot and toolchain. You can download it. In this case you need to have correct dependencies. It is up to you.

Enjoy.




