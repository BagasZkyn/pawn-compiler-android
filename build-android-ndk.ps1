# =============================================================================
# Cross-compile Pawn Compiler for Android/Termux using Android NDK
# Run this on Windows, then copy the binary to your Android device.
#
# Requirements:
#   - Android NDK r21+ (https://developer.android.com/ndk/downloads)
#   - CMake 3.10+ (in PATH)
#   - Ninja or make (ninja recommended, install via: winget install Ninja-build.Ninja)
#
# Usage:
#   $env:ANDROID_NDK = "C:\android-ndk-r25c"
#   .\build-android-ndk.ps1 [-Abi arm64-v8a] [-Platform android-24]
# =============================================================================

param(
    [string]$Abi      = "arm64-v8a",
    [string]$Platform = "android-24"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Pawn Compiler - Android NDK Cross-Compile (Windows) ===" -ForegroundColor Cyan
Write-Host "    ABI      : $Abi"
Write-Host "    Platform : $Platform"

# Resolve NDK path
$ndkPath = $env:ANDROID_NDK
if (-not $ndkPath) {
    # Try Android Studio default location
    $candidate = "$env:LOCALAPPDATA\Android\Sdk\ndk"
    if (Test-Path $candidate) {
        $ndkPath = (Get-ChildItem $candidate | Sort-Object Name -Descending | Select-Object -First 1).FullName
        Write-Host "    NDK      : $ndkPath (auto-detected)" -ForegroundColor Yellow
    } else {
        Write-Error "ANDROID_NDK environment variable is not set and NDK could not be auto-detected.`nSet it with: `$env:ANDROID_NDK = 'C:\path\to\ndk'"
    }
} else {
    Write-Host "    NDK      : $ndkPath"
}

if (-not (Test-Path $ndkPath)) {
    Write-Error "NDK directory not found: $ndkPath"
}

$buildDir = "build-android-$Abi"
$toolchainFile = (Resolve-Path "cmake\android-ndk-toolchain.cmake").Path

Write-Host ""
Write-Host "[1/3] Configuring..." -ForegroundColor Green
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

$ndkToolchain = "$ndkPath\build\cmake\android.toolchain.cmake"
if (-not (Test-Path $ndkToolchain)) {
    Write-Error "Toolchain file not found: $ndkToolchain"
}
# Convert to forward slashes for CMake compatibility
$ndkToolchain = $ndkToolchain.Replace("\", "/")
$TermuxLib = "/data/data/com.termux/files/usr/lib"
$TermuxBin = "/data/data/com.termux/files/usr/bin"

$cmakeArgs = @(
    "..\source\compiler",
    "-DCMAKE_TOOLCHAIN_FILE=$ndkToolchain",
    "-DANDROID_ABI=$Abi",
    "-DANDROID_PLATFORM=$Platform",
    "-DANDROID_TERMUX=ON",
    "-DCMAKE_BUILD_TYPE=Release",
    "-DBUILD_TESTING=OFF",
    "-DCMAKE_INSTALL_PREFIX=/data/data/com.termux/files/usr",
    "-DCMAKE_INSTALL_RPATH=$TermuxLib",
    "-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON",
    "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath,$TermuxLib",
    "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-rpath,$TermuxLib",
    "-DCMAKE_MAKE_PROGRAM=ninja",
    "-GNinja"
)

Push-Location $buildDir
try {
    & cmake @cmakeArgs
    if ($LASTEXITCODE -ne 0) { throw "CMake configure failed" }

    Write-Host ""
    Write-Host "[2/3] Building..." -ForegroundColor Green
    & cmake --build . --config Release
    if ($LASTEXITCODE -ne 0) { throw "Build failed" }
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "[3/3] Done!" -ForegroundColor Green
Write-Host ""
Write-Host "Binaries are in: $buildDir\" -ForegroundColor Cyan
Write-Host ""
Write-Host "To deploy to Termux via ADB:" -ForegroundColor Yellow
Write-Host "  adb push $buildDir\pawncc /data/data/com.termux/files/usr/bin/"
Write-Host "  adb push $buildDir\libpawnc.so /data/data/com.termux/files/usr/lib/"
Write-Host "  adb shell chmod +x /data/data/com.termux/files/usr/bin/pawncc"
Write-Host ""
Write-Host "NOTE: libpawnc.so MUST be copied to Termux before running pawncc." -ForegroundColor Red
Write-Host "      RPATH is set to /data/data/com.termux/files/usr/lib" -ForegroundColor Red
