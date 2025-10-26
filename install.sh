#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
INSTALL_DIR="/opt/chromium-latest"
DESKTOP_FILE="/usr/share/applications/chromium-latest.desktop"
ICON_PATH="/usr/share/icons/hicolor/scalable/apps/chromium-latest.svg"

echo "=== Chromium Latest Installer ==="

echo "Updating/installing Chromium..."
LASTCHANGE_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2FLAST_CHANGE?alt=media"
REVISION=$(curl -s -S "$LASTCHANGE_URL")
echo "Latest revision is $REVISION"

TMP_DIR=$(mktemp -d)
ZIP_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F$REVISION%2Fchrome-linux.zip?alt=media"
ZIP_FILE="$TMP_DIR/chrome-linux.zip"

echo "Fetching Chromium build..."
curl -# -L -o "$ZIP_FILE" "$ZIP_URL"

echo "Unzipping..."
unzip -q "$ZIP_FILE" -d "$TMP_DIR"

echo "Installing to $INSTALL_DIR..."
sudo rm -rf "$INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"
sudo cp -r "$TMP_DIR/chrome-linux/." "$INSTALL_DIR/"

echo "Creating wrapper script /usr/bin/chromium..."
sudo tee /usr/bin/chromium > /dev/null <<'EOL'
#!/bin/bash
FLAGS=""
if [[ -f /etc/lsb-release ]]; then
    DISTRO=$(grep DISTRIB_ID /etc/lsb-release | cut -d= -f2)
    case "$DISTRO" in
        Ubuntu|LinuxMint|Pop|elementary)
            FLAGS="--no-sandbox"
            ;;
    esac
fi
exec /opt/chromium-latest/chrome $FLAGS "$@"
EOL
sudo chmod +x /usr/bin/chromium

echo "Downloading icon..."
sudo mkdir -p "$(dirname "$ICON_PATH")"
sudo curl -fsSL -o "$ICON_PATH" "https://upload.wikimedia.org/wikipedia/commons/2/28/Chromium_Logo.svg"

echo "Creating .desktop entry..."
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

echo "Installing chromiumup command..."
sudo tee /usr/local/bin/chromiumup > /dev/null <<'EOL'
#!/bin/bash
set -e
echo "Chromium Updater - Fetching latest build..."
TMP=$(mktemp)
curl -fsSL -o "$TMP" "https://raw.githubusercontent.com/Mealman1551/chromium-latest-Enhanced/refs/heads/master/install.sh"
chmod +x "$TMP"
bash "$TMP"
rm -f "$TMP"
EOL
sudo chmod +x /usr/local/bin/chromiumup

echo
echo "Installation completed!"
echo "You can now run Chromium from the menu or type: chromium"
echo "To update anytime, run: chromiumup"
