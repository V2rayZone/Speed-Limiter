#!/bin/bash

# V2rayZone Speed Limiter - Manual Speed Limit
# Author: V2rayZone

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
CONFIG_FILE="$SCRIPT_DIR/manual_config.conf"

# Source network utilities
source "$SCRIPT_DIR/utils/network_utils.sh"

# Display manual limit banner
show_manual_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    Manual Speed Limiter                     ║"
    echo "║              Set Custom Speed + Optional Data Cap            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Get interface from user
get_interface_input() {
    local default_interface=$(get_primary_interface)
    
    echo -e "${YELLOW}Available network interfaces:${NC}"
    list_interfaces | nl -w2 -s'. '
    echo ""
    
    echo -e "${BLUE}Enter network interface${NC} [default: $default_interface]: "
    read -r interface_input
    
    if [[ -z "$interface_input" ]]; then
        interface_input="$default_interface"
    fi
    
    if ! validate_interface "$interface_input"; then
        echo -e "${RED}Error: Interface '$interface_input' not found!${NC}"
        return 1
    fi
    
    echo "$interface_input"
}

# Get speed limit from user
get_speed_input() {
    local limit_type=$1  # "download" or "upload"
    
    while true; do
        echo -e "${BLUE}Enter $limit_type speed limit in Mbps${NC} (e.g., 100): "
        read -r speed_input
        
        if validate_speed "$speed_input"; then
            echo "$speed_input"
            return 0
        else
            echo -e "${RED}Invalid speed. Please enter a positive number.${NC}"
        fi
    done
}

# Get data cap from user
get_data_cap_input() {
    echo -e "${YELLOW}Do you want to set a monthly data cap?${NC} [y/N]: "
    read -r cap_choice
    
    if [[ "$cap_choice" =~ ^[Yy]$ ]]; then
        while true; do
            echo -e "${BLUE}Enter monthly data cap in GB${NC} (e.g., 500): "
            read -r cap_input
            
            if validate_speed "$cap_input"; then
                echo "$cap_input"
                return 0
            else
                echo -e "${RED}Invalid data cap. Please enter a positive number.${NC}"
            fi
        done
    else
        echo "0"  # No cap
    fi
}

# Save configuration
save_manual_config() {
    local interface=$1
    local download_speed=$2
    local upload_speed=$3
    local data_cap=$4
    
    cat > "$CONFIG_FILE" << EOF
# V2rayZone Speed Limiter - Manual Configuration
# Generated on: $(date)

INTERFACE="$interface"
DOWNLOAD_SPEED="$download_speed"
UPLOAD_SPEED="$upload_speed"
DATA_CAP="$data_cap"
CREATED_DATE="$(date +%Y-%m-%d)"
MODE="manual"
EOF
    
    echo -e "${GREEN}✓ Configuration saved to $CONFIG_FILE${NC}"
}

# Load existing configuration
load_manual_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        return 0
    else
        return 1
    fi
}

# Show current configuration
show_current_config() {
    if load_manual_config; then
        echo -e "${YELLOW}Current Manual Configuration:${NC}"
        echo "Interface: $INTERFACE"
        echo "Download Speed: ${DOWNLOAD_SPEED} Mbps"
        echo "Upload Speed: ${UPLOAD_SPEED} Mbps"
        if [[ "$DATA_CAP" != "0" ]]; then
            echo "Data Cap: ${DATA_CAP} GB/month"
        else
            echo "Data Cap: No limit"
        fi
        echo "Created: $CREATED_DATE"
        echo ""
        return 0
    else
        echo -e "${YELLOW}No existing manual configuration found.${NC}"
        echo ""
        return 1
    fi
}

# Check data cap usage
check_data_cap() {
    local interface=$1
    local data_cap=$2
    
    if [[ "$data_cap" == "0" ]]; then
        return 0  # No cap set
    fi
    
    local current_usage=$(get_monthly_usage "$interface")
    local cap_bytes=$(gb_to_bytes "$data_cap")
    
    if [[ "$current_usage" -gt "$cap_bytes" ]]; then
        echo -e "${RED}⚠ WARNING: Monthly data cap exceeded!${NC}"
        echo "Used: $(bytes_to_gb "$current_usage") GB"
        echo "Cap: $data_cap GB"
        echo ""
        return 1
    else
        local remaining=$(echo "$data_cap - $(bytes_to_gb "$current_usage")" | bc)
        echo -e "${GREEN}Data usage within limits${NC}"
        echo "Used: $(bytes_to_gb "$current_usage") GB"
        echo "Remaining: $remaining GB"
        echo ""
        return 0
    fi
}

