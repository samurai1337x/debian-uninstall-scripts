#!/usr/bin/env bash

echo "Stopping cloudflared if running..."
sudo systemctl stop cloudflared 2>/dev/null || true
sudo systemctl disable cloudflared 2>/dev/null || true

# ---------------------------------------------------------
# Remove cloudflared package
# ---------------------------------------------------------
echo "Removing cloudflared package..."
sudo apt remove -y cloudflared 2>/dev/null || true
sudo apt autoremove -y --purge

# ---------------------------------------------------------
# Remove Cloudflare repo files
# ---------------------------------------------------------
echo "Removing Cloudflare repository files..."
sudo rm -f /etc/apt/sources.list.d/cloudflared.sources
sudo rm -f /etc/apt/sources.list.d/cloudflared.list

# ---------------------------------------------------------
# Remove Cloudflare keyrings
# ---------------------------------------------------------
echo "Removing Cloudflare keyrings..."
sudo rm -f /etc/apt/keyrings/cloudflare-main.asc
sudo rm -f /usr/share/keyrings/cloudflare-main.gpg

# ---------------------------------------------------------
# Update apt index
# ---------------------------------------------------------
sudo apt update

echo "Cloudflared has been fully uninstalled."
