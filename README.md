# Turbomod 🚀

**Turbomod** (the official successor to Daergi) is a lightweight, secure bash utility designed for Linux environments to easily moderate Intel Turbo Boost. By interfacing directly with the Intel P-State driver, Turbomod allows gamers, developers, and power users to instantly toggle their CPU's turbo frequencies. 

## Why Turbomod Exists
Daergi was a nice idea, but in order to maintain the security, it required strict lockdown of admin privileges to prevent a local privilege escalation vulnerability. A more elegant path was simply to choose the simple shell script to do this work. The GUI was nice, but it created overhead and problems that really aren't necessary. 

Disabling Turbo Boost is a highly effective strategy for:
- **Stabilizing Framerates**: Preventing sudden frequency spikes and thermal throttling during intense gaming sessions.
- **Controlling Thermals**: Drastically lowering CPU temperatures on laptops or small form-factor builds.
- **Battery Preservation**: Capping power draw when maximum burst performance isn't necessary.
- **No Stuttering in Game**: Essentially, the prevents weird optical glitches in the games due to chaotic Turbo Boost virtual core operations.

---

## 🛠️ Installation

1. Clone or download the repository to your local machine.
2. Ensure the script is executable:
   ```bash
   chmod +x turbomod
   ```
3. (Optional) Move it to your path for global access:
   ```bash
   sudo cp turbomod /usr/local/bin/turbomod
   ```

---

## 🎮 Usage

Turbomod provides three simple commands: `status`, `enable`, and `disable`.

### Check Status
Find out if your Intel processor is currently utilizing Turbo Boost.
*(Does not require `sudo`)*
```bash
turbomod status
# Output: Turbo Boost is currently ON
```

### Disable Turbo Boost
Lock your CPU to its base clock speed. Ideal for preventing thermal throttling during sustained workloads or gaming.
*(Requires administrative privileges)*
```bash
sudo turbomod disable
# Output: Turbo Boost disabled.
```

### Enable Turbo Boost
Restore your CPU's ability to automatically boost above its base clock for peak burst performance.
*(Requires administrative privileges)*
```bash
sudo turbomod enable
# Output: Turbo Boost enabled.
```

---

## 🔍 How it Works
Turbomod interacts directly with the Linux kernel's CPU frequency scaling framework. It specifically targets the `no_turbo` parameter exposed by the Intel P-State driver located at:
`/sys/devices/system/cpu/intel_pstate/no_turbo`

- Writing `1` to this file immediately halts turbo boosting.
- Writing `0` restores normal P-State boosting behavior.

### Security
Turbomod contains strict EUID enforcement. If a user attempts to mutate the state of the processor without administrative privileges, the script will gracefully intercept the execution and instruct the user to elevate their permissions securely.

---

## ⚖️ License
This project is part of the AntiGravity suite. 
*(Nordheim Online Product - Copyright © Chuck Talk)*
