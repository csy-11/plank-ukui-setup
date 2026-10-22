# plank-ukui-setup

一行命令装好 **Plank Dock**，并把 **UKUI 任务栏**（麒麟/银河麒麟等 UKUI 桌面）设成自动隐藏。

脚本是幂等的：重复运行不会重复安装，已存在的东西会跳过。

## 它做什么

| # | 动作 | 说明 |
|---|---|---|
| 1 | `apt update` + 安装 `plank` | 已装则跳过 |
| 2 | 写 `~/.config/autostart/plank.desktop` | 开机自启 Dock |
| 3 | 启动 Plank | 已在跑则跳过 |
| 4 | 用 `gsettings` 开启 UKUI 面板自动隐藏 | 自动适配 `org.ukui.panel.settings hidepanel` 与 `org.ukui.panel.toplevel auto-hide` 两套键名 |
| 5 | 设置隐藏延迟 300ms | 避免鼠标擦边误触 |
| 6 | 重启 `ukui-panel` 生效 | 让配置立刻加载 |
| 7 | 打开 Plank 首选项 | 方便马上调主题/图标 |

## 前提

- Ubuntu / 麒麟等带 **UKUI 桌面**、支持 `apt` 的发行版
- 图形会话里运行（脚本会检查 `DISPLAY` / `WAYLAND_DISPLAY`，SSH 纯终端里会拒绝）
- **不要用 sudo 或 root 运行**（脚本会主动拒绝）—— 它内部需要时自己调 `sudo`
- 需要能输入 `sudo` 密码的普通用户

## 用法

### 直连

```bash
curl -fsSL https://raw.githubusercontent.com/csy-11/plank-ukui-setup/main/setup-plank-ukui-autohide.sh | bash
```

### 走代理（国内直连 GitHub 慢/不通时）

```bash
curl -x http://127.0.0.1:38457 -fsSL https://raw.githubusercontent.com/csy-11/plank-ukui-setup/main/setup-plank-ukui-autohide.sh | bash
```

> `-x` 后面换成你自己的 HTTP 代理地址。这里给的 `38457` 是 [FastGithub](https://github.com/dotnetcore/FastGithub) 的默认监听端口。

### 先看一眼再跑（推荐）

```bash
curl -x http://127.0.0.1:38457 -fsSL https://raw.githubusercontent.com/csy-11/plank-ukui-setup/main/setup-plank-ukui-autohide.sh -o setup.sh
less setup.sh        # 看完确认
bash setup.sh
```

### 两个坑

1. **别用 `sudo bash`** —— 脚本检测到 `uid=0` 会直接退出。
2. **别在纯 SSH 会话里跑** —— 没有 `DISPLAY` 会被拒。要么在桌面终端里跑，要么 `ssh -X` 转发。

## 手动兜底

如果 `gsettings` 那步失败（不同 UKUI 版本键名不一致），可以手动开：

> 开始菜单 → 控制中心 → 个性化 → 任务栏 → 勾选「自动隐藏任务栏」

## License

MIT
