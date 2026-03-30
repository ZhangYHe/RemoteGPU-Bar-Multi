# RemoteGPU-Bar-Multi

Multi-server macOS menu bar GPU monitor built on top of the original `RemoteGPU-Bar`.

This fork keeps the original single-server script and adds a multi-server version for users who need to watch several SSH targets from one SwiftBar item.

![icon](icon.png)

[中文说明](README_CN.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![Requires](https://img.shields.io/badge/requires-SwiftBar-orange)

## What Changed In This Fork

- Original upstream mainly targets a single remote server.
- This fork adds `gpu_monitor_multi.1m.sh` for monitoring multiple servers in one menu.
- The multi-server script uses SSH config aliases from your local `~/.ssh/config`.
- The original `gpu_monitor.1m.sh` is still kept for single-server usage.

## Features

- No server-side deployment. The remote host only needs `ssh` access and `nvidia-smi`.
- Aggregated top bar summary such as `GPU: 5/16 Free`.
- Per-host dropdown grouped by server.
- Offline hosts are shown directly in the menu.
- Refresh interval is controlled by the script filename, as required by SwiftBar.

## Screenshot

![Screenshot](screenshot.png)

## Files

- `gpu_monitor_multi.1m.sh`: recommended entry for multi-server monitoring.
- `gpu_monitor.1m.sh`: original single-server version.

## Prerequisites

1. macOS.
2. [SwiftBar](https://github.com/swiftbar/SwiftBar/releases) installed.
3. Passwordless SSH access from your Mac to each target server.
4. `nvidia-smi` available on the target servers.

Test your SSH setup first:

```bash
ssh alias1
ssh alias2
```

If those commands connect without asking for a password, the multi-server script is ready to use.

## Multi-Server Setup

### 1. Configure SSH aliases

Add each server to your local `~/.ssh/config`:

```sshconfig
Host alias1
    HostName your.server.one
    User your_username
    IdentityFile ~/.ssh/id_ed25519

Host alias2
    HostName your.server.two
    User your_username
    IdentityFile ~/.ssh/id_ed25519
```

The names after `Host` are the aliases used by the script.

### 2. Install the SwiftBar plugin

Copy `gpu_monitor_multi.1m.sh` into the SwiftBar plugin folder.

If you want a different refresh interval, rename the file before or after copying it:

- `gpu_monitor_multi.1m.sh`: refresh every 1 minute
- `gpu_monitor_multi.5m.sh`: refresh every 5 minutes
- `gpu_monitor_multi.30s.sh`: refresh every 30 seconds

Then grant execution permission:

```bash
chmod +x ~/Documents/SwiftBar/gpu_monitor_multi.1m.sh
```

Use your real SwiftBar plugin path if it differs.

### 3. Edit the host list in the script

Open `gpu_monitor_multi.1m.sh` and update the `HOSTS` array:

```bash
HOSTS=(
  "alias1"
  "alias2"
  "alias3"
)
```

Each entry must match a `Host` alias in `~/.ssh/config`.

### 4. Refresh SwiftBar

After saving the script:

1. SwiftBar usually reloads automatically.
2. If not, click the SwiftBar item and use `Refresh All`.

## How It Works

For each host in `HOSTS`, the script runs:

```bash
nvidia-smi --query-gpu=index,name,utilization.gpu,memory.free,memory.total --format=csv,noheader,nounits
```

The script currently treats a GPU as "free" when:

- GPU utilization is below `5%`
- Free memory is above `4000 MB`

The top bar shows the global free/total count across all reachable servers.

## Single-Server Usage

If you only need one server, you can still use `gpu_monitor.1m.sh`.

That script is configured differently:

- it uses a single `HOST="user@server"` value
- it uses an explicit `ID_FILE=...` path

So for most multi-server users, `gpu_monitor_multi.1m.sh` is the correct choice.

## FAQ

### Top bar shows `GPU: Offline`

At least one of the following is wrong:

- the SSH alias is missing or misspelled
- SSH key-based login is not working
- the host is unreachable
- `nvidia-smi` is unavailable on that server

Try connecting manually first:

```bash
ssh alias1
```

### A host appears as `Offline` in the dropdown

The multi-server script skips hosts it cannot query. Check the alias, network connectivity, and remote NVIDIA driver environment.

### How do I change the refresh interval?

Rename the script file. SwiftBar reads refresh frequency from the filename, not from script contents.

### Can I use this with Slurm?

The included scripts are written around `nvidia-smi` on login or GPU nodes. If your cluster requires `srun`, `squeue`, or `sinfo`, you will need to adapt the command logic in the script.

## Credit

- Original project: `ZeyuuuChen/RemoteGPU-Bar`
- This repository is a fork focused on multi-server monitoring

## License

MIT License
