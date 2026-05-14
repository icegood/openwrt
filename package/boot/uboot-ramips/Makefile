include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_VERSION:=2026.07
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=$(ICE_GIT)/u-boot.git
PKG_SOURCE_VERSION:=master_dir620_revA1
PKG_MIRROR_HASH:=skip

UBOOT_USE_INTREE_DTC:=1

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define U-Boot/Default
  BUILD_TARGET:=ramips
  BUILD_SUBTARGET:=rt305x
  UBOOT_IMAGE:=u-boot.bin
  UBOOT_CONFIG:=dir-620
endef

define U-Boot/dir-620
  NAME:=D-Link DIR-620 A1 (RT3052, NOR flash)
  BUILD_DEVICES:=dlink_dir-620-a1
  UBOOT_CONFIG:=dir-620
endef

define U-Boot/dir-620-test
  NAME:=D-Link DIR-620 A1 TEST (base 0x50000)
  BUILD_DEVICES:=dlink_dir-620-a1
  UBOOT_CONFIG:=dir-620
  UBOOT_CUSTOMIZE_CONFIG := \
	--set-val DIR620_FLASH_BASE 0x50000 \
	--set-val TEXT_BASE 0x80050000 \
	--set-val SPL_TEXT_BASE 0x80000000 \
	--set-str BUILD_TARGET u-boot-dir620-test-flash.bin
endef

UBOOT_TARGETS := dir-620 dir-620-test

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/$(UBOOT_IMAGE) $(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-$(UBOOT_IMAGE)
	for img in u-boot-dir620-flash.bin u-boot-dir620-test-flash.bin; do \
		[ -f "$(PKG_BUILD_DIR)/$$$$img" ] && \
		$(INSTALL_DATA) $(PKG_BUILD_DIR)/$$$$img $(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-$$$$img || true; \
	done
endef

$(eval $(call BuildPackage/U-Boot))
