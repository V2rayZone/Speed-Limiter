#!/bin/bash

# V2RayZone Speed Limiter - Main Installation Script
# Author: V2RayZone
# Description: Ubuntu VPS Speed Limiter with Manual and Auto modes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="/opt/speed-limiter"
BIN_PATH="/usr/bin/speedlimiter"
GITHUB_REPO="https://github.com/V2RayZone/speed-limiter.git"
RAW_BASE="https://raw.githubusercontent.com/V2RayZone/speed-limiter/main"

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root. Use: sudo bash <(curl -Ls https://raw.githubusercontent.com/V2RayZone/speed-limiter/main/install.sh)"
        exit 1
    fi
}

# Detect OS
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        error "Cannot detect OS. This script is designed for Ubuntu."
        exit 1
    fi
    
    if [[ $OS != *"Ubuntu"* ]]; then
        error "This script is designed for Ubuntu only. Detected: $OS"
        exit 1
    fi
    
    log "Detected: $OS $VER"
}

# Install dependencies
install_dependencies() {
    log "Installing required dependencies..."
    
    apt-get update -qq
    
    # Install required packages
    local packages=("iproute2" "vnstat" "iptables-persistent" "curl" "wget" "bc" "cron")
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            log "Installing $package..."
            apt-get install -y "$package" > /dev/null 2>&1
        else
            log "$package is already installed"
        fi
    done
    
    # Start and enable vnstat
    systemctl enable vnstat > /dev/null 2>&1
    systemctl start vnstat > /dev/null 2>&1
    
    log "Dependencies installed successfully"
}

# Download core scripts
download_scripts() {
    log "Downloading core scripts..."
    
    # Create directory structure
    mkdir -p "$SCRIPT_DIR"/{core,utils}
    
    # Download core files
    local files=(
        "core/menu.sh"
        "core/limit_manual.sh"
        "core/limit_auto.sh"
        "core/uninstall.sh"
        "core/update.sh"
        "utils/detect_os.sh"
        "utils/network_utils.sh"
    )
    
    for file in "${files[@]}"; do
        log "Downloading $file..."
        curl -s "$RAW_BASE/$file" -o "$SCRIPT_DIR/$file"
        chmod +x "$SCRIPT_DIR/$file"
    done
    
    log "Core scripts downloaded successfully"
}

# Create main executable
create_executable() {
    log "Creating main executable..."
    
    cat > "$BIN_PATH" << 'EOF'
#!/bin/bash
# V2RayZone Speed Limiter - Main Entry Point

SCRIPT_DIR="/opt/speed-limiter"

if [[ ! -d "$SCRIPT_DIR" ]]; then
    echo "Speed Limiter is not installed. Please run the installation script first."
    exit 1
fi

# Source the main menu
source "$SCRIPT_DIR/core/menu.sh"
EOF
    
    chmod +x "$BIN_PATH"
    log "Executable created at $BIN_PATH"
}

# Main installation function
main() {
    echo -e "${BLUE}"
    echo "==========================================="
    echo "    V2RayZone Speed Limiter Installer"
    echo "==========================================="
    echo -e "${NC}"
    
    check_root
    detect_os
    install_dependencies
    download_scripts
    create_executable
    
    echo -e "${GREEN}"
    echo "==========================================="
    echo "         Installation Complete!"
    echo "==========================================="
    echo -e "${NC}"
    echo "Usage: speedlimiter"
    echo "Or run: /usr/bin/speedlimiter"
    echo ""
    echo "To start the speed limiter menu, simply type: speedlimiter"
    echo ""
}

# Run main function
main "$@"