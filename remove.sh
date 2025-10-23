#!/bin/bash
set -e

INSTALL_DIR="/opt/chromium-latest"
DESKTOP_FILE="/usr/share/applications/chromium-latest.desktop"
SYMLINK="/usr/bin/chromium"

echo "Removing Chromium installation..."

if [ -L "$SYMLINK" ]; then
    sudo rm "$SYMLINK"
    echo "Removed symlink $SYMLINK"
fi

if [ -d "$INSTALL_DIR" ]; then
    sudo rm -rf "$INSTALL_DIR"
    echo "Removed installation directory $INSTALL_DIR"
fi

if [ -f "$DESKTOP_FILE" ]; then
    sudo rm "$DESKTOP_FILE"
    echo "Removed desktop entry $DESKTOP_FILE"
fi

echo "Uninstallation completed."
