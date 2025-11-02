#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate
##-----------------Del duplicate packages------------------
rm -rf feeds/packages/net/open-app-filter
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang
##----------------------------
git clone https://github.com/kenzok8/golang -b 1.25 feeds/packages/lang/golang
(cat << 'EOF'
--- Makefile	2025-11-02 06:50:46.952052786 +0000
+++ Makefile	2025-11-02 06:50:46.952156980 +0000
@@ -45,17 +45,17 @@ 
 
 ifeq ($(HOST_ARCH),x86_64)
 	PKG_ARCH:=amd64
-	SHA256:=b945ae2bb5db01a0fb4786afde64e6fbab50b67f6fa0eb6cfa4924f16a7ff1eb
+	BOOTSTRAP_HASH:=999805bed7d9039ec3da1a53bfbcafc13e367da52aa823cb60b68ba22d44c616
 endif
 
 ifeq ($(HOST_ARCH),aarch64)
 	PKG_ARCH:=arm64
-	SHA256:=4e15ab37556e979181a1a1cc60f6d796932223a0f5351d7c83768b356f84429b
+	BOOTSTRAP_HASH:=c15fa895341b8eaf7f219fada25c36a610eb042985dc1a912410c1c90098eaf2
 endif
 
-BOOTSTRAP_SOURCE:=go1.20.6.linux-$(PKG_ARCH).tar.gz
+BOOTSTRAP_SOURCE:=go1.22.6.linux-$(PKG_ARCH).tar.gz
 BOOTSTRAP_SOURCE_URL:=$(GO_SOURCE_URLS)
-BOOTSTRAP_HASH:=$(SHA256)
+BOOTSTRAP_HASH:=$(BOOTSTRAP_HASH)
 
 BOOTSTRAP_BUILD_DIR:=$(HOST_BUILD_DIR)/.go_bootstrap
EOF
) | patch -p0 feeds/packages/lang/golang/golang/Makefile
###
##-----------------Add OpenClash dev core (Mihomo Meta, Latest)------------------
# Fetch latest version from GitHub API
LATEST_TAG=$(curl -sL -m 30 --retry 3 https://api.github.com/repos/MetaCubeX/mihomo/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/v//')
if [ -z "$LATEST_TAG" ]; then
    echo "Failed to fetch latest version, using fallback v1.19.15"
    LATEST_TAG=1.19.15
fi
VERSION=v${LATEST_TAG}
# Download and install
curl -sL -m 30 --retry 3 https://github.com/MetaCubeX/mihomo/releases/download/${VERSION}/mihomo-linux-arm64-v${LATEST_TAG}.gz -o /tmp/mihomo.gz
gzip -d /tmp/mihomo.gz >/dev/null 2>&1
chmod +x /tmp/mihomo >/dev/null 2>&1
mkdir -p feeds/luci/applications/luci-app-openclash/root/etc/openclash/core
mv /tmp/mihomo feeds/luci/applications/luci-app-openclash/root/etc/openclash/core/clash_meta >/dev/null 2>&1
rm -rf /tmp/mihomo.gz >/dev/null 2>&1
# Optional: Echo version for log
echo "Installed Mihomo Meta Core version: ${VERSION}"

##-----------------Delete DDNS's examples-----------------
sed -i '/myddns_ipv4/,$d' feeds/packages/net/ddns-scripts/files/etc/config/ddns
##-----------------Manually set CPU frequency for MT7981B-----------------
sed -i '/"mediatek"\/\*|\"mvebu"\/\*/{n; s/.*/\tcpu_freq="1.3GHz" ;;/}' package/emortal/autocore/files/generic/cpuinfo
