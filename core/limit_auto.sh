#!/bin/bash

# V2rayZone Speed Limiter - Auto Speed Limit
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

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
AUTO_CONFIG_FILE="$SCRIPT_DIR/auto_config.conf"

# Source network utilities
source "$SCRIPT_DIR/utils/network_utils.sh"

# Display auto limit banner
show_auto_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                     Auto Speed Limiter                       ║"
    echo "║           Calculate Speed Based on Bandwidth + Date          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Get total bandwidth from user
get_bandwidth_input() {
    while true; do
        echo -e "${BLUE}Enter total bandwidth allocation in GB${NC} (e.g., 1000): "
        read -r bandwidth_input
        
        if validate_speed "$bandwidth_input"; then
            echo "$bandwidth_input"
            return 0
        else
            echo -e "${RED}Invalid bandwidth. Please enter a positive number.${NC}"
        fi
    done
}

# Get expiry date from user
get_expiry_date_input() {
    while true; do
        echo -e "${BLUE}Enter expiry date${NC} (YYYY-MM-DD format, e.g., 2025-08-01): "
        read -r date_input
        
        # Validate date format
        if date -d "$date_input" >/dev/null 2>&1; then
            local current_date=$(date +%Y-%m-%d)
            local days_remaining=$(days_between_dates "$current_date" "$date_input")
            
            if [[ $days_remaining -gt 0 ]]; then
                echo "$date_input"
                return 0
            else
                echo -e "${RED}Expiry date must be in the future.${NC}"
            fi
        else
            echo -e "${RED}Invalid date format. Please use YYYY-MM-DD format.${NC}"
        fi
    done
}

# Calculate optimal speed
calculate_auto_speed() {
    local total_bandwidth_gb=$1
    local expiry_date=$2
    local interface=$3
    
    local current_date=$(date +%Y-%m-%d)
    local days_remaining=$(days_between_dates "$current_date" "$expiry_date")
    
    # Get current usage
    local current_usage_bytes=$(get_monthly_usage "$interface")
    local current_usage_gb=$(bytes_to_gb "$current_usage_bytes")
    
    # Calculate remaining bandwidth
    local remaining_bandwidth=$(echo "$total_bandwidth_gb - $current_usage_gb" | bc)
    
    # Ensure remaining bandwidth is positive
    if (( $(echo "$remaining_bandwidth <= 0" | bc -l) )); then
        echo "0"  # No bandwidth remaining
        return 1
    fi
    
    # Calculate daily allowance in GB
    local daily_allowance=$(echo "scale=2; $remaining_bandwidth / $days_remaining" | bc)
    
    # Convert to Mbps (assuming 24 hours usage)
    # Formula: (GB per day * 1024 MB/GB * 8 bits/MB) / (24 hours * 3600 seconds/hour)
    local speed_mbps=$(echo "scale=2; ($daily_allowance * 1024 * 8) / (24 * 3600)" | bc)
    
    # Round down to ensure we don't exceed the limit
    local speed_mbps_rounded=$(echo "$speed_mbps / 1" | bc)
    
    echo "$speed_mbps_rounded"
    return 0
}

# Show calculation details
show_calculation_details() {
    local total_bandwidth_gb=$1
    local expiry_date=$2
    local interface=$3
    local calculated_speed=$4
    
    local current_date=$(date +%Y-%m-%d)
    local days_remaining=$(days_between_dates "$current_date" "$expiry_date")
    local current_usage_bytes=$(get_monthly_usage "$interface")
    local current_usage_gb=$(bytes_to_gb "$current_usage_bytes")
    local remaining_bandwidth=$(echo "$total_bandwidth_gb - $current_usage_gb" | bc)
    local daily_allowance=$(echo "scale=2; $remaining_bandwidth / $days_remaining" | bc)
    
    echo -e "${PURPLE}=== Auto Speed Calculation Details ===${NC}"
    echo "Current Date: $current_date"
    echo "Expiry Date: $expiry_date"
    echo "Days Remaining: $days_remaining days"
    echo ""
    echo "Total Bandwidth: $total_bandwidth_gb GB"
    echo "Used Bandwidth: $current_usage_gb GB"
    echo "Remaining Bandwidth: $remaining_bandwidth GB"
    echo ""
    echo "Daily Allowance: $daily_allowance GB/day"
    echo "Calculated Speed: $calculated_speed Mbps"
    echo ""
}

