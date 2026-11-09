# OpenWrt 云编译（ImageBuilder）

使用 **OpenWrt 官方 ImageBuilder** 组装固件，由 GitHub Actions 云端构建，产物自动发布到 **Releases**。

> ImageBuilder 只做「官方预编译软件包 + 配置」的组装，不重新编译内核和工具链，
> 因此构建时间通常 **5–15 分钟**，稳定可靠。

---

## 🚀 支持的设备与方案

| 方案 | 目标平台 | 适用设备 | 构建时间 |
| --- | --- | --- | --- |
| **CR660X** | ramips/mt7621 | 小米 CR6606 / CR6608 / CR6609 | ~5-10 分钟 |
| **x86_64** | x86/64 | 通用 x86_64 设备（软路由、虚拟机、工控机） | ~5-10 分钟 |

---

## 🚀 使用方法

1. 打开仓库 **Actions** 页面。
2. 选择 **OpenWrt CR660X & x86_64 ImageBuilder** → **Run workflow**。
3. 参数（都可留空）：
   - `version`：OpenWrt 版本，例如 `25.12.6`；留空自动使用最新 `25.12.x`。
   - `target`：`cr660x`（默认，仅构建 CR660X）/ `x86_64`（仅构建 x86_64）/ `all`（两者都构建）。
4. 等待 5–15 分钟构建完成，进入 **Releases** 下载固件。

---

## 📦 固件包含对比

### CR660X 方案 (ramips/mt7621)

| 项目 | 说明 |
| --- | --- |
| OpenWrt | 25.12.x（默认自动取最新版本） |
| 管理地址 | `http://192.168.66.1`，默认无密码 |
| WiFi | 双频合一，SSID `cr660x`，密码 `12345678`（WPA2-PSK） |
| WiFi 驱动 | 开源 `mt76` (mt7915e) + 性能调优参数 |
| 主题 | Argon（第三方） |
| DNS | MosDNS v5（第三方） |
| 其他 | LuCI、中文界面、默认中文、时区 Asia/Shanghai、主机名 CR660X |

### x86_64 方案 (x86/64)

| 项目 | 说明 |
| --- | --- |
| OpenWrt | 25.12.x（默认自动取最新版本） |
| 管理地址 | `http://192.168.31.66`（默认无密码，静态 IP） |
| 主题 | Argon（第三方） |
| DNS | MosDNS v5（第三方）+ SmartDNS + AdGuard Home |
| 其他 | LuCI、中文、smartdns、adguardhome |
| 固件格式 | `.img.gz`（UEFI + Legacy BIOS 双支持） |

---

## 📁 固件下载与刷机

### CR660X 固件文件（以 25.12.6 为例）

```text
openwrt-25.12.6-ramips-mt7621-xiaomi_mi-router-cr6606-squashfs-sysupgrade.bin
openwrt-25.12.6-ramips-mt7621-xiaomi_mi-router-cr6606-squashfs-firmware.bin
openwrt-25.12.6-ramips-mt7621-xiaomi_mi-router-cr6606-initramfs-kernel.bin
openwrt-25.12.6-ramips-mt7621-xiaomi_mi-router-cr6606.manifest
SHA256SUMS
```

| 场景 | 使用文件 | 说明 |
| --- | --- | --- |
| **已在 OpenWrt** | `*-squashfs-sysupgrade.bin` | 系统 → 备份/升级 → 刷写（可不保留配置） |
| **首次从原厂固件** | 先 `*-initramfs-kernel.bin` 再 sysupgrade | 先进临时系统，再刷正式固件 |
| **部分设备支持** | `*-squashfs-firmware.bin` | 按设备教程直接刷入 |

### x86_64 固件文件

```text
openwrt-25.12.6-x86-64-generic-ext4-combined-efi.img.gz
openwrt-25.12.6-x86-64-generic-ext4-combined.img.gz
openwrt-25.12.6-x86-64-generic-squashfs-combined-efi.img.gz
openwrt-25.12.6-x86-64-generic-kernel.bin
openwrt-25.12.6-x86-64-generic-ext4-rootfs.img.gz
SHA256SUMS
```

| 文件 | 适用场景 | 推荐度 |
| --- | --- | --- |
| `*-ext4-combined-efi.img.gz` | **UEFI 启动，完整分区表** | ⭐⭐⭐ 推荐 |
| `*-ext4-combined.img.gz` | Legacy BIOS 启动，完整分区表 | ⭐⭐ |
| `*-squashfs-combined-efi.img.gz` | UEFI，squashfs 只读根分区（可用 overlay） | ⭐ |
| `*-kernel.bin` + `*-rootfs.img.gz` | 内核+根分区分离（高级用途） | — |

#### x86_64 写盘/刷机步骤

1. 解压 `.gz` 文件得到 `.img`（如 `gunzip openwrt-*.img.gz`）
2. 使用工具写入 USB/硬盘：
   - Linux/macOS: `sudo dd if=openwrt-*.img of=/dev/sdX bs=4M status=progress && sync`
   - Windows: `balenaEtcher` / `Rufus` / `Ventoy`
