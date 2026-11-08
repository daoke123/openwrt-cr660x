# OpenWRT CR660X 云编译配置

本仓库包含编译 Xiaomi CR660X (CR6606/CR6608) OpenWRT 固件所需的配置文件。CR660X 是一款基于 MediaTek MT7621 的 WiFi6 AX1800 路由器。

## 主要说明
- .config: 目标 ramips/mt7621, IP 192.168.66.1, Argon 主题, MosDNS
- feeds.conf.default: 6 个官方软件包源
- diy-config.sh: 自动更新feeds, 安装主题和MosDNS, 设置固定IP
- build.yml: GitHub Actions 云编译工作流

## 使用方法
### 本地编译
1. git clone https://github.com/coolsnowwolf/lede.git
2. 复制配置文件
3. ./scripts/feeds update -a && ./scripts/feeds install -a
4. chmod +x diy-config.sh && ./diy-config.sh
5. make -j1 V=s 开始编译

### GitHub云编译
1. 进入 Actions 标签页
2. 点击 Run workflow 手动触发
3. 等待 1-2 小时编译完成
4. 从 Artifacts 下载固件

## 注意事项
- CR660X 规格: MediaTek MT7621, WiFi6 AX1800, 4 GE 口
- 内存: 128MB/256MB, 如不足请使用 make -j1
- WiFi: 可能需要 kmod-mt7663-firmware-ap
- 内核: Linux 5.10.x 稳定版