# Save auto configuration
save_auto_config() {
    local interface=$1
    local total_bandwidth=$2
    local expiry_date=$3
    local calculated_speed=$4
    
    cat > "$AUTO_CONFIG_FILE" << EOF
# V2rayZone Speed Limiter - Auto Configuration
# Generated on: $(date)

INTERFACE="$interface"
TOTAL_BANDWIDTH="$total_bandwidth"
EXPIRY_DATE="$expiry_date"
CALCULATED_SPEED="$calculated_speed"
CREATED_DATE="$(date +%Y-%m-%d)"
LAST_UPDATED="$(date +%Y-%m-%d)"
MODE="auto"
EOF
    
    echo -e "${GREEN}✓ Auto configuration saved to $AUTO_CONFIG_FILE${NC}"
}

# Load auto configuration
load_auto_config() {
    if [[ -f "$AUTO_CONFIG_FILE" ]]; then
        source "$AUTO_CONFIG_FILE"
        return 0
    else
        return 1
    fi
}

# Show current auto configuration
show_current_auto_config() {
    if load_auto_config; then
        echo -e "${YELLOW}Current Auto Configuration:${NC}"
        echo "Interface: $INTERFACE"
        echo "Total Bandwidth: $TOTAL_BANDWIDTH GB"
        echo "Expiry Date: $EXPIRY_DATE"
        echo "Last Calculated Speed: $CALCULATED_SPEED Mbps"
        echo "Created: $CREATED_DATE"
        echo "Last Updated: $LAST_UPDATED"
        echo ""
        
        # Show time remaining
        local current_date=$(date +%Y-%m-%d)
        local days_remaining=$(days_between_dates "$current_date" "$EXPIRY_DATE")
        
        if [[ $days_remaining -gt 0 ]]; then
            echo -e "${GREEN}Days Remaining: $days_remaining days${NC}"
        else
            echo -e "${RED}⚠ Configuration has expired!${NC}"
        fi
        echo ""
        return 0
    else
        echo -e "${YELLOW}No existing auto configuration found.${NC}"
        echo ""
        return 1
    fi
}

# Update auto speed calculation
update_auto_calculation() {
    if load_auto_config; then
        local new_speed
        new_speed=$(calculate_auto_speed "$TOTAL_BANDWIDTH" "$EXPIRY_DATE" "$INTERFACE")
        
        if [[ $? -eq 0 && "$new_speed" != "0" ]]; then
            # Update configuration with new speed
            sed -i "s/CALCULATED_SPEED=.*/CALCULATED_SPEED=\"$new_speed\"/" "$AUTO_CONFIG_FILE"
            sed -i "s/LAST_UPDATED=.*/LAST_UPDATED=\"$(date +%Y-%m-%d)\"/" "$AUTO_CONFIG_FILE"
            
            echo -e "${GREEN}✓ Speed recalculated: $new_speed Mbps${NC}"
            return 0
        else
            echo -e "${RED}✗ Cannot calculate speed (bandwidth exhausted or expired)${NC}"
            return 1
        fi
    else
        echo -e "${RED}No auto configuration found${NC}"
        return 1
    fi
}

