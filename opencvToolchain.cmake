cmake_minimum_required(VERSION 3.20)
include_guard(GLOBAL)

# Set the system name and processor for cross-compilation
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Set the target sysroot and architecture
set(TARGET_SYSROOT /build/sysroot)
set(TARGET_ARCHITECTURE aarch64-linux-gnu)
set(CMAKE_SYSROOT ${TARGET_SYSROOT})
SET(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT})

# Set the C and C++ compilers
set(CMAKE_C_COMPILER /usr/bin/${TARGET_ARCHITECTURE}-gcc-12)
set(CMAKE_CXX_COMPILER /usr/bin/${TARGET_ARCHITECTURE}-g++-12)

# Set compiler optimizations for ARM
set(CMAKE_C_FLAGS_INIT "-march=armv8-a -mtune=cortex-a72 -ftree-vectorize -mfpu=neon -mfloat-abi=hard --sysroot=${CMAKE_SYSROOT}")
set(CMAKE_CXX_FLAGS_INIT "-march=armv8-a -mtune=cortex-a72 -ftree-vectorize -mfpu=neon -mfloat-abi=hard --sysroot=${CMAKE_SYSROOT}")

# Set linker flags to use sysroot libraries
set(CMAKE_EXE_LINKER_FLAGS_INIT "--sysroot=${CMAKE_SYSROOT} -L${CMAKE_SYSROOT}/usr/lib -Wl,-rpath-link,${CMAKE_SYSROOT}/lib:${CMAKE_SYSROOT}/usr/lib")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "--sysroot=${CMAKE_SYSROOT} -L${CMAKE_SYSROOT}/usr/lib -Wl,-rpath-link,${CMAKE_SYSROOT}/lib:${CMAKE_SYSROOT}/usr/lib")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "--sysroot=${CMAKE_SYSROOT} -L${CMAKE_SYSROOT}/usr/lib -Wl,-rpath-link,${CMAKE_SYSROOT}/lib:${CMAKE_SYSROOT}/usr/lib")

SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

SET(CMAKE_C_FLAGS "--sysroot=${CMAKE_SYSROOT}")
SET(CMAKE_CXX_FLAGS "--sysroot=${CMAKE_SYSROOT}")

