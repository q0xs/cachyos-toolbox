#!/usr/bin/env bash
# ==============================================================================
#  Ghost Rider 4K Wallpaper Uninstaller for KDE Plasma 6
# ==============================================================================
set -e

if [ "$EUID" -eq 0 ]; then
    echo "HATA: Lütfen bu betiği 'sudo' ile ÇALIŞTIRMAYIN. Normal kullanıcı olarak çalıştırın: ./uninstall.sh"
    exit 1
fi

echo "=========================================================="
echo "      Ghost Rider Duvar Kağıdı Kaldırma Betiği            "
echo "=========================================================="

# 1. Reset lockscreen
echo "[1/3] Kilit ekranı sıfırlanıyor..."
if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image ""
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key PreviewImage ""
    if command -v qdbus6 >/dev/null 2>&1; then
        qdbus6 org.kde.screensaver /ScreenSaver org.kde.screensaver.configure 2>/dev/null || true
    fi
    echo "✓ Kilit ekranı varsayılana döndürüldü."
fi

# 2. Reset desktop
echo "[2/3] Masaüstü varsayılan resim moduna döndürülüyor..."
if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    for (let d of desktops()) {
        d.wallpaperPlugin = 'org.kde.image';
    }
    " 2>/dev/null || true
    echo "✓ Masaüstü standart duvar kağıdı moduna alındı."
fi

# 3. Clean files (optional prompt)
read -p "Duvar kağıdı dosyaları ($HOME/.local/share/wallpapers/GhostRider ve /usr/share/wallpapers/GhostRider) silinsin mi? [y/N]: " -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    rm -rf "$HOME/.local/share/wallpapers/GhostRider"
    if [ -d "/usr/share/wallpapers/GhostRider" ]; then
        sudo rm -rf "/usr/share/wallpapers/GhostRider" 2>/dev/null || true
    fi
    echo "✓ Dosyalar silindi."
fi

echo ""
echo "Kaldırma işlemi tamamlandı."
