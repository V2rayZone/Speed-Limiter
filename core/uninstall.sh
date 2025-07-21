#!/bin/bash

# V2rayZone Speed Limiter - Uninstall Script
# Author: V2rayZone

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

SCRIPT_DIR="/opt/speed-limiter"
BIN_PATH="/usr/bin/speedlimiter"

# Source network utilities if available
if [[ -f "$SCRIPT_DIR/utils/network_utils.sh" ]]; then
    source "$SCRIPT_DIR/utils/network_utils.sh"
fi

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

# Display uninstall banner
show_uninstall_banner() {
    echo -e "${RED}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    V2rayZone Speed Limiter                  ║"
    echo "║                      Uninstall Script                       ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Show what will be removed
show_removal_items() {
    echo -e "${YELLOW}The following items will be removed:${NC}"
    echo ""
    
    echo -e "${BLUE}Files and Directories:${NC}"
    if [[ -d "$SCRIPT_DIR" ]]; then
        echo "  ✓ $SCRIPT_DIR (main installation directory)"
    fi
    
    if [[ -f "$BIN_PATH" ]]; then
        echo "  ✓ $BIN_PATH (main executable)"
    fi
    
    echo ""
    echo -e "${BLUE}Configurations:${NC}"
    if [[ -f "$SCRIPT_DIR/manual_config.conf" ]]; then
        echo "  ✓ Manual speed limit configuration"
    fi
    
    if [[ -f "$SCRIPT_DIR/auto_config.conf" ]]; then
        echo "  ✓ Auto speed limit configuration"
    fi
    
    echo ""
    echo -e "${BLUE}Network Settings:${NC}"
    echo "  ✓ All traffic control rules (tc qdisc)"
    echo "  ✓ Speed limiting iptables rules"
    
    echo ""
    echo -e "${BLUE}Scheduled Tasks:${NC}"
    if crontab -l 2>/dev/null | grep -q "speed-limiter\|auto_update\|monitor_data_cap"; then
        echo "  ✓ Cron jobs for auto updates and monitoring"
    else
        echo "  - No cron jobs found"
    fi
    
    echo ""
}

# Get current network status
show_current_status() {
    echo -e "${CYAN}Current Network Status:${NC}"
    
    # Try to get primary interface
    local interface
    if command -v get_primary_interface >/dev/null 2>&1; then
        interface=$(get_primary_interface)
    else
        interface=$(ip route | grep '^default' | awk '{print $5}' | head -1)
    fi
    
    if [[ -n "$interface" ]]; then
        echo "Primary Interface: $interface"
        
        # Check for active traffic control
        if tc qdisc show dev "$interface" 2>/dev/null | grep -q "htb\|tbf\|ingress"; then
            echo -e "${YELLOW}⚠ Speed limiting is currently ACTIVE${NC}"
            tc qdisc show dev "$interface" | head -3
        else
            echo -e "${GREEN}✓ No speed limiting active${NC}"
        fi
    else
        echo "Could not determine primary interface"
    fi
    
    echo ""
}

# Remove traffic control rules
remove_traffic_control() {
    log "Removing traffic control rules..."
    
    # Get all network interfaces
    local interfaces
    interfaces=$(ip link show | grep -E '^[0-9]+:' | grep -v 'lo:' | awk -F': ' '{print $2}')
    
    for interface in $interfaces; do
        log "Cleaning interface: $interface"
        
        # Remove all qdisc rules
        tc qdisc del dev "$interface" root 2>/dev/null || true
        tc qdisc del dev "$interface" ingress 2>/dev/null || true
        
        log "✓ Traffic control rules removed from $interface"
    done
    
    # Remove any iptables rules related to speed limiting
    log "Removing iptables rules..."
    iptables -t mangle -F 2>/dev/null || true
    
    log "✓ All traffic control rules removed"
}

# Remove cron jobs
remove_cron_jobs() {
    log "Removing cron jobs..."
    
    # Get current crontab
    local current_crontab
    current_crontab=$(crontab -l 2>/dev/null || echo "")
    
    if [[ -n "$current_crontab" ]]; then
        # Remove speed-limiter related cron jobs
        local new_crontab
        new_crontab=$(echo "$current_crontab" | grep -v "speed-limiter\|auto_update\|monitor_data_cap" || true)
        
        if [[ "$current_crontab" != "$new_crontab" ]]; then
            echo "$new_crontab" | crontab -
            log "✓ Speed limiter cron jobs removed"
        else
            log "No speed limiter cron jobs found"
        fi
    else
        log "No crontab found"
    fi
}

# Create backup before removal
create_backup() {
    local backup_dir="/tmp/speed-limiter-backup-$(date +%Y%m%d_%H%M%S)"
    
    log "Creating backup at $backup_dir..."
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
    
    # Backup current traffic control rules
    ip link show | grep -E '^[0-9]+:' | grep -v 'lo:' | awk -F': ' '{print $2}' | while read -r interface; do
        tc qdisc show dev "$interface" > "$backup_dir/tc_${interface}.bak" 2>/dev/null || true
    done
    
    echo "$backup_dir"
}

# Remove files and directories
remove_files() {
    log "Removing files and directories..."
    
    # Remove main executable
    if [[ -f "$BIN_PATH" ]]; then
        rm -f "$BIN_PATH"
        log "✓ Main executable removed: $BIN_PATH"
    fi
    
    # Remove installation directory
    if [[ -d "$SCRIPT_DIR" ]]; then
        rm -rf "$SCRIPT_DIR"
        log "✓ Installation directory removed: $SCRIPT_DIR"
    fi
    
    log "✓ All files removed"
}

# Optional: Remove dependencies
remove_dependencies() {
    echo -e "${YELLOW}Do you want to remove installed dependencies?${NC}"
    echo "This will remove packages that were installed for the speed limiter."
    echo "WARNING: These packages might be used by other applications!"
    echo ""
    echo "Packages to remove: iproute2, vnstat, bc, jq"
    echo ""
    echo -e "${RED}Remove dependencies?${NC} [y/N]: "
    read -r remove_deps
    
    if [[ "$remove_deps" =~ ^[Yy]$ ]]; then
        log "Removing dependencies..."
        
        local packages=("vnstat" "bc" "jq")
        
        for package in "${packages[@]}"; do
            if dpkg -l | grep -q "^ii  $package "; then
                log "Removing $package..."
                apt-get remove -y "$package" > /dev/null 2>&1 || warn "Failed to remove $package"
            fi
        done
        
        # Clean up
        apt-get autoremove -y > /dev/null 2>&1 || true
        
        log "✓ Dependencies removed"
    else
        log "Dependencies kept (recommended)"
    fi
}

# Verify removal
verify_removal() {
    log "Verifying removal..."
    
    local issues=0
    
    # Check if files still exist
    if [[ -f "$BIN_PATH" ]]; then
        error "Main executable still exists: $BIN_PATH"
        ((issues++))
    fi
    
    if [[ -d "$SCRIPT_DIR" ]]; then
        error "Installation directory still exists: $SCRIPT_DIR"
        ((issues++))
    fi
    
    # Check for remaining cron jobs
    if crontab -l 2>/dev/null | grep -q "speed-limiter\|auto_update\|monitor_data_cap"; then
        error "Some cron jobs still exist"
        ((issues++))
    fi
    
    # Check for active traffic control
    local interfaces
    interfaces=$(ip link show | grep -E '^[0-9]+:' | grep -v 'lo:' | awk -F': ' '{print $2}')
    
    for interface in $interfaces; do
        if tc qdisc show dev "$interface" 2>/dev/null | grep -q "htb\|tbf\|ingress"; then
            warn "Traffic control rules still active on $interface"
            ((issues++))
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        log "✓ Removal verification successful"
        return 0
    else
        error "$issues issues found during verification"
        return 1
    fi
}

# Main uninstall function
uninstall_speed_limiter() {
    show_uninstall_banner
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root. Use: sudo speedlimiter"
        return 1
    fi
    
    # Show current status
    show_current_status
    
    # Show what will be removed
    show_removal_items
    
    # Confirmation
    echo -e "${RED}⚠ WARNING: This will completely remove V2rayZone Speed Limiter!${NC}"
    echo -e "${YELLOW}All configurations and speed limits will be lost.${NC}"
    echo ""
    echo -e "${CYAN}Are you sure you want to continue?${NC} [y/N]: "
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Uninstallation cancelled."
        return 0
    fi
    
    echo ""
    log "Starting uninstallation process..."
    
    # Create backup
    local backup_dir
    backup_dir=$(create_backup)
    
    # Remove components
    remove_traffic_control
    remove_cron_jobs
    remove_files
    
    # Optional dependency removal
    remove_dependencies
    
    # Verify removal
    if verify_removal; then
        echo -e "${GREEN}"
        echo "==========================================="
        echo "      Uninstallation Complete!"
        echo "==========================================="
        echo -e "${NC}"
        echo "V2rayZone Speed Limiter has been completely removed."
        echo ""
        echo "Backup created at: $backup_dir"
        echo "You can restore configurations from this backup if needed."
        echo ""
        echo "Thank you for using V2rayZone Speed Limiter!"
    else
        echo -e "${YELLOW}"
        echo "==========================================="
        echo "    Uninstallation Completed with Issues"
        echo "==========================================="
        echo -e "${NC}"
        echo "Some components may not have been removed completely."
        echo "Please check the error messages above."
        echo ""
        echo "Backup created at: $backup_dir"
    fi
    
    echo ""
    echo "To reinstall, run:"
    echo "bash <(curl -Ls https://raw.githubusercontent.com/V2RayZone/speed-limiter/main/install.sh)"
    echo ""
}

# Show uninstall options
show_uninstall_options() {
    show_uninstall_banner
    
    echo -e "${YELLOW}Uninstall Options:${NC}"
    echo -e "${BLUE}1.${NC} Complete Uninstall (Remove everything)"
    echo -e "${BLUE}2.${NC} Remove Speed Limits Only (Keep installation)"
    echo -e "${BLUE}3.${NC} Reset to Default (Remove configs, keep installation)"
    echo -e "${BLUE}4.${NC} Back to Main Menu"
    echo ""
    echo -e "${CYAN}Enter your choice [1-4]:${NC} "
    read -r choice
    
    case $choice in
        1)
            uninstall_speed_limiter
            ;;
        2)
            remove_speed_limits_only
            ;;
        3)
            reset_to_default
            ;;
        4)
            return 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            ;;
    esac
}

# Remove speed limits only
remove_speed_limits_only() {
    log "Removing speed limits only..."
    
    remove_traffic_control
    remove_cron_jobs
    
    echo -e "${GREEN}✓ Speed limits removed. Installation kept intact.${NC}"
}

# Reset to default
reset_to_default() {
    log "Resetting to default configuration..."
    
    # Create backup
    local backup_dir
    backup_dir=$(create_backup)
    
    # Remove speed limits
    remove_traffic_control
    remove_cron_jobs
    
    # Remove configuration files
    rm -f "$SCRIPT_DIR/manual_config.conf"
    rm -f "$SCRIPT_DIR/auto_config.conf"
    rm -f "$SCRIPT_DIR/"*.log
    
    echo -e "${GREEN}✓ Reset to default. Backup created at: $backup_dir${NC}"
}

# Main function for direct calls
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_uninstall_options
fi