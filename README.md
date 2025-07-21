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

<!-- 3D Quick Start Section -->
<div style="margin: 40px 0; perspective: 1000px;">
  <h2 style="text-align: center; font-size: 2.5em; background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; margin-bottom: 30px; text-shadow: 0 5px 10px rgba(0,0,0,0.2); transform: perspective(1000px) rotateX(10deg);">⚡ Quick Start</h2>
  
  <!-- Documentation Notice -->
  <div style="background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%); padding: 20px; border-radius: 15px; margin: 20px 0; border-left: 5px solid #667eea; box-shadow: 0 8px 25px rgba(0,0,0,0.1); transform: perspective(1000px) rotateX(3deg);">
    <p style="margin: 0; font-size: 1.1em; color: #333;">📖 <strong>Full Documentation</strong>: For comprehensive installation and configuration guides, visit our <a href="https://github.com/V2rayZone/speed-limiter/wiki" style="color: #667eea; text-decoration: none; font-weight: bold;">Project Wiki</a></p>
  </div>
  
  <!-- Main Installation Command -->
  <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 25px; border-radius: 15px; margin: 25px 0; box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3); transform: perspective(1000px) rotateX(5deg); transition: all 0.3s ease;">
    <h3 style="color: white; margin: 0 0 15px 0; font-size: 1.3em; text-align: center;">🚀 One-Click Installation</h3>
    <div style="background: rgba(0,0,0,0.2); padding: 15px; border-radius: 10px; font-family: 'Courier New', monospace; color: #fff; font-size: 1.1em; text-align: center; border: 2px dashed rgba(255,255,255,0.3);">
      <code>bash &lt;(curl -Ls https://raw.githubusercontent.com/V2rayZone/speed-limiter/main/install.sh)</code>
    </div>
  </div>
  
  <!-- Alternative Methods -->
  <div style="margin: 30px 0;">
    <h3 style="text-align: center; background: linear-gradient(45deg, #764ba2, #f093fb); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; font-size: 1.8em; margin-bottom: 25px;">🔧 Alternative Installation Methods</h3>
    
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px;">
      
      <!-- Wget Method -->
      <div style="background: linear-gradient(135deg, #764ba2 0%, #f093fb 100%); padding: 20px; border-radius: 15px; color: white; box-shadow: 0 8px 25px rgba(118, 75, 162, 0.3); transform: perspective(1000px) rotateY(-3deg) rotateX(3deg); transition: all 0.3s ease;">
        <h4 style="margin: 0 0 15px 0; font-size: 1.2em; text-align: center;">📥 Using wget</h4>
        <div style="background: rgba(0,0,0,0.2); padding: 12px; border-radius: 8px; font-family: 'Courier New', monospace; font-size: 0.9em; border: 1px dashed rgba(255,255,255,0.3);">
          <code>wget -O install.sh https://raw.githubusercontent.com/V2rayZone/speed-limiter/main/install.sh && sudo bash install.sh</code>
        </div>
      </div>
      
      <!-- Manual Method -->
      <div style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); padding: 20px; border-radius: 15px; color: white; box-shadow: 0 8px 25px rgba(240, 147, 251, 0.3); transform: perspective(1000px) rotateY(3deg) rotateX(3deg); transition: all 0.3s ease;">
        <h4 style="margin: 0 0 15px 0; font-size: 1.2em; text-align: center;">🛠️ Manual Installation</h4>
        <div style="background: rgba(0,0,0,0.2); padding: 12px; border-radius: 8px; font-family: 'Courier New', monospace; font-size: 0.9em; border: 1px dashed rgba(255,255,255,0.3);">
          <code># Download and verify<br>wget https://raw.githubusercontent.com/V2rayZone/speed-limiter/main/install.sh<br>chmod +x install.sh<br>sudo ./install.sh</code>
        </div>
      </div>
      
      <!-- Specific Version -->
      <div style="background: linear-gradient(135deg, #f5576c 0%, #4facfe 100%); padding: 20px; border-radius: 15px; color: white; box-shadow: 0 8px 25px rgba(245, 87, 108, 0.3); transform: perspective(1000px) rotateY(-3deg) rotateX(3deg); transition: all 0.3s ease;">
        <h4 style="margin: 0 0 15px 0; font-size: 1.2em; text-align: center;">🏷️ Specific Version</h4>
        <div style="background: rgba(0,0,0,0.2); padding: 12px; border-radius: 8px; font-family: 'Courier New', monospace; font-size: 0.9em; border: 1px dashed rgba(255,255,255,0.3);">
          <code>VERSION=v1.0.0 && bash &lt;(curl -Ls "https://raw.githubusercontent.com/V2rayZone/speed-limiter/$VERSION/install.sh") $VERSION</code>
        </div>
      </div>
      
    </div>
  </div>
