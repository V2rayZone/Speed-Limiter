# V2rayZone Speed Limiter

🚀 **A powerful and user-friendly Ubuntu VPS Speed Limiter script with automatic bandwidth management**

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/V2rayZone/speed-limiter)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Ubuntu](https://img.shields.io/badge/ubuntu-18.04%2B-orange.svg)](https://ubuntu.com/)
[![Debian](https://img.shields.io/badge/debian-9%2B-red.svg)](https://www.debian.org/)

## 📋 Table of Contents

- [Features](#-features)
- [Quick Installation](#-quick-installation)
- [Usage](#-usage)
- [Speed Limiting Modes](#-speed-limiting-modes)
- [System Requirements](#-system-requirements)
- [Advanced Configuration](#-advanced-configuration)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

### 🎯 **Dual Speed Limiting Modes**
- **Manual Mode**: Set custom speed limits with optional data caps
- **Auto Mode**: Intelligent speed calculation based on bandwidth allocation and expiry date

### 🛠️ **Easy Management**
- One-command installation via curl
- Clean, numbered menu interface
- Real-time network statistics
- Automatic dependency installation

### 📊 **Advanced Monitoring**
- Network usage tracking with vnstat
- Data cap monitoring and enforcement
- Automatic speed recalculation
- Detailed logging and reporting

### 🔄 **Smart Automation**
- Cron-based auto updates
- Bandwidth exhaustion detection
- Expiry date management
- Configuration backup and restore

### 🔧 **System Integration**
- Traffic control using Linux `tc` (HTB + ingress)
- iptables integration for advanced filtering
- Systemd service management
- Multi-interface support

## 🚀 Quick Installation

### One-Line Installation

```bash
bash <(curl -Ls https://raw.githubusercontent.com/V2rayZone/speed-limiter/main/install.sh)
```

### Manual Installation

```bash
# Download the installer
wget https://raw.githubusercontent.com/V2rayZone/speed-limiter/main/install.sh

# Make it executable
chmod +x install.sh

# Run the installer
sudo ./install.sh
```

### After Installation

Once installed, simply run:

```bash
speedlimiter
```

## 📖 Usage

### Main Menu Options

```
╔══════════════════════════════════════════════════════════════╗
║                    V2rayZone Speed Limiter                  ║
║                     Network Traffic Control                  ║
╚══════════════════════════════════════════════════════════════╝

Available Options:
1. Install/Update Dependencies
2. Update Script from GitHub
3. Manual Speed Limit (Set custom Mbps + optional data cap)
4. Auto Speed Limit (Based on bandwidth + expiry date)
5. Remove Speed Limits
6. View Detailed Network Statistics
7. Uninstall Speed Limiter
8. Exit
```

### Quick Start Examples

#### Example 1: Manual Speed Limit
```bash
# Set 100 Mbps limit with 500GB monthly cap
speedlimiter
# Choose option 3 → Manual Speed Limit
# Interface: eth0 (default)
# Download Speed: 100
# Upload Speed: 100 (same as download)
# Data Cap: 500 GB
```

#### Example 2: Auto Speed Limit
```bash
# Auto-calculate speed for 1TB bandwidth until Aug 1, 2025
speedlimiter
# Choose option 4 → Auto Speed Limit
# Interface: eth0 (default)
# Total Bandwidth: 1000 GB
# Expiry Date: 2025-08-01
# System calculates optimal daily speed automatically
```

## 🎛️ Speed Limiting Modes

### 1. Manual Mode

**Perfect for**: Fixed speed requirements, testing, specific use cases

**Features**:
- Custom download/upload speed in Mbps
- Optional monthly data cap in GB
- Real-time usage monitoring
- Automatic cap enforcement

**Configuration Example**:
```bash
Interface: eth0
Download Speed: 50 Mbps
Upload Speed: 25 Mbps
Data Cap: 300 GB/month
```

### 2. Auto Mode

**Perfect for**: VPS with bandwidth quotas, time-limited services

**Features**:
- Intelligent speed calculation
- Automatic daily recalculation
- Bandwidth exhaustion protection
- Expiry date management

**Calculation Formula**:
```
Daily Allowance = (Total Bandwidth - Used Bandwidth) / Days Remaining
Speed (Mbps) = (Daily Allowance × 1024 × 8) / (24 × 3600)
```

**Configuration Example**:
```bash
Total Bandwidth: 1000 GB
Expiry Date: 2025-08-01
Current Usage: 150 GB
Days Remaining: 45
→ Calculated Speed: ~42 Mbps
```

## 💻 System Requirements

### Supported Operating Systems
- **Ubuntu**: 18.04, 20.04, 22.04, 24.04 LTS
- **Debian**: 9, 10, 11, 12

### Hardware Requirements
- **RAM**: 512 MB minimum, 1 GB recommended
- **Disk Space**: 100 MB free space
- **Network**: Any standard network interface

### Required Privileges
- **Root access** (sudo) for traffic control and system configuration

### Dependencies (Auto-installed)
- `iproute2` - Traffic control utilities
- `vnstat` - Network statistics
- `iptables-persistent` - Firewall rules
- `curl`, `wget` - Download utilities
- `bc` - Mathematical calculations
- `jq` - JSON processing
- `cron` - Task scheduling

## ⚙️ Advanced Configuration

### Configuration Files

```bash
/opt/speed-limiter/
├── manual_config.conf    # Manual mode settings
├── auto_config.conf      # Auto mode settings
├── version.txt          # Current version
└── backup/              # Configuration backups
```

### Manual Configuration File
```bash
# /opt/speed-limiter/manual_config.conf
INTERFACE="eth0"
DOWNLOAD_SPEED="100"
UPLOAD_SPEED="100"
DATA_CAP="500"
CREATED_DATE="2024-01-15"
MODE="manual"
```

### Auto Configuration File
```bash
# /opt/speed-limiter/auto_config.conf
INTERFACE="eth0"
TOTAL_BANDWIDTH="1000"
EXPIRY_DATE="2025-08-01"
CALCULATED_SPEED="42"
CREATED_DATE="2024-01-15"
LAST_UPDATED="2024-01-20"
MODE="auto"
```

### Cron Jobs

The script automatically sets up cron jobs for:

```bash
# Auto mode daily recalculation (2 AM)
0 2 * * * /opt/speed-limiter/auto_update.sh

# Manual mode data cap monitoring (hourly)
0 * * * * /opt/speed-limiter/monitor_data_cap.sh
```

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

## 🔧 Troubleshooting

### Common Issues

#### 1. "tc: command not found"
```bash
# Install iproute2
sudo apt update
sudo apt install iproute2
```

#### 2. "Permission denied" errors
```bash
# Ensure running as root
sudo speedlimiter
```

#### 3. Speed limits not working
```bash
# Check if interface exists
ip link show

# Verify traffic control rules
tc qdisc show dev eth0

# Check for conflicting rules
iptables -t mangle -L
```

#### 4. vnstat not collecting data
```bash
# Restart vnstat service
sudo systemctl restart vnstat

# Check vnstat status
sudo systemctl status vnstat

# Initialize interface manually
sudo vnstat -i eth0 --create
```

### Debug Mode

Enable debug logging:
```bash
# Set debug environment variable
export SPEEDLIMITER_DEBUG=1
speedlimiter
```

### Log Files

Check log files for issues:
```bash
# Auto update logs
tail -f /opt/speed-limiter/auto_update.log

# Data cap monitoring logs
tail -f /opt/speed-limiter/data_cap.log

# System logs
journalctl -u vnstat
```

### Reset Configuration

```bash
# Remove all speed limits
speedlimiter
# Choose option 5 → Remove Speed Limits

# Or manually reset
sudo tc qdisc del dev eth0 root
sudo tc qdisc del dev eth0 ingress
```

## 🔄 Updates and Maintenance

### Automatic Updates

The script can update itself from GitHub:

```bash
speedlimiter
# Choose option 2 → Update Script from GitHub
```

### Manual Update

```bash
# Download latest version
bash <(curl -Ls https://raw.githubusercontent.com/V2rayZone/speed-limiter/main/install.sh)
```

### Backup and Restore

```bash
# Backup configurations
cp -r /opt/speed-limiter/backup/ ~/speedlimiter-backup/

# Restore from backup
cp ~/speedlimiter-backup/* /opt/speed-limiter/
```

## 🗑️ Uninstallation

### Complete Removal

```bash
speedlimiter
# Choose option 7 → Uninstall Speed Limiter
# Choose option 1 → Complete Uninstall
```

### Manual Removal

```bash
# Remove speed limits
sudo tc qdisc del dev eth0 root 2>/dev/null || true
sudo tc qdisc del dev eth0 ingress 2>/dev/null || true

# Remove files
sudo rm -rf /opt/speed-limiter
sudo rm -f /usr/bin/speedlimiter

# Remove cron jobs
crontab -l | grep -v speed-limiter | crontab -
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Reporting Issues

1. Check existing [issues](https://github.com/V2rayZone/speed-limiter/issues)
2. Create a new issue with:
   - OS version and architecture
   - Error messages or logs
   - Steps to reproduce
   - Expected vs actual behavior

### Feature Requests

1. Open an issue with the "enhancement" label
2. Describe the feature and use case
3. Provide examples if possible

### Code Contributions

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Development Setup

```bash
# Clone the repository
git clone https://github.com/V2rayZone/speed-limiter.git
cd speed-limiter

# Test locally
sudo ./install.sh
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Linux Traffic Control (`tc`) developers
- vnstat network statistics tool
- Ubuntu and Debian communities
- All contributors and users

## 📞 Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/V2rayZone/speed-limiter/issues)
- **Documentation**: This README and inline help
- **Community**: Share experiences and solutions

## 🔗 Links

- **GitHub Repository**: https://github.com/V2rayZone/speed-limiter
- **Installation Script**: https://raw.githubusercontent.com/V2rayZone/speed-limiter/main/install.sh
- **Latest Release**: https://github.com/V2rayZone/speed-limiter/releases/latest

---

**Made with ❤️ by V2rayZone**

*Simplifying VPS bandwidth management, one script at a time.*