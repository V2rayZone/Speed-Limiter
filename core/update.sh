#!/bin/bash

# V2RayZone Speed Limiter - Update Script
# Author: V2RayZone

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR="/opt/speed-limiter"
GITHUB_REPO="https://github.com/V2RayZone/speed-limiter.git"
RAW_BASE="https://raw.githubusercontent.com/V2RayZone/speed-limiter/main"
VERSION_FILE="$SCRIPT_DIR/version.txt"
CURRENT_VERSION="1.0.0"

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

# Check internet connectivity
check_internet() {
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        return 0
    else
        error "No internet connection available"
        return 1
    fi
}

# Get current version
get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE"
    else
        echo "$CURRENT_VERSION"
    fi
}

# Get latest version from GitHub
get_latest_version() {
    curl -s "$RAW_BASE/version.txt" 2>/dev/null || echo "unknown"
}

# Save version
save_version() {
    local version=$1
    echo "$version" > "$VERSION_FILE"
}

# Install/Update dependencies
install_dependencies() {
    log "Checking and installing dependencies..."
    
    # Update package list
    apt-get update -qq
    
    # Required packages
    local packages=(
        "iproute2"           # For tc (traffic control)
        "vnstat"             # For network statistics
        "iptables-persistent" # For iptables rules
        "curl"               # For downloading files
        "wget"               # Alternative downloader
        "bc"                 # For calculations
        "cron"               # For scheduled tasks
        "jq"                 # For JSON parsing
        "git"                # For version control
    )
    
    local installed_count=0
    local updated_count=0
    
    for package in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii  $package "; then
            log "$package is already installed"
            ((installed_count++))
        else
            log "Installing $package..."
            if apt-get install -y "$package" > /dev/null 2>&1; then
                log "✓ $package installed successfully"
                ((updated_count++))
            else
                error "Failed to install $package"
            fi
        fi
    done
    
    # Start and enable services
    log "Configuring services..."
    
    # Enable and start vnstat
    if systemctl enable vnstat > /dev/null 2>&1; then
        log "✓ vnstat service enabled"
    fi
    
    if systemctl start vnstat > /dev/null 2>&1; then
        log "✓ vnstat service started"
    fi
    
    # Enable and start cron
    if systemctl enable cron > /dev/null 2>&1; then
        log "✓ cron service enabled"
    fi
    
    if systemctl start cron > /dev/null 2>&1; then
        log "✓ cron service started"
    fi
    
    echo -e "${GREEN}"
    echo "==========================================="
    echo "     Dependency Installation Complete"
    echo "==========================================="
    echo -e "${NC}"
    echo "Already installed: $installed_count packages"
    echo "Newly installed: $updated_count packages"
    echo ""
}

# Backup current configuration
backup_config() {
    local backup_dir="$SCRIPT_DIR/backup/$(date +%Y%m%d_%H%M%S)"
    
    log "Creating configuration backup..."
    mkdir -p "$backup_dir"
    
    # Backup configuration files
    if [[ -f "$SCRIPT_DIR/manual_config.conf" ]]; then
        cp "$SCRIPT_DIR/manual_config.conf" "$backup_dir/"
        log "✓ Manual configuration backed up"
    fi
    
    if [[ -f "$SCRIPT_DIR/auto_config.conf" ]]; then
        cp "$SCRIPT_DIR/auto_config.conf" "$backup_dir/"
        log "✓ Auto configuration backed up"
    fi
    
    # Backup crontab
    crontab -l > "$backup_dir/crontab.bak" 2>/dev/null || true
    
    echo "$backup_dir"
}

# Restore configuration
restore_config() {
    local backup_dir=$1
    
    if [[ -d "$backup_dir" ]]; then
        log "Restoring configuration from backup..."
        
        if [[ -f "$backup_dir/manual_config.conf" ]]; then
            cp "$backup_dir/manual_config.conf" "$SCRIPT_DIR/"
            log "✓ Manual configuration restored"
        fi
        
        if [[ -f "$backup_dir/auto_config.conf" ]]; then
            cp "$backup_dir/auto_config.conf" "$SCRIPT_DIR/"
            log "✓ Auto configuration restored"
        fi
    fi
}

# Download file with retry
download_file() {
    local url=$1
    local output=$2
    local max_retries=3
    local retry=0
    
    while [[ $retry -lt $max_retries ]]; do
        if curl -s -f "$url" -o "$output"; then
            return 0
        else
            ((retry++))
            warn "Download failed, retry $retry/$max_retries"
            sleep 2
        fi
    done
    
    return 1
}

