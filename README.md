# Turbomod 🚀

**Turbomod** (the successor to Daergi) is a lightweight bash utility for Linux that moderates Intel Turbo Boost. By writing to the Intel P-State driver's `no_turbo` control, Turbomod lets you instantly toggle your CPU's turbo frequencies from the command line.

> **Supported hardware:** Turbomod works only on Intel CPUs using the `intel_pstate` scaling driver. AMD processors and Intel systems running the `acpi-cpufreq` driver are **not** supported — on those systems Turbomod reports that the driver is missing and exits.

## Why Turbomod Exists

Daergi was a GUI app for the same job. Keeping it safe meant locking down its privileged helper to avoid a local privilege escalation (LPE) surface. A plain shell script run under `sudo` reaches the same result with far less moving machinery — no setuid binary and no polkit helper to secure — so Turbomod replaced the GUI. The reduced attack surface, not the loss of the GUI, is the point.

Disabling Turbo Boost can help with:

- **Stabilizing framerates** — avoiding sudden frequency spikes and thermal throttling during long gaming sessions.
- **Controlling thermals** — lowering CPU temperatures on laptops and small-form-factor builds.
- **Battery preservation** — capping power draw when burst performance isn't needed.
- **Smoother frametimes** — reducing stutter caused by aggressive turbo ramping under sustained load.

---

## 🛠️ Installation

### Quick install (recommended)

```bash
sudo ./install.sh
```

This installs `turbomod` to `/usr/local/bin`, a man page, bash completion, and an optional (disabled) systemd unit for boot persistence. Remove everything with `sudo ./install.sh --uninstall`.

### Manual install

```bash
chmod +x turbomod
sudo cp turbomod /usr/local/bin/turbomod
```

---

## 🎮 Usage

Turbomod provides three everyday commands — `status`, `enable`, `disable` — plus `restore` for boot persistence.

### Check status
*(Does not require `sudo`)*
```bash
turbomod status
# Output: Turbo Boost is currently ON
```

### Disable Turbo Boost
Lock the CPU to its base clock. Useful for preventing thermal throttling during sustained workloads or gaming.
*(Requires `sudo`)*
```bash
sudo turbomod disable
# Output: Turbo Boost disabled.
```

### Enable Turbo Boost
Restore the CPU's ability to boost above base clock.
*(Requires `sudo`)*
```bash
sudo turbomod enable
# Output: Turbo Boost enabled.
```

After each change, Turbomod reads `no_turbo` back and confirms the new value actually took effect before reporting success.

### Persist across reboots
sysfs settings are runtime-only and reset on boot. Add `--persist` to remember your choice, then enable the systemd unit:
```bash
sudo turbomod disable --persist
sudo systemctl enable turbomod-restore.service
```
The saved state lives in `/etc/turbomod/state` and is re-applied at every boot by `turbomod restore`.

---

## 🔍 How It Works

Turbomod targets the `no_turbo` parameter exposed by the Intel P-State driver at:

`/sys/devices/system/cpu/intel_pstate/no_turbo`

- Writing `1` disables turbo boosting.
- Writing `0` restores normal P-State boosting.

### Security

Modifying Turbo Boost requires writing to sysfs, which is root-only. Turbomod checks `EUID` before any write and, if you're not root, prints how to re-run under `sudo` rather than failing obscurely. The more important security property is architectural: by being a plain `sudo`-invoked script, Turbomod has no setuid binary and no privileged background helper — and therefore no local privilege escalation surface of the kind a GUI helper would introduce.

---

## ⚖️ License

This project is part of the AntiGravity suite.
*(Nordheim Online Product — Copyright © Chuck Talk)*
