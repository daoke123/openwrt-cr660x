# OpenWrt CR660X 云编译

为小米 CR660X（CR6606 / CR6608 / CR6609，ramips/mt7621）提供两套构建方案，
均由 GitHub Actions 云端编译，产物自动发布到 **Releases**。

---

## 🚀 快速开始

1. 进入仓库 **Actions** 页面
2. 选择任一工作流 → **Run workflow**
3. 填写参数（可留空用默认） → 运行
4. 完成后去 **Releases** 下载固件

---

## 📦 两套构建方案对比

| 特性 | **开源 mt76 版** (build-open.yml) | **闭源 mt_wifi 版** (build-mtk.yml) |
|---|---|---|
| **构建方式** | 官方 ImageBuilder 组装 | Lean LEDE 源码全量编译 |
| **构建时间** | ~5 分钟 | ~60-120 分钟 |
| **WiFi 驱动** | 开源 `mt76` (mt7915e) | **MediaTek 闭源 `mt_wifi`** (MT7915E_DBDC) |
| **驱动特点** | 开源、内核同步更新、标准 cfg80211 | 厂商原生优化、DBDC 成熟、吞吐/漫游/功耗通常更好 |
| **维护性** | 高（官方源、长期维护） | 中（闭源、内核绑定、升级内核需重编） |
| **调优方式** | UCI + mac80211.sh 参数 | 厂商 .dat 校准文件 + mt7615.lua |
| **适用场景** | 日常使用、追求开源、不想折腾 | 极致性能、接受闭源、固定内核版本 |
| **包含组件** | Argon、MosDNS、LuCI、中文 | 同上 + mt_wifi 专用配置工具 |

> **默认推荐**：先用 **开源版** 测试。若 WiFi 速度/稳定性不达标，再尝试 **闭源版**。

---

## 📁 固件下载与刷机

Release 中文件（以 25.12.6 为例）：

```text
# 开源版
openwrt-25.12.6-ramips-mt7621-xiaomi_mi-router-cr6606-squashfs-sysupgrade.bin
openwrt-25.12.6-ramips-mt7621-xiaomi_mi-router-cr6606-squashfs-firmware.bin
openwrt-25.12.6-ramips-mt7621-xiaomi_mi-router-cr6606-initramfs-kernel.bin

# 闭源版（文件名含 lean commit）
openwrt-<commit>-ramips-mt7621-xiaomi_mi-router-cr6606-squashfs-sysupgrade.bin
...
```

### 刷机方式

| 场景 | 使用文件 | 说明 |
|---|---|---|
| **已在 OpenWrt** | `*-squashfs-sysupgrade.bin` | 系统 → 备份/升级 → 刷写（可不保留配置） |
| **首次从原厂固件** | `*-initramfs-kernel.bin` → `*-squashfs-sysupgrade.bin` | 先刷 initramfs 进临时系统，再刷 sysupgrade |
| **部分设备支持** | `*-squashfs-firmware.bin` | 按设备教程直接刷入 |

> ⚠️ 刷机有风险，请先备份原厂固件与 EEPROM。

---

## ⚙️ 默认配置（两版通用）

| 项目 | 默认值 |
|---|---|
| 管理地址 | `http://192.168.66.1`（默认无密码） |
| WiFi SSID | `cr660x` |
| WiFi 密码 | `12345678` |
| 双频合一 | ✅ 已启用（2.4G + 5G 同一 SSID，支持 Band Steering） |
| 加密方式 | WPA2-PSK (AES/CCMP) |
| 国家代码 | CN |
| LuCI 语言 | 中文 |
| 时区 | Asia/Shanghai (CST-8) |
| 主机名 | CR660X |
| 主题 | Argon（第三方） |
| DNS | MosDNS v5（第三方） |

> 首次登录建议立即修改 WiFi 密码和管理密码。

---

## 🛠 修改默认配置

编辑 `files/etc/uci-defaults/99-cr660x`，修改后重新触发 Actions 即可生效。

### 常见修改示例

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

# 开源版：调整发射功率
uci set wireless.radio0.txpower='23'
uci set wireless.radio1.txpower='23'

# 开源版：固定信道（避免 DFS/自动选信道抖动）
uci set wireless.radio0.channel='6'
uci set wireless.radio1.channel='149'
```

---

## 📋 工作流参数说明

### build-open.yml（开源 mt76 + ImageBuilder）

| 参数 | 说明 | 默认值 |
|---|---|---|
| `version` | OpenWrt 版本，如 `25.12.6` | 自动取最新 25.12.x |
| `device` | `all` / `cr6606` / `cr6608` / `cr6609` | `all` |

### build-mtk.yml（闭源 mt_wifi + Lean LEDE）

| 参数 | 说明 | 默认值 |
|---|---|---|
| `branch` | Lean LEDE 分支 | `master` |
| `device` | `all` / `cr6606` / `cr6608` / `cr6609` | `all` |

---

## 🔧 WiFi 性能调优建议

### 开源 mt76 版（已内置以下调优）

```sh
# 关闭电源管理、最大发射功率、启用 HE/MU-MIMO
uci set wireless.radio0.txpower='23'
uci set wireless.radio1.txpower='23'
uci set wireless.radio0.he_bss_color='1'
uci set wireless.radio1.he_bss_color='1'
uci set wireless.radio0.mu_beamformer='1'
uci set wireless.radio1.mu_beamformer='1'
```

### 闭源 mt_wifi 版

- 由厂商 `.dat` 校准文件决定射频参数（`/etc/wireless/mt7615/*.dat`）
- 如需微调：编辑对应 `.dat` 文件或通过 `mt7615.lua` UCI 接口

### 通用排查步骤

1. **确认客户端支持**：WiFi 6 (802.11ax)、160MHz、4×4 MIMO
2. **选清净信道**：5G 推荐 149/153/157/161（非 DFS），2.4G 推荐 1/6/11
3. **关闭不必要的服务**：如未用 IPv6、VPN 等可在 LuCI 禁用
4. **散热/天线**：确保路由器散热良好、天线未遮挡
5. **测试工具**：`iperf3 -c <路由器IP> -P 4 -t 30`（本地测速排除宽带影响）

---

## 📂 仓库结构

```text
.github/workflows/
  build-open.yml    # 开源 mt76 版（ImageBuilder，~5min）
  build-mtk.yml     # 闭源 mt_wifi 版（Lean LEDE 源码编译，~1-2h）
files/
  etc/uci-defaults/
    99-cr660x        # 首启脚本：IP、WiFi、语言、时区、主题等
README.md            # 本文件
```

---

## 📝 更新日志

- **2026-11-08** 新增双工作流：开源版 + 闭源版；默认 WiFi `cr660x/12345678` 双频合一
- **2026-11-08** 开源版应用 mt76 调优参数（txpower、HE、MU-MIMO、禁电源管理）
- **2026-11-08** 闭源版启用 `CONFIG_MTK_CHIP_MT7915E_DBDC=y` 及 `mt_wifi` 包

---

## ⚖️ 许可与致谢

- OpenWrt 官方：<https://openwrt.org>
- Lean LEDE：<https://github.com/coolsnowwolf/lede>
- Argon Theme：<https://github.com/jerrykuku/luci-theme-argon>
- MosDNS：<https://github.com/sbwml/luci-app-mosdns>
- MediaTek mt_wifi：来自 Lean 源码 `package/lean/mt/drivers/mt_wifi`

本项目仅提供自动化构建配置，固件组件版权归各上游所有。