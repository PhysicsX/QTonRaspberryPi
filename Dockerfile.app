FROM qtcrossbuild:latest

RUN rm -rf /build/project

RUN mkdir /build/project

COPY project /build/project

RUN { \
    cd project && \
    /build/qt6/pi/bin/qt-cmake -DCMAKE_BUILD_TYPE=Debug && \
    cmake --build . --config Debug; \
}
