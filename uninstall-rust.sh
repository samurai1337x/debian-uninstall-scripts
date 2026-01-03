#!/bin/bash

################################################################################
# Uninstall Rust Uninstall Script
# 
# Description:
#   Safely removes Rust programming language and Cargo from Debian/Ubuntu systems.
#   Removes binaries, toolchains, cache, and related data.
#
# Supported Distributions:
#   - Debian: Bullseye (11), Bookworm (12), Trixie (13)
#   - Ubuntu: 20.04 LTS, 22.04 LTS, 24.04 LTS
#
# Usage:
#   sudo bash uninstall-rust.sh
#
# Author: samurai1337x
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
    read -p "Are you sure you want to uninstall Rust? This will remove all Rust binaries and toolchains. (yes/no): " response
    
    if [ "$response" != "yes" ]; then
        log_warn "Uninstallation cancelled"
        exit 0
    fi
}

# Uninstall Rust using rustup
uninstall_rust() {
    log_info "Uninstalling Rust using rustup..."
    
    # Check if rustup exists
    if command -v rustup &> /dev/null; then
        rustup self uninstall -y
        log_success "Rust uninstalled using rustup"
    else
        log_warn "rustup not found, removing directories manually"
    fi
}

# Remove Cargo and Rust directories
remove_rust_directories() {
    log_info "Removing Rust directories..."
    
    local home_dirs=()
    
    # Get all home directories for users who might have Rust installed
    while IFS=: read -r username _ uid gid _ home _; do
        if [ "$uid" -ge 1000 ] 2>/dev/null; then
            home_dirs+=("$home")
        fi
    done < /etc/passwd
    
    # Also add root's home
    home_dirs+=("/root")
    
    # Remove .cargo and .rustup directories
    for home in "${home_dirs[@]}"; do
        if [ -d "$home/.cargo" ]; then
            rm -rf "$home/.cargo"
            log_info "Removed $home/.cargo"
        fi
        
        if [ -d "$home/.rustup" ]; then
            rm -rf "$home/.rustup"
            log_info "Removed $home/.rustup"
        fi
    done
    
    log_success "Rust directories removed"
}

# Remove build tools if not needed
remove_build_tools_prompt() {
    local response
    read -p "Do you want to remove build tools (build-essential, curl, git, libssl-dev, pkg-config)? These may be needed for other tools. (yes/no): " response
    
    if [ "$response" = "yes" ]; then
        log_info "Removing build tools..."
        apt-get remove -y build-essential curl wget git libssl-dev pkg-config || true
        log_success "Build tools removed"
    else
        log_warn "Build tools retained"
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
    log_info "Verifying Rust uninstallation..."
    
    if command -v rustc &> /dev/null; then
        log_error "Rust is still installed"
        return 1
    fi
    
    if command -v cargo &> /dev/null; then
        log_error "Cargo is still installed"
        return 1
    fi
    
    log_success "Uninstallation verified"
}

# Print post-uninstallation instructions
print_instructions() {
    cat << 'EOF'

================================================================================
Rust Uninstallation Complete!
================================================================================

Rust has been successfully removed from your system.

If you want to verify complete removal:
  which rustc                         # Should return nothing
  which cargo                         # Should return nothing
  ls ~/.cargo                         # Should return nothing
  ls ~/.rustup                        # Should return nothing

To reinstall Rust in the future:
  sudo bash install-rust.sh

Important Notes:
- All Rust toolchains have been removed
- Cargo directories have been cleaned up
- Build tools may have been retained if you declined removal
- Your Rust projects will remain intact

For more information, visit: https://www.rust-lang.org/

================================================================================

EOF
}

# Main execution
main() {
    log_info "Starting Rust uninstallation..."
    
    confirmation_prompt
    
    uninstall_rust
    remove_rust_directories
    remove_build_tools_prompt
    clean_package_manager
    verify_uninstallation
    print_instructions
    
    log_success "Rust uninstallation completed successfully!"
}

main
