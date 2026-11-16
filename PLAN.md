# Plan for turbomod v1.1.2: SonarQube Cloud & ShadowAgent Remediation
- [x] Create `Sonar` branch (`TaliskerMan_turbomod`) and gather all 10 SonarQube Cloud and Jira issues.
- [x] Remediate `docs/guide/build_guide.js`, `docs/guide/package.json`, and self-contained `docs/guide/logo.png` (`2 × jssecurity:S8707`).
- [x] Remediate `install.sh` (`shell:S131`, `5 × shell:S7688`), `release.sh` (`2 × shell:S7688`), `turbomod`, and `packaging/turbomod.bash-completion` (`0` `shellcheck` warnings).
- [x] Add `TURBOMOD_SYSFS_PATH` / `TURBOMOD_STATE_PATH` / `TURBOMOD_EUID` testability hooks and expand `tests/turbomod.bats` (18/18 tests passing).
- [x] Add `.sonarcloud.properties`, tracked `sonar-project.properties`, `.sonarlint/connectedMode.json`, `.snyk`, `.dcignore`, and SHA-pinned `.github/workflows/ci.yml`.
- [x] Regenerate `Audit/checksums.sha512` and path-sanitized CycloneDX SBOM (`Audit/sbom.json`, `Audit/SBOM-Linux.json`, `Audit/SBOM-Linux`).
- [x] Verify live SonarQube Cloud Quality Gate (`TaliskerMan_turbomod` `PASSED`, `0` issues) and merge `Sonar` into `main`.

# Plan for turbomod v1.1.1 Official Release

- [x] Pass Shift-Left Quality Gate (`code-gate.sh`): SonarQube, ShellCheck, Semgrep, OSV, Syft, Grype
- [x] Clean obsolete/unsupported claims (`Audit/SBOM-macOS*`)
- [x] Verify all user documentation against executable implementation
- [x] Build 64-bit Debian package (`turbomod_1.1.1_amd64.deb`)
- [x] Generate signed release checksums with `release.sh --sign`
- [x] Stage complete release artifacts in `/home/freecode/NOBuilds/turbomod-10-16-2026-1.1.1/` per `L-Release`
- [x] Git commit, tag `v1.1.1`, and push to GitHub origin