# Setup cron job for data cap monitoring
setup_data_cap_monitoring() {
    local data_cap=$1
    
    if [[ "$data_cap" != "0" ]]; then
        # Create monitoring script
        cat > "$SCRIPT_DIR/monitor_data_cap.sh" << 'EOF'
#!/bin/bash
# Data cap monitoring script

SCRIPT_DIR="/opt/speed-limiter"
CONFIG_FILE="$SCRIPT_DIR/manual_config.conf"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
    source "$SCRIPT_DIR/utils/network_utils.sh"
    
    if [[ "$DATA_CAP" != "0" ]]; then
        current_usage=$(get_monthly_usage "$INTERFACE")
        cap_bytes=$(gb_to_bytes "$DATA_CAP")
        
        if [[ "$current_usage" -gt "$cap_bytes" ]]; then
            # Remove speed limits when cap is exceeded
            tc qdisc del dev "$INTERFACE" root 2>/dev/null || true
            tc qdisc del dev "$INTERFACE" ingress 2>/dev/null || true
            
            # Log the event
            echo "$(date): Data cap exceeded. Speed limits removed." >> "$SCRIPT_DIR/data_cap.log"
        fi
    fi
fi
EOF
        
        chmod +x "$SCRIPT_DIR/monitor_data_cap.sh"
        
        # Add to crontab (check every hour)
        (crontab -l 2>/dev/null | grep -v "monitor_data_cap"; echo "0 * * * * $SCRIPT_DIR/monitor_data_cap.sh") | crontab -
        
        echo -e "${GREEN}✓ Data cap monitoring enabled (hourly checks)${NC}"
    fi
}

# Apply manual speed limits
apply_manual_limits() {
    local interface=$1
    local download_speed=$2
    local upload_speed=$3
    
    echo "Applying speed limits..."
    echo "Interface: $interface"
    echo "Download: ${download_speed} Mbps"
    echo "Upload: ${upload_speed} Mbps"
    echo ""
    
    if apply_speed_limit "$interface" "$download_speed" "$upload_speed"; then
        echo -e "${GREEN}✓ Speed limits applied successfully!${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to apply speed limits${NC}"
        return 1
    fi
}

# Main setup function
setup_manual_limit() {
    show_manual_banner
    
    # Show current configuration if exists
    show_current_config
    
    echo -e "${YELLOW}Choose an option:${NC}"
    echo "1. Create new manual speed limit"
    echo "2. Apply existing configuration"
    echo "3. Remove current limits"
    echo "4. Back to main menu"
    echo ""
    echo -e "${CYAN}Enter your choice [1-4]:${NC} "
    read -r choice
    
    case $choice in
        1)
            create_new_manual_limit
            ;;
        2)
            apply_existing_manual_limit
            ;;
        3)
            remove_manual_limits
            ;;
        4)
            return 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            ;;
    esac
}

# Create new manual limit
create_new_manual_limit() {
    echo -e "${GREEN}Creating new manual speed limit...${NC}"
    echo ""
    
    # Get interface
    local interface
    interface=$(get_interface_input)
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Get download speed
    local download_speed
    download_speed=$(get_speed_input "download")
    
    # Get upload speed
    echo -e "${YELLOW}Use same speed for upload?${NC} [Y/n]: "
    read -r same_speed
    
    local upload_speed
    if [[ "$same_speed" =~ ^[Nn]$ ]]; then
        upload_speed=$(get_speed_input "upload")
    else
        upload_speed="$download_speed"
    fi
    
    # Get data cap
    local data_cap
    data_cap=$(get_data_cap_input)
    
    # Confirm settings
    echo ""
    echo -e "${CYAN}Configuration Summary:${NC}"
    echo "Interface: $interface"
    echo "Download Speed: ${download_speed} Mbps"
    echo "Upload Speed: ${upload_speed} Mbps"
    if [[ "$data_cap" != "0" ]]; then
        echo "Data Cap: ${data_cap} GB/month"
    else
        echo "Data Cap: No limit"
    fi
    echo ""
    
    echo -e "${YELLOW}Apply these settings?${NC} [Y/n]: "
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Nn]$ ]]; then
        # Save configuration
        save_manual_config "$interface" "$download_speed" "$upload_speed" "$data_cap"
        
        # Apply limits
        if apply_manual_limits "$interface" "$download_speed" "$upload_speed"; then
            # Setup monitoring if data cap is set
            setup_data_cap_monitoring "$data_cap"
            echo -e "${GREEN}✓ Manual speed limit configured successfully!${NC}"
        fi
    else
        echo "Configuration cancelled."
    fi
}

# Apply existing manual limit
apply_existing_manual_limit() {
    if load_manual_config; then
        echo "Applying existing configuration..."
        
        # Check data cap first
        check_data_cap "$INTERFACE" "$DATA_CAP"
        
        if apply_manual_limits "$INTERFACE" "$DOWNLOAD_SPEED" "$UPLOAD_SPEED"; then
            setup_data_cap_monitoring "$DATA_CAP"
        fi
    else
        echo -e "${RED}No existing configuration found. Please create a new one.${NC}"
    fi
}

# Remove manual limits
remove_manual_limits() {
    if load_manual_config; then
        echo "Removing speed limits for interface: $INTERFACE"
        
        # Remove traffic control rules
        tc qdisc del dev "$INTERFACE" root 2>/dev/null || true
        tc qdisc del dev "$INTERFACE" ingress 2>/dev/null || true
        
        # Remove cron job
        crontab -l 2>/dev/null | grep -v "monitor_data_cap" | crontab - 2>/dev/null || true
        
        echo -e "${GREEN}✓ Manual speed limits removed${NC}"
    else
        echo -e "${YELLOW}No manual configuration found${NC}"
    fi
}

# Main execution - only run if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_manual_limit
fi