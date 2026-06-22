#!/bin/bash
#
# release.sh - produce release artifacts for turbomod:
#   - checksums.sha512  (SHA-512 of the shipped files)
#   - checksums.sha512.asc  (detached GPG signature, if a key is available)
#
# Usage:
#   ./release.sh                  # generate checksums.sha512
#   ./release.sh --sign           # also create a detached GPG signature
#   GPG_KEY=you@example.com ./release.sh --sign
#
set -euo pipefail

cd "$(dirname "$0")"
OUT_DIR="Audit"
CHECKSUMS="$OUT_DIR/checksums.sha512"

# Files that constitute a release. Add to this list as the project grows.
FILES=(
    "turbomod"
    "install.sh"
    "packaging/turbomod.1"
    "packaging/turbomod.bash-completion"
    "packaging/turbomod-restore.service"
)

mkdir -p "$OUT_DIR"

echo "Generating $CHECKSUMS ..."
# Use sha512sum if present (Linux), otherwise fall back to shasum (macOS).
if command -v sha512sum >/dev/null 2>&1; then
    sha512sum "${FILES[@]}" > "$CHECKSUMS"
elif command -v shasum >/dev/null 2>&1; then
    shasum -a 512 "${FILES[@]}" > "$CHECKSUMS"
else
    echo "Error: no sha512sum or shasum available." >&2
    exit 1
fi
echo "Wrote $(wc -l < "$CHECKSUMS") checksums."

if [ "${1:-}" = "--sign" ]; then
    if ! command -v gpg >/dev/null 2>&1; then
        echo "Error: gpg not found; cannot sign." >&2
        exit 1
    fi
    KEY_ARG=()
    [ -n "${GPG_KEY:-}" ] && KEY_ARG=(--local-user "$GPG_KEY")
    echo "Creating detached signature $CHECKSUMS.asc ..."
    gpg "${KEY_ARG[@]}" --armor --detach-sign --output "$CHECKSUMS.asc" "$CHECKSUMS"
    echo "Signed. Verify with: gpg --verify $CHECKSUMS.asc $CHECKSUMS"
else
    echo "Skipping GPG signature (run with --sign to produce checksums.sha512.asc)."
fi