</div>

<style>
.install-card:hover {
  transform: perspective(1000px) rotateY(0deg) rotateX(0deg) scale(1.02) !important;
  box-shadow: 0 12px 35px rgba(102, 126, 234, 0.4) !important;
}
</style>

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
| **OS** | Ubuntu 18.04+ / Debian 9+ |
| **RAM** | 512 MB minimum |
| **Storage** | 100 MB free space |
| **Privileges** | Root access (sudo) |
| **Network** | Standard interface (eth0, ens3, etc.) |

### Dependencies
All dependencies are automatically installed:
- `iproute2`, `vnstat`, `iptables-persistent`
- `curl`, `wget`, `bc`, `jq`, `cron`

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

<!-- 3D Special Thanks Section -->
<div style="margin: 50px 0; perspective: 1000px;">
  <h2 style="text-align: center; font-size: 2.5em; background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; margin-bottom: 30px; text-shadow: 0 5px 10px rgba(0,0,0,0.2); transform: perspective(1000px) rotateX(10deg);">🙏 A Special Thanks to</h2>
  
  <div style="text-align: center; background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%); padding: 30px; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); transform: perspective(1000px) rotateX(3deg); transition: all 0.3s ease;">
    <a href="https://github.com/V2rayZone/speed-limiter/graphs/contributors" style="display: inline-block; transform: perspective(500px) rotateX(5deg); transition: all 0.3s ease;">
      <img src="https://contrib.rocks/image?repo=V2rayZone/speed-limiter" style="border-radius: 15px; box-shadow: 0 8px 25px rgba(0,0,0,0.2); filter: brightness(1.1);" />
    </a>
  </div>
</div>

