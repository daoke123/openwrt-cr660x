# OpenWRT CR660X Cloud Compilation

This repository contains the configuration files needed to compile OpenWRT for Xiaomi CR660X (CR6606/CR6608) in the cloud (GitHub Actions).

## Directory Structure

/Openwrt/
├── .config          # Main build configuration
├── feeds.conf.default  # Package feeds sources
├── diy-config.sh    # Custom configuration script
└── .github/
    └── workflows/
        └── build.yml  # GitHub Actions workflow (optional)

## Files Description

### 1. `.config`
Main configuration file containing:
- Target: ramips/mt7621 (CR660X platform)
- Default IP: 192.168.66.1 (changed from default 192.168.1.1)
- Theme: luci-theme-argon (enabled)
- DNS: MosDNS (enabled)
- Kernel: Linux 5.10 for MT7621
- Essential packages: kmod-mt76, kmod-mt7621, etc.

### 2. `feeds.conf.default`
Defines the package feed sources from the official OpenWRT snapshot repositories. Includes:
- core, base, luci, routing, telephony, management feeds
- Comments showing how to add third-party feeds

### 3. `diy-config.sh`
Customization script called during build process. It:
- Updates all feeds
- Installs Argon theme and MosDNS
- Installs additional recommended packages
- Sets the default IP to 192.168.66.1
- Runs `make defconfig`

### 4. `README.md`
Detailed usage guide, including:
- Directory structure overview
- Each file's function explanation
- **Local compilation** step-by-step tutorial
- **GitHub cloud compilation** tutorial (with complete `.github/workflows/build.yml` workflow)
- Customization guide: adding more packages, modifying IP, changing theme
- CR660X hardware notes (memory, WiFi firmware, kernel version)

## How to Use

### Local Compilation

1. Clone the OpenWRT source:
   ```bash
   git clone https://github.com/coolsnowwolf/lede.git
   cd lede
   ```

2. Copy the configuration files:
   ```bash
   mkdir -p /tmp/openwrt-cr660x
   # Copy .config, feeds.conf.default, diy-config.sh from this repo
   ```

3. Initialize and update feeds:
   ```bash
   ./scripts/feeds update -a
   ./scripts/feeds install -a
   ```

4. Run the customization script:
   ```bash
   chmod +x diy-config.sh
   ./diy-config.sh
   ```

5. Start compilation:
   ```bash
   make -j1 V=s
   ```

### GitHub Cloud Compilation

1. Create a new repository on GitHub
2. Upload these files to the repository
3. Add a GitHub Actions workflow (see example above)
4. Go to the "Actions" tab and trigger the build
5. Wait for compilation to complete (typically 1-2 hours)
6. Download the firmware from the Actions artifacts

## Customization

### Adding More Packages
Edit `diy-config.sh` to add more packages:
```bash
./scripts/feeds install package-name
```

### Modifying the IP Address
To change the default IP, edit `.config`:
```
CONFIG_INTERFACE_LAN='192.168.xxx.yyy'
```

### Changing the Theme
The Argon theme version can be selected by modifying:
- `luci-theme-argon` (default)
- `luci-theme-argon-mod` (modified version)
- Other themes by changing the package name

## Notes

- **CR660X Specifications**: MediaTek MT7621, WiFi6 AX1800, 4 GE ports
- **RAM**: Typically 128MB or 256MB - use `make -j1` if memory issues occur
- **WiFi**: May require `kmod-mt7663-firmware-ap` for full functionality
- **Kernel**: This configuration uses Linux 5.10.x which is stable for MT7621
