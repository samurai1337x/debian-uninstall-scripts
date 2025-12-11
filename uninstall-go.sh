#!/bin/bash
set -e

GO_INSTALL_DIR="/usr/local/go"

echo "---------------------------------------------------------"
echo "Uninstalling Go (Golang)..."
echo "---------------------------------------------------------"

# Stop any Go-related processes (ignore errors if none)
echo "Stopping any Go-related processes (ignore errors if none)..."
pkill -f /usr/local/go || true

# Remove Go directory
if [ -d "$GO_INSTALL_DIR" ]; then
    sudo rm -rf "$GO_INSTALL_DIR"
    echo "Removed $GO_INSTALL_DIR"
else
    echo "No Go installation found in $GO_INSTALL_DIR"
fi

# Remove Go PATH from ~/.profile
if grep -q "/usr/local/go/bin" ~/.profile; then
    sed -i '/\/usr\/local\/go\/bin/d' ~/.profile
    echo "Removed Go from PATH in ~/.profile"
fi

# Remove system-wide symlinks
if [ -L "/usr/bin/go" ]; then
    sudo rm -f /usr/bin/go
    echo "Removed /usr/bin/go"
fi
if [ -L "/usr/bin/gofmt" ]; then
    sudo rm -f /usr/bin/gofmt
    echo "Removed /usr/bin/gofmt"
fi

echo "---------------------------------------------------------"
echo "Golang has been safely uninstalled."
echo "To update your PATH in the current terminal, run: source ~/.profile"
echo "---------------------------------------------------------"
