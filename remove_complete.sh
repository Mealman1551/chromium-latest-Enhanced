#!/bin/bash
set -e

INSTALL_DIR="/opt/chromium-latest"
DESKTOP_FILE="/usr/share/applications/chromium-latest.desktop"
SYMLINK="/usr/bin/chromium"
CHROMIUMUP="/usr/local/bin/chromiumup"
ICON_PATH="/usr/share/icons/hicolor/scalable/apps/chromium-latest.svg"

echo "Completely removing Chromium installation..."

if [ -L "$SYMLINK" ] || [ -f "$SYMLINK" ]; then
    sudo rm -f "$SYMLINK"
    echo "Removed wrapper $SYMLINK"
fi

if [ -d "$INSTALL_DIR" ]; then
    sudo rm -rf "$INSTALL_DIR"
    echo "Removed installation directory $INSTALL_DIR"
fi

if [ -f "$DESKTOP_FILE" ]; then
    sudo rm -f "$DESKTOP_FILE"
    echo "Removed desktop entry $DESKTOP_FILE"
fi

if [ -f "$CHROMIUMUP" ]; then
    sudo rm -f "$CHROMIUMUP"
    echo "Removed chromiumup command $CHROMIUMUP"
fi

if [ -f "$ICON_PATH" ]; then
    sudo rm -f "$ICON_PATH"
    echo "Removed icon $ICON_PATH"
fi

echo "Complete uninstallation done. Geen bestanden van Chromium blijven achter."
