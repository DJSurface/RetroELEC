PKG_NAME="ppsspp-libretro"
PKG_VERSION="122f871"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/hrydgard/ppsspp"
PKG_URL="https://github.com/hrydgard/ppsspp.git"
PKG_SECTION="escalade"
PKG_DEPENDS_TARGET="toolchain ffmpeg SDL2"
PKG_SHORTDESC="A PSP emulator for Android, Windows, Mac and Linux, written in C++."
PKG_TOOLCHAIN="cmake"
GET_HANDLER_SUPPORT="git"

PKG_CMAKE_OPTS_TARGET="-DLIBRETRO=on -DUSE_SYSTEM_FFMPEG=on -DUSING_EGL=off -DUSE_DISCORD=no"

case $PROJECT in
  Generic)
    PKG_CMAKE_OPTS_TARGET+=" -DUSING_GLES2=off"
    PKG_DEPENDS_TARGET+=" glew"
    ;;
  OdroidXU3|RPi)
    PKG_CMAKE_OPTS_TARGET+=" -DARMV7=on -DUSING_GLES2=on -DARM_NO_VULKAN=on"
    ;;
esac

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp lib/ppsspp_libretro.so $INSTALL/usr/lib/libretro/
}