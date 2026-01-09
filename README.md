# RemoteGPU-Bar 🟢

> 一个极其轻量、无需服务器端部署的 macOS 菜单栏小组件，用于通过 SSH 监控远程服务器的 NVIDIA GPU 状态。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![Requires](https://img.shields.io/badge/requires-SwiftBar-orange)

**RemoteGPU-Bar** 是一个基于 Shell 脚本的 [SwiftBar](https://github.com/swiftbar/SwiftBar) 插件。它通过 SSH 连接到你的 Linux 服务器，运行 `nvidia-smi` 命令，并将结果解析为美观、直观的 macOS 菜单栏信息。

**特点：**
* 🚀 **零依赖**：服务器端无需安装 Python、Node.js 或任何 Web 服务。只要有 SSH 和 `nvidia-smi` 即可。
* 👀 **一目了然**：菜单栏常驻显示空闲 GPU 数量（例如 `GPU: 2/4 Free`）。
* 📊 **详细数据**：点击下拉展示每张卡的名称、显存占用和利用率。
* 🎨 **智能着色**：空闲显卡显示绿色 🟢，忙碌显卡显示红色 🔴。
* 🔤 **完美对齐**：使用等宽字体 (Menlo)，数字显示整齐治愈。
* 🖥️ **快捷终端**：一键打开 SSH 终端连接到服务器。

---

## 📸 预览截图

![Screenshot](screenshot.png)
*(请替换为你自己的截图)*

---

## 🛠 前置要求

在使用此插件之前，请确保你满足以下条件：

1.  **macOS**: 你的电脑是 Mac。
2.  **SwiftBar**: 已安装 [SwiftBar](https://github.com/swiftbar/SwiftBar/releases) (一个免费开源的菜单栏管理工具)。
3.  **SSH 免密登录**: 你的 Mac 必须配置了 SSH 密钥对，并能**免密码**登录到目标服务器。
    * *测试方法：在终端输入 `ssh user@your_server_ip`，如果不需要输入密码直接登录成功，即满足要求。*

---

## 📥 安装步骤

1.  **下载脚本**：
    将本仓库中的 `gpu_monitor.1m.sh` 文件下载到你的本地电脑。
    *(注意文件名中的 `.1m.` 代表每 1 分钟刷新一次，你可以按需修改)*

2.  **放入插件目录**：
    打开 SwiftBar，点击菜单栏图标 -> `Open Plugin Folder...`，将下载的 `.sh` 文件拖入该目录。

3.  **赋予执行权限**：
    打开终端，运行以下命令（替换为你实际的插件目录路径）：
    ```bash
    chmod +x ~/Documents/SwiftBar/gpu_monitor.1m.sh
    ```

---

## ⚙️ 配置方法 (重要!)

你需要修改脚本文件以匹配你的服务器信息。

使用文本编辑器（推荐 VSCode, Sublime Text 或终端 nano，**不要用自带的文本编辑**）打开 `gpu_monitor.1m.sh`。

修改脚本顶部的配置区域：

```bash
# ================= 配置区域 =================
# 1. 修改为你的服务器 SSH 用户名和 IP 地址
HOST="user@your_server_ip"

# 2. 修改为你 Mac 本地的 SSH 私钥绝对路径
# 通常是 ~/.ssh/id_rsa 或 ~/.ssh/id_ed25519
ID_FILE="/Users/你的用户名/.ssh/id_rsa"
# ===========================================
