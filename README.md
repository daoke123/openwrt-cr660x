# OpenWrt CR660X 云编译（ImageBuilder）

使用 **OpenWrt 官方 ImageBuilder** 为小米 CR660X（CR6606 / CR6608 / CR6609，ramips/mt7621）组装固件，
由 GitHub Actions 云端构建，产物自动发布到 **Releases**。

> ImageBuilder 只做「官方预编译软件包 + 配置」的组装，不重新编译内核和工具链，
> 因此构建时间通常 **5–15 分钟**（源码全量编译需要 1–2 小时）。

## 固件包含

| 项目 | 说明 |
| --- | --- |
| OpenWrt | 25.12.x（默认自动取最新版本） |
| 管理地址 | `http://192.168.66.1`，默认无密码 |
| 主题 | Argon（第三方） |
| DNS | MosDNS v5（第三方） |
| 其他 | LuCI、中文语言包、默认中文界面、时区 Asia/Shanghai |

第三方组件来源：

- Argon：<https://github.com/jerrykuku/luci-theme-argon>
- MosDNS：<https://github.com/sbwml/luci-app-mosdns>（分支 `v5`，预编译包 `mipsel_24kc-openwrt-25.12`）

## 使用方法

1. 打开仓库 **Actions** 页面。
2. 选择 **OpenWrt CR660X ImageBuilder** → **Run workflow**。
3. 参数（都可留空）：
   - `version`：OpenWrt 版本，例如 `25.12.6`；留空自动使用最新 `25.12.x`。
   - `device`：`all`（默认，三个型号都构建）/ `cr6606` / `cr6608` / `cr6609`。
4. 等待构建完成，进入 **Releases** 下载固件。

## 下载与刷机

Release 中的文件（以 25.12.6 为例）：

```text
openwrt-25.12.6-ramips-mt7621-xiaomi_mi-router-cr6606-squashfs-sysupgrade.bin
openwrt-25.12.6-ramips-mt7621-xiaomi_mi-router-cr6606-squashfs-firmware.bin
openwrt-25.12.6-ramips-mt7621-xiaomi_mi-router-cr6606-initramfs-kernel.bin
openwrt-25.12.6-ramips-mt7621-xiaomi_mi-router-cr6606.manifest
SHA256SUMS
```

- 已在 OpenWrt：用 `*-squashfs-sysupgrade.bin` 在「系统 → 备份/升级」中升级。
- 首次刷入：先刷 `*-initramfs-kernel.bin` 进入临时系统，再刷 `*-squashfs-sysupgrade.bin`；
  也可按设备教程使用 `*-squashfs-firmware.bin`。
- 刷机有风险，请先备份原厂固件和 EEPROM。

## 仓库结构

```text
.github/workflows/build.yml        GitHub Actions 工作流（ImageBuilder 组装 + 发布 Releases）
files/etc/uci-defaults/99-cr660x    首次启动脚本：LAN IP、主机名、时区、中文界面
README.md                           本文件
```

## 修改默认配置

- **改 LAN IP / 主机名 / 时区**：编辑 `files/etc/uci-defaults/99-cr660x`。
- **加装软件包**：编辑工作流 `env.EXTRA_PACKAGES`，包名需在官方源中（apk 包名）。
- **换第三方组件版本**：工作流中 `gh release download` 默认取各自仓库的 **最新 Release**，无需改脚本。

## 说明

- 25.12 起 OpenWrt 使用 `apk` 包管理器，因此这里用 `.apk` 预编译包；老版本（24.10 及以前）是 `opkg/.ipk`。
- 内核、驱动、基础系统均来自 OpenWrt 官方 ImageBuilder，未做任何源码补丁。
- Argon 与 MosDNS 属于第三方组件，升级/兼容性由各自上游维护；不使用它们不影响 OpenWrt 基础 DHCP/DNS 功能。
