#!/bin/sh
set -e

# 1. 更新 Lean 自带 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 2. 安装 Argon 主题（Lean luci feed 中通常已包含）
./scripts/feeds install -p luci luci-theme-argon || true

# 3. 删除源码中自带的 mosdns / v2ray-geodata，避免冲突
find ./ | grep Makefile | grep v2ray-geodata | xargs -r rm -f
find ./ | grep Makefile | grep mosdns | xargs -r rm -f

# 4. 使用第三方仓库：sbwml/luci-app-mosdns (v5) + sbwml/v2ray-geodata
git clone --depth 1 -b v5 https://github.com/sbwml/luci-app-mosdns package/mosdns
git clone --depth 1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 5. 设置默认 IP 为 192.168.66.1
sed -i 's/192.168.1.1/192.168.66.1/g' package/base-files/files/bin/config_generate

# 6. 生成默认配置
make defconfig
