#!/usr/bin/env bats
#
# Author: Chuck Talk, <chuck@nordheim.online>
# Project: turbomod
# Purpose: BATS test suite for turbomod command dispatch, privilege & sysfs
#          guards, state persistence, write-back verification, and install.sh.
#
# Run with:  bats tests/turbomod.bats

setup() {
    SCRIPT="${BATS_TEST_DIRNAME}/../turbomod"
    TEST_TMP="$(mktemp -d)"
    MOCK_TURBO="${TEST_TMP}/no_turbo"
    MOCK_STATE="${TEST_TMP}/state"
}

teardown() {
    rm -rf -- "${TEST_TMP}"
}

@test "no arguments prints help and exits non-zero" {
    run "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage: turbomod"* ]]
}

@test "--version prints version" {
    run "$SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"turbomod 1.1.2"* ]]
}

@test "-v prints version" {
    run "$SCRIPT" -v
    [ "$status" -eq 0 ]
    [[ "$output" == *"turbomod 1.1.2"* ]]
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
    run env TURBOMOD_EUID=1000 "$SCRIPT" enable
    [ "$status" -eq 1 ]
    [[ "$output" == *"administrative privileges"* ]]
}

@test "disable without root is refused" {
    run env TURBOMOD_EUID=1000 "$SCRIPT" disable
    [ "$status" -eq 1 ]
    [[ "$output" == *"administrative privileges"* ]]
}

@test "status reports missing driver cleanly when sysfs absent" {
    run env TURBOMOD_SYSFS_PATH="${TEST_TMP}/missing_no_turbo" "$SCRIPT" status
    [ "$status" -eq 1 ]
    [[ "$output" == *"Intel P-State driver not found"* ]]
}

@test "status reports ON when no_turbo is 0 and OFF when no_turbo is 1" {
    printf '0\n' > "$MOCK_TURBO"
    run env TURBOMOD_SYSFS_PATH="$MOCK_TURBO" "$SCRIPT" status
    [ "$status" -eq 0 ]
    [[ "$output" == *"Turbo Boost is currently ON"* ]]

    printf '1\n' > "$MOCK_TURBO"
    run env TURBOMOD_SYSFS_PATH="$MOCK_TURBO" "$SCRIPT" status
    [ "$status" -eq 0 ]
    [[ "$output" == *"Turbo Boost is currently OFF"* ]]

    printf '9\n' > "$MOCK_TURBO"
    run env TURBOMOD_SYSFS_PATH="$MOCK_TURBO" "$SCRIPT" status
    [ "$status" -eq 0 ]
    [[ "$output" == *"Turbo Boost state unknown (9)"* ]]
}

@test "disable and enable write no_turbo and persist state when --persist is passed" {
    printf '0\n' > "$MOCK_TURBO"
    run env TURBOMOD_EUID=0 TURBOMOD_SYSFS_PATH="$MOCK_TURBO" TURBOMOD_STATE_PATH="$MOCK_STATE" "$SCRIPT" disable --persist
    [ "$status" -eq 0 ]
    [[ "$output" == *"Turbo Boost disabled."* ]]
    [ "$(cat "$MOCK_TURBO")" = "1" ]
    [ "$(cat "$MOCK_STATE")" = "disable" ]

    run env TURBOMOD_EUID=0 TURBOMOD_SYSFS_PATH="$MOCK_TURBO" TURBOMOD_STATE_PATH="$MOCK_STATE" "$SCRIPT" enable --persist
    [ "$status" -eq 0 ]
    [[ "$output" == *"Turbo Boost enabled."* ]]
    [ "$(cat "$MOCK_TURBO")" = "0" ]
    [ "$(cat "$MOCK_STATE")" = "enable" ]
}

@test "write-back verification fails loudly when sysfs rejects change" {
    printf '0\n' > "$MOCK_TURBO"
    run env TURBOMOD_EUID=0 TURBOMOD_SYSFS_PATH="$MOCK_TURBO" TURBOMOD_SIMULATE_REJECT=1 "$SCRIPT" disable
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error: write was not applied"* ]]
}

@test "restore re-applies saved state and handles missing or invalid state files" {
    printf '0\n' > "$MOCK_TURBO"
    run env TURBOMOD_EUID=0 TURBOMOD_SYSFS_PATH="$MOCK_TURBO" TURBOMOD_STATE_PATH="$MOCK_STATE" "$SCRIPT" restore
    [ "$status" -eq 0 ]
    [[ "$output" == *"No saved state to restore"* ]]

    printf 'disable\n' > "$MOCK_STATE"
    run env TURBOMOD_EUID=0 TURBOMOD_SYSFS_PATH="$MOCK_TURBO" TURBOMOD_STATE_PATH="$MOCK_STATE" "$SCRIPT" restore
    [ "$status" -eq 0 ]
    [ "$(cat "$MOCK_TURBO")" = "1" ]

    printf 'bogus\n' > "$MOCK_STATE"
    run env TURBOMOD_EUID=0 TURBOMOD_SYSFS_PATH="$MOCK_TURBO" TURBOMOD_STATE_PATH="$MOCK_STATE" "$SCRIPT" restore
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error: unrecognized saved state 'bogus'"* ]]
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
    rm -rf -- "$stage"
}

@test "install.sh default PREFIX matches the shipped unit" {
    stage="$(mktemp -d)"
    run env DESTDIR="$stage" "${BATS_TEST_DIRNAME}/../install.sh"
    [ "$status" -eq 0 ]
    grep -qx 'ExecStart=/usr/local/bin/turbomod restore' \
        "$stage/etc/systemd/system/turbomod-restore.service"
    rm -rf -- "$stage"
}

@test "install.sh refuses a relative or spaced PREFIX" {
    run env DESTDIR=/tmp/x PREFIX=relative "${BATS_TEST_DIRNAME}/../install.sh"
    [ "$status" -eq 1 ]
    run env DESTDIR=/tmp/x PREFIX="/opt/my dir" "${BATS_TEST_DIRNAME}/../install.sh"
    [ "$status" -eq 1 ]
}
