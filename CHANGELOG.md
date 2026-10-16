# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.1] - 2026-10-16
### Fixed
- **Licence:** `LICENSE` named AGPL-3.0 but didn't contain the licence text,
  and the website said GPLv3. Turbomod is now GPL-3.0-or-later, with the full
  text in `LICENSE` and a licence statement in the README, script and man page.
- **Custom `PREFIX` broke boot persistence:** the boot unit always ran
  `/usr/local/bin/turbomod`. `install.sh` now writes the unit's `ExecStart`
  for the `PREFIX` it installs to, and rejects relative or spaced paths.
  Added `DESTDIR` for staged/packaged installs.
- **Mistyped options were silently ignored** (`disable --persits` disabled
  turbo but didn't save anything, with no warning). Unknown arguments are now
  errors, as is `--persist` on commands other than enable/disable.
- `--persist` said the state was saved "across reboots" even when the boot
  service wasn't enabled (it's installed disabled). It now says whether the
  service will re-apply it, and how to enable it if not.
- Man page referred to a nonexistent `turbomod-restore.service(8)` page.

### Changed
- README notes the trade-off (lower peak performance) and that firmware or
  other power tools can override the setting; documents release verification.
- Tests: argument validation and `install.sh` unit path (14 bats tests).

## [1.1.0] - 2026-06-22
### Added
- `--version` / `-v` flag and version string in `--help`.
- Write-back verification: `enable`/`disable` now read `no_turbo` back and fail
  loudly if the change did not take effect.
- Reboot persistence: `--persist` saves the chosen state to `/etc/turbomod/state`,
  a new `restore` command re-applies it, and a `turbomod-restore.service` systemd
  unit runs it at boot.
- `install.sh` / `--uninstall`, a `turbomod.1` man page, and bash completion.
- `release.sh` to generate `checksums.sha512` and (with `--sign`) a detached
  GPG signature; `Audit/checksums.sha512` is now shipped with the release.
- `tests/turbomod.bats` covering command dispatch and the EUID / missing-driver
  guard branches.

### Changed
- README scoped honestly to Intel `intel_pstate` only; AMD / `acpi-cpufreq` are
  documented as unsupported.
- README security section reworded to describe the EUID check plainly and keep
  the architectural (no-LPE-surface) rationale.
- Error and privilege messages now go to stderr.

## [1.0.0] - 2026-06-10
### Added
- Standardized Intel Turbo Boost moderator tool (`turbomod`).
- Status checking (`status`), enabling (`enable`), and disabling (`disable`)
  commands for `intel_pstate`.

### Hardened
- EUID verification so processor adjustments require root/sudo.
- Safe execution flags via `set -euo pipefail`.
- Removed the legacy GUI wrapper to mitigate local privilege escalation (LPE) risk.
