################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
#
#  OpenELEC is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  OpenELEC is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

PKG_NAME="oem"
PKG_VERSION="1.0"
PKG_ARCH="any"
PKG_LICENSE="various"
PKG_SITE="http://www.libreelec.tv"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="oem"
PKG_SHORTDESC="OEM: Metapackage for various OEM packages"
PKG_LONGDESC="OEM: Metapackage for various OEM packages"

PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

OEM_APPS_COMMON=" \
  binutils \
  cryptsetup \
  dstat-system \
  htop-system \
  nmon-system \
  plexmediaserver-script \
  rsync \
  SABnzbd \
  sdl-jstest \
  tcpdump \
  ttf-tlwg \
  nfs-utils \
  vim-system"

OEM_APPS_GENERIC=" \
  google-chrome \
  spotify \
  tigervnc-system \
  qemu"

OEM_EMU_COMMON=" \
  beetle-wswan-libretro \
  dosbox-sdl2 \
  dosbox-svn-libretro \
  ds4drv \
  emulationstation-retropie \
  fuse-libretro \
  genesis-plus-gx-libretro \
  mgba-libretro \
  mrboom-libretro \
  mupen64plus-libretro \
  nxengine-libretro \
  quicknes-libretro \
  prboom-libretro \
  residualvm \
  retroarch \
  scraper \
  scummvm-libretro \
  transmission \
  tyrquake-libretro \
  vice-libretro \
  vice"

OEM_EMU_GENERIC=" \
  beetle-psx-libretro \
  beetle-saturn-libretro \
  citra-libretro \
  craft-libretro \
  desmume-libretro \
  dolphin \
  mame2016-libretro \
  fs-uae \
  parallel-n64-libretro \
  puae-libretro \
  reicast-libretro \
  ppsspp-libretro \
  snes9x-libretro \
  unclutter"

OEM_EMU_RPI=" \
  amiberry \
  gpsp-libretro \
  mame2003-plus-libretro \
  pcsx_rearmed-libretro \
  reicast \
  snes9x2010-libretro \
  yabause-libretro"

if [ ! "$OEM_APPS" = "no" ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET $OEM_APPS_COMMON"
  case $PROJECT in
    Generic)
      PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET $OEM_APPS_GENERIC"
      ;;
    RPi*)
      PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET $OEM_APPS_RPI"
      ;;
  esac
fi

if [ ! "$OEM_EMU" = "no" ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET $OEM_EMU_COMMON"
  case $PROJECT in
    Generic)
      PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET $OEM_EMU_GENERIC"
      ;;
    RPi*)
      PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET $OEM_EMU_RPI"
      ;;
  esac
fi

make_target() {
  :
}

makeinstall_target() {
  mkdir -p $INSTALL
  cp -PR $PKG_DIR/files/* $INSTALL
}

post_install() {
  enable_service binfmt.service
}
