#!/bin/bash

# V2RayZone Speed Limiter - OS Detection Utilities
# Author: V2RayZone

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables for OS information
OS_NAME=""
OS_VERSION=""
OS_ID=""
OS_CODENAME=""
OS_ARCH=""
KERNEL_VERSION=""

# Detect operating system
detect_os() {
    # Get architecture
    OS_ARCH=$(uname -m)
    
    # Get kernel version
    KERNEL_VERSION=$(uname -r)
    
    # Detect OS using /etc/os-release
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS_NAME="$NAME"
        OS_VERSION="$VERSION_ID"
        OS_ID="$ID"
        OS_CODENAME="$VERSION_CODENAME"
    elif [[ -f /etc/lsb-release ]]; then
        source /etc/lsb-release
        OS_NAME="$DISTRIB_ID"
        OS_VERSION="$DISTRIB_RELEASE"
        OS_CODENAME="$DISTRIB_CODENAME"
        OS_ID=$(echo "$OS_NAME" | tr '[:upper:]' '[:lower:]')
    else
        # Fallback detection
        if [[ -f /etc/debian_version ]]; then
            OS_NAME="Debian"
            OS_VERSION=$(cat /etc/debian_version)
            OS_ID="debian"
        elif [[ -f /etc/redhat-release ]]; then
            OS_NAME="Red Hat"
            OS_VERSION=$(cat /etc/redhat-release | grep -o '[0-9]\+\.[0-9]\+')
            OS_ID="rhel"
        else
            OS_NAME="Unknown"
            OS_VERSION="Unknown"
            OS_ID="unknown"
        fi
    fi
}

# Check if OS is supported
is_supported_os() {
    case "$OS_ID" in
        ubuntu|debian)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Check Ubuntu version compatibility
