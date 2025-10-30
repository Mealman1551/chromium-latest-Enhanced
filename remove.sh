#!/bin/bash
set -e

INSTALL_DIR="/opt/chromium-latest"
DESKTOP_FILE="/usr/share/applications/chromium-latest.desktop"
SYMLINK="/usr/bin/chromium"

echo "Safely removing Chromium installation..."

if [ -L "$SYMLINK" ]; then
    sudo rm "$SYMLINK"
    echo "Removed wrapper $SYMLINK"
fi

if [ -d "$INSTALL_DIR" ]; then
    # Verwijder alles behalve crashpad
    sudo find "$INSTALL_DIR" -mindepth 1 -not -name 'crashpad' -exec rm -rf {} +
    echo "Removed Chromium binaries but kept crashpad"
fi

if [ -f "$DESKTOP_FILE" ]; then
    sudo rm "$DESKTOP_FILE"
    echo "Removed desktop entry $DESKTOP_FILE"
fi

echo "Safe removal completed."
