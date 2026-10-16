#!/bin/bash
#
# install.sh - install turbomod, its man page, bash completion, and the
# optional systemd boot-persistence unit.
#
# Usage:
#   sudo ./install.sh                          # install under /usr/local
#   sudo PREFIX=/usr ./install.sh              # install under /usr
#   sudo ./install.sh --uninstall              # (use the same PREFIX)
#   DESTDIR=/tmp/stage ./install.sh            # stage files for packaging;
#                                              # no root, no systemctl calls
#
set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"
# The boot unit's ExecStart is written with this path, so it must be an
# absolute path without spaces (systemd would split it).
case "$PREFIX" in
    /*) ;;
    *) echo "Error: PREFIX must be an absolute path (got '$PREFIX')." >&2; exit 1 ;;
esac
case "$PREFIX" in
    *[[:space:]]*|*'|'*) echo "Error: PREFIX must not contain spaces or '|'." >&2; exit 1 ;;
esac
BINDIR="$PREFIX/bin"
MANDIR="$PREFIX/share/man/man1"
COMPDIR="/usr/share/bash-completion/completions"
UNITDIR="/etc/systemd/system"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
DESTDIR="${DESTDIR:-}"

if [ -z "$DESTDIR" ] && [ "$EUID" -ne 0 ]; then
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

echo "Installing turbomod to ${DESTDIR}$BINDIR ..."
install -Dm755 "$SRC_DIR/turbomod"                              "${DESTDIR}$BINDIR/turbomod"
install -Dm644 "$SRC_DIR/packaging/turbomod.1"                  "${DESTDIR}$MANDIR/turbomod.1"
install -Dm644 "$SRC_DIR/packaging/turbomod.bash-completion"    "${DESTDIR}$COMPDIR/turbomod"

# The systemd unit is optional; install it but leave it disabled by default.
if [ -n "$DESTDIR" ] || command -v systemctl >/dev/null 2>&1; then
    # Point the unit at where turbomod is actually installed: PREFIX may not
    # be /usr/local, and a unit pointing at a missing file fails at boot.
    unit_tmp="$(mktemp)"
    trap 'rm -f "$unit_tmp"' EXIT
    sed "s|^ExecStart=.*|ExecStart=$BINDIR/turbomod restore|" \
        "$SRC_DIR/packaging/turbomod-restore.service" > "$unit_tmp"
    install -Dm644 "$unit_tmp" "${DESTDIR}$UNITDIR/turbomod-restore.service"
    if [ -z "$DESTDIR" ]; then
        systemctl daemon-reload
        echo ""
        echo "Optional boot persistence installed but not enabled."
        echo "To have your chosen state re-applied at boot:"
        echo "  sudo turbomod disable --persist   # or enable --persist"
        echo "  sudo systemctl enable turbomod-restore.service"
    fi
fi

echo ""
echo "turbomod installed. Try: turbomod status"