<!-- 3D Acknowledgment Section -->
<div style="margin: 50px 0; perspective: 1000px;">
  <h2 style="text-align: center; font-size: 2.5em; background: linear-gradient(135deg, #764ba2 0%, #f093fb 50%, #f5576c 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; margin-bottom: 30px; text-shadow: 0 5px 10px rgba(0,0,0,0.2); transform: perspective(1000px) rotateX(10deg);">🏆 Acknowledgment</h2>
  
  <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; margin: 30px 0;">
    
    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 25px; border-radius: 15px; color: white; box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3); transform: perspective(1000px) rotateY(-5deg) rotateX(5deg); transition: all 0.3s ease; animation: float 6s ease-in-out infinite;">
      <div style="font-size: 2.5em; margin-bottom: 15px; text-align: center;">🐧</div>
      <h3 style="margin: 0 0 10px 0; font-size: 1.2em; text-align: center;">Linux Traffic Control</h3>
      <p style="margin: 0; opacity: 0.9; line-height: 1.5; text-align: center;">Advanced traffic shaping capabilities using `tc` and HTB queueing discipline</p>
    </div>
    
    <div style="background: linear-gradient(135deg, #764ba2 0%, #f093fb 100%); padding: 25px; border-radius: 15px; color: white; box-shadow: 0 10px 30px rgba(118, 75, 162, 0.3); transform: perspective(1000px) rotateY(5deg) rotateX(5deg); transition: all 0.3s ease; animation: float 6s ease-in-out infinite 0.5s;">
      <div style="font-size: 2.5em; margin-bottom: 15px; text-align: center;">📊</div>
      <h3 style="margin: 0 0 10px 0; font-size: 1.2em; text-align: center;">vnstat</h3>
      <p style="margin: 0; opacity: 0.9; line-height: 1.5; text-align: center;">Network traffic monitoring and statistics collection</p>
    </div>
    
    <div style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); padding: 25px; border-radius: 15px; color: white; box-shadow: 0 10px 30px rgba(240, 147, 251, 0.3); transform: perspective(1000px) rotateY(-5deg) rotateX(5deg); transition: all 0.3s ease; animation: float 6s ease-in-out infinite 1s;">
      <div style="font-size: 2.5em; margin-bottom: 15px; text-align: center;">🌐</div>
      <h3 style="margin: 0 0 10px 0; font-size: 1.2em; text-align: center;">iproute2</h3>
      <p style="margin: 0; opacity: 0.9; line-height: 1.5; text-align: center;">Modern networking utilities for Linux traffic control</p>
    </div>
    
    <div style="background: linear-gradient(135deg, #f5576c 0%, #4facfe 100%); padding: 25px; border-radius: 15px; color: white; box-shadow: 0 10px 30px rgba(245, 87, 108, 0.3); transform: perspective(1000px) rotateY(5deg) rotateX(5deg); transition: all 0.3s ease; animation: float 6s ease-in-out infinite 1.5s;">
      <div style="font-size: 2.5em; margin-bottom: 15px; text-align: center;">🐧</div>
      <h3 style="margin: 0 0 10px 0; font-size: 1.2em; text-align: center;">Ubuntu/Debian Communities</h3>
      <p style="margin: 0; opacity: 0.9; line-height: 1.5; text-align: center;">Providing stable platforms and package management</p>
    </div>
    
  </div>
</div>

