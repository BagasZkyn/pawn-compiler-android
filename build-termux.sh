#!/bin/bash
# =============================================================================
# Build script for Pawn Compiler on Termux (Android)
# Usage: bash build-termux.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build-termux"
SOURCE_DIR="$SCRIPT_DIR/source/compiler"

echo "=== Pawn Compiler - Termux/Android Build ==="
echo "    Source : $SOURCE_DIR"
echo "    Build  : $BUILD_DIR"

# --- Detect environment ---
IS_TERMUX=0
if [ -n "$PREFIX" ] && [ -d "$PREFIX/bin" ]; then
  IS_TERMUX=1
  echo "    Env    : Termux (PREFIX=$PREFIX)"
else
  echo "    Env    : Generic Linux (non-Termux)"
  PREFIX="/usr/local"
fi

# --- Install dependencies (Termux only) ---
if [ "$IS_TERMUX" -eq 1 ]; then
  echo ""
  echo "[1/4] Installing dependencies..."
  pkg install -y cmake ninja clang
else
  echo ""
  echo "[1/4] Skipping pkg install (not Termux)"
  # Check tools exist
  for tool in cmake ninja clang; do
    if ! command -v $tool &>/dev/null; then
      echo "ERROR: '$tool' not found. Please install it first."
      exit 1
    fi
  done
fi

# --- Configure ---
echo ""
echo "[2/4] Configuring with CMake..."
mkdir -p "$BUILD_DIR"

cmake "$SOURCE_DIR" \
  -B "$BUILD_DIR" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DBUILD_TESTING=OFF \
  -DANDROID_TERMUX=ON \
  -GNinja

# --- Build ---
echo ""
echo "[3/4] Building..."
cmake --build "$BUILD_DIR" --parallel

# --- Install ---
echo ""
echo "[4/4] Installing to $PREFIX ..."
cmake --install "$BUILD_DIR"

echo ""
echo "=== Build complete! ==="
echo ""
echo "Installed:"
echo "  $PREFIX/bin/pawncc"
echo "  $PREFIX/bin/pawndisasm"
echo "  $PREFIX/lib/libpawnc.so"
echo ""
echo "Test with: pawncc --version"
