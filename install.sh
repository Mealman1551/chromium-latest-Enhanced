#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
INSTALL_DIR="/opt/chromium-latest"
DESKTOP_FILE="/usr/share/applications/chromium-latest.desktop"

echo "Updating Chromium..."
LASTCHANGE_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2FLAST_CHANGE?alt=media"
REVISION=$(curl -s -S $LASTCHANGE_URL)
echo "Latest revision is $REVISION"

# Maak een tijdelijke map voor het downloaden
TMP_DIR=$(mktemp -d)

ZIP_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F$REVISION%2Fchrome-linux.zip?alt=media"
ZIP_FILE="$TMP_DIR/chrome-linux.zip"

echo "Fetching $ZIP_URL"
curl -# -o "$ZIP_FILE" "$ZIP_URL"

echo "Unzipping..."
unzip -q "$ZIP_FILE" -d "$TMP_DIR"

rm -f "$SCRIPT_DIR/latest"
ln -s "$TMP_DIR/chrome-linux" "$SCRIPT_DIR/latest"

echo "Installing to $INSTALL_DIR..."
sudo rm -rf "$INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"
sudo cp -r "$SCRIPT_DIR/latest/." "$INSTALL_DIR/"

echo "Creating symlink /usr/bin/chromium..."
sudo ln -sf "$INSTALL_DIR/chrome" /usr/bin/chromium

echo "Creating .desktop file..."
sudo tee "$DESKTOP_FILE" > /dev/null <<EOL
[Desktop Entry]
Version=1.0
Name=Chromium Latest
Comment=The latest Chromium Browser
Exec=$INSTALL_DIR/chrome %U
Icon=$INSTALL_DIR/product_logo_48.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOL

# Verwijder tijdelijke map
rm -rf "$TMP_DIR"

echo "Installation completed."
echo "Chromium can now be launched from the menu or by running: chromium"
