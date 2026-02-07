include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=warmup_crypto
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define KernelPackage/warmup_crypto
  SUBMENU:=Cryptographic API modules
  TITLE:=Kernel Crypto Warmup Module
  FILES:=$(PKG_BUILD_DIR)/warmup_crypto.ko
  AUTOLOAD:=$(call AutoProbe,warmup_crypto)
  KCONFIG:=
  DEPENDS:=+kmod-crypto-aead +kmod-crypto-ccm +kmod-crypto-manager
endef

define KernelPackage/warmup_crypto/description
  Initializes ccm(aes) at boot/load time to trigger self-tests.
endef

define Build/Compile
	$(KERNEL_MAKE) M="$(PKG_BUILD_DIR)" modules
endef

$(eval $(call KernelPackage,warmup_crypto))
