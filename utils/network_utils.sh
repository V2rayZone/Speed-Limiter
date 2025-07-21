#!/bin/bash

# V2rayZone Speed Limiter - Network Utilities
# Author: V2rayZone

# Get primary network interface
get_primary_interface() {
    # Try to get the interface with default route
    local interface=$(ip route | grep '^default' | awk '{print $5}' | head -1)
    
    # If no default route, try common interface names
    if [[ -z "$interface" ]]; then
        for iface in eth0 ens3 ens18 venet0 vps0; do
            if ip link show "$iface" >/dev/null 2>&1; then
                interface="$iface"
                break
            fi
        done
    fi
    
    # If still no interface found, get the first non-loopback interface
    if [[ -z "$interface" ]]; then
        interface=$(ip link show | grep -E '^[0-9]+:' | grep -v 'lo:' | head -1 | awk -F': ' '{print $2}')
    fi
    
    echo "$interface"
}

# Validate interface exists
validate_interface() {
    local interface=$1
    
    if [[ -z "$interface" ]]; then
        return 1
    fi
    
    if ip link show "$interface" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Get interface speed in Mbps (if available)
get_interface_speed() {
    local interface=$1
    local speed_file="/sys/class/net/$interface/speed"
    
    if [[ -f "$speed_file" ]]; then
        cat "$speed_file" 2>/dev/null || echo "unknown"
    else
        echo "unknown"
    fi
}

# Convert bytes to human readable format
bytes_to_human() {
    local bytes=$1
    local units=("B" "KB" "MB" "GB" "TB")
    local unit=0
    
    while (( bytes > 1024 && unit < ${#units[@]} - 1 )); do
        bytes=$((bytes / 1024))
        ((unit++))
    done
    
    echo "$bytes ${units[$unit]}"
}

# Get current bandwidth usage
get_current_usage() {
    local interface=$1
    local rx_bytes=$(cat "/sys/class/net/$interface/statistics/rx_bytes" 2>/dev/null || echo "0")
    local tx_bytes=$(cat "/sys/class/net/$interface/statistics/tx_bytes" 2>/dev/null || echo "0")
    
    echo "RX: $(bytes_to_human $rx_bytes), TX: $(bytes_to_human $tx_bytes)"
}

# Check if tc (traffic control) is available
check_tc_available() {
    if command -v tc >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Apply speed limit using tc
apply_speed_limit() {
    local interface=$1
    local download_limit=$2  # in Mbps
    local upload_limit=$3    # in Mbps (optional, defaults to download_limit)
    
    if [[ -z "$upload_limit" ]]; then
        upload_limit="$download_limit"
    fi
    
    # Remove existing rules
    tc qdisc del dev "$interface" root 2>/dev/null || true
    tc qdisc del dev "$interface" ingress 2>/dev/null || true
    
    # Apply download limit (ingress)
    tc qdisc add dev "$interface" handle ffff: ingress
    tc filter add dev "$interface" parent ffff: protocol ip prio 50 u32 match ip src 0.0.0.0/0 police rate "${download_limit}mbit" burst 10k drop flowid :1
    
    # Apply upload limit (egress)
    tc qdisc add dev "$interface" root handle 1: htb default 30
    tc class add dev "$interface" parent 1: classid 1:1 htb rate "${upload_limit}mbit"
    tc class add dev "$interface" parent 1:1 classid 1:10 htb rate "${upload_limit}mbit" ceil "${upload_limit}mbit"
    tc qdisc add dev "$interface" parent 1:10 handle 10: sfq perturb 10
    tc filter add dev "$interface" parent 1:0 protocol ip prio 1 u32 match ip dst 0.0.0.0/0 flowid 1:10
    
    return $?
}

# Check if speed limit is active
is_speed_limit_active() {
    local interface=$1
    
    if tc qdisc show dev "$interface" | grep -q "htb\|tbf\|ingress"; then
        return 0
    else
        return 1
    fi
}

# Get current speed limit
get_current_speed_limit() {
    local interface=$1
    
    # Try to extract rate from tc output
    local limit=$(tc qdisc show dev "$interface" | grep -o '[0-9]*Mbit' | head -1)
    
    if [[ -n "$limit" ]]; then
        echo "$limit"
    else
        echo "No limit set"
    fi
}

# Validate speed input
validate_speed() {
    local speed=$1
    
    # Check if it's a positive number
    if [[ "$speed" =~ ^[0-9]+([.][0-9]+)?$ ]] && (( $(echo "$speed > 0" | bc -l) )); then
        return 0
    else
        return 1
    fi
}

# Calculate days between two dates
days_between_dates() {
    local date1=$1  # YYYY-MM-DD format
    local date2=$2  # YYYY-MM-DD format
    
    local timestamp1=$(date -d "$date1" +%s)
    local timestamp2=$(date -d "$date2" +%s)
    
    local diff=$((timestamp2 - timestamp1))
    local days=$((diff / 86400))
    
    echo "$days"
}

# Convert GB to bytes
gb_to_bytes() {
    local gb=$1
    echo "$(echo "$gb * 1024 * 1024 * 1024" | bc)"
}

# Convert bytes to GB
bytes_to_gb() {
    local bytes=$1
    echo "$(echo "scale=2; $bytes / 1024 / 1024 / 1024" | bc)"
}

# Get monthly usage from vnstat
get_monthly_usage() {
    local interface=$1
    
    if command -v vnstat >/dev/null 2>&1; then
        # Get current month usage in bytes
        local usage=$(vnstat -i "$interface" --json | jq -r '.interfaces[0].traffic.month[0].rx + .interfaces[0].traffic.month[0].tx' 2>/dev/null)
        
        if [[ "$usage" != "null" && -n "$usage" ]]; then
            echo "$usage"
        else
            # Fallback to parsing text output
            vnstat -i "$interface" -m | grep "$(date +%Y-%m)" | awk '{print $2}' | sed 's/GiB//' | head -1
        fi
    else
        echo "0"
    fi
}

# List all available interfaces
list_interfaces() {
    ip link show | grep -E '^[0-9]+:' | grep -v 'lo:' | awk -F': ' '{print $2}' | sort
}

# Test network connectivity
test_connectivity() {
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}