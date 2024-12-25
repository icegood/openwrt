#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lz4
PKG_VERSION:=1.10.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/lz4/lz4/releases/download/v$(PKG_VERSION)
PKG_HASH:=537512904744b35e232912055ccf8ec66d768639ff3abe5788d90d792ec5f48b

PKG_MAINTAINER:=Darik Horn <dajhorn@vanadac.com>
PKG_CPE_ID:=cpe:/a:lz4_project:lz4

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/meson.mk

MESON_HOST_BUILD_DIR:=$(HOST_BUILD_DIR)/build/meson/openwrt-build

HOSTCC:= $(HOSTCC_NOCACHE)
HOST_LDFLAGS += -Wl,-rpath,$(STAGING_DIR_HOST)/lib

$(eval $(call HostBuild))