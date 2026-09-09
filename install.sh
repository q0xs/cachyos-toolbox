#!/usr/bin/env bash
# ==============================================================================
#  install.sh - Legacy alias forwarding to setup.sh
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
exec "$SCRIPT_DIR/setup.sh" "$@"
