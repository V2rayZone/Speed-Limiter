#!/bin/bash

# V2RayZone Speed Limiter - Main Menu
# Author: V2RayZone

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR="/opt/speed-limiter"

# Source utility functions
source "$SCRIPT_DIR/utils/network_utils.sh"

# Display banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    V2RayZone Speed Limiter                  ║"
    echo "║                     Network Traffic Control                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Display current status
show_status() {
    echo -e "${YELLOW}Current Status:${NC}"
    
    # Check if any traffic control is active
    local interface=$(get_primary_interface)
    if tc qdisc show dev "$interface" | grep -q "htb\|tbf"; then
        echo -e "${GREEN}✓ Speed limiting is ACTIVE on $interface${NC}"
        
        # Show current limits
        local current_limit=$(tc qdisc show dev "$interface" | grep -o '[0-9]*Mbit' | head -1)
        if [[ -n "$current_limit" ]]; then
            echo -e "${BLUE}  Current limit: $current_limit${NC}"
        fi
    else
        echo -e "${RED}✗ No speed limiting active${NC}"
    fi
    
    # Show network usage if vnstat is available
    if command -v vnstat >/dev/null 2>&1; then
        echo -e "${YELLOW}Network Usage (Today):${NC}"
        vnstat -i "$interface" --oneline | awk -F';' '{print "  Download: " $9 "  Upload: " $10}'
    fi
    
    echo ""
}

# Main menu
show_menu() {
    echo -e "${PURPLE}Available Options:${NC}"
    echo -e "${BLUE}1.${NC} Install/Update Dependencies"
    echo -e "${BLUE}2.${NC} Update Script from GitHub"
    echo -e "${BLUE}3.${NC} Manual Speed Limit (Set custom Mbps + optional data cap)"
    echo -e "${BLUE}4.${NC} Auto Speed Limit (Based on bandwidth + expiry date)"
    echo -e "${BLUE}5.${NC} Remove Speed Limits"
    echo -e "${BLUE}6.${NC} View Detailed Network Statistics"
    echo -e "${BLUE}7.${NC} Uninstall Speed Limiter"
    echo -e "${BLUE}8.${NC} Exit"
    echo ""
    echo -e "${CYAN}Enter your choice [1-8]:${NC} "
}

# Handle user choice
handle_choice() {
    local choice=$1
    
    case $choice in
        1)
            echo -e "${GREEN}Installing/Updating dependencies...${NC}"
            source "$SCRIPT_DIR/core/update.sh"
            install_dependencies
            ;;
        2)
            echo -e "${GREEN}Updating script from GitHub...${NC}"
            source "$SCRIPT_DIR/core/update.sh"
            update_from_github
            ;;
        3)
            echo -e "${GREEN}Starting Manual Speed Limit setup...${NC}"
            source "$SCRIPT_DIR/core/limit_manual.sh"
            setup_manual_limit
            ;;
        4)
            echo -e "${GREEN}Starting Auto Speed Limit setup...${NC}"
            source "$SCRIPT_DIR/core/limit_auto.sh"
            setup_auto_limit
            ;;
        5)
            echo -e "${GREEN}Removing speed limits...${NC}"
            remove_all_limits
            ;;
        6)
            echo -e "${GREEN}Displaying network statistics...${NC}"
            show_detailed_stats
            ;;
        7)
            echo -e "${YELLOW}Starting uninstallation...${NC}"
            source "$SCRIPT_DIR/core/uninstall.sh"
            uninstall_speed_limiter
            ;;
        8)
            echo -e "${GREEN}Thank you for using V2RayZone Speed Limiter!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please enter a number between 1-8.${NC}"
            ;;
    esac
}

# Remove all speed limits
remove_all_limits() {
    local interface=$(get_primary_interface)
    
    echo "Removing all traffic control rules..."
    
    # Remove all qdisc rules
    tc qdisc del dev "$interface" root 2>/dev/null || true
    tc qdisc del dev "$interface" ingress 2>/dev/null || true
    
    # Remove any iptables rules related to speed limiting
    iptables -t mangle -F 2>/dev/null || true
    
    echo -e "${GREEN}✓ All speed limits removed successfully${NC}"
    
    # Remove cron jobs if any
    crontab -l 2>/dev/null | grep -v "speed-limiter" | crontab - 2>/dev/null || true
    
    echo "Press Enter to continue..."
    read
}

# Show detailed network statistics
show_detailed_stats() {
    local interface=$(get_primary_interface)
    
    echo -e "${CYAN}=== Network Interface Statistics ===${NC}"
    echo "Primary Interface: $interface"
    echo ""
    
    if command -v vnstat >/dev/null 2>&1; then
        echo -e "${YELLOW}Daily Statistics:${NC}"
        vnstat -i "$interface" -d
        echo ""
        
        echo -e "${YELLOW}Monthly Statistics:${NC}"
        vnstat -i "$interface" -m
        echo ""
    fi
    
    echo -e "${YELLOW}Current Traffic Control Rules:${NC}"
    tc qdisc show dev "$interface" || echo "No traffic control rules active"
    echo ""
    
    echo -e "${YELLOW}Interface Information:${NC}"
    ip addr show "$interface" | grep -E "inet |link/"
    echo ""
    
    echo "Press Enter to continue..."
    read
}

# Main loop
main_loop() {
    while true; do
        show_banner
        show_status
        show_menu
        
        read -r choice
        echo ""
        
        handle_choice "$choice"
        
        if [[ $choice != "8" ]]; then
            echo ""
            echo "Press Enter to return to main menu..."
            read
        fi
    done
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root. Use: sudo speedlimiter${NC}"
    exit 1
fi

# Start the main loop
main_loop