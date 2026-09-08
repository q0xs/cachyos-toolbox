#!/usr/bin/env bash
# ==============================================================================
#  🔥 Ghost Rider 4K Wallpaper Installer for KDE Plasma 6
# ==============================================================================
set -e

# Renkler
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

TARGET_DIR="$HOME/.local/share/wallpapers/GhostRider"
VIDEO_NAME="ghost_rider_clean_loop_06x.mp4"
LOCKSCREEN_NAME="lockscreen_ghost_rider.png"
VIDEO_PATH="$TARGET_DIR/$VIDEO_NAME"
LOCKSCREEN_PATH="$TARGET_DIR/$LOCKSCREEN_NAME"
REPO_URL="https://github.com/q0xs/ghost-rider-wallpaper.git"

# Root kontrolü (KDE ayarlarının doğru kullanıcıya yazılması için)
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}HATA: Lütfen bu betiği 'sudo' ile ÇALIŞTIRMAYIN.${NC}"
    echo "Doğrudan normal kullanıcı olarak çalıştırın: ./install.sh"
    exit 1
fi

echo -e "${CYAN}==========================================================${NC}"
echo -e "${YELLOW}       🔥 Ghost Rider 4K HDR Wallpaper Installer 🔥       ${NC}"
echo -e "${CYAN}==========================================================${NC}"

# 1. Dosyaların temini (Repo içinden mi çalıştırıldı, curl ile mi?)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
TEMP_CLONE=""

if [ -f "$SCRIPT_DIR/$VIDEO_NAME" ] && [ -f "$SCRIPT_DIR/$LOCKSCREEN_NAME" ]; then
    SOURCE_DIR="$SCRIPT_DIR"
else
    echo -e "${CYAN}[1/4] Depo indiriliyor (hızlı klon)...${NC}"
    if ! command -v git >/dev/null 2>&1; then
        echo -e "${YELLOW}Git paketi bulunamadı, kuruluyor...${NC}"
        sudo pacman -S --needed --noconfirm git
    fi
    TEMP_CLONE="/tmp/ghost-rider-wallpaper-$$"
    git clone --depth 1 "$REPO_URL" "$TEMP_CLONE"
    SOURCE_DIR="$TEMP_CLONE"
fi

# 2. Bağımlılıkları kontrol et
echo -e "${CYAN}[2/4] Gerekli eklentiler ve paketler kontrol ediliyor...${NC}"
MISSING_PKGS=()

if [ ! -d "/usr/share/plasma/wallpapers/com.github.catsout.wallpaperEngineKde" ] && \
   [ ! -d "$HOME/.local/share/plasma/wallpapers/com.github.catsout.wallpaperEngineKde" ]; then
    MISSING_PKGS+=("plasma6-wallpapers-wallpaper-engine-git")
fi

if ! command -v mpv >/dev/null 2>&1; then
    MISSING_PKGS+=("mpv")
fi

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo -e "${YELLOW}Eksik paketler tespit edildi: ${MISSING_PKGS[*]}${NC}"
    if command -v pacman >/dev/null 2>&1; then
        echo -e "${CYAN}Paketler yükleniyor...${NC}"
        sudo pacman -S --needed --noconfirm "${MISSING_PKGS[@]}" || {
            echo -e "${YELLOW}UYARI: Otomatik paket kurulumu atlandı. Gerekirse şu komutu çalıştırın:${NC}"
            echo "  sudo pacman -S --needed ${MISSING_PKGS[*]}"
        }
    fi
else
    echo -e "${GREEN}✓ Gerekli eklentiler hazır.${NC}"
fi

# 3. Dosyaları kalıcı konuma kopyala
echo -e "${CYAN}[3/4] 4K Video ve Kilit Ekranı dosyaları yerleştiriliyor...${NC}"
mkdir -p "$TARGET_DIR"
cp -f "$SOURCE_DIR/$VIDEO_NAME" "$TARGET_DIR/"
cp -f "$SOURCE_DIR/$LOCKSCREEN_NAME" "$TARGET_DIR/"