# Setup auto update cron job
setup_auto_update_cron() {
    # Create auto update script
    cat > "$SCRIPT_DIR/auto_update.sh" << 'EOF'
#!/bin/bash
# Auto speed update script

SCRIPT_DIR="/opt/speed-limiter"
AUTO_CONFIG_FILE="$SCRIPT_DIR/auto_config.conf"

if [[ -f "$AUTO_CONFIG_FILE" ]]; then
    source "$AUTO_CONFIG_FILE"
    source "$SCRIPT_DIR/utils/network_utils.sh"
    source "$SCRIPT_DIR/core/limit_auto.sh"
    
    # Check if configuration is still valid
    current_date=$(date +%Y-%m-%d)
    days_remaining=$(days_between_dates "$current_date" "$EXPIRY_DATE")
    
    if [[ $days_remaining -gt 0 ]]; then
        # Recalculate and apply new speed
        new_speed=$(calculate_auto_speed "$TOTAL_BANDWIDTH" "$EXPIRY_DATE" "$INTERFACE")
        
        if [[ $? -eq 0 && "$new_speed" != "0" ]]; then
            # Apply new speed limit
            apply_speed_limit "$INTERFACE" "$new_speed" "$new_speed"
            
            # Update configuration
            sed -i "s/CALCULATED_SPEED=.*/CALCULATED_SPEED=\"$new_speed\"/" "$AUTO_CONFIG_FILE"
            sed -i "s/LAST_UPDATED=.*/LAST_UPDATED=\"$(date +%Y-%m-%d)\"/" "$AUTO_CONFIG_FILE"
            
            # Log the update
            echo "$(date): Auto speed updated to $new_speed Mbps" >> "$SCRIPT_DIR/auto_update.log"
        else
            # Remove limits if bandwidth exhausted
            tc qdisc del dev "$INTERFACE" root 2>/dev/null || true
            tc qdisc del dev "$INTERFACE" ingress 2>/dev/null || true
            
            echo "$(date): Bandwidth exhausted. Speed limits removed." >> "$SCRIPT_DIR/auto_update.log"
        fi
    else
        # Configuration expired, remove limits
        tc qdisc del dev "$INTERFACE" root 2>/dev/null || true
        tc qdisc del dev "$INTERFACE" ingress 2>/dev/null || true
        
        echo "$(date): Configuration expired. Speed limits removed." >> "$SCRIPT_DIR/auto_update.log"
    fi
fi
EOF
    
    chmod +x "$SCRIPT_DIR/auto_update.sh"
    
    # Add to crontab (update daily at 2 AM)
    (crontab -l 2>/dev/null | grep -v "auto_update"; echo "0 2 * * * $SCRIPT_DIR/auto_update.sh") | crontab -
    
    echo -e "${GREEN}✓ Auto update scheduled (daily at 2 AM)${NC}"
}

# Apply auto speed limits
apply_auto_limits() {
    local interface=$1
    local speed=$2
    
    echo "Applying auto speed limits..."
    echo "Interface: $interface"
    echo "Calculated Speed: ${speed} Mbps"
    echo ""
    
    if apply_speed_limit "$interface" "$speed" "$speed"; then
        echo -e "${GREEN}✓ Auto speed limits applied successfully!${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to apply auto speed limits${NC}"
        return 1
    fi
}

# Main setup function
setup_auto_limit() {
    show_auto_banner
    
    # Show current configuration if exists
    show_current_auto_config
    
    echo -e "${YELLOW}Choose an option:${NC}"
    echo "1. Create new auto speed limit"
    echo "2. Apply existing configuration"
    echo "3. Recalculate and update speed"
    echo "4. Remove auto limits"
    echo "5. Back to main menu"
    echo ""
    echo -e "${CYAN}Enter your choice [1-5]:${NC} "
    read -r choice
    
    case $choice in
        1)
            create_new_auto_limit
            ;;
        2)
            apply_existing_auto_limit
            ;;
        3)
            recalculate_auto_speed
            ;;
        4)
            remove_auto_limits
            ;;
        5)
            return 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            ;;
    esac
}

