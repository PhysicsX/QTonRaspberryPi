FROM qtcrossbuild:latest

ARG projectDir=project

RUN rm -rf /home/ulas/Development/QTonRaspberryPi/$projectDir

RUN mkdir -p /home/ulas/Development/QTonRaspberryPi/$projectDir

COPY $projectDir /home/ulas/Development/QTonRaspberryPi/$projectDir

RUN cd /home/ulas/Development/QTonRaspberryPi/$projectDir && \
    /build/qt6/pi/bin/qt-cmake . -DCMAKE_BUILD_TYPE=Debug && \
    cmake --build .
