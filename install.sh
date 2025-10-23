#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
INSTALL_DIR="/opt/chromium-latest"
DESKTOP_FILE="/usr/share/applications/chromium-latest.desktop"
ICON_PATH="/usr/share/icons/hicolor/scalable/apps/chromium-latest.svg"

echo "Updating Chromium..."
LASTCHANGE_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2FLAST_CHANGE?alt=media"
REVISION=$(curl -s -S $LASTCHANGE_URL)
echo "Latest revision is $REVISION"

# Maak tijdelijke map
TMP_DIR=$(mktemp -d)

# Download Chromium zip
ZIP_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F$REVISION%2Fchrome-linux.zip?alt=media"
ZIP_FILE="$TMP_DIR/chrome-linux.zip"
echo "Fetching $ZIP_URL"
curl -# -o "$ZIP_FILE" "$ZIP_URL"

# Unzip
echo "Unzipping..."
unzip -q "$ZIP_FILE" -d "$TMP_DIR"

# Update symlink
rm -f "$SCRIPT_DIR/latest"
ln -s "$TMP_DIR/chrome-linux" "$SCRIPT_DIR/latest"

# Installeren
echo "Installing to $INSTALL_DIR..."
sudo rm -rf "$INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"
sudo cp -r "$SCRIPT_DIR/latest/." "$INSTALL_DIR/"

# SUID sandbox instellen en testen
echo "Setting up SUID sandbox..."
SUID_OK=false
if [ -f "$INSTALL_DIR/chrome-sandbox" ]; then
    sudo chown root:root "$INSTALL_DIR/chrome-sandbox"
    sudo chmod 4755 "$INSTALL_DIR/chrome-sandbox"
    # Test sandbox (veilig, zonder GUI)
    if "$INSTALL_DIR/chrome" --no-startup-window --no-sandbox-test &>/dev/null; then
        SUID_OK=true
    fi
fi

# Kies juiste exec command voor .desktop file
if [ "$SUID_OK" = true ]; then
    EXEC_CMD="$INSTALL_DIR/chrome %U"
    echo "SUID sandbox is ready."
else
    EXEC_CMD="$INSTALL_DIR/chrome --no-sandbox %U"
    echo "SUID sandbox not usable; Chromium will run with --no-sandbox in the menu."
fi

# Symlink naar /usr/bin (alleen executable, geen flags)
echo "Creating symlink /usr/bin/chromium..."
sudo ln -sf "$INSTALL_DIR/chrome" /usr/bin/chromium

# Download SVG icon
echo "Downloading SVG icon..."
sudo curl -L -o "$ICON_PATH" "https://upload.wikimedia.org/wikipedia/commons/2/28/Chromium_Logo.svg"

# .desktop bestand maken
echo "Creating .desktop file..."
sudo tee "$DESKTOP_FILE" > /dev/null <<EOL
[Desktop Entry]
Version=1.0
Name=Chromium Latest
Comment=The latest Chromium Browser
Exec=$EXEC_CMD
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOL

# Opruimen tijdelijke map
rm -rf "$TMP_DIR"

echo "Installation completed."
echo "Chromium can now be launched from the menu or by running: chromium"
