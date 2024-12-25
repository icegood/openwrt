#
# Copyright (C) 2006-2020 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=firmware-utils
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=/home/ice/external/openwrt_build/under_env/local_packages/firmware-utils/.git
PKG_SOURCE_DATE:=2025-01-07
PKG_SOURCE_VERSION:=597b3c214980092bfd4e2ab64b9e5c989ed18cc3
PKG_MIRROR_HASH:=skip

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk

$(eval $(call HostBuild))
