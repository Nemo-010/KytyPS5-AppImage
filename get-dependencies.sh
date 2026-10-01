#!/bin/sh

set -eu

ARCH=$(uname -m)
UPSTREAM=https://github.com/KytyPS5/KytyPS5.git
INSTALL_PREFIX=/usr/lib/kytyps5

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    alsa-lib          \
    clang             \
    cmake             \
    dbus              \
    glslang           \
    kvantum           \
    libpulse          \
    libx11            \
    libxcursor        \
    libxext           \
    libxfixes         \
    libxi             \
    libxkbcommon      \
    libxrandr         \
    libxss            \
    libxtst           \
    lld               \
    lxqt-qtplugin     \
    mesa              \
    ninja             \
    pkgconf           \
    qt6-base          \
    qt6ct             \
    qt6-imageformats  \
    qt6-wayland       \
    systemd-libs      \
    vulkan-headers    \
    vulkan-icd-loader \
    wayland           \
    wayland-protocols

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

echo "Building KytyPS5 from source..."
echo "---------------------------------------------------------------"
git clone "$UPSTREAM" ./kyty && (
	cd ./kyty

	# Build the latest stable tag, nightly builds are not used
	TAG=$(git tag --list 'KytyPS5-*' --sort=-v:refname | head -n 1)
	git checkout "$TAG"
	git submodule update --init --recursive
	echo "${TAG#KytyPS5-}" > ~/version

	patch -p1 < ../patches/0001-launcher-use-xdg-base-directories.patch
	patch -p1 < ../patches/0002-mainDialog.cpp-use-posix-sh-for-the-run-script.patch

	cmake -B ./build . -GNinja -Wno-dev \
		-DCMAKE_BUILD_TYPE=Release      \
		-DCMAKE_C_COMPILER=clang        \
		-DCMAKE_CXX_COMPILER=clang++    \
		-DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
	cmake --build ./build --target launcher --parallel "$(nproc)"
	cmake --install ./build
)
