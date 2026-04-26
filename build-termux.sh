#!/data/data/com.termux/files/usr/bin/bash
# =============================================================================
# Build script for Pawn Compiler on Termux (Android)
# Usage: bash build-termux.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build-termux"
SOURCE_DIR="$SCRIPT_DIR/source/compiler"

# Configuracao Inicial
clear
pkg install ncurses-utils -y &> /dev/null
clear

tput civis

# Separador de Linha
function linebreaker {
	for i in $(seq 1 $(tput cols)); do
		echo -en "\033[1m\033[35m=\033[0m"
	done
}

linebreaker
echo -e "\033[1m\033[32mPROJETO: \033[37mPawn Compiler - Termux Build"
echo -e "\033[1m\033[32mSOURCE : \033[37m$SOURCE_DIR"
echo -e "\033[1m\033[32mBUILD  : \033[37m$BUILD_DIR"
linebreaker

# --- Detect environment ---
if [ -z "$PREFIX" ] || [ ! -d "$PREFIX/bin" ]; then
  echo -e "\033[1m\033[31m[!] Este script deve ser executado no Termux!\033[0m"
  tput cnorm
  exit 1
fi

# Atualizar os Pacotes
echo -en "\033[1m\033[32m[\033[37m+\033[32m] \033[33mAtualizando pacotes............................ \033[32m[\033[37m**\033[32m]"
yes | pkg update -y &> /dev/null
yes | pkg upgrade -y &> /dev/null
echo -e "\b\b\b\033[1m\033[37mOK\033[32m]"

# Instalar os Repositorios
echo -en "\033[1m\033[32m[\033[37m+\033[32m] \033[33mInstalando repositorio x11-repo................ \033[32m[\033[37m**\033[32m]"
pkg install x11-repo -y &> /dev/null
echo -e "\b\b\b\033[1m\033[37mOK\033[32m]"

echo -en "\033[1m\033[32m[\033[37m+\033[32m] \033[33mInstalando repositorio tur-repo................ \033[32m[\033[37m**\033[32m]"
pkg install tur-repo -y &> /dev/null
echo -e "\b\b\b\033[1m\033[37mOK\033[32m]"

# Atualizar apos adicionar repositorios
echo -en "\033[1m\033[32m[\033[37m+\033[32m] \033[33mAtualizando repositorios....................... \033[32m[\033[37m**\033[32m]"
yes | pkg update -y &> /dev/null
yes | pkg upgrade -y &> /dev/null
echo -e "\b\b\b\033[1m\033[37mOK\033[32m]"

# Instalar os Pacotes
echo -en "\033[1m\033[32m[\033[37m+\033[32m] \033[33mInstalando pacote cmake........................ \033[32m[\033[37m**\033[32m]"
pkg install cmake -y &> /dev/null
echo -e "\b\b\b\033[1m\033[37mOK\033[32m]"

echo -en "\033[1m\033[32m[\033[37m+\033[32m] \033[33mInstalando pacote gcc-9........................ \033[32m[\033[37m**\033[32m]"
pkg install gcc-9 -y &> /dev/null
echo -e "\b\b\b\033[1m\033[37mOK\033[32m]"

echo -en "\033[1m\033[32m[\033[37m+\033[32m] \033[33mInstalando pacote make......................... \033[32m[\033[37m**\033[32m]"
pkg install make -y &> /dev/null
echo -e "\b\b\b\033[1m\033[37mOK\033[32m]"

# Construir o Compilador
echo -en "\033[1m\033[32m[\033[37m+\033[32m] \033[33mConstruindo o compilador [1/2]................. \033[32m[\033[37m**\033[32m]"
mkdir -p "$BUILD_DIR"
cmake "$SOURCE_DIR" \
  -B "$BUILD_DIR" \
  -DCMAKE_C_COMPILER="$PREFIX/bin/gcc-9" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_INSTALL_RPATH="$PREFIX/lib" \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
  -DANDROID_TERMUX=ON \
  -DBUILD_TESTING=OFF &> /dev/null
echo -e "\b\b\b\033[1m\033[37mOK\033[32m]"

echo -en "\033[1m\033[32m[\033[37m+\033[32m] \033[33mConstruindo o compilador [2/2]................. \033[32m[\033[37m**\033[32m]"
cmake --build "$BUILD_DIR" --parallel &> /dev/null
echo -e "\b\b\b\033[1m\033[37mOK\033[32m]"

# Instalando os Programas
echo -en "\033[1m\033[32m[\033[37m+\033[32m] \033[33mInstalando pawncc, pawndisasm, libpawnc.so..... \033[32m[\033[37m**\033[32m]"
cmake --install "$BUILD_DIR" &> /dev/null
echo -e "\b\b\b\033[1m\033[37mOK\033[32m]"

# Como Usar
linebreaker
echo -e "\033[1m\033[32mCompilador instalado com sucesso!\n"
echo -e "\033[0m\033[1m- Utilize \033[33mpawncc <arquivo.pwn> \033[37mpara compilar algum script!\n"
echo -e "\033[1m\033[32mExemplo de Uso:"
echo -e "\033[0m\033[1mpawncc gamemodes/new.pwn"
echo -e "\033[0m\033[1mpawncc --version"
linebreaker

# Restaurar o Cursor
tput cnorm
