# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-06-10
### Added
- Standardized Intel Turbo Boost moderator tool (`turbomod`).
- Added status checking (`status`), enabling (`enable`), and disabling (`disable`) commands for `intel_pstate`.
- Structured release build signatures, including `checksums.sha512` and detached GPG files.

### Hardened
- Implemented strict EUID verification to ensure processor adjustments require root/sudo authentication.
- Configured safety execution variables via `set -euo pipefail`.
- Removed legacy GUI wrapper overhead to mitigate LPE (Local Privilege Escalation) security risks.
