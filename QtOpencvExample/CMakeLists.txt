cmake_minimum_required(VERSION 3.10)
project(QtOpencvHello)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_PREFIX_PATH "/build/sysroot/usr/lib/aarch64-linux-gnu")

set(Qt6_DIR "/build/qt6/pi/lib/cmake/Qt6")
set(OpenCV_DIR "/build/opencvBuild")     # Update for cross-compiled OpenCV

set(CMAKE_MODULE_PATH "/build/qt6/pi/lib/cmake/Qt6/platforms" ${CMAKE_MODULE_PATH})
find_package(Qt6 REQUIRED COMPONENTS Gui Widgets OpenGL)

find_package(Qt6 REQUIRED COMPONENTS Widgets Gui)
find_package(OpenCV REQUIRED)

include_directories(${Qt6_INCLUDE_DIRS})
message(STATUS "Qt6 Include Dirs: ${Qt6_INCLUDE_DIRS}")
message(STATUS "Qt6 Libraries: ${Qt6_LIBRARIES}")

# Ensure CMake searches for BLAS and LAPACK in the sysroot
set(LAPACK_LIB "/build/sysroot/usr/lib/aarch64-linux-gnu/liblapack.so")
set(BLAS_LIB "/build/sysroot/usr/lib/aarch64-linux-gnu/libblas.so")

add_executable(QtOpencvHello main.cpp)
target_link_libraries(QtOpencvHello PRIVATE Qt6::Widgets Qt6::Gui ${OpenCV_LIBS} ${LAPACK_LIB} ${BLAS_LIB})
