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

echo -e "\n${CYAN}[1/4] Checking wallpaper dependencies...${NC}"
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
echo -e "${CYAN}[2/4] Deploying 4K media files to $TARGET_DIR...${NC}"
mkdir -p "$TARGET_DIR"
cp -f "$ASSETS_DIR/$VIDEO_NAME" "$TARGET_DIR/"
cp -f "$ASSETS_DIR/$LOCKSCREEN_NAME" "$TARGET_DIR/"
echo -e "${GREEN}✓ 4K video and lockscreen image deployed.${NC}"

# Apply to Desktop
echo -e "${CYAN}[3/4] Applying 4K 60fps live desktop wallpaper...${NC}"
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

# Apply Lockscreen (User Session)
echo -e "${CYAN}[4/4] Applying matching 4K lockscreen & login screen...${NC}"
GLOBAL_DIR="/usr/share/wallpapers/GhostRider"
GLOBAL_IMG="$GLOBAL_DIR/contents/images/3840x2160.png"

# Try deploying system-wide wallpaper package for Plasma Login Manager & SDDM
APPLIED_GLOBAL=false
if command -v sudo >/dev/null 2>&1; then
    echo -e "${CYAN}Deploying system-wide wallpaper package to $GLOBAL_DIR...${NC}"
    if sudo mkdir -p "$GLOBAL_DIR/contents/images" 2>/dev/null; then
        sudo cp -f "$ASSETS_DIR/$LOCKSCREEN_NAME" "$GLOBAL_IMG" 2>/dev/null || true
        sudo cp -f "$ASSETS_DIR/$LOCKSCREEN_NAME" "$GLOBAL_DIR/contents/screenshot.png" 2>/dev/null || true
        sudo tee "$GLOBAL_DIR/metadata.desktop" >/dev/null << 'EOF'
[Desktop Entry]
Name=GhostRider
X-KDE-PluginInfo-Name=Ghost Rider 4K
X-KDE-PluginInfo-Author=q0xs
X-KDE-PluginInfo-License=CC-BY-SA-4.0
EOF
        sudo chmod -R 755 "$GLOBAL_DIR" 2>/dev/null || true
        sudo chmod 644 "$GLOBAL_DIR/metadata.desktop" "$GLOBAL_DIR/contents/screenshot.png" "$GLOBAL_IMG" 2>/dev/null || true
        APPLIED_GLOBAL=true
    fi
fi

# Determine image path to use for lockscreen
if [ "$APPLIED_GLOBAL" = true ] && [ -f "$GLOBAL_IMG" ]; then
    EFFECTIVE_LOCK_IMG="$GLOBAL_IMG"
else
    EFFECTIVE_LOCK_IMG="$LOCKSCREEN_PATH"
fi

# 1. Configure KDE Plasma Screen Locker (kscreenlockerrc)
if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file kscreenlockerrc --group Greeter --key wallpaperPlugin "org.kde.image"
    kwriteconfig6 --file kscreenlockerrc --group Greeter --key wallpaperPluginId "org.kde.image"
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "$EFFECTIVE_LOCK_IMG"
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key PreviewImage "$EFFECTIVE_LOCK_IMG"
    if command -v qdbus6 >/dev/null 2>&1; then
        qdbus6 org.kde.screensaver /ScreenSaver org.kde.screensaver.configure 2>/dev/null || true
    fi
    echo -e "${GREEN}✓ KDE Screen Locker wallpaper configured.${NC}"
fi

# 2. Configure Plasma Login Manager (plasmalogin.conf) if installed
if [ "$APPLIED_GLOBAL" = true ] && { [ -f "/etc/plasmalogin.conf" ] || command -v plasmalogin >/dev/null 2>&1; }; then
    echo -e "${CYAN}Configuring Plasma Login Manager (boot login screen)...${NC}"
    sudo kwriteconfig6 --file /etc/plasmalogin.conf --group Greeter --key WallpaperPluginId "org.kde.image" 2>/dev/null || true
    sudo kwriteconfig6 --file /etc/plasmalogin.conf --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "$GLOBAL_IMG" 2>/dev/null || true
    sudo kwriteconfig6 --file /etc/plasmalogin.conf --group Greeter --group Wallpaper --group org.kde.image --group General --key PreviewImage "$GLOBAL_IMG" 2>/dev/null || true
    
    # If plasmalogin cache dir exists, ensure it has the wallpaper too
    if [ -d "/var/lib/plasmalogin" ]; then
        sudo mkdir -p "/var/lib/plasmalogin/wallpapers" 2>/dev/null || true
        sudo cp -f "$GLOBAL_IMG" "/var/lib/plasmalogin/wallpapers/3840x2160.png" 2>/dev/null || true
        sudo chown -R plasmalogin:plasmalogin "/var/lib/plasmalogin/wallpapers" 2>/dev/null || true
    fi
    echo -e "${GREEN}✓ Plasma Login Manager greeter configured.${NC}"
fi

# 3. Configure SDDM if installed
if [ "$APPLIED_GLOBAL" = true ] && [ -d "/usr/share/sddm/themes" ]; then
    for theme_dir in /usr/share/sddm/themes/*; do
        if [ -d "$theme_dir" ] && [ -f "$theme_dir/theme.conf" ]; then
            sudo cp -f "$GLOBAL_IMG" "$theme_dir/background.png" 2>/dev/null || true
        fi
    done
fi

echo -e "${GREEN}✓ 4K 60fps MP4 live desktop wallpaper, lockscreen & login screen applied successfully!${NC}"