# Geçici klon varsa temizle
if [ -n "$TEMP_CLONE" ] && [ -d "$TEMP_CLONE" ]; then
    rm -rf "$TEMP_CLONE"
fi
echo -e "${GREEN}✓ Dosyalar '$TARGET_DIR' altına yüklendi.${NC}"

# 4. Masaüstü MP4 Video Duvar Kağıdını Uygula
echo -e "${CYAN}[4/4] Masaüstü ve Kilit Ekranı uygulanıyor...${NC}"

# 4A. Canlı masaüstlerine uygula (DBus)
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

# 4B. Kalıcılık için desktop-appletsrc dosyasını güncelle
APPLETRC="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
if [ -f "$APPLETRC" ] && command -v python3 >/dev/null 2>&1; then
    python3 -c "
import re
path = '$APPLETRC'
try:
    with open(path, 'r') as f:
        text = f.read()

    # Masaüstü containments bloklarını güncelle
    def update_block(match):
        block = match.group(0)
        # Sadece masaüstü olanları güncelle (panel olmayanlar)
        if 'formfactor=2' in block or 'plugin=org.kde.panel' in block:
            return block
        block = re.sub(r'wallpaperplugin=[^\n]+', 'wallpaperplugin=com.github.catsout.wallpaperEngineKde', block)
        return block

    text = re.sub(r'\[Containments\]\[\d+\][^\[]*', update_block, text)

    # WallpaperSource satırlarını güncelle
    source_pattern = r'(\[Containments\]\[\d+\]\[Wallpaper\]\[com\.github\.catsout\.wallpaperEngineKde\]\[General\][^\[]*?WallpaperSource=)[^\n]+'
    text = re.sub(source_pattern, r'\g<1>$VIDEO_PATH+video', text)

    with open(path, 'w') as f:
        f.write(text)
except Exception:
    pass
" 2>/dev/null || true
fi
echo -e "${GREEN}✓ Masaüstü MP4 video duvar kağıdı (4K 60FPS 0.6x) uygulandı.${NC}"

# 4C. Kilit Ekranını (Lock Screen) 4K Görselle Yapılandır
if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file kscreenlockerrc --group Greeter --key wallpaperPlugin "org.kde.image"
    kwriteconfig6 --file kscreenlockerrc --group Greeter --key wallpaperPluginId "org.kde.image"
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file://$LOCKSCREEN_PATH"
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key PreviewImage "file://$LOCKSCREEN_PATH"
    
    if command -v qdbus6 >/dev/null 2>&1; then
        qdbus6 org.kde.screensaver /ScreenSaver org.kde.screensaver.configure 2>/dev/null || true
    fi
    echo -e "${GREEN}✓ Kilit ekranı (4K UHD) uygulandı.${NC}"
fi

# 4D. Ekran Uyku Süresini (20 dakika) Yapılandır
if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file powerdevilrc --group AC --group Display --key TurnOffDisplayIdleTimeoutSec 1200
    kwriteconfig6 --file powerdevilrc --group AC --group Display --key TurnOffDisplayWhenIdle true
    kwriteconfig6 --file powerdevilrc --group Battery --group Display --key TurnOffDisplayIdleTimeoutSec 1200
    kwriteconfig6 --file powerdevilrc --group Battery --group Display --key TurnOffDisplayWhenIdle true
    if command -v qdbus6 >/dev/null 2>&1; then
        qdbus6 org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement refreshStatus 2>/dev/null || true
    fi
fi

echo ""
echo -e "${GREEN}==========================================================${NC}"
echo -e "${GREEN}  🎉 KURULUM TAMAMLANDI!                                  ${NC}"
echo -e "${GREEN}  • Masaüstü: 4K 60FPS Canlı Video                        ${NC}"
echo -e "${GREEN}  • Kilit Ekranı: 4K Ultra HD Ghost Rider                 ${NC}"
echo -e "${GREEN}  • Ekran Uyku Süresi: 20 Dakika                         ${NC}"
echo -e "${GREEN}==========================================================${NC}"
