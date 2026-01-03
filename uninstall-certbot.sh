#!/bin/bash

################################################################################
# Uninstall Certbot Uninstall Script
# 
# Description:
#   Safely removes Certbot and SSL/TLS certificate management from Debian/Ubuntu systems.
#   Removes packages and related data while preserving certificates if needed.
#
# Supported Distributions:
#   - Debian: Bullseye (11), Bookworm (12), Trixie (13)
#   - Ubuntu: 20.04 LTS, 22.04 LTS, 24.04 LTS
#
# Usage:
#   sudo bash uninstall-certbot.sh
#
# Author: debian-install-scripts
# License: MIT
################################################################################

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_error "This script must be run as root or with sudo"
    exit 1
fi

# Confirmation prompt
confirmation_prompt() {
    local response
    read -p "Are you sure you want to uninstall Certbot? This will remove Certbot and SSL/TLS certificate management tools. (yes/no): " response
    
    if [ "$response" != "yes" ]; then
        log_warn "Uninstallation cancelled"
        exit 0
    fi
}

# Stop Certbot services
stop_certbot_services() {
    log_info "Stopping Certbot services..."
    
    # Stop timer if running
    if systemctl is-enabled certbot.timer &> /dev/null; then
        systemctl stop certbot.timer
        log_info "Stopped certbot.timer"
    fi
    
    # Stop service if running
    if systemctl is-active --quiet certbot 2> /dev/null; then
        systemctl stop certbot || true
        log_info "Stopped certbot service"
    fi
    
    log_success "Certbot services stopped"
}

# Disable Certbot services
disable_certbot_services() {
    log_info "Disabling Certbot services..."
    
    systemctl disable certbot.timer || true
    systemctl disable certbot || true
    systemctl daemon-reload || true
    
    log_success "Certbot services disabled"
}

# Uninstall packages
uninstall_packages() {
    log_info "Uninstalling Certbot packages..."
    apt-get purge -y certbot python3-certbot-nginx || apt-get purge -y certbot || true
    log_success "Certbot packages uninstalled"
}

# Handle certificate preservation
handle_certificates() {
    local response
    read -p "Do you want to preserve Let's Encrypt certificates for future use? (yes/no): " response
    
    if [ "$response" = "no" ]; then
        log_info "Removing SSL/TLS certificates..."
        if [ -d /etc/letsencrypt ]; then
            rm -rf /etc/letsencrypt
            log_success "Certificates removed"
        else
            log_warn "Certificate directory not found"
        fi
    else
        log_warn "Certificates preserved at /etc/letsencrypt"
    fi
}

# Remove Certbot cache
remove_certbot_cache() {
    log_info "Removing Certbot cache..."
    
    if [ -d /var/cache/certbot ]; then
        rm -rf /var/cache/certbot
        log_success "Certbot cache removed"
    fi
    
    if [ -d /var/log/letsencrypt ]; then
        rm -rf /var/log/letsencrypt
        log_success "Certbot logs removed"
    fi
}

# Clean package manager
clean_package_manager() {
    log_info "Cleaning package manager..."
    apt-get autoremove -y
    apt-get autoclean -y
    apt-get update -y
    log_success "Package manager cleaned"
}

# Verify uninstallation
verify_uninstallation() {
    log_info "Verifying Certbot uninstallation..."
    
    if command -v certbot &> /dev/null; then
        log_error "Certbot is still installed"
        return 1
    fi
    
    log_success "Uninstallation verified"
}

# Print post-uninstallation instructions
print_instructions() {
    cat << 'EOF'

================================================================================
Certbot Uninstallation Complete!
================================================================================

Certbot has been successfully removed from your system.

If you want to verify complete removal:
  which certbot                        # Should return nothing
  dpkg -l | grep certbot               # Should return no packages
  systemctl list-unit-files | grep certbot  # Should show nothing

To reinstall Certbot in the future:
  sudo bash install-certbot.sh

Important Notes:
- Certbot has been removed from your system
- SSL/TLS certificates were preserved or removed based on your choice
- If certificates were preserved, they are located at /etc/letsencrypt
- Any active HTTPS services may be affected

If you need to restore certificates without Certbot:
  - Certificates are in /etc/letsencrypt/live/
  - Update your web server configuration manually
  - To reinstall Certbot: sudo bash install-certbot.sh

For more information, visit: https://certbot.eff.org/

================================================================================

EOF
}

# Main execution
main() {
    log_info "Starting Certbot uninstallation..."
    
    confirmation_prompt
    
    stop_certbot_services
    disable_certbot_services
    uninstall_packages
    handle_certificates
    remove_certbot_cache
    clean_package_manager
    verify_uninstallation
    print_instructions
    
    log_success "Certbot uninstallation completed successfully!"
}

main