<!-- 3D Support Project Section -->
<div style="margin: 50px 0; perspective: 1000px;">
  <h2 style="text-align: center; font-size: 2.5em; background: linear-gradient(135deg, #f5576c 0%, #4facfe 50%, #00f2fe 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; margin-bottom: 30px; text-shadow: 0 5px 10px rgba(0,0,0,0.2); transform: perspective(1000px) rotateX(10deg);">💖 Support project</h2>
  
  <div style="text-align: center; margin: 30px 0;">
    <div style="background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%); padding: 25px; border-radius: 20px; display: inline-block; box-shadow: 0 10px 30px rgba(102, 126, 234, 0.2); transform: perspective(1000px) rotateX(5deg); transition: all 0.3s ease;">
      <p style="font-size: 1.3em; margin: 0 0 15px 0; background: linear-gradient(45deg, #667eea, #764ba2); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; font-weight: bold;">If this project is helpful to you, you may wish to give it a🌟</p>
      <a href="https://github.com/V2rayZone/speed-limiter/stargazers" style="display: inline-block; transform: perspective(500px) rotateX(3deg); transition: all 0.3s ease;">
        <img src="https://img.shields.io/github/stars/V2rayZone/speed-limiter?style=social" alt="GitHub stars" style="border-radius: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.2);">
      </a>
    </div>
  </div>
  
  <!-- Donation Section -->
  <div style="margin: 40px 0;">
    <h3 style="text-align: center; background: linear-gradient(45deg, #f5576c, #4facfe); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; font-size: 1.8em; margin-bottom: 25px;">💰 Crypto Donations</h3>
    
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; max-width: 800px; margin: 0 auto;">
      
      <!-- USDT -->
      <div style="background: linear-gradient(135deg, #f5576c 0%, #4facfe 100%); padding: 20px; border-radius: 15px; color: white; box-shadow: 0 8px 25px rgba(245, 87, 108, 0.3); transform: perspective(1000px) rotateY(-3deg) rotateX(3deg); transition: all 0.3s ease;">
        <div style="font-size: 2em; margin-bottom: 10px; text-align: center;">💎</div>
        <h4 style="margin: 0 0 10px 0; font-size: 1.1em; text-align: center;">USDT (TRC20)</h4>
        <div style="background: rgba(0,0,0,0.2); padding: 10px; border-radius: 8px; font-family: 'Courier New', monospace; font-size: 0.8em; word-break: break-all; text-align: center; border: 1px dashed rgba(255,255,255,0.3);">
          <code>TXncxkvhkDWGts487Pjqq1qT9JmwRUz8CC</code>
        </div>
      </div>
      
      <!-- MATIC -->
      <div style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); padding: 20px; border-radius: 15px; color: white; box-shadow: 0 8px 25px rgba(79, 172, 254, 0.3); transform: perspective(1000px) rotateY(3deg) rotateX(3deg); transition: all 0.3s ease;">
        <div style="font-size: 2em; margin-bottom: 10px; text-align: center;">🔷</div>
        <h4 style="margin: 0 0 10px 0; font-size: 1.1em; text-align: center;">MATIC (Polygon)</h4>
        <div style="background: rgba(0,0,0,0.2); padding: 10px; border-radius: 8px; font-family: 'Courier New', monospace; font-size: 0.8em; word-break: break-all; text-align: center; border: 1px dashed rgba(255,255,255,0.3);">
          <code>0x41C9548675D044c6Bfb425786C765bc37427256A</code>
        </div>
      </div>
      
      <!-- LTC -->
      <div style="background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%); padding: 20px; border-radius: 15px; color: white; box-shadow: 0 8px 25px rgba(0, 242, 254, 0.3); transform: perspective(1000px) rotateY(-3deg) rotateX(3deg); transition: all 0.3s ease;">
        <div style="font-size: 2em; margin-bottom: 10px; text-align: center;">🪙</div>
        <h4 style="margin: 0 0 10px 0; font-size: 1.1em; text-align: center;">LTC (Litecoin)</h4>
        <div style="background: rgba(0,0,0,0.2); padding: 10px; border-radius: 8px; font-family: 'Courier New', monospace; font-size: 0.8em; word-break: break-all; text-align: center; border: 1px dashed rgba(255,255,255,0.3);">
          <code>ltc1q2ach7x6d2zq0n4l0t4zl7d7xe2s6fs7a3vspwv</code>
        </div>
      </div>
      
    </div>
  </div>
</div>

<!-- 3D Stargazers Section -->
<div style="margin: 50px 0; perspective: 1000px;">
  <h2 style="text-align: center; font-size: 2.5em; background: linear-gradient(135deg, #4facfe 0%, #00f2fe 50%, #667eea 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; margin-bottom: 30px; text-shadow: 0 5px 10px rgba(0,0,0,0.2); transform: perspective(1000px) rotateX(10deg);">⭐ Stargazers over Time</h2>
  
  <div style="text-align: center; background: linear-gradient(135deg, rgba(79, 172, 254, 0.1) 0%, rgba(0, 242, 254, 0.1) 100%); padding: 30px; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); transform: perspective(1000px) rotateX(3deg); transition: all 0.3s ease;">
    <a href="https://github.com/V2rayZone/speed-limiter/stargazers" style="display: inline-block; transform: perspective(500px) rotateX(5deg); transition: all 0.3s ease;">
      <img src="https://starchart.cc/V2rayZone/speed-limiter.svg" alt="Stargazers over time" style="border-radius: 15px; box-shadow: 0 8px 25px rgba(0,0,0,0.2); filter: brightness(1.1); max-width: 100%; height: auto;">
    </a>
  </div>
</div>

<style>
.support-card:hover {
  transform: perspective(1000px) rotateY(0deg) rotateX(0deg) scale(1.05) !important;
  box-shadow: 0 15px 40px rgba(102, 126, 234, 0.4) !important;
}

.ack-card:hover {
  transform: perspective(1000px) rotateY(0deg) rotateX(0deg) scale(1.05) !important;
  box-shadow: 0 15px 40px rgba(118, 75, 162, 0.4) !important;
}
</style>