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

# SUID sandbox instellen
echo "Setting up SUID sandbox..."
SUID_OK=false
if [ -f "$INSTALL_DIR/chrome-sandbox" ]; then
    sudo chown root:root "$INSTALL_DIR/chrome-sandbox"
    sudo chmod 4755 "$INSTALL_DIR/chrome-sandbox"
    if "$INSTALL_DIR/chrome" --no-startup-window &>/dev/null; then
        SUID_OK=true
    fi
fi

if [ "$SUID_OK" = true ]; then
    echo "SUID sandbox is ready. Chromium will run safely."
else
    echo "SUID sandbox not usable; Chromium will run with --no-sandbox."
fi

# Wrapper-script maken voor /usr/bin/chromium
echo "Creating wrapper script at /usr/bin/chromium..."
sudo tee /usr/bin/chromium > /dev/null <<EOF
#!/bin/bash
CHROMIUM_DIR="$INSTALL_DIR"
SANDBOX="\$CHROMIUM_DIR/chrome-sandbox"

if [ -f "\$SANDBOX" ] && [ -u "\$SANDBOX" ]; then
    exec "\$CHROMIUM_DIR/chrome" "\$@"
else
    exec "\$CHROMIUM_DIR/chrome" --no-sandbox "\$@"
fi
EOF
sudo chmod +x /usr/bin/chromium

# SVG icon downloaden
echo "Downloading SVG icon..."
sudo curl -L -o "$ICON_PATH" "https://upload.wikimedia.org/wikipedia/commons/2/28/Chromium_Logo.svg"

# .desktop bestand
echo "Creating .desktop file..."
sudo tee "$DESKTOP_FILE" > /dev/null <<EOL
[Desktop Entry]
Version=1.0
Name=Chromium Latest
Comment=The latest Chromium Browser
Exec=/usr/bin/chromium %U
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOL

rm -rf "$TMP_DIR"

echo "Installation completed."
echo "Chromium can now be launched from the menu or by running: chromium"
