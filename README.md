**English** | [فارسی](#) | [العربية](#) | [中文](#) | [Español](#) | [Русский](#)

<p align="center">
  <a href="https://github.com/V2rayZone/speed-limiter">
    <img src="https://img.shields.io/github/v/release/V2rayZone/speed-limiter?style=flat-square" alt="Version">
  </a>
  <a href="https://github.com/V2rayZone/speed-limiter/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/V2rayZone/speed-limiter?style=flat-square" alt="License">
  </a>
  <a href="https://github.com/V2rayZone/speed-limiter/stargazers">
    <img src="https://img.shields.io/github/stars/V2rayZone/speed-limiter?style=flat-square" alt="Stars">
  </a>
  <a href="https://github.com/V2rayZone/speed-limiter/network/members">
    <img src="https://img.shields.io/github/forks/V2rayZone/speed-limiter?style=flat-square" alt="Forks">
  </a>
</p>

# Speed Limiter

**Speed Limiter** — advanced, open-source bandwidth management tool designed for VPS traffic control. It offers a user-friendly interface for configuring and monitoring network speed limits with both manual and automatic modes.

> **Important**  
> This project is only for personal use, please do not use it for illegal purposes, please do not use it in a production environment.

<p align="center">
  <strong>A powerful VPS bandwidth management tool that provides intelligent speed limiting with both manual and automatic modes. Perfect for managing server resources and controlling network traffic efficiently.</strong>
</p>

> **⚠️ Important Disclaimer**  
> This tool is designed for legitimate server administration and bandwidth management purposes only. Users are responsible for ensuring compliance with their hosting provider's terms of service and applicable laws. The developers are not responsible for any misuse of this software.

---

## Table of Contents

- [🚀 Features](#features)
- [⚡ Quick Start](#quick-start)
- [💻 System Requirements](#system-requirements)
- [📖 Usage](#usage)
- [🎛️ Speed Limiting Modes](#speed-limiting-modes)
- [⚙️ Advanced Configuration](#advanced-configuration)
- [🔧 Troubleshooting](#troubleshooting)
- [🔄 Updates and Maintenance](#updates-and-maintenance)
- [🤝 Contributing](#contributing)
- [📄 License](#license)

## Features

- **Dual Speed Control Modes**: Manual speed setting and intelligent auto-calculation based on bandwidth quotas
- **Advanced Traffic Shaping**: Linux `tc` with HTB queueing discipline and ingress control
- **Real-time Monitoring**: Network statistics with vnstat integration and data cap enforcement
- **Smart Automation**: Cron-based updates, bandwidth exhaustion detection, and expiry management
- **Easy Installation**: One-command setup with automatic dependency management
- **Multi-platform Support**: Ubuntu 18.04+ and Debian 9+ compatibility
- **Professional Interface**: Clean menu system with detailed network statistics
- **Configuration Management**: Backup/restore capabilities with version control
- **System Integration**: iptables support and systemd service management

## Quick Start

> **📖 Full Documentation**: For comprehensive installation and configuration guides, visit our [Project Wiki](https://github.com/V2rayZone/speed-limiter/wiki)

### 🚀 One-Click Installation

```bash
bash <(curl -Ls https://raw.githubusercontent.com/V2rayZone/speed-limiter/main/install.sh)
```

### 🔧 Alternative Installation Methods

**Using wget:**
```bash
wget -O install.sh https://raw.githubusercontent.com/V2rayZone/speed-limiter/main/install.sh && sudo bash install.sh
```

**Manual Installation:**
```bash
# Download and verify
wget https://raw.githubusercontent.com/V2rayZone/speed-limiter/main/install.sh
chmod +x install.sh
sudo ./install.sh
```

**Specific Version:**
```bash
VERSION=v1.0.0 && bash <(curl -Ls "https://raw.githubusercontent.com/V2rayZone/speed-limiter/$VERSION/install.sh") $VERSION
```

## Usage

After installation, run the speed limiter:

```bash
speedlimiter
```

### Main Menu

```
╔══════════════════════════════════════════════════════════════╗
║                    V2rayZone Speed Limiter                  ║
║                     Network Traffic Control                  ║
╚══════════════════════════════════════════════════════════════╝

1. Install/Update Dependencies
2. Update Script from GitHub  
3. Manual Speed Limit
4. Auto Speed Limit
5. Remove Speed Limits
6. View Network Statistics
7. Uninstall Speed Limiter
8. Exit
```

### Quick Examples

**Manual Mode**: Set 100 Mbps with 500GB cap
```bash
speedlimiter → Option 3 → eth0 → 100 Mbps → 500 GB
```

**Auto Mode**: Calculate speed for 1TB until expiry
```bash
speedlimiter → Option 4 → eth0 → 1000 GB → 2025-08-01
```

## Speed Limiting Modes

### Manual Mode
Fixed speed limits with optional data caps
- Custom download/upload speeds (Mbps)
- Monthly data cap enforcement
- Real-time usage monitoring
- Perfect for testing and specific requirements

### Auto Mode  
Intelligent speed calculation based on quotas
- Automatic daily speed recalculation
- Bandwidth exhaustion protection
- Expiry date management
- Ideal for VPS with bandwidth limits

**Auto Calculation Formula:**
```
Daily Allowance = (Total - Used) / Days Remaining
Speed (Mbps) = (Daily Allowance × 8192) / 86400
```

## System Requirements

| Component | Requirement |
|-----------|-------------|
| **OS** | Ubuntu 18.04+ / Debian 9+ / CentOS 7+ |
| **Architecture** | x86_64 / ARM64 |
| **RAM** | 512MB minimum |
| **Storage** | 100MB free space |
| **Network** | Root access required |

**Dependencies:** `tc`, `vnstat`, `iptables`, `cron`, `curl/wget`

## Advanced Configuration

### File Structure
```
/opt/speed-limiter/
├── manual_config.conf    # Manual mode settings
├── auto_config.conf      # Auto mode settings  
├── version.txt          # Current version
└── backup/              # Configuration backups
```

### Configuration Examples

**Manual Mode:**
```bash
INTERFACE="eth0"
DOWNLOAD_SPEED="100"
UPLOAD_SPEED="100" 
DATA_CAP="500"
MODE="manual"
```

**Auto Mode:**
```bash
INTERFACE="eth0"
TOTAL_BANDWIDTH="1000"
EXPIRY_DATE="2025-08-01"
CALCULATED_SPEED="42"
MODE="auto"
```

### Automation
Automatic cron jobs are configured for:
- Auto mode: Daily recalculation (2 AM)
- Manual mode: Hourly data cap monitoring

### Traffic Control Commands

View current traffic control rules:
```bash
# Show all qdisc rules
tc qdisc show

# Show rules for specific interface
tc qdisc show dev eth0

# Show detailed class information
tc class show dev eth0
```

### Network Statistics

View network usage:
```bash
# Daily statistics
vnstat -d

# Monthly statistics
vnstat -m

# Real-time monitoring
vnstat -l
```

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| `tc: command not found` | `sudo apt install iproute2` |
| Permission denied | Run with `sudo speedlimiter` |
| Speed limits not working | Check interface: `ip link show` |
| vnstat not collecting | `sudo systemctl restart vnstat` |

### Debug Commands
```bash
# Check traffic control rules
tc qdisc show dev eth0

# Verify network interface
ip link show

# Monitor real-time traffic
vnstat -l

# Check system logs
journalctl -u vnstat
```

## Updates and Maintenance

### Update Methods
```bash
# Via menu system
speedlimiter → Option 2

# Direct update
bash <(curl -Ls https://raw.githubusercontent.com/V2rayZone/speed-limiter/main/install.sh)
```

### Backup/Restore
```bash
# Backup
cp -r /opt/speed-limiter/backup/ ~/speedlimiter-backup/

# Restore  
cp ~/speedlimiter-backup/* /opt/speed-limiter/
```

## Uninstallation

### Via Menu
```bash
speedlimiter → Option 7 → Complete Uninstall
```

### Manual Removal
```bash
# Remove traffic control
sudo tc qdisc del dev eth0 root 2>/dev/null || true
sudo tc qdisc del dev eth0 ingress 2>/dev/null || true

# Remove files and cron jobs
sudo rm -rf /opt/speed-limiter /usr/bin/speedlimiter
crontab -l | grep -v speed-limiter | crontab -
```

## Contributing

We welcome contributions to improve V2rayZone Speed Limiter!

### How to Contribute

1. **Report Issues**: Use [GitHub Issues](https://github.com/V2rayZone/speed-limiter/issues) with detailed information
2. **Feature Requests**: Open an issue with the "enhancement" label
3. **Code Contributions**: Fork → Branch → Code → Test → Pull Request

### Development

```bash
# Clone and test
git clone https://github.com/V2rayZone/speed-limiter.git
cd speed-limiter && sudo ./install.sh
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## A Special Thanks to

<p align="center">
  <a href="https://github.com/V2rayZone/speed-limiter/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=V2rayZone/speed-limiter" alt="Contributors">
  </a>
</p>

## Acknowledgment

- **Linux Traffic Control**: Advanced traffic shaping capabilities using `tc` and HTB queueing discipline
- **vnstat**: Network traffic monitoring and statistics collection
- **iproute2**: Modern networking utilities for Linux traffic control
- **Ubuntu/Debian Communities**: Providing stable platforms and package management

## Support project

If this project is helpful to you, you may wish to give it a🌟

<p align="center">
  <a href="https://github.com/V2rayZone/speed-limiter/stargazers">
    <img src="https://img.shields.io/github/stars/V2rayZone/speed-limiter?style=social" alt="GitHub stars">
  </a>
</p>

**USDT (TRC20)**: `TXncxkvhkDWGts487Pjqq1qT9JmwRUz8CC`  
**MATIC (Polygon)**: `0x41C9548675D044c6Bfb425786C765bc37427256A`  
**LTC (Litecoin)**: `ltc1q2ach7x6d2zq0n4l0t4zl7d7xe2s6fs7a3vspwv`

## Stargazers over Time

<p align="center">
  <a href="https://github.com/V2rayZone/speed-limiter/stargazers">
    <img src="https://starchart.cc/V2rayZone/speed-limiter.svg" alt="Stargazers over time">
  </a>
</p>