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
# Latest stable upstream release, nightly builds are not used
TAG=$(wget -qO- https://api.github.com/repos/KytyPS5/KytyPS5/releases/latest \
      | grep -m 1 '"tag_name"' | cut -d '"' -f 4)
echo "${TAG#KytyPS5-}" > ~/version

git clone --recursive --branch "$TAG" "$UPSTREAM" ./kyty
git -C ./kyty apply "$PWD/patches/xdg-base-dirs.patch"

cmake -S ./kyty -B ./kyty/_Build/linux -G Ninja \
    -DCMAKE_BUILD_TYPE=Release                  \
    -DCMAKE_C_COMPILER=clang                    \
    -DCMAKE_CXX_COMPILER=clang++                \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"

cmake --build ./kyty/_Build/linux --target launcher --parallel "$(nproc)"
cmake --install ./kyty/_Build/linux