# Update from GitHub
update_from_github() {
    echo -e "${CYAN}"
    echo "==========================================="
    echo "       Updating from GitHub"
    echo "==========================================="
    echo -e "${NC}"
    
    # Check internet connectivity
    if ! check_internet; then
        return 1
    fi
    
    # Get version information
    local current_version=$(get_current_version)
    local latest_version=$(get_latest_version)
    
    log "Current version: $current_version"
    log "Latest version: $latest_version"
    
    if [[ "$latest_version" == "unknown" ]]; then
        warn "Cannot determine latest version. Proceeding with update anyway..."
    elif [[ "$current_version" == "$latest_version" ]]; then
        log "Already running the latest version"
        echo -e "${YELLOW}Force update anyway?${NC} [y/N]: "
        read -r force_update
        if [[ ! "$force_update" =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    # Create backup
    local backup_dir
    backup_dir=$(backup_config)
    
    # Download updated files
    log "Downloading updated files..."
    
    local files=(
        "install.sh"
        "core/menu.sh"
        "core/limit_manual.sh"
        "core/limit_auto.sh"
        "core/uninstall.sh"
        "core/update.sh"
        "utils/detect_os.sh"
        "utils/network_utils.sh"
        "version.txt"
    )
    
    local success_count=0
    local total_files=${#files[@]}
    
    for file in "${files[@]}"; do
        local url="$RAW_BASE/$file"
        local output="$SCRIPT_DIR/$file"
        
        # Create directory if needed
        mkdir -p "$(dirname "$output")"
        
        log "Downloading $file..."
        if download_file "$url" "$output"; then
            chmod +x "$output"
            log "✓ $file updated"
            ((success_count++))
        else
            error "Failed to download $file"
        fi
    done
    
    # Restore configuration
    restore_config "$backup_dir"
    
    # Update version
    if [[ "$latest_version" != "unknown" ]]; then
        save_version "$latest_version"
    fi
    
    echo -e "${GREEN}"
    echo "==========================================="
    echo "         Update Complete"
    echo "==========================================="
    echo -e "${NC}"
    echo "Successfully updated: $success_count/$total_files files"
    
    if [[ $success_count -eq $total_files ]]; then
        echo -e "${GREEN}✓ All files updated successfully${NC}"
        log "Update completed successfully"
    else
        echo -e "${YELLOW}⚠ Some files failed to update${NC}"
        warn "Partial update completed"
    fi
    
    echo "Configuration backup saved to: $backup_dir"
    echo ""
}

# Check for updates
check_for_updates() {
    echo -e "${CYAN}Checking for updates...${NC}"
    
    if ! check_internet; then
        return 1
    fi
    
    local current_version=$(get_current_version)
    local latest_version=$(get_latest_version)
    
    echo "Current version: $current_version"
    echo "Latest version: $latest_version"
    
    if [[ "$latest_version" == "unknown" ]]; then
        warn "Cannot determine latest version"
        return 1
    elif [[ "$current_version" != "$latest_version" ]]; then
        echo -e "${YELLOW}A new version is available!${NC}"
        echo -e "${BLUE}Would you like to update now?${NC} [Y/n]: "
        read -r update_choice
        
        if [[ ! "$update_choice" =~ ^[Nn]$ ]]; then
            update_from_github
        fi
    else
        echo -e "${GREEN}✓ You are running the latest version${NC}"
    fi
}

# Repair installation
repair_installation() {
    echo -e "${YELLOW}Repairing installation...${NC}"
    
    # Reinstall dependencies
    install_dependencies
    
    # Re-download all files
    update_from_github
    
    # Fix permissions
    find "$SCRIPT_DIR" -name "*.sh" -exec chmod +x {} \;
    
    # Recreate main executable
    local bin_path="/usr/bin/speedlimiter"
    cat > "$bin_path" << 'EOF'
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
    
    chmod +x "$bin_path"
    
    echo -e "${GREEN}✓ Installation repaired${NC}"
}

# Show update menu
show_update_menu() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    Update & Maintenance                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    echo -e "${BLUE}1.${NC} Install/Update Dependencies"
    echo -e "${BLUE}2.${NC} Check for Updates"
    echo -e "${BLUE}3.${NC} Force Update from GitHub"
    echo -e "${BLUE}4.${NC} Repair Installation"
    echo -e "${BLUE}5.${NC} Show Version Information"
    echo -e "${BLUE}6.${NC} Back to Main Menu"
    echo ""
    echo -e "${CYAN}Enter your choice [1-6]:${NC} "
    read -r choice
    
    case $choice in
        1)
            install_dependencies
            ;;
        2)
            check_for_updates
            ;;
        3)
            update_from_github
            ;;
        4)
            repair_installation
            ;;
        5)
            show_version_info
            ;;
        6)
            return 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            ;;
    esac
}

# Show version information
show_version_info() {
    echo -e "${CYAN}=== Version Information ===${NC}"
    echo "Current Version: $(get_current_version)"
    echo "Installation Directory: $SCRIPT_DIR"
    echo "GitHub Repository: $GITHUB_REPO"
    echo ""
    
    if [[ -f "$VERSION_FILE" ]]; then
        echo "Version file: $VERSION_FILE"
        echo "Last modified: $(stat -c %y "$VERSION_FILE" 2>/dev/null || echo 'Unknown')"
    fi
    
    echo ""
    echo "Installed components:"
    find "$SCRIPT_DIR" -name "*.sh" -type f | sort | while read -r file; do
        echo "  $(basename "$file")"
    done
    echo ""
}

# Main function for direct calls
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_update_menu
fi