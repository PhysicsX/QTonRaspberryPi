#!/bin/bash

# install sshpass and gdb-multiarch
# sudo apt-get install sshpass gdb-multiarch

# Update the hostPath according to yours
hostPath=/home/ulas/Development/QtJetsonNx6.6.3/project

nxUserName=ulas
nxIpAddress=192.168.178.21
nxPath=/home/ulas
nxPass=1234
qtPathOnTarget=/usr/local/qt6/lib/

case "$1" in
  build_docker_image)
    echo "build docker image to build app"
    docker build -f Dockerfile.app -t final-app .
    ;;
   create_binary_and_copy)
    echo "Remove tmpapp container if it is exist"
    docker rm -f tmpapp
    echo "Create a tmp container to copy binary"
    docker create --name tmpapp final-app
    echo "Copy the binary from tmp container"
    docker cp tmpapp:$hostPath/HelloQt6 ./HelloQt6
    ;;
  send_binary_to_rasp)
    echo "Send binary to rasp over scp"
    sshpass -p "$nxPass" scp HelloQt6 "$nxUserName"@"$nxIpAddress":"$nxPath"
    ;;
  run_gdb_server_on_rasp)
    echo "Start gdb server on raspberry pi"
    sshpass -p "$nxPass" ssh -X "$nxUserName"@"$nxIpAddress" "export LD_LIBRARY_PATH=$qtPathOnTarget pkill gdbserver; gdbserver localhost:2000 $nxPath/HelloQt6 &"
    ;;
  *)
    echo "Usage: $0 {build_docker_image|create_binary_and_copy|send_binary_to_nx|run_gdb_server_on_nx}"
    exit 1
    ;;
esac
