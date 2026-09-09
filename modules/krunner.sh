#!/usr/bin/env bash
# ==============================================================================
#  Module: Spotlight-Style Alt+Space (KRunner)
# ==============================================================================
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "\n${CYAN}[+] Configuring Spotlight-style Alt+Space (KRunner)...${NC}"

if command -v kwriteconfig6 >/dev/null 2>&1; then
    # Center KRunner floating on screen like macOS Spotlight
    kwriteconfig6 --file krunnerrc --group General --key FreeFloating true
    kwriteconfig6 --file krunnerrc --group General --key HistoryEnabled true
    kwriteconfig6 --file krunnerrc --group General --key RetainPriorSearch false

    # Hide the help / question mark runner
    kwriteconfig6 --file krunnerrc --group Plugins --key helprunnerEnabled false
    kwriteconfig6 --file krunnerrc --group Plugins --key krunner_helprunnerEnabled false
    kwriteconfig6 --file krunnerrc --group Plugins --key org.kde.helprunnerEnabled false

    # Hide settings button on KRunner bar for a minimalist spotlight appearance
    kwriteconfig6 --file kdeglobals --group "KDE Control Module Restrictions" --key "kcm_krunnersettings" false

    # Restart KRunner daemon so changes take effect immediately
    systemctl --user restart plasma-krunner.service 2>/dev/null || (kquitapp6 krunner 2>/dev/null; kstart6 krunner 2>/dev/null &)

    echo -e "${GREEN}✓ KRunner configured: Centered Spotlight mode, clean search bar without question-mark icon.${NC}"
else
    echo "Warning: kwriteconfig6 not found. Are you running KDE Plasma 6?"
fi
