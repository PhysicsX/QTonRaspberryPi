#!/bin/bash

# install sshpass and gdb-multiarch
# sudo apt-get install sshpass gdb-multiarch

# Update the hostPath according to yours
hostPath=/home/ulas/Development/QTonRaspberryPi/project

piUserName=ulas
piIpAddress=192.168.178.21
piPath=/home/ulas
piPass=1234
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
    sshpass -p "$piPass" scp HelloQt6 "$piUserName"@"$piIpAddress":"$piPath"
    ;;
  run_gdb_server_on_rasp)
    echo "Start gdb server on raspberry pi"
    sshpass -p "$piPass" ssh -X "$piUserName"@"$piIpAddress" "export LD_LIBRARY_PATH=$qtPathOnTarget pkill gdbserver; gdbserver localhost:2000 $piPath/HelloQt6 &"
    ;;
  *)
    echo "Usage: $0 {build_docker_image|create_binary_and_copy|send_binary_to_rasp|run_gdb_server_on_rasp}"
    exit 1
    ;;
esac
