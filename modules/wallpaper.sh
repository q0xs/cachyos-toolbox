#!/usr/bin/env bash
# ==============================================================================
#  Module: Ghost Rider 4K HDR Live Wallpaper & Lock Screen
# ==============================================================================
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$MODULE_DIR/.." && pwd)"
ASSETS_DIR="$ROOT_DIR/assets"
TARGET_DIR="$HOME/.local/share/wallpapers/GhostRider"

VIDEO_NAME="ghost_rider_clean_loop_06x.mp4"
LOCKSCREEN_NAME="lockscreen_ghost_rider.png"
VIDEO_PATH="$TARGET_DIR/$VIDEO_NAME"
LOCKSCREEN_PATH="$TARGET_DIR/$LOCKSCREEN_NAME"

echo -e "\n${CYAN}[1/3] Checking wallpaper dependencies...${NC}"
MISSING_PKGS=()

if [ ! -d "/usr/share/plasma/wallpapers/com.github.catsout.wallpaperEngineKde" ] && \
   [ ! -d "$HOME/.local/share/plasma/wallpapers/com.github.catsout.wallpaperEngineKde" ]; then
    MISSING_PKGS+=("plasma6-wallpapers-wallpaper-engine-git")
fi

if ! command -v mpv >/dev/null 2>&1; then
    MISSING_PKGS+=("mpv")
fi

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo -e "${YELLOW}Installing missing packages: ${MISSING_PKGS[*]}...${NC}"
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm "${MISSING_PKGS[@]}" || {
            echo -e "${YELLOW}Warning: Could not install automatically. Run manually: sudo pacman -S --needed ${MISSING_PKGS[*]}${NC}"
        }
    fi
else
    echo -e "${GREEN}✓ Wallpaper dependencies are satisfied.${NC}"
fi

# Copy assets
echo -e "${CYAN}[2/3] Deploying 4K media files to $TARGET_DIR...${NC}"
mkdir -p "$TARGET_DIR"
cp -f "$ASSETS_DIR/$VIDEO_NAME" "$TARGET_DIR/"
cp -f "$ASSETS_DIR/$LOCKSCREEN_NAME" "$TARGET_DIR/"
echo -e "${GREEN}✓ 4K video and lockscreen image deployed.${NC}"

# Apply to Desktop
echo -e "${CYAN}[3/3] Applying desktop & lockscreen wallpaper...${NC}"
if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    for (let d of desktops()) {
        d.wallpaperPlugin = 'com.github.catsout.wallpaperEngineKde';
        d.currentConfigGroup = ['Wallpaper', 'com.github.catsout.wallpaperEngineKde', 'General'];
        d.writeConfig('WallpaperSource', '$VIDEO_PATH+video');
        d.writeConfig('VideoBackend', 1);
        d.writeConfig('MuteAudio', true);
        d.writeConfig('Fps', 60);
    }
    " 2>/dev/null || true
fi

# Update desktop-appletsrc for reboot persistence
APPLETRC="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
if [ -f "$APPLETRC" ] && command -v python3 >/dev/null 2>&1; then
    python3 -c "
import re
path = '$APPLETRC'
try:
    with open(path, 'r') as f:
        text = f.read()

    def update_block(match):
        block = match.group(0)
        if 'formfactor=2' in block or 'plugin=org.kde.panel' in block:
            return block
        return re.sub(r'wallpaperplugin=[^\n]+', 'wallpaperplugin=com.github.catsout.wallpaperEngineKde', block)

    text = re.sub(r'\[Containments\]\[\d+\][^\[]*', update_block, text)
    source_pat = r'(\[Containments\]\[\d+\]\[Wallpaper\]\[com\.github\.catsout\.wallpaperEngineKde\]\[General\][^\[]*?WallpaperSource=)[^\n]+'
    text = re.sub(source_pat, r'\g<1>$VIDEO_PATH+video', text)

    with open(path, 'w') as f:
        f.write(text)
except Exception:
    pass
" 2>/dev/null || true
fi

# Apply Lockscreen
if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file kscreenlockerrc --group Greeter --key wallpaperPlugin "org.kde.image"
    kwriteconfig6 --file kscreenlockerrc --group Greeter --key wallpaperPluginId "org.kde.image"
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file://$LOCKSCREEN_PATH"
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key PreviewImage "file://$LOCKSCREEN_PATH"
    if command -v qdbus6 >/dev/null 2>&1; then
        qdbus6 org.kde.screensaver /ScreenSaver org.kde.screensaver.configure 2>/dev/null || true
    fi
fi

echo -e "${GREEN}✓ 4K 60fps MP4 live desktop wallpaper and lockscreen applied successfully!${NC}"
