# Podman TUI for OpenWrt

Podman Terminal UI是一个用于管理Podman容器的终端用户界面工具，现已移植到OpenWrt。

## 功能特性

- 🖥️ 直观的终端用户界面
- 🐳 完整的容器管理功能
- 📊 实时容器状态监控
- 🌐 支持远程Podman连接（通过SSH）
- 🎨 支持256色终端显示
- ⚡ 轻量级，适合嵌入式环境

## 安装要求

- OpenWrt 24.10或更高版本
- 已安装podman包
- 至少64MB可用内存
- 支持256色的终端

## 安装步骤

1. 编译安装包：
```bash
make package/Applications/Zag/podman-tui/compile V=s
```

2. 安装到设备：
```bash
opkg install podman-tui_*.ipk
```

## 配置说明

### UCI配置文件

配置文件位于 `/etc/config/podman-tui`，包含以下选项：

```
config podman-tui 'config'
    option enabled '1'                    # 启用服务
    option local_socket '/run/podman/podman.sock'  # 本地socket路径
    option config_dir '/etc/podman-tui'    # 配置目录
    option log_level 'info'               # 日志级别
    option color_mode '256'               # 颜色模式
```

> **注意**：在配置中，本地socket路径可以直接使用文件路径格式（如 `/run/podman/podman.sock`），系统会自动添加 `unix://` 前缀。这样设计更符合OpenWrt用户的使用习惯。

### 连接配置

可以配置多个连接：

```
# 本地连接
config connection 'localhost'
    option uri '/run/podman/podman.sock'  # 直接使用路径，系统自动添加unix://前缀
    option enabled '1'
    option default '1'

# 远程连接示例
config connection 'remote_server'
    option uri 'ssh://user@remote-host:22/run/user/1000/podman/podman.sock'  # SSH连接保持原样
    option identity '/root/.ssh/id_rsa'
    option enabled '1'
    option default '0'
```

**URI格式说明**：
- **本地连接**：直接输入socket文件路径，如 `/run/podman/podman.sock`
- **远程连接**：使用完整的SSH URI，如 `ssh://user@host:port/path/to/socket`
- 系统会自动为本地连接添加 `unix://` 前缀，无需手动添加

## 使用方法

### 配置管理
```bash
# 启用配置管理服务（用于生成配置文件）
/etc/init.d/podman-tui start
/etc/init.d/podman-tui enable
```

### 交互式使用
**重要**：Podman TUI是交互式终端程序，不能作为后台服务运行。可以通过以下方式访问：

#### 1. 本地终端访问（推荐）
如果您已经登录到OpenWrt系统（例如通过LuCI、ttyd或SSH），可以直接运行：

```bash
# 在OpenWrt本地终端中直接运行（无需-t参数）
podman-tui
```

**适用场景**：
- OpenWrt的ttyd Web终端
- 已建立的SSH会话中
- 本地串口终端
- 其他本地终端环境

**技术原理**：本地终端已经具备TTY环境，无需额外分配伪终端。

#### 2. SSH远程执行
从外部计算机直接执行命令：

```bash
# 通过SSH远程执行Podman TUI（必需-t参数）
ssh root@router_ip -t podman-tui
```

**参数说明**：
- `-t`：必需参数，强制SSH分配伪终端（pseudo-terminal）
- 没有`-t`参数：TUI程序无法正常显示交互式界面
- **区别**：这是直接执行命令，不是先登录再运行

### 启动服务
```bash
# 启用并启动服务
/etc/init.d/podman-tui enable
/etc/init.d/podman-tui start

# 直接运行（前台）
podman-tui
```

### 前置条件

1. **确保Podman socket服务运行**：
```bash
# 启动podman socket
/etc/init.d/podman start

# 检查socket状态
ls -la /run/podman/podman.sock
```

2. **SSH远程连接**（如果使用远程模式）：
```bash
# 生成SSH密钥
ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa

# 复制公钥到远程主机
ssh-copy-id user@remote-host
```

### 快捷键

- `Tab` / `Shift+Tab` - 切换面板
- `Enter` - 选择/执行
- `Esc` - 返回/取消
- `Ctrl+C` - 退出
- `F1` - 帮助
- `F10` - 退出

## 故障排除

### 常见问题

1. **连接失败**
   - 检查podman socket是否运行
   - 验证socket路径是否正确
   - 确认权限设置

2. **远程连接问题**
   - 验证SSH密钥配置
   - 检查网络连通性
   - 确认远程podman服务状态

3. **显示问题**
   - 确保终端支持256色
   - 调整终端窗口大小
   - 检查TERM环境变量

### 日志查看
```bash
# 查看服务日志
logread | grep podman-tui

# 查看系统日志
dmesg | grep podman
```

## 技术规格

- **语言**: Go 1.23.3+
- **架构**: 支持所有OpenWrt支持的架构
- **依赖**: podman, golang运行时
- **资源占用**: ~10MB内存，~5MB存储

## 开发信息

- **上游项目**: https://github.com/containers/podman-tui
- **版本**: 1.7.0
- **许可证**: Apache 2.0
- **维护者**: Zag

## 更新日志

### v1.7.0 (2025-07-22)
- 首次移植到OpenWrt
- 支持本地和远程连接
- 集成OpenWrt配置系统
- 添加init.d服务脚本
