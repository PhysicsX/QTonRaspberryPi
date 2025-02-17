# Specify the target system
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(TARGET_ARCHITECTURE aarch64-linux-gnu)
set(CMAKE_SYSROOT ${TARGET_SYSROOT})

# Set the C and C++ compilers
set(CMAKE_C_COMPILER /usr/bin/${TARGET_ARCHITECTURE}-gcc-12)
set(CMAKE_CXX_COMPILER /usr/bin/${TARGET_ARCHITECTURE}-g++-12)

# Define the sysroot path (adjust this to your sysroot location)
set(CMAKE_SYSROOT /build/sysroot)
set(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT})

# Set compiler optimizations for ARM
set(CMAKE_C_FLAGS "-march=armv8.2-a+dotprod+fp16 -mtune=cortex-a72 -ftree-vectorize --sysroot=${CMAKE_SYSROOT}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "-march=armv8.2-a+dotprod+fp16 -mtune=cortex-a72 -ftree-vectorize --sysroot=${CMAKE_SYSROOT}" CACHE STRING "" FORCE)

# Set linker flags
set(CMAKE_EXE_LINKER_FLAGS "-L${CMAKE_SYSROOT}/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,${CMAKE_SYSROOT}/usr/lib/aarch64-linux-gnu")

# Set CMake paths for Qt and OpenCV
set(Qt6_DIR "/build/qt6/pi/lib/cmake/Qt6")
set(OpenCV_DIR "/build/opencvBuild")

# Set CMake module and package path
set(CMAKE_PREFIX_PATH "${Qt6_DIR};${OpenCV_DIR}")

# Define how CMake should search for dependencies
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