# Create new auto limit
create_new_auto_limit() {
    echo -e "${GREEN}Creating new auto speed limit...${NC}"
    echo ""
    
    # Get interface
    local interface
    interface=$(get_interface_input)
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Get total bandwidth
    local total_bandwidth
    total_bandwidth=$(get_bandwidth_input)
    
    # Get expiry date
    local expiry_date
    expiry_date=$(get_expiry_date_input)
    
    # Calculate optimal speed
    echo "Calculating optimal speed..."
    local calculated_speed
    calculated_speed=$(calculate_auto_speed "$total_bandwidth" "$expiry_date" "$interface")
    
    if [[ $? -ne 0 || "$calculated_speed" == "0" ]]; then
        echo -e "${RED}Cannot calculate speed. Bandwidth may be exhausted or invalid parameters.${NC}"
        return 1
    fi
    
    # Show calculation details
    show_calculation_details "$total_bandwidth" "$expiry_date" "$interface" "$calculated_speed"
    
    # Confirm settings
    echo -e "${YELLOW}Apply these auto settings?${NC} [Y/n]: "
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Nn]$ ]]; then
        # Save configuration
        save_auto_config "$interface" "$total_bandwidth" "$expiry_date" "$calculated_speed"
        
        # Apply limits
        if apply_auto_limits "$interface" "$calculated_speed"; then
            # Setup auto update
            setup_auto_update_cron
            echo -e "${GREEN}✓ Auto speed limit configured successfully!${NC}"
        fi
    else
        echo "Configuration cancelled."
    fi
}

# Apply existing auto limit
apply_existing_auto_limit() {
    if load_auto_config; then
        echo "Applying existing auto configuration..."
        
        # Check if configuration is still valid
        local current_date=$(date +%Y-%m-%d)
        local days_remaining=$(days_between_dates "$current_date" "$EXPIRY_DATE")
        
        if [[ $days_remaining -le 0 ]]; then
            echo -e "${RED}Configuration has expired. Please create a new one.${NC}"
            return 1
        fi
        
        if apply_auto_limits "$INTERFACE" "$CALCULATED_SPEED"; then
            setup_auto_update_cron
        fi
    else
        echo -e "${RED}No existing auto configuration found. Please create a new one.${NC}"
    fi
}

# Recalculate auto speed
recalculate_auto_speed() {
    if load_auto_config; then
        echo "Recalculating auto speed..."
        
        local new_speed
        new_speed=$(calculate_auto_speed "$TOTAL_BANDWIDTH" "$EXPIRY_DATE" "$INTERFACE")
        
        if [[ $? -eq 0 && "$new_speed" != "0" ]]; then
            show_calculation_details "$TOTAL_BANDWIDTH" "$EXPIRY_DATE" "$INTERFACE" "$new_speed"
            
            echo -e "${YELLOW}Apply the new calculated speed?${NC} [Y/n]: "
            read -r confirm
            
            if [[ ! "$confirm" =~ ^[Nn]$ ]]; then
                # Update configuration
                update_auto_calculation
                
                # Apply new limits
                apply_auto_limits "$INTERFACE" "$new_speed"
            fi
        else
            echo -e "${RED}Cannot recalculate speed. Bandwidth may be exhausted.${NC}"
        fi
    else
        echo -e "${RED}No auto configuration found${NC}"
    fi
}

# Remove auto limits
remove_auto_limits() {
    if load_auto_config; then
        echo "Removing auto speed limits for interface: $INTERFACE"
        
        # Remove traffic control rules
        tc qdisc del dev "$INTERFACE" root 2>/dev/null || true
        tc qdisc del dev "$INTERFACE" ingress 2>/dev/null || true
        
        # Remove cron job
        crontab -l 2>/dev/null | grep -v "auto_update" | crontab - 2>/dev/null || true
        
        echo -e "${GREEN}✓ Auto speed limits removed${NC}"
    else
        echo -e "${YELLOW}No auto configuration found${NC}"
    fi
}

# Main execution - only run if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_auto_limit
fi