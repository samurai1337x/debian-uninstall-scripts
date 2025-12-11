#!/usr/bin/env bash

echo "Stopping Docker service (ignore errors if not installed)..."
sudo systemctl stop docker 2>/dev/null || true
sudo systemctl stop containerd 2>/dev/null || true

# ---------------------------------------------------------
# Remove Docker CE packages
# ---------------------------------------------------------
sudo apt remove -y docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras 2>/dev/null || true

# Remove conflicting Debian packages (docker.io, etc.)
CONFLICT_PKGS=$(dpkg --get-selections \
    docker.io docker-compose docker-doc podman-docker containerd runc 2>/dev/null | cut -f1)

if [ -n "$CONFLICT_PKGS" ]; then
    echo "Removing conflicting packages: $CONFLICT_PKGS"
    sudo apt remove -y $CONFLICT_PKGS
fi

sudo apt autoremove -y --purge

# ---------------------------------------------------------
# Remove Docker data directories
# ---------------------------------------------------------
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# ---------------------------------------------------------
# Remove Docker configuration & repository
# ---------------------------------------------------------
sudo rm -rf /etc/docker
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/sources.list.d/docker.sources
sudo rm -f /etc/apt/keyrings/docker.gpg
sudo rm -f /etc/apt/keyrings/docker.asc

sudo apt update

echo "Docker has been fully uninstalled."
