cmake_minimum_required(VERSION 3.25)
include_guard(GLOBAL)

# Set the system name and processor for cross-compilation
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# Set the target sysroot and architecture
set(TARGET_SYSROOT /build/sysroot)
set(TARGET_ARCHITECTURE aarch64-linux-gnu)
set(CMAKE_SYSROOT ${TARGET_SYSROOT})
set(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT})

# Configure the pkg-config environment variables
set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:${CMAKE_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}/pkgconfig")
set(ENV{PKG_CONFIG_LIBDIR} "/usr/lib/pkgconfig:/usr/share/pkgconfig:${CMAKE_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}/pkgconfig:${CMAKE_SYSROOT}/usr/lib/pkgconfig")
set(ENV{PKG_CONFIG_SYSROOT_DIR} "${CMAKE_SYSROOT}")

# Set the C and C++ compilers
set(CMAKE_C_COMPILER /usr/bin/${TARGET_ARCHITECTURE}-gcc-14)
set(CMAKE_CXX_COMPILER /usr/bin/${TARGET_ARCHITECTURE}-g++-14)

# Set compiler optimizations for ARM
set(CMAKE_C_FLAGS "-march=armv8-a -mtune=cortex-a72 -O2 --sysroot=${CMAKE_SYSROOT}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "-march=armv8-a -mtune=cortex-a72 -O2 --sysroot=${CMAKE_SYSROOT}" CACHE STRING "" FORCE)
# set(CMAKE_C_FLAGS "-march=armv8.2-a+dotprod+fp16 -mtune=cortex-a72 -ftree-vectorize --sysroot=${CMAKE_SYSROOT}" CACHE STRING "" FORCE)
# set(CMAKE_CXX_FLAGS "-march=armv8.2-a+dotprod+fp16 -mtune=cortex-a72 -ftree-vectorize --sysroot=${CMAKE_SYSROOT}" CACHE STRING "" FORCE)

# Set linker flags to use sysroot libraries + OpenGL + Math
set(OPENGL_LIB_PATH "${CMAKE_SYSROOT}/usr/lib/aarch64-linux-gnu")
set(MATH_LIB_PATH "${CMAKE_SYSROOT}/usr/lib/aarch64-linux-gnu")

set(CMAKE_EXE_LINKER_FLAGS_INIT "--sysroot=${CMAKE_SYSROOT} \
    -L${CMAKE_SYSROOT}/usr/lib \
    -Wl,-rpath-link,${CMAKE_SYSROOT}/lib:${CMAKE_SYSROOT}/usr/lib \
    -L${MATH_LIB_PATH} -L${OPENGL_LIB_PATH} \
    -Wl,-rpath-link,${MATH_LIB_PATH}:${OPENGL_LIB_PATH} \
    -lm -lGLEW -lGLU -lGL -lEGL -lX11 -lGLX -lXext -lXrandr")  # Order matters: GLEW before GL/GLU

set(CMAKE_SHARED_LINKER_FLAGS_INIT "${CMAKE_EXE_LINKER_FLAGS_INIT}")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "${CMAKE_EXE_LINKER_FLAGS_INIT}")

# CMake find settings
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
