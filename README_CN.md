# RemoteGPU-Bar-Multi

这是一个基于原始 `RemoteGPU-Bar` 改出来的 fork，核心目标是支持在 macOS 菜单栏里同时查看多台服务器的 GPU 空闲情况。

这个仓库保留了原来的单机脚本，同时新增了多机版本脚本，适合已经通过 SSH 管理多台 GPU 服务器的使用场景。

![icon](icon.png)

[English README](README.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![Requires](https://img.shields.io/badge/requires-SwiftBar-orange)

## 这个 Fork 做了什么

- 原仓库主要是单服务器监控。
- 当前仓库新增了 `gpu_monitor_multi.1m.sh`，用于多服务器聚合监控。
- 多机版脚本依赖你本机 `~/.ssh/config` 里的 Host 别名。
- 原来的 `gpu_monitor.1m.sh` 仍然保留，方便单机使用。

## 功能说明

- 不需要在服务器端部署额外服务。
- 菜单栏顶部显示所有在线服务器的 GPU 总空闲数，例如 `GPU: 5/16 Free`。
- 下拉菜单按服务器分组展示每张卡的状态。
- 如果某台服务器离线，会直接显示为 `Offline`。
- 刷新频率由 SwiftBar 脚本文件名控制。

## 预览

![Screenshot](screenshot.png)

## 仓库文件说明

- `gpu_monitor_multi.1m.sh`：多服务器版本，推荐使用。
- `gpu_monitor.1m.sh`：原始单服务器版本。

## 前置要求

1. 你的电脑是 macOS。
2. 已安装 [SwiftBar](https://github.com/swiftbar/SwiftBar/releases)。
3. 你的 Mac 能通过 SSH 免密连接到目标服务器。
4. 目标服务器上可以直接执行 `nvidia-smi`。

建议先手动验证 SSH：

```bash
ssh alias1
ssh alias2
```

如果这两个命令都能直接登录，不需要输入密码，多机脚本基本就可以正常工作。

## 多服务器使用流程

### 1. 在本机配置 SSH 别名

编辑 `~/.ssh/config`，为每台服务器配置一个 Host：

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

这里的 `alias1`、`alias2` 就是后面脚本里要填写的名字。

### 2. 安装 SwiftBar 插件

把 `gpu_monitor_multi.1m.sh` 复制到 SwiftBar 的插件目录中。

如果你想调整刷新频率，可以直接改文件名：

- `gpu_monitor_multi.1m.sh`：每 1 分钟刷新
- `gpu_monitor_multi.5m.sh`：每 5 分钟刷新
- `gpu_monitor_multi.30s.sh`：每 30 秒刷新

然后赋予执行权限：

```bash
chmod +x ~/Documents/SwiftBar/gpu_monitor_multi.1m.sh
```

如果你的 SwiftBar 插件目录不是这个路径，请替换成实际路径。

### 3. 修改脚本中的 Host 列表

打开 `gpu_monitor_multi.1m.sh`，修改顶部的 `HOSTS`：

```bash
HOSTS=(
  "alias1"
  "alias2"
  "alias3"
)
```

每一项都必须和 `~/.ssh/config` 里的 `Host` 名称完全一致。

### 4. 刷新 SwiftBar

保存脚本后：

1. SwiftBar 通常会自动刷新。
2. 如果没有刷新，可以点击菜单栏图标，选择 `Refresh All`。

## 脚本当前的判定逻辑

多机脚本会对每台服务器执行：

```bash
nvidia-smi --query-gpu=index,name,utilization.gpu,memory.free,memory.total --format=csv,noheader,nounits
```

当前把 GPU 视为“空闲”的条件是：

- 利用率小于 `5%`
- 空闲显存大于 `4000 MB`

顶部栏展示的是所有在线服务器聚合后的空闲数和总数。

## 单服务器脚本怎么用

如果你只想监控一台服务器，也可以继续使用 `gpu_monitor.1m.sh`。

它和多机版的配置方式不同：

- 单机版用的是 `HOST="user@your_server_ip"`
- 单机版需要手动指定 `ID_FILE="/path/to/private_key"`

所以如果你的需求是多台机器统一看，优先用 `gpu_monitor_multi.1m.sh`。

## 常见问题

### 顶部显示 `GPU: Offline`

通常意味着下面几种情况之一：

- `~/.ssh/config` 里的别名没有配好
- SSH 免密登录没有配通
- 服务器当前无法连接
- 远端没有 `nvidia-smi`

建议先手动执行：

```bash
ssh alias1
```

确认 SSH 本身没有问题。

### 某台机器在下拉菜单里显示 `Offline`

说明脚本没有成功从这台机器取到 GPU 信息。优先检查：

- Host 别名是否写对
- 网络是否可达
- 该机器是否装好了 NVIDIA 驱动
- `nvidia-smi` 是否能正常执行

### 如何修改刷新频率

直接改脚本文件名即可。SwiftBar 是通过文件名里的时间后缀识别刷新频率的，不是通过脚本内容识别。

### 能不能用于 Slurm 集群

当前脚本是按照直接执行 `nvidia-smi` 的模式写的，更适合普通 GPU 服务器，或者可以直接在登录节点访问 GPU 信息的环境。

如果你的集群必须通过 `srun`、`sinfo`、`squeue` 才能拿到资源状态，那就需要你自己再改脚本命令逻辑。

## 致谢

- 原始项目：`ZeyuuuChen/RemoteGPU-Bar`
- 当前仓库是在原项目基础上增加多服务器支持的 fork

## License

MIT License
