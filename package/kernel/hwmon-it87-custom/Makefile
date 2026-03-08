include $(TOPDIR)/rules.mk

PKG_NAME:=hwmon-it87-custom
PKG_VERSION:=20250327
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/frankcrawford/it87
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2025-03-27
PKG_SOURCE_VERSION:=4bff981a91bf9209b52e30ee24ca39df163a8bcd
PKG_MIRROR_HASH:=skip

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/$(PKG_NAME)
  SUBMENU:=Hardware Monitoring Support
  TITLE:=IT87 module (out of tree)
  KCONFIG:=CONFIG_SENSORS_IT87=m
  FILES:=$(PKG_BUILD_DIR)/it87.ko
  AUTOLOAD:=$(call AutoProbe,it87)
  DEPENDS:=+kmod-hwmon-vid
endef

define KernelPackage/$(PKG_NAME)/description
Out-of-tree kernel driver for ITE IT87xx family, supporting IT8613E and more.
endef

define Build/Compile
	$(KERNEL_MAKE) M="$(PKG_BUILD_DIR)" modules
endef

$(eval $(call KernelPackage,$(PKG_NAME)))
