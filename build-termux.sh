#!/bin/bash
# =============================================================================
# Build script for Pawn Compiler on Termux (Android)
# Usage: bash build-termux.sh
# =============================================================================

set -e

echo "=== Pawn Compiler - Termux/Android Build ==="

# Check if running on Termux
if [ -z "$PREFIX" ] || [ ! -d "$PREFIX/bin" ]; then
  echo "WARNING: \$PREFIX not set. Are you running this in Termux?"
  echo "Assuming PREFIX=/data/data/com.termux/files/usr"
  PREFIX="/data/data/com.termux/files/usr"
fi

# Install dependencies
echo ""
echo "[1/4] Installing dependencies..."
pkg install -y cmake make clang binutils

# Create build directory
BUILD_DIR="build-termux"
echo ""
echo "[2/4] Configuring with CMake..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

cmake ../source/compiler \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DBUILD_TESTING=OFF \
  -DANDROID_TERMUX=ON

echo ""
echo "[3/4] Building..."
make -j$(nproc)

echo ""
echo "[4/4] Installing to $PREFIX/bin ..."
make install

echo ""
echo "=== Build complete! ==="
echo "Run: pawncc --version"
