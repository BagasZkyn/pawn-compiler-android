#!/bin/bash
# =============================================================================
# Cross-compile Pawn Compiler for Android/Termux using Android NDK
# Run this on your PC (Linux/macOS/WSL), then copy the binary to your device.
#
# Requirements:
#   - Android NDK r21+ (download from https://developer.android.com/ndk/downloads)
#   - CMake 3.10+
#   - make / ninja
#
# Usage:
#   export ANDROID_NDK=/path/to/android-ndk-r25c
#   bash build-android-ndk.sh [arm64-v8a|armeabi-v7a|x86_64]
# =============================================================================

set -e

ABI="${1:-arm64-v8a}"
PLATFORM="android-24"
BUILD_DIR="build-android-${ABI}"

echo "=== Pawn Compiler - Android NDK Cross-Compile ==="
echo "    ABI      : $ABI"
echo "    Platform : $PLATFORM"
echo "    NDK      : ${ANDROID_NDK:-<not set>}"
echo ""

if [ -z "$ANDROID_NDK" ]; then
  echo "ERROR: ANDROID_NDK environment variable is not set."
  echo "  export ANDROID_NDK=/path/to/android-ndk-rXX"
  exit 1
fi

if [ ! -d "$ANDROID_NDK" ]; then
  echo "ERROR: NDK directory not found: $ANDROID_NDK"
  exit 1
fi

echo "[1/3] Configuring..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

cmake ../source/compiler \
  -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI="$ABI" \
  -DANDROID_PLATFORM="$PLATFORM" \
  -DANDROID_TERMUX=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTING=OFF

echo ""
echo "[2/3] Building..."
make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo ""
echo "[3/3] Done!"
echo ""
echo "Binaries are in: $BUILD_DIR/"
echo ""
echo "To deploy to your Android device via ADB:"
echo "  adb push $BUILD_DIR/pawncc /data/local/tmp/"
echo "  adb push $BUILD_DIR/libpawnc.so /data/local/tmp/"
echo "  adb shell chmod +x /data/local/tmp/pawncc"
echo ""
echo "To deploy to Termux via ADB:"
echo "  adb push $BUILD_DIR/pawncc /data/data/com.termux/files/usr/bin/"
echo "  adb push $BUILD_DIR/libpawnc.so /data/data/com.termux/files/usr/lib/"
echo "  adb shell chmod +x /data/data/com.termux/files/usr/bin/pawncc"
echo ""
echo "Or copy manually via USB/scp to Termux's \$PREFIX/bin and \$PREFIX/lib"
