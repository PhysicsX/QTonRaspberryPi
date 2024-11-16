cmake_minimum_required(VERSION 3.20)
include_guard(GLOBAL)

# Set the system name and processor for cross-compilation
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# Define the sysroot and target architecture
set(CMAKE_SYSROOT /build/sysroot)
set(TARGET_ARCHITECTURE aarch64-linux-gnu)

# Set the C and C++ compilers (assuming cross-compilers are system-installed)
set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

# Configure pkg-config environment variables
set(ENV{PKG_CONFIG_PATH} "${CMAKE_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}/pkgconfig:${CMAKE_SYSROOT}/usr/share/pkgconfig")
set(ENV{PKG_CONFIG_LIBDIR} "${CMAKE_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}/pkgconfig:${CMAKE_SYSROOT}/usr/lib/pkgconfig:${CMAKE_SYSROOT}/usr/share/pkgconfig")
set(ENV{PKG_CONFIG_SYSROOT_DIR} "${CMAKE_SYSROOT}")

# Compiler and linker flags for Qt and general builds
set(QT_COMPILER_FLAGS "-march=armv8-a -mtune=cortex-a72 -mfloat-abi=hard")
set(QT_COMPILER_FLAGS_RELEASE "-O2 -pipe")
set(QT_LINKER_FLAGS "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed -Wl,-rpath-link=${CMAKE_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE}")

# Initialize CMake configuration variables with the specified flags
set(CMAKE_C_FLAGS_INIT "${QT_COMPILER_FLAGS} -isystem=${CMAKE_SYSROOT}/usr/include")
set(CMAKE_CXX_FLAGS_INIT "${QT_COMPILER_FLAGS} -isystem=${CMAKE_SYSROOT}/usr/include")
set(CMAKE_EXE_LINKER_FLAGS_INIT "${QT_LINKER_FLAGS}")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "${QT_LINKER_FLAGS}")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "${QT_LINKER_FLAGS}")

# Configure CMake find root path modes
set(CMAKE_FIND_ROOT_PATH /build/sysroot)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# OpenGL and XCB libraries
set(GL_INC_DIR ${CMAKE_SYSROOT}/usr/include)
set(GL_LIB_DIR ${CMAKE_SYSROOT}/usr/lib/${TARGET_ARCHITECTURE})
set(EGL_INCLUDE_DIR ${GL_INC_DIR})
set(EGL_LIBRARY ${GL_LIB_DIR}/libEGL.so)
set(OPENGL_INCLUDE_DIR ${GL_INC_DIR})
set(OPENGL_opengl_LIBRARY ${GL_LIB_DIR}/libOpenGL.so)
set(GLESv2_INCLUDE_DIR ${GL_INC_DIR})
set(GLESv2_LIBRARY ${GL_LIB_DIR}/libGLESv2.so)

# DRM and XCB paths
set(gbm_INCLUDE_DIR ${GL_INC_DIR})
set(gbm_LIBRARY ${GL_LIB_DIR}/libgbm.so)
set(Libdrm_INCLUDE_DIR ${GL_INC_DIR})
set(Libdrm_LIBRARY ${GL_LIB_DIR}/libdrm.so)
set(XCB_XCB_INCLUDE_DIR ${GL_INC_DIR})
set(XCB_XCB_LIBRARY ${GL_LIB_DIR}/libxcb.so)

# Append to CMake library and prefix paths
list(APPEND CMAKE_LIBRARY_PATH ${GL_LIB_DIR})
list(APPEND CMAKE_PREFIX_PATH ${GL_LIB_DIR}/cmake)
