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
