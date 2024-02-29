FROM qtcrossbuild:latest

RUN rm -rf /home/ulas/Development/QTonRaspberryPi/project

RUN mkdir -p /home/ulas/Development/QTonRaspberryPi/project

COPY project /home/ulas/Development/QTonRaspberryPi/project

RUN cd /home/ulas/Development/QTonRaspberryPi/project && \
    /build/qt6/pi/bin/qt-cmake . -DCMAKE_BUILD_TYPE=Debug && \
    cmake --build .
