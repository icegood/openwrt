#
# Copyright (C) 2009-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=squashfs-tools
PKG_VERSION:=4.6.1
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/plougher/squashfs-tools.git
PKG_SOURCE_DATE:=2025-01-01
PKG_SOURCE_VERSION:=dbe45af1d616bc8b79f35d255bb2b80d273ad9f6
PKG_MIRROR_HASH:=skip
PKG_ABI_VERSION:=$(call abi_version_str,$(PKG_SOURCE_DATE))

HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk

MAKE_VARS:=

define Host/Compile
	+$(HOST_MAKE_VARS) \
	$(MAKE) -C $(HOST_BUILD_DIR)/$(PKG_NAME) \
		XZ_EXTENDED_OPTIONS=1 \
		XZ_SUPPORT=1 \
		LZMA_XZ_SUPPORT=1 \
		LZO_SUPPORT=0 \
		LZ4_SUPPORT=1 \
		ZSTD_SUPPORT=1 \
		INSTALL_MANPAGES_DIR="" \
		all
endef

define Host/Install
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/$(PKG_NAME)/mksquashfs* $(STAGING_DIR_HOST)/bin/
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/$(PKG_NAME)/unsquashfs* $(STAGING_DIR_HOST)/bin/
endef

define Host/Clean
	rm -f $(STAGING_DIR_HOST)/bin/mksquashfs*
	rm -f $(STAGING_DIR_HOST)/bin/unsquashfs*
endef

$(eval $(call HostBuild))
