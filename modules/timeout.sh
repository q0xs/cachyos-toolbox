#!/usr/bin/env bash
# ==============================================================================
#  Module: 20-Minute Display Sleep Timeout
# ==============================================================================
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "\n${CYAN}[+] Setting display sleep timeout to 20 minutes (1200 seconds)...${NC}"

if command -v kwriteconfig6 >/dev/null 2>&1; then
    # Configure AC power profile
    kwriteconfig6 --file powerdevilrc --group AC --group Display --key TurnOffDisplayIdleTimeoutSec 1200
    kwriteconfig6 --file powerdevilrc --group AC --group Display --key TurnOffDisplayWhenIdle true

    # Configure Battery power profile
    kwriteconfig6 --file powerdevilrc --group Battery --group Display --key TurnOffDisplayIdleTimeoutSec 1200
    kwriteconfig6 --file powerdevilrc --group Battery --group Display --key TurnOffDisplayWhenIdle true

    # Reload powerdevil daemon
    if command -v qdbus6 >/dev/null 2>&1; then
        qdbus6 org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement refreshStatus 2>/dev/null || true
    fi
    systemctl --user restart plasma-powerdevil.service 2>/dev/null || true

    echo -e "${GREEN}✓ Display sleep timeout set to 20 minutes (AC and Battery).${NC}"
else
    echo "Warning: kwriteconfig6 not found."
fi
