# Pawn Compiler — Android / Termux

> Pawn compiler ported to run natively on Android via [Termux](https://termux.dev), with cross-compile support using Android NDK.

This is a fork of [pawn-lang/compiler](https://github.com/pawn-lang/compiler) (Pawn Community Compiler v3.10.10) with modifications to support building and running on Android (arm64-v8a, armeabi-v7a, x86_64).

---

## Requirements

### Build directly in Termux
- [Termux](https://termux.dev) installed on your Android device
- Packages: `cmake`, `clang`, `make` (installed automatically by the script)

### Cross-compile from PC
- [Android NDK r21+](https://developer.android.com/ndk/downloads) (tested with r27d)
- CMake 3.10+
- Ninja build system

---

## Option A — Build directly inside Termux (recommended)

Clone the repo inside Termux and run the build script:

```bash
pkg install git -y
git clone https://github.com/BagasZkyn/pawn-compiler-android.git
cd pawn-compiler-android
bash build-termux.sh
```

This will install `pawncc` and `libpawnc.so` into Termux's `$PREFIX/bin` and `$PREFIX/lib` automatically.

Verify:
```bash
pawncc --version
```

---

## Option B — Cross-compile from PC

### Linux / macOS

```bash
export ANDROID_NDK=/path/to/android-ndk-r27d

# arm64-v8a (modern 64-bit Android, recommended)
bash build-android-ndk.sh arm64-v8a

# armeabi-v7a (older 32-bit Android)
bash build-android-ndk.sh armeabi-v7a

# x86_64 (emulator)
bash build-android-ndk.sh x86_64
```

### Windows (PowerShell)

```powershell
$env:ANDROID_NDK = "C:\android-ndk-r27d"

# arm64-v8a (recommended)
.\build-android-ndk.ps1 -Abi arm64-v8a

# armeabi-v7a
.\build-android-ndk.ps1 -Abi armeabi-v7a
```

### Deploy to device via ADB

After cross-compiling, push the binaries to your Android device:

```bash
adb push build-android-arm64-v8a/pawncc      /data/data/com.termux/files/usr/bin/
adb push build-android-arm64-v8a/libpawnc.so /data/data/com.termux/files/usr/lib/
adb shell chmod +x /data/data/com.termux/files/usr/bin/pawncc
```

---

## Supported ABIs

| ABI | Description | Recommended for |
|---|---|---|
| `arm64-v8a` | 64-bit ARM | Most Android devices (2015+) |
| `armeabi-v7a` | 32-bit ARM | Older devices |
| `x86_64` | 64-bit x86 | Android emulator |

Minimum Android API level: **24 (Android 7.0)**

---

## What changed from upstream

- `source/compiler/CMakeLists.txt` — skip `-lpthread` and `-ldl` on Android (already built into Bionic libc), add Android linker flags (`-Wl,-z,noexecstack`, `--build-id`)
- `build-termux.sh` — one-shot build script for Termux
- `build-android-ndk.sh` — cross-compile script for Linux/macOS
- `build-android-ndk.ps1` — cross-compile script for Windows
- `cmake/android-ndk-toolchain.cmake` — CMake toolchain helper for Android NDK

---

## Usage example (in Termux)

```bash
# Compile a .pwn file
pawncc myscript.pwn -o myscript.amx

# With compatibility mode (recommended for SA-MP scripts)
pawncc myscript.pwn -Z -O3 -o myscript.amx
```

---

## Credits

- **ITB CompuPhase** — original Pawn language and compiler (1997–2006)
- **Zeex** — started the Pawn Community Compiler project
- **pawn-lang/compiler contributors** — ongoing bug fixes and enhancements  
  → upstream repo: https://github.com/pawn-lang/compiler
- **BagasZkyn** — Android/Termux port and build system

---

## License

This project is distributed under the **zLib/libpng license**, same as the original Pawn compiler.

```
This software is provided "as-is", without any express or implied warranty.
In no event will the authors be held liable for any damages arising from
the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software in
   a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not
   be misrepresented as being the original software.

3. This notice may not be removed or altered from any source distribution.
```

Full license text: [license.txt](license.txt)
