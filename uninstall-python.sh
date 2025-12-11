#!/usr/bin/env bash

echo "Stopping any Python-related processes (ignore errors if none)..."
pkill -f python3 2>/dev/null || true

# ---------------------------------------------------------
# Remove Python development packages safely
# ---------------------------------------------------------
echo "Removing Python development and optional packages..."
sudo apt remove -y \
    python3-dev \
    python3-full \
    python3-venv \
    python3-virtualenv \
    idle \
    idle-python3.* \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    build-essential 2>/dev/null || true

sudo apt autoremove -y --purge

# ---------------------------------------------------------
# Remove user-installed Python packages
# ---------------------------------------------------------
echo "Removing Python user packages from ~/.local..."
rm -rf ~/.local/lib/python3*
rm -rf ~/.local/bin/pip*
rm -rf ~/.local/bin/virtualenv
rm -rf ~/.local/bin/idle

# ---------------------------------------------------------
# Optional: Remove virtual environments manually
# ---------------------------------------------------------
echo "Note: Existing virtual environments in your home directories are not deleted automatically."
echo "You can remove them manually if desired, e.g.:"
echo "  rm -rf ~/myenv"

# ---------------------------------------------------------
# Clean up
# ---------------------------------------------------------
sudo apt update

echo "Python development environment has been safely uninstalled."
echo "System Python (python3) is still intact for system tools."
