#!/bin/bash

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
    docker cp tmpapp:/home/ulas/Development/QTonRaspberryPi/project/HelloQt6 ./HelloQt6
    ;;
  send_binary_to_rasp)
    echo "Send binary to rasp over scp"
    sshpass -p '1234' scp HelloQt6 ulas@192.168.178.21:/home/ulas
    ;;
  run_gdb_server_on_rasp)
    echo "Start gdb server on raspberry pi"
    sshpass -p '1234' ssh -X ulas@192.168.178.21 'export LD_LIBRARY_PATH=/usr/local/qt6/lib/ pkill gdbserver; gdbserver localhost:2000 /home/ulas/HelloQt6 &'
    ;;
  *)
    echo "Usage: $0 {build_docker_image|create_tmp_container|copy_binary|send_binary_to_rasp}"
    exit 1
    ;;
esac