check_ubuntu_version() {
    if [[ "$OS_ID" == "ubuntu" ]]; then
        local version_major=$(echo "$OS_VERSION" | cut -d. -f1)
        
        # Support Ubuntu 18.04 and newer
        if [[ $version_major -ge 18 ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

# Check Debian version compatibility
check_debian_version() {
    if [[ "$OS_ID" == "debian" ]]; then
        local version_major=$(echo "$OS_VERSION" | cut -d. -f1)
        
        # Support Debian 9 and newer
        if [[ $version_major -ge 9 ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

# Get package manager
get_package_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "apt"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Check if systemd is available
has_systemd() {
    if command -v systemctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
        return 0
    else
        return 1
    fi
}

# Check if running in container
is_container() {
    if [[ -f /.dockerenv ]] || [[ -f /run/.containerenv ]]; then
        return 0
    elif grep -q "container" /proc/1/cgroup 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Check if running as root
is_root() {
    if [[ $EUID -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# Check available memory
get_memory_info() {
    local total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local available_mem=$(grep MemAvailable /proc/meminfo | awk '{print $2}' 2>/dev/null || grep MemFree /proc/meminfo | awk '{print $2}')
    
    # Convert from KB to MB
    total_mem=$((total_mem / 1024))
    available_mem=$((available_mem / 1024))
    
    echo "$total_mem $available_mem"
}

# Check disk space
get_disk_space() {
    local root_space=$(df / | tail -1 | awk '{print $4}')
    # Convert from KB to MB
    root_space=$((root_space / 1024))
    echo "$root_space"
}

# Display OS information
show_os_info() {
    detect_os
    
    echo -e "${BLUE}=== System Information ===${NC}"
    echo "OS Name: $OS_NAME"
    echo "OS Version: $OS_VERSION"
    echo "OS ID: $OS_ID"
    if [[ -n "$OS_CODENAME" ]]; then
        echo "Codename: $OS_CODENAME"
    fi
    echo "Architecture: $OS_ARCH"
    echo "Kernel: $KERNEL_VERSION"
    
    echo ""
    echo -e "${BLUE}=== System Status ===${NC}"
    
    if is_root; then
        echo -e "${GREEN}✓ Running as root${NC}"
    else
        echo -e "${RED}✗ Not running as root${NC}"
    fi
    
    if has_systemd; then
        echo -e "${GREEN}✓ Systemd available${NC}"
    else
        echo -e "${YELLOW}⚠ Systemd not available${NC}"
    fi
    
    if is_container; then
        echo -e "${YELLOW}⚠ Running in container${NC}"
    else
        echo -e "${GREEN}✓ Running on bare metal/VM${NC}"
    fi
    
    local package_manager=$(get_package_manager)
    echo "Package Manager: $package_manager"
    
    # Memory and disk info
    local mem_info=($(get_memory_info))
    echo "Total Memory: ${mem_info[0]} MB"
    echo "Available Memory: ${mem_info[1]} MB"
    
    local disk_space=$(get_disk_space)
    echo "Available Disk Space: $disk_space MB"
    
    echo ""
    echo -e "${BLUE}=== Compatibility Check ===${NC}"
    
    if is_supported_os; then
        echo -e "${GREEN}✓ OS is supported${NC}"
        
        if check_ubuntu_version || check_debian_version; then
            echo -e "${GREEN}✓ OS version is compatible${NC}"
        else
            echo -e "${YELLOW}⚠ OS version may have limited support${NC}"
        fi
    else
        echo -e "${RED}✗ OS is not officially supported${NC}"
        echo "This script is designed for Ubuntu/Debian systems."
    fi
}

# Check system requirements
check_requirements() {
    local errors=0
    local warnings=0
    
    detect_os
    
    echo -e "${BLUE}Checking system requirements...${NC}"
    
    # Check OS support
    if ! is_supported_os; then
        echo -e "${RED}✗ Unsupported OS: $OS_NAME${NC}"
        ((errors++))
    else
        echo -e "${GREEN}✓ Supported OS: $OS_NAME${NC}"
    fi
    
    # Check root privileges
    if ! is_root; then
        echo -e "${RED}✗ Root privileges required${NC}"
        ((errors++))
    else
        echo -e "${GREEN}✓ Running as root${NC}"
    fi
    
    # Check package manager
    local pkg_mgr=$(get_package_manager)
    if [[ "$pkg_mgr" == "apt" ]]; then
        echo -e "${GREEN}✓ APT package manager available${NC}"
    else
        echo -e "${RED}✗ APT package manager not found${NC}"
        ((errors++))
    fi
    
    # Check memory
    local mem_info=($(get_memory_info))
    if [[ ${mem_info[0]} -lt 512 ]]; then
        echo -e "${YELLOW}⚠ Low memory: ${mem_info[0]} MB (recommended: 512+ MB)${NC}"
        ((warnings++))
    else
        echo -e "${GREEN}✓ Sufficient memory: ${mem_info[0]} MB${NC}"
    fi
    
    # Check disk space
    local disk_space=$(get_disk_space)
    if [[ $disk_space -lt 100 ]]; then
        echo -e "${RED}✗ Insufficient disk space: $disk_space MB (required: 100+ MB)${NC}"
        ((errors++))
    else
        echo -e "${GREEN}✓ Sufficient disk space: $disk_space MB${NC}"
    fi
    
    # Check if running in container
    if is_container; then
        echo -e "${YELLOW}⚠ Running in container - some features may be limited${NC}"
        ((warnings++))
    fi
    
    # Check required commands
    local required_commands=("tc" "ip" "iptables")
    for cmd in "${required_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Command available: $cmd${NC}"
        else
            echo -e "${YELLOW}⚠ Command not found: $cmd (will be installed)${NC}"
            ((warnings++))
        fi
    done
    
    echo ""
    
    if [[ $errors -eq 0 ]]; then
        if [[ $warnings -eq 0 ]]; then
            echo -e "${GREEN}✓ All requirements met!${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠ Requirements met with $warnings warnings${NC}"
            return 0
        fi
    else
        echo -e "${RED}✗ $errors critical requirements not met${NC}"
        return 1
    fi
}

# Get system recommendations
get_recommendations() {
    detect_os
    
    echo -e "${BLUE}=== System Recommendations ===${NC}"
    
    # Memory recommendations
    local mem_info=($(get_memory_info))
    if [[ ${mem_info[0]} -lt 1024 ]]; then
        echo -e "${YELLOW}• Consider upgrading to at least 1GB RAM for better performance${NC}"
    fi
    
    # Container recommendations
    if is_container; then
        echo -e "${YELLOW}• Running in container detected:${NC}"
        echo "  - Ensure the container has CAP_NET_ADMIN capability"
        echo "  - Traffic control may require privileged mode"
        echo "  - Some network features may be limited"
    fi
    
    # OS version recommendations
    if [[ "$OS_ID" == "ubuntu" ]]; then
        local version_major=$(echo "$OS_VERSION" | cut -d. -f1)
        if [[ $version_major -lt 20 ]]; then
            echo -e "${YELLOW}• Consider upgrading to Ubuntu 20.04 LTS or newer${NC}"
        fi
    fi
    
    echo ""
}

# Main function for direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-info}" in
        "info")
            show_os_info
            ;;
        "check")
            check_requirements
            ;;
        "recommend")
            get_recommendations
            ;;
        *)
            echo "Usage: $0 [info|check|recommend]"
            echo "  info      - Show system information"
            echo "  check     - Check system requirements"
            echo "  recommend - Show recommendations"
            ;;
    esac
fi