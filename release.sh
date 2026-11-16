#!/usr/bin/env bash
#
# Author: Chuck Talk, <chuck@nordheim.online>
# Project: turbomod
# Purpose: Produce release artifacts (checksums.sha512 and detached GPG signature).
# Updated: 2026-11-15
#
# Usage:
#   ./release.sh                  # generate checksums.sha512
#   ./release.sh --sign           # also create a detached GPG signature
#   GPG_KEY=you@example.com ./release.sh --sign
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
cd "${SCRIPT_DIR}"

readonly OUT_DIR="Audit"
readonly CHECKSUMS="${OUT_DIR}/checksums.sha512"

# Files that constitute a release. Add to this list as the project grows.
readonly FILES=(
    "turbomod"
    "install.sh"
    "packaging/turbomod.1"
    "packaging/turbomod.bash-completion"
    "packaging/turbomod-restore.service"
)

mkdir -p "${OUT_DIR}"

echo "Generating ${CHECKSUMS} ..."
# Use sha512sum if present (Linux), otherwise fall back to shasum (macOS).
if command -v sha512sum >/dev/null 2>&1; then
    sha512sum -- "${FILES[@]}" > "${CHECKSUMS}"
elif command -v shasum >/dev/null 2>&1; then
    shasum -a 512 -- "${FILES[@]}" > "${CHECKSUMS}"
else
    echo "Error: no sha512sum or shasum available." >&2
    exit 1
fi
echo "Wrote $(wc -l < "${CHECKSUMS}") checksums."

if [[ "${1:-}" == "--sign" ]]; then
    if ! command -v gpg >/dev/null 2>&1; then
        echo "Error: gpg not found; cannot sign." >&2
        exit 1
    fi
    KEY_ARG=()
    if [[ -n "${GPG_KEY:-}" ]]; then
        KEY_ARG=(--local-user "${GPG_KEY}")
    fi
    echo "Creating detached signature ${CHECKSUMS}.asc ..."
    gpg ${KEY_ARG[@]+"${KEY_ARG[@]}"} --armor --detach-sign --output "${CHECKSUMS}.asc" "${CHECKSUMS}"
    echo "Signed. Verify with: gpg --verify ${CHECKSUMS}.asc ${CHECKSUMS}"
else
    echo "Skipping GPG signature (run with --sign to produce checksums.sha512.asc)."
fi
