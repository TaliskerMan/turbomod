#!/usr/bin/env bats
#
# Tests for turbomod. These run without root and without real sysfs by pointing
# TURBO_FILE/STATE_FILE at temp files via a small harness that sources nothing —
# instead we exercise the script's command dispatch and guard branches.
#
# Run with:  bats tests/turbomod.bats
#
# Note: tests that exercise a successful write are skipped unless running as
# root against a real intel_pstate file, since we cannot write sysfs in CI.

setup() {
    SCRIPT="${BATS_TEST_DIRNAME}/../turbomod"
}

@test "no arguments prints help and exits non-zero" {
    run "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage: turbomod"* ]]
}

@test "--version prints version" {
    run "$SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"turbomod 1.1.1"* ]]
}

@test "-v prints version" {
    run "$SCRIPT" -v
    [ "$status" -eq 0 ]
    [[ "$output" == *"turbomod 1.1.1"* ]]
}

@test "--help prints usage and exits zero" {
    run "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Commands:"* ]]
}

@test "unknown command exits non-zero and shows help" {
    run "$SCRIPT" frobnicate
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown command: frobnicate"* ]]
}

@test "enable without root is refused" {
    if [ "$EUID" -eq 0 ]; then skip "running as root"; fi
    run "$SCRIPT" enable
    [ "$status" -eq 1 ]
    [[ "$output" == *"administrative privileges"* ]]
}

@test "disable without root is refused" {
    if [ "$EUID" -eq 0 ]; then skip "running as root"; fi
    run "$SCRIPT" disable
    [ "$status" -eq 1 ]
    [[ "$output" == *"administrative privileges"* ]]
}

@test "status reports missing driver cleanly when sysfs absent" {
    if [ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
        skip "real intel_pstate present on this host"
    fi
    run "$SCRIPT" status
    [ "$status" -eq 1 ]
    [[ "$output" == *"Intel P-State driver not found"* ]]
}

@test "a mistyped option is rejected, not ignored" {
    run "$SCRIPT" disable --persits
    [ "$status" -eq 1 ]
    [[ "$output" == *"unexpected argument '--persits'"* ]]
}

@test "--persist is rejected for status" {
    run "$SCRIPT" status --persist
    [ "$status" -eq 1 ]
    [[ "$output" == *"--persist only applies to enable and disable"* ]]
}

@test "extra arguments after status are rejected" {
    run "$SCRIPT" status now
    [ "$status" -eq 1 ]
    [[ "$output" == *"unexpected argument 'now'"* ]]
}

@test "install.sh points the boot unit at the PREFIX it installs to" {
    stage="$(mktemp -d)"
    run env DESTDIR="$stage" PREFIX=/opt/tm "${BATS_TEST_DIRNAME}/../install.sh"
    [ "$status" -eq 0 ]
    [ -x "$stage/opt/tm/bin/turbomod" ]
    [ -f "$stage/opt/tm/share/man/man1/turbomod.1" ]
    grep -qx 'ExecStart=/opt/tm/bin/turbomod restore' \
        "$stage/etc/systemd/system/turbomod-restore.service"
    rm -rf "$stage"
}

@test "install.sh default PREFIX matches the shipped unit" {
    stage="$(mktemp -d)"
    run env DESTDIR="$stage" "${BATS_TEST_DIRNAME}/../install.sh"
    [ "$status" -eq 0 ]
    grep -qx 'ExecStart=/usr/local/bin/turbomod restore' \
        "$stage/etc/systemd/system/turbomod-restore.service"
    rm -rf "$stage"
}

@test "install.sh refuses a relative or spaced PREFIX" {
    run env DESTDIR=/tmp/x PREFIX=relative "${BATS_TEST_DIRNAME}/../install.sh"
    [ "$status" -eq 1 ]
    run env DESTDIR=/tmp/x PREFIX="/opt/my dir" "${BATS_TEST_DIRNAME}/../install.sh"
    [ "$status" -eq 1 ]
}