3. UEFI 机器用 `-efi.img`，老旧 BIOS 用 `-combined.img`
4. 启动后：LAN 默认 **静态 IP `192.168.31.66`**，网关 `192.168.31.1`，DNS `192.168.31.1`
5. 请确保上级路由网段为 `192.168.31.x`，或首次启动后进入 LuCI 修改网络设置

> ⚠️ 刷机有风险，请先备份原厂固件与重要数据。
> 首次登录建议立即修改管理密码。

---

## 🛠 修改默认配置

编辑 `files/etc/uci-defaults/99-cr660x`，修改后重新触发 Actions 即可生效（仅影响 CR660X 方案）。

x86_64 方案编辑 `files-x86/etc/uci-defaults/99-x86-static-ip`，修改后重新触发 Actions 即可生效。

### CR660X 常见修改示例

```sh
# 改 LAN IP
uci set network.lan.ipaddr='192.168.10.1'

# 改 WiFi 名称/密码
uci set wireless.default_radio0.ssid='mywifi'
uci set wireless.default_radio0.key='mypassword'
uci set wireless.default_radio1.ssid='mywifi'
uci set wireless.default_radio1.key='mypassword'

# 关闭双频合一（分别设置不同 SSID）
uci set wireless.default_radio0.ssid='cr660x-2g'
uci set wireless.default_radio1.ssid='cr660x-5g'

# 固定信道，避免 DFS/自动选信道抖动（按环境启用）
uci set wireless.radio0.channel='6'
uci set wireless.radio1.channel='149'

# 需要更高发射功率（合规自查）
uci set wireless.radio0.country='US'
uci set wireless.radio1.country='US'
```

---

## 📋 工作流参数说明

| 参数 | 说明 | 默认值 |
| --- | --- | --- |
| `version` | OpenWrt 版本，如 `25.12.6` | 自动取最新 25.12.x |
| `target` | `cr660x` / `x86_64` / `all` | `cr660x` |

第三方组件在构建时自动从各自仓库的**最新 Release** 拉取，无需手动维护版本：

- Argon：<https://github.com/jerrykuku/luci-theme-argon>
- MosDNS：<https://github.com/sbwml/luci-app-mosdns>（分支 `v5`，预编译包 `mipsel_24kc` / `x86_64`）
- SmartDNS / AdGuard Home：OpenWrt 官方包仓库（已内置）

---

## 📖 WiFi 性能调优建议（仅 CR660X）

如果 WiFi 速度不理想，按顺序排查：

1. **确认客户端能力**：WiFi 6 (802.11ax)、支持 80MHz 频宽、2×2 MIMO 以上
2. **选清净信道**：5G 推荐 149/153/157/161（非 DFS），2.4G 推荐 1/6/11
3. **距离与遮挡**：5G 穿墙衰减大，近距测速；2.4G 抗遮挡但速率低
4. **散热**：路由器过热会触发降频，注意通风
5. **本地测速排除宽带因素**：`iperf3 -c 192.168.66.1 -P 4 -t 30`
6. **固定信道 + 固定频宽**：在 LuCI 无线设置中锁定 80MHz（5G）/ 40MHz（2.4G）
7. **CR660X 硬件上限参考**：5G 近距理想值 600-900Mbps，2.4G 100-250Mbps

---

## 📂 仓库结构

```text
.github/workflows/build.yml          GitHub Actions 工作流（双平台并行构建）
files/etc/uci-defaults/99-cr660x     CR660X 首启脚本（IP / WiFi / 中文 / 调优）
files-x86/etc/uci-defaults/99-x86-static-ip  x86_64 首启脚本（静态 IP / 中文 / 时区）
README.md                            本文件
```

---

## 📝 更新日志

- **2026-11-09** 新增 x86_64 通用方案，预置 SmartDNS + AdGuard Home + MosDNS + Argon
- **2026-11-09** 移除闭源 mt_wifi 编译方案（与 Linux 6.18 内核存在多层 API 不兼容，维护成本过高）
- **2026-11-08** 开源版修复 `kmod-mt76-xqca` 不存在导致的构建失败；新增 mt76 调优参数
- **2026-11-08** 新增默认 WiFi 配置：`cr660x` / `12345678` 双频合一
- **2026-11-08** 从源码全量编译迁移到官方 ImageBuilder，构建时间从 1–2 小时降至 5–15 分钟

---

## ⚖️ 许可与致谢

- OpenWrt 官方：<https://openwrt.org>
- Argon Theme：<https://github.com/jerrykuku/luci-theme-argon>
- MosDNS：<https://github.com/sbwml/luci-app-mosdns>
- SmartDNS：<https://github.com/pymumu/smartdns>
- AdGuard Home：<https://github.com/AdguardTeam/AdGuardHome>
- 开源 mt76 驱动：Linux 内核主线 / OpenWrt 官方源

本项目仅提供自动化构建配置，固件组件版权归各上游所有。