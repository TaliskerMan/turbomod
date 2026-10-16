title: Turbomod
subtitle: Installation and User Guide
version: 1.1.1
platforms: Linux (Intel CPUs with intel_pstate)
## About Turbomod

Turbomod is a small command-line tool that turns Intel Turbo Boost on or off. With Turbo Boost off, the processor stays at its base clock speed instead of bursting higher, which can help with:

- **Steadier frame rates** in long gaming sessions, without sudden spikes followed by thermal throttling.
- **Cooler running** on laptops and small cases.
- **Longer battery life** when you don't need burst performance.
- **Smoother frame times** under sustained load.

The trade-off: with Turbo Boost off, the processor never runs above its base speed, so peak and single-threaded performance drop and some games and tasks will run slower. Results depend on your processor and cooling, so try it and compare.

Turbomod is the successor to Daergi, a graphical app for the same job. A plain script run with `sudo` does the job with no background helper and no setuid program, so there's nothing extra for an attacker to target.

Turbomod is free, open-source software under the GNU General Public License, version 3 or later (GPLv3+). Source: github.com/TaliskerMan/turbomod.

## Will it work on my computer?

Turbomod works only on **Intel processors using the `intel_pstate` driver**, which most modern Intel systems on Linux use. It doesn't work on AMD processors, or on Intel systems using the `acpi-cpufreq` driver.

Check in a terminal:

```
cat /sys/devices/system/cpu/cpufreq/policy0/scaling_driver
```

If it prints `intel_pstate` (or `intel_cpufreq`, the same driver in passive mode), Turbomod will work. If the file `/sys/devices/system/cpu/intel_pstate/no_turbo` doesn't exist, Turbomod reports that the driver is missing and stops without changing anything.

| | |
|---|---|
| Operating system | Any Linux distribution with `bash` |
| Processor | Intel, `intel_pstate` driver |
| Optional | `systemd` (to keep your choice after a reboot) |

## Installing Turbomod

1. Get the Turbomod source: clone the repository, or on the GitHub release page download **Source code (tar.gz)** and extract it. Open a terminal in that folder. (Don't use the individual files attached to a release for installing: they are flat copies, and `install.sh` needs the `packaging/` folder.)
2. Optionally, check the files against the signed checksums shipped in `Audit/`:

```
gpg --import Audit/pubkey.asc
gpg --verify Audit/checksums.sha512.asc Audit/checksums.sha512
sha512sum -c Audit/checksums.sha512
```

3. Install:

```
sudo ./install.sh
```

This installs:

| File | Location |
|---|---|
| The `turbomod` command | `/usr/local/bin/turbomod` |
| Manual page (`man turbomod`) | `/usr/local/share/man/man1/turbomod.1` |
| Bash tab completion | `/usr/share/bash-completion/completions/turbomod` |
| Boot service (installed but **off**) | `/etc/systemd/system/turbomod-restore.service` |

To install somewhere other than `/usr/local`, set `PREFIX`, for example `sudo PREFIX=/usr ./install.sh`. The boot service is set up to run Turbomod from that location. Use the same `PREFIX` when uninstalling.

**Manual install** (just the command): `chmod +x turbomod && sudo cp turbomod /usr/local/bin/`.

### Uninstalling

```
sudo ./install.sh --uninstall
```

This removes the command, man page, completion and boot service. Your saved setting in `/etc/turbomod/` is left in place; delete it with `sudo rm -r /etc/turbomod` if you like.

## Using Turbomod

| Command | What it does | Needs `sudo` |
|---|---|---|
| `turbomod status` | Shows whether Turbo Boost is on or off | No |
| `sudo turbomod disable` | Turns Turbo Boost off (base clock only) | Yes |
| `sudo turbomod enable` | Turns Turbo Boost back on | Yes |
| `sudo turbomod disable --persist` | Turns it off and saves that for the boot service to re-apply | Yes |
| `sudo turbomod enable --persist` | Turns it on and saves that for the boot service to re-apply | Yes |
| `sudo turbomod restore` | Re-applies the saved setting (used at boot) | Yes |
| `turbomod --help` | Usage | No |
| `turbomod --version` | Version | No |

Examples:

```
$ turbomod status
Turbo Boost is currently ON

$ sudo turbomod disable
Turbo Boost disabled.
```

After every change, Turbomod reads the setting back and only reports success if it really changed. If you forget `sudo`, it tells you how to re-run the command. Arguments it doesn't recognise, such as a mistyped `--persist`, are reported as errors instead of being ignored.

## Keeping your choice after a reboot

The Turbo Boost setting resets every time the computer starts. To keep yours:

1. Run the command with `--persist`, for example:

```
sudo turbomod disable --persist
```

   This saves `disable` to `/etc/turbomod/state`. If the boot service isn't enabled yet, Turbomod reminds you that the saved setting won't be applied at boot until you do step 2.

2. Turn on the boot service once:

```
sudo systemctl enable turbomod-restore.service
```

At each boot the service runs `turbomod restore`, which applies the saved setting. It only runs if the `intel_pstate` control and the saved state both exist.

To stop applying it at boot: `sudo systemctl disable turbomod-restore.service`.

## How it works and what it changes

Turbomod writes one value to one Linux kernel setting:

- `1` to `/sys/devices/system/cpu/intel_pstate/no_turbo` turns Turbo Boost **off**;
- `0` turns it **on**.

That's all it changes. It doesn't touch other power settings, governors or frequency limits, and it has no background process. The kernel setting is root-only, which is why changes need `sudo`.

> **Note:** Some laptops' firmware or other power tools (TLP, power-profiles-daemon, thermald) may also manage Turbo Boost and can override Turbomod's setting. If the setting doesn't stick, check those tools.

## Troubleshooting

**"Intel P-State driver not found".** Your system doesn't use `intel_pstate` (for example, an AMD processor or the `acpi-cpufreq` driver). Turbomod can't be used there.

**"Modifying Turbo Boost requires administrative privileges."** Run `enable`, `disable` and `restore` with `sudo`.

**"Error: write was not applied".** Turbomod wrote the setting but the processor didn't accept it, usually because the firmware (BIOS/UEFI) has Turbo Boost turned off or locked. Check your firmware settings. Nothing else was changed.

**"Unknown command" or "unexpected argument".** Check the spelling; `turbomod --help` lists the commands. `--persist` only works with `enable` and `disable`.

**My setting resets after a reboot.** Use `--persist` and enable `turbomod-restore.service` as described above.

**The setting changes back by itself.** Another power-management tool is managing Turbo Boost; see the note above.

## Support and license

Report problems on GitHub (github.com/TaliskerMan/turbomod) or email **chuck@nordheim.online**.

| | |
|---|---|
| Website | nordheim.online |
| Source code | github.com/TaliskerMan/turbomod |
| License | GNU GPL v3 or later (no warranty) |
| Copyright | © 2026 Chuck Talk, Nordheim Online, LLC |
