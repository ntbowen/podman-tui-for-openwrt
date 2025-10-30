include $(TOPDIR)/rules.mk

PKG_NAME:=podman-tui
PKG_VERSION:=1.10.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ntbowen/podman-tui.git
PKG_SOURCE_VERSION:=master-dev
# PKG_MIRROR_HASH:=d5bea2f8af34f59457af69736213bff7064c07db34cc523a30df29e1ea6350a9

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=docs/LICENSE
PKG_MAINTAINER:=Zag <ntbowen2001@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/containers/podman-tui
GO_PKG_BUILD_PKG:=github.com/containers/podman-tui

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/podman-tui
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Container
  TITLE:=Podman Terminal UI
  URL:=https://github.com/containers/podman-tui
  DEPENDS:=$(GO_ARCH_DEPENDS) +podman
  PKGARCH:=all
endef

define Package/podman-tui/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	/etc/init.d/podman-tui enable
	echo "Podman TUI installed. Access via: ssh root@router_ip -t podman-tui"
	echo "Web interface available at: System -> Services -> Podman TUI (if luci-app-podman-tui is installed)"
}
exit 0
endef

define Package/podman-tui/description
  podman-tui is a terminal user interface for podman environment. 
  It uses podman go bindings to communicate with local or remote 
  podman machine (through SSH).
  
  Features:
  - Multi-language support (English, Chinese)
  - Automatic language detection from system locale
  - Configurable language settings via UCI
endef

define Package/podman-tui/conffiles
/etc/config/podman-tui
endef

GO_PKG_INSTALL_EXTRA:=

# 设置构建标签，排除不需要的功能
GO_PKG_TAGS:=exclude_graphdriver_btrfs containers_image_openpgp remote

# 设置构建参数
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=

define Build/Compile
	$(call GoPackage/Build/Compile)
endef

define Package/podman-tui/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/podman-tui $(1)/usr/bin/
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/podman-tui.config $(1)/etc/config/podman-tui
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/podman-tui.init $(1)/etc/init.d/podman-tui
	
	# Create directory for language config file
	$(INSTALL_DIR) $(1)/root/.config/podman-tui
endef

$(eval $(call GoBinPackage,podman-tui))
$(eval $(call BuildPackage,podman-tui))
