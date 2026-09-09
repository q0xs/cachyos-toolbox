#!/usr/bin/env bash
# ==============================================================================
#  ⚡ CachyOS Toolbox - Setup & Customization Suite
#  Author: q0xs (https://github.com/q0xs)
# ==============================================================================
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

REPO_URL="https://github.com/q0xs/cachyos-toolbox.git"

# Root safety check
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}ERROR: Please do NOT run this script as root / sudo.${NC}"
    echo "Run as your normal user: ./setup.sh"
    exit 1
fi

# Determine source directory (local clone vs curl one-liner)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
TEMP_DIR=""

if [ -d "$SCRIPT_DIR/modules" ] && [ -d "$SCRIPT_DIR/assets" ]; then
    BASE_DIR="$SCRIPT_DIR"
else
    echo -e "${CYAN}[+] Downloading CachyOS Toolbox repository...${NC}"
    if ! command -v git >/dev/null 2>&1; then
        echo -e "${YELLOW}Git not found, installing...${NC}"
        sudo pacman -S --needed --noconfirm git
    fi
    TEMP_DIR="/tmp/cachyos-toolbox-$$"
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR"
    BASE_DIR="$TEMP_DIR"
fi

MODULES_DIR="$BASE_DIR/modules"

cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# Ensure interactive terminal access even when piped (e.g., curl ... | bash)
if [ ! -t 0 ] && [ -e /dev/tty ]; then
    exec < /dev/tty
fi

# Parse command line flags for non-interactive / direct execution
RUN_WALLPAPER=false
RUN_KRUNNER=false
RUN_TIMEOUT=false
NON_INTERACTIVE=false

if [ "$#" -gt 0 ]; then
    NON_INTERACTIVE=true
    for arg in "$@"; do
        case "$arg" in
            -a|--all)
                RUN_WALLPAPER=true
                RUN_KRUNNER=true
                RUN_TIMEOUT=true
                ;;
            -w|--wallpaper) RUN_WALLPAPER=true ;;
            -k|--krunner)   RUN_KRUNNER=true ;;
            -t|--timeout)   RUN_TIMEOUT=true ;;
            -h|--help)
                echo "⚡ CachyOS Toolbox - Setup & Customization Suite"
                echo "Usage: ./setup.sh [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  -a, --all         Install and configure all components"
                echo "  -w, --wallpaper   Ghost Rider 4K HDR Live Wallpaper, Lock & Login Screen"
                echo "  -k, --krunner     Spotlight-style Alt+Space (Centered, Minimal)"
                echo "  -t, --timeout     Set display sleep timeout to 20 minutes"
                echo "  -h, --help        Show this help message"
                echo ""
                echo "Running without arguments opens the interactive checklist UI."
                exit 0
                ;;
            *)
                echo "Unknown option: $arg. Use --help for usage."
                exit 1
                ;;
        esac
    done
fi

# Interactive UI Selection
if [ "$NON_INTERACTIVE" = false ]; then
    if command -v whiptail >/dev/null 2>&1 && [ -t 0 ]; then
        CHOICES=$(whiptail --title "⚡ CachyOS Toolbox" \
            --checklist "\nSelect the components you want to install and configure:\n(Use [SPACE] to select/deselect, [ENTER] to confirm)" \
            16 76 3 \
            "WALLPAPER" "Ghost Rider 4K Wallpaper (Desktop MP4, Lock & Login Screen)" ON \
            "KRUNNER"   "Spotlight-style Alt+Space (Centered, Clean, No help icon)" ON \
            "TIMEOUT"   "Display Sleep Timeout (Set screen off to 20 minutes)" ON \
            3>&1 1>&2 2>&3) || {
                echo -e "\n${YELLOW}Installation cancelled by user.${NC}"
                exit 0
            }

        for item in $CHOICES; do
            clean_item=$(echo "$item" | tr -d '"')
            case "$clean_item" in
                WALLPAPER) RUN_WALLPAPER=true ;;
                KRUNNER)   RUN_KRUNNER=true ;;
                TIMEOUT)   RUN_TIMEOUT=true ;;
            esac
        done
    else
        # Fallback text mode if no whiptail or non-interactive pipe
        echo -e "${CYAN}==========================================================${NC}"
        echo -e "${BOLD}       ⚡ CachyOS Toolbox - Setup & Customization        ${NC}"
        echo -e "${CYAN}==========================================================${NC}"
        echo "Select options to install (default: 1,2,3):"
        echo "1) Ghost Rider 4K Wallpaper (Desktop MP4, Lock & Login Screen)"
        echo "2) Spotlight-style Alt+Space (KRunner Centered & Clean)"
        echo "3) Display Sleep Timeout (20 minutes)"
        echo "0) Cancel / Exit"
        read -p "Enter selections separated by spaces [1 2 3]: " -r user_choices
        user_choices=${user_choices:-"1 2 3"}
        for ch in $user_choices; do
            case "$ch" in
                1) RUN_WALLPAPER=true ;;
                2) RUN_KRUNNER=true ;;
                3) RUN_TIMEOUT=true ;;
                0|q|Q)
                    echo -e "\n${YELLOW}Installation cancelled by user.${NC}"
                    exit 0
                    ;;
            esac
        done
    fi
fi

# Execute selected components
echo -e "\n${CYAN}==========================================================${NC}"
echo -e "${BOLD}       Applying Selected Configurations...                ${NC}"
echo -e "${CYAN}==========================================================${NC}"

chmod +x "$MODULES_DIR"/*.sh

if [ "$RUN_WALLPAPER" = true ]; then
    "$MODULES_DIR/wallpaper.sh"
fi

if [ "$RUN_KRUNNER" = true ]; then
    "$MODULES_DIR/krunner.sh"
fi

if [ "$RUN_TIMEOUT" = true ]; then
    "$MODULES_DIR/timeout.sh"
fi

echo -e "\n${GREEN}==========================================================${NC}"
echo -e "${GREEN}${BOLD}  🎉 ALL SELECTED CONFIGURATIONS APPLIED SUCCESSFULLY!     ${NC}"
echo -e "${GREEN}==========================================================${NC}"
