#!/bin/bash
#
# install.sh - install turbomod, its man page, bash completion, and the
# optional systemd boot-persistence unit.
#
# Usage:
#   sudo ./install.sh           # install
#   sudo ./install.sh --uninstall
#
set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"
BINDIR="$PREFIX/bin"
MANDIR="$PREFIX/share/man/man1"
COMPDIR="/usr/share/bash-completion/completions"
UNITDIR="/etc/systemd/system"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$EUID" -ne 0 ]; then
    echo "Error: install.sh must be run as root (use sudo)." >&2
    exit 1
fi

uninstall() {
    echo "Removing turbomod..."
    systemctl disable turbomod-restore.service 2>/dev/null || true
    rm -f "$BINDIR/turbomod" \
          "$MANDIR/turbomod.1" \
          "$COMPDIR/turbomod" \
          "$UNITDIR/turbomod-restore.service"
    systemctl daemon-reload 2>/dev/null || true
    echo "Done. (/etc/turbomod was left in place; remove it manually if desired.)"
}

if [ "${1:-}" = "--uninstall" ]; then
    uninstall
    exit 0
fi

echo "Installing turbomod to $BINDIR ..."
install -Dm755 "$SRC_DIR/turbomod"                              "$BINDIR/turbomod"
install -Dm644 "$SRC_DIR/packaging/turbomod.1"                  "$MANDIR/turbomod.1"
install -Dm644 "$SRC_DIR/packaging/turbomod.bash-completion"    "$COMPDIR/turbomod"

# The systemd unit is optional; install it but leave it disabled by default.
if command -v systemctl >/dev/null 2>&1; then
    install -Dm644 "$SRC_DIR/packaging/turbomod-restore.service" "$UNITDIR/turbomod-restore.service"
    systemctl daemon-reload
    echo ""
    echo "Optional boot persistence installed but not enabled."
    echo "To have your chosen state re-applied at boot:"
    echo "  sudo turbomod disable --persist   # or enable --persist"
    echo "  sudo systemctl enable turbomod-restore.service"
fi

echo ""
echo "turbomod installed. Try: turbomod status"
