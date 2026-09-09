#!/usr/bin/env bash
# ==============================================================================
#  CachyOS Toolbox - Rollback / Uninstaller Script
# ==============================================================================
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}ERROR: Please do NOT run this script with sudo directly.${NC}"
    echo "Run as your normal user: ./uninstall.sh"
    exit 1
fi

echo -e "${CYAN}==========================================================${NC}"
echo -e "       ⚡ CachyOS Toolbox - Rollback / Uninstaller         "
echo -e "${CYAN}==========================================================${NC}"

# 1. Reset lockscreen
echo -e "\n${CYAN}[1/3] Reverting lock screen settings to KDE default...${NC}"
if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image ""
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key PreviewImage ""
    if command -v qdbus6 >/dev/null 2>&1; then
        qdbus6 org.kde.screensaver /ScreenSaver org.kde.screensaver.configure 2>/dev/null || true
    fi
    echo -e "${GREEN}✓ Lock screen restored to default.${NC}"
fi

# 2. Reset desktop live wallpaper to default static image
echo -e "\n${CYAN}[2/3] Reverting desktop to default wallpaper plugin...${NC}"
if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    for (let d of desktops()) {
        d.wallpaperPlugin = 'org.kde.image';
    }
    " 2>/dev/null || true
    echo -e "${GREEN}✓ Desktop returned to standard static wallpaper mode.${NC}"
fi

# 3. Clean files (optional prompt)
echo -e "\n${CYAN}[3/3] Cleaning up deployed wallpaper assets...${NC}"
if [ ! -t 0 ] && [ -e /dev/tty ]; then
    exec < /dev/tty
fi

read -p "Remove wallpaper files from ~/.local/share and /usr/share? [y/N]: " -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    rm -rf "$HOME/.local/share/wallpapers/GhostRider"
    if [ -d "/usr/share/wallpapers/GhostRider" ]; then
        sudo rm -rf "/usr/share/wallpapers/GhostRider" 2>/dev/null || true
    fi
    if [ -f "/etc/plasmalogin.conf" ] && command -v sudo >/dev/null 2>&1; then
        sudo kwriteconfig6 --file /etc/plasmalogin.conf --group Greeter --delete 2>/dev/null || true
    fi
    echo -e "${GREEN}✓ Deployed media files removed.${NC}"
else
    echo "Skipped file deletion."
fi

echo -e "\n${GREEN}✓ Uninstallation / Rollback completed successfully.${NC}"
