#!/bin/bash

################################################################################
# Uninstall Node.js Uninstall Script
# 
# Description:
#   Safely removes Node.js and npm from Debian/Ubuntu systems.
#   Removes packages, repositories, keyrings, and related data.
#
# Supported Distributions:
#   - Debian: Bullseye (11), Bookworm (12), Trixie (13)
#   - Ubuntu: 20.04 LTS, 22.04 LTS, 24.04 LTS
#
# Usage:
#   sudo bash uninstall-nodejs.sh
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
    read -p "Are you sure you want to uninstall Node.js? This will remove all Node.js packages. (yes/no): " response
    
    if [ "$response" != "yes" ]; then
        log_warn "Uninstallation cancelled"
        exit 0
    fi
}

# Stop services (if running)
stop_services() {
    log_info "Stopping Node.js services..."
    # Node.js doesn't have a daemon, but we stop any npm-related processes
    pkill -f npm || true
    log_success "Services stopped"
}

# Uninstall packages
uninstall_packages() {
    log_info "Uninstalling Node.js packages..."
    apt-get purge -y nodejs
    log_success "Packages uninstalled"
}

# Remove repository
remove_nodejs_repository() {
    log_info "Removing Node.js repository..."
    
    if [ -f /etc/apt/sources.list.d/nodesource.list ]; then
        rm -f /etc/apt/sources.list.d/nodesource.list
        log_success "Repository removed"
    else
        log_warn "Node.js repository file not found"
    fi
}

# Remove GPG key
remove_nodejs_gpg_key() {
    log_info "Removing Node.js GPG key..."
    
    if [ -f /etc/apt/keyrings/nodesource.gpg ]; then
        rm -f /etc/apt/keyrings/nodesource.gpg
        log_success "GPG key removed"
    else
        log_warn "Node.js GPG key not found"
    fi
}

# Remove npm cache and user data
remove_npm_data() {
    log_info "Removing npm cache and user data..."
    
    if [ -d "$HOME/.npm" ]; then
        rm -rf "$HOME/.npm"
        log_success "npm cache removed"
    fi
    
    if [ -d "$HOME/.config/npm" ]; then
        rm -rf "$HOME/.config/npm"
        log_success "npm config removed"
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
    log_info "Verifying Node.js uninstallation..."
    
    if command -v node &> /dev/null; then
        log_error "Node.js is still installed"
        return 1
    fi
    
    if command -v npm &> /dev/null; then
        log_error "npm is still installed"
        return 1
    fi
    
    log_success "Uninstallation verified"
}

# Print post-uninstallation instructions
print_instructions() {
    cat << 'EOF'

================================================================================
Node.js Uninstallation Complete!
================================================================================

Node.js and npm have been successfully removed from your system.

If you want to verify complete removal:
  which node                        # Should return nothing
  which npm                         # Should return nothing
  apt list --installed | grep node  # Should return no nodejs packages

To reinstall Node.js in the future:
  sudo bash install-nodejs.sh

For more information, visit: https://nodejs.org/

================================================================================

EOF
}

# Main execution
main() {
    log_info "Starting Node.js uninstallation..."
    
    confirmation_prompt
    
    stop_services
    uninstall_packages
    remove_nodejs_repository
    remove_nodejs_gpg_key
    remove_npm_data
    clean_package_manager
    verify_uninstallation
    print_instructions
    
    log_success "Node.js uninstallation completed successfully!"
}

main
