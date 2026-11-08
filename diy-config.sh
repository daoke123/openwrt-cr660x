#!/bin/sh
./scripts/feeds update -a
./scripts/feeds install -a
# Install Argon theme
./scripts/feeds install -p luci -l luci-theme-argon
# Install MosDNS
./scripts/feeds install -p mosdns -a
# Set default IP to 192.168.66.1
sed -i 's/192.168.1.1/192.168.66.1/g' package/base-files/files/bin/config_generate
make defconfig