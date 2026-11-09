# OpenWrt CR660X 云编译（ImageBuilder）

使用 **OpenWrt 官方 ImageBuilder** 为小米 CR660X（CR6606 / CR6608 / CR6609，ramips/mt7621）组装固件，
由 GitHub Actions 云端构建，产物自动发布到 **Releases**。

> ImageBuilder 只做「官方预编译软件包 + 配置」的组装，不重新编译内核和工具链，
> 因此构建时间通常 **5–15 分钟**，稳定可靠，已验证通过。

---

## 🚀 使用方法

1. 打开仓库 **Actions** 页面。
2. 选择 **OpenWrt CR660X ImageBuilder** → **Run workflow**。
3. 参数（都可留空）：
   - `version`：OpenWrt 版本，例如 `25.12.6`；留空自动使用最新 `25.12.x`。
   - `device`：`all`（默认，三个型号都构建）/ `cr6606` / `cr6608` / `cr6609`。
4. 等待 5–15 分钟构建完成，进入 **Releases** 下载固件。

---

## 📦 固件包含

| 项目 | 说明 |
| --- | --- |
| OpenWrt | 25.12.x（默认自动取最新版本） |
| 管理地址 | `http://192.168.66.1`，默认无密码 |
| WiFi | 双频合一，SSID `cr660x`，密码 `12345678`（WPA2-PSK） |
| WiFi 驱动 | 开源 `mt76` (mt7915e) + 性能调优参数 |
| 主题 | Argon（第三方） |
| DNS | MosDNS v5（第三方） |
| 其他 | LuCI、中文界面、默认中文、时区 Asia/Shanghai、主机名 CR660X |

### 开源驱动已内置的调优参数

```sh
# 发射功率 23dBm（2.4G / 5G）
uci set wireless.radio0.txpower='23'
uci set wireless.radio1.txpower='23'
# HE (802.11ax) BSS Coloring
uci set wireless.radio0.he_bss_color='1'
uci set wireless.radio1.he_bss_color='1'
# MU-MIMO Beamformer / Beamformee
uci set wireless.radio0.mu_beamformer='1'
uci set wireless.radio1.mu_beamformer='1'
```

---

## 📁 固件下载与刷机

Release 中的文件（以 25.12.6 为例）：

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

> ⚠️ 刷机有风险，请先备份原厂固件与 EEPROM。
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
| `device` | `all` / `cr6606` / `cr6608` / `cr6609` | `all` |

第三方组件在构建时自动从各自仓库的**最新 Release** 拉取，无需手动维护版本：

- Argon：<https://github.com/jerrykuku/luci-theme-argon>
- MosDNS：<https://github.com/sbwml/luci-app-mosdns>（分支 `v5`，预编译包 `mipsel_24kc-openwrt-25.12`）

---

## 📖 WiFi 性能调优建议

如果 WiFi 速度仍不理想，按顺序排查：

1. **确认客户端能力**：WiFi 6 (802.11ax)、支持 80MHz 频宽、2×2 MIMO 以上
2. **选清净信道**：5G 推荐 149/153/157/161（非 DFS），2.4G 推荐 1/6/11
3. **距离与遮挡**：5G 穿墙衰减大，近距测速；2.4G 抗遮挡但速率低（理论上限 ~866Mbps，实际 150-300Mbps）
4. **散热**：路由器过热会触发降频，注意通风
5. **本地测速排除宽带因素**：`iperf3 -c 192.168.66.1 -P 4 -t 30`
6. **固定信道 + 固定频宽**：在 LuCI 无线设置中锁定 80MHz（5G）/ 40MHz（2.4G）
7. **CR660X 硬件上限参考**：5G 近距理想值 600-900Mbps，2.4G 100-250Mbps；若远低于此再考虑驱动因素

---

## 📂 仓库结构

```text
.github/workflows/build.yml       GitHub Actions 工作流（ImageBuilder 组装 + 发布 Releases）
files/etc/uci-defaults/99-cr660x  首启脚本：LAN IP、WiFi、中文、时区、驱动调优
README.md                         本文件
```

---

## 📝 更新日志

- **2026-11-09** 移除闭源 mt_wifi 编译方案（与 Linux 6.18 内核存在多层 API 不兼容，维护成本过高）；保留并优化开源 ImageBuilder 方案为唯一构建方式
- **2026-11-08** 开源版修复 `kmod-mt76-xqca` 不存在导致的构建失败；新增 mt76 调优参数
- **2026-11-08** 新增默认 WiFi 配置：`cr660x` / `12345678` 双频合一
- **2026-11-08** 从源码全量编译迁移到官方 ImageBuilder，构建时间从 1–2 小时降至 5–15 分钟

---

## ⚖️ 许可与致谢

- OpenWrt 官方：<https://openwrt.org>
- Argon Theme：<https://github.com/jerrykuku/luci-theme-argon>
- MosDNS：<https://github.com/sbwml/luci-app-mosdns>
- 开源 mt76 驱动：Linux 内核主线 / OpenWrt 官方源

本项目仅提供自动化构建配置，固件组件版权归各上游所有。