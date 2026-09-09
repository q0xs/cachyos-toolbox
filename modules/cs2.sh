#!/usr/bin/env bash
# ==============================================================================
#  Module: CS2 Gaming & Latency Optimizer
# ==============================================================================
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "\n${CYAN}[+] Setting up CS2 Gaming Optimizations on CachyOS...${NC}"

# Check & install gaming packages
PACKAGES=("gamemode" "lib32-gamemode" "gamescope")
if command -v pacman >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing gaming utilities: ${PACKAGES[*]}...${NC}"
    sudo pacman -S --needed --noconfirm "${PACKAGES[@]}" || {
        echo -e "${YELLOW}Warning: Could not install automatically. Run: sudo pacman -S --needed ${PACKAGES[*]}${NC}"
    }

    # Fix Gamescope VAC capability if gamescope is present
    if [ -f "/usr/bin/gamescope" ]; then
        sudo setcap -r /usr/bin/gamescope 2>/dev/null || true
    fi
fi

echo -e "${GREEN}✓ Gaming packages and low-latency permissions configured!${NC}"
echo -e "\n${BOLD}Recommended CS2 Steam Launch Options:${NC}"
echo -e "  • ${CYAN}Native Wayland (Sharpest image, ultra-low latency, 240Hz):${NC}"
echo -e "    ${BOLD}gamemoderun SDL_VIDEO_DRIVER=wayland %command%${NC}"
echo -e "  • ${CYAN}True 4:3 Stretched (1280x960 @ 240Hz with Gamescope):${NC}"
echo -e "    ${BOLD}gamescope -w 1280 -h 960 -W 1920 -H 1080 -r 240 -S stretch -f --force-grab-cursor -- %command%${NC}"
