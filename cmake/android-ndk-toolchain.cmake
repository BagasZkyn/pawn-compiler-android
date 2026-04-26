# =============================================================================
# CMake Toolchain file for Android NDK cross-compilation
# Targets: arm64-v8a (AArch64) - recommended for modern Android/Termux
#
# Usage:
#   cmake ../source/compiler \
#     -DCMAKE_TOOLCHAIN_FILE=../../cmake/android-ndk-toolchain.cmake \
#     -DANDROID_NDK=/path/to/android-ndk \
#     -DANDROID_ABI=arm64-v8a \
#     -DANDROID_PLATFORM=android-24
# =============================================================================

cmake_minimum_required(VERSION 3.10)

# --- User-configurable variables ---
# Path to Android NDK (can also be set via env var ANDROID_NDK)
if(NOT DEFINED ANDROID_NDK)
  if(DEFINED ENV{ANDROID_NDK})
    set(ANDROID_NDK "$ENV{ANDROID_NDK}")
  elseif(DEFINED ENV{ANDROID_NDK_HOME})
    set(ANDROID_NDK "$ENV{ANDROID_NDK_HOME}")
  else()
    message(FATAL_ERROR
      "ANDROID_NDK is not set.\n"
      "Pass -DANDROID_NDK=/path/to/ndk or set the ANDROID_NDK environment variable.")
  endif()
endif()

# ABI: arm64-v8a | armeabi-v7a | x86_64 | x86
if(NOT DEFINED ANDROID_ABI)
  set(ANDROID_ABI "arm64-v8a")
endif()

# Minimum API level (24 = Android 7.0, good baseline for Termux)
if(NOT DEFINED ANDROID_PLATFORM)
  set(ANDROID_PLATFORM "android-24")
endif()

string(REPLACE "android-" "" ANDROID_API_LEVEL "${ANDROID_PLATFORM}")

# --- Toolchain prefix mapping ---
if(ANDROID_ABI STREQUAL "arm64-v8a")
  set(ANDROID_TRIPLE      "aarch64-linux-android")
  set(ANDROID_ARCH_NAME   "arm64")
elseif(ANDROID_ABI STREQUAL "armeabi-v7a")
  set(ANDROID_TRIPLE      "armv7a-linux-androideabi")
  set(ANDROID_ARCH_NAME   "arm")
elseif(ANDROID_ABI STREQUAL "x86_64")
  set(ANDROID_TRIPLE      "x86_64-linux-android")
  set(ANDROID_ARCH_NAME   "x86_64")
elseif(ANDROID_ABI STREQUAL "x86")
  set(ANDROID_TRIPLE      "i686-linux-android")
  set(ANDROID_ARCH_NAME   "x86")
else()
  message(FATAL_ERROR "Unsupported ANDROID_ABI: ${ANDROID_ABI}")
endif()

# --- Detect host OS for NDK toolchain path ---
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
  set(NDK_HOST_TAG "windows-x86_64")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
  set(NDK_HOST_TAG "darwin-x86_64")
else()
  set(NDK_HOST_TAG "linux-x86_64")
endif()

set(NDK_TOOLCHAIN_BIN "${ANDROID_NDK}/toolchains/llvm/prebuilt/${NDK_HOST_TAG}/bin")

# --- Compiler and tools ---
set(CMAKE_SYSTEM_NAME      Android)
set(CMAKE_SYSTEM_VERSION   ${ANDROID_API_LEVEL})
set(CMAKE_ANDROID_ARCH_ABI ${ANDROID_ABI})

set(CMAKE_C_COMPILER
  "${NDK_TOOLCHAIN_BIN}/${ANDROID_TRIPLE}${ANDROID_API_LEVEL}-clang")
set(CMAKE_CXX_COMPILER
  "${NDK_TOOLCHAIN_BIN}/${ANDROID_TRIPLE}${ANDROID_API_LEVEL}-clang++")
set(CMAKE_AR
  "${NDK_TOOLCHAIN_BIN}/llvm-ar" CACHE FILEPATH "Archiver")
set(CMAKE_RANLIB
  "${NDK_TOOLCHAIN_BIN}/llvm-ranlib" CACHE FILEPATH "Ranlib")
set(CMAKE_STRIP
  "${NDK_TOOLCHAIN_BIN}/llvm-strip" CACHE FILEPATH "Strip")

# --- Sysroot ---
set(CMAKE_SYSROOT
  "${ANDROID_NDK}/toolchains/llvm/prebuilt/${NDK_HOST_TAG}/sysroot")

# --- Android-specific flags ---
set(ANDROID_TERMUX ON)
add_definitions(-DANDROID)

# Set RPATH to Termux lib directory so pawncc can find libpawnc.so at runtime
set(TERMUX_LIB_DIR "/data/data/com.termux/files/usr/lib")
set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
set(CMAKE_INSTALL_RPATH "${TERMUX_LIB_DIR}")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-rpath,${TERMUX_LIB_DIR}")
set(CMAKE_EXE_LINKER_FLAGS    "${CMAKE_EXE_LINKER_FLAGS}    -Wl,-rpath,${TERMUX_LIB_DIR}")

# Don't try to find host libraries
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
