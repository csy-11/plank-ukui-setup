# 麒麟 / UOS 桌面与办公工具集
# Kylin / UOS desktop & office toolkit

国产 Linux 桌面（统信 UOS、银河麒麟等）上常用的一键脚本合集，全部是**单文件、可 curl 直接运行**的 shell 脚本。

| 工具 | 目录 | 解决什么问题 |
|---|---|---|
| **Plank Dock + UKUI 任务栏自动隐藏** | 仓库根目录 `setup-plank-ukui-autohide.sh` | 一行命令装好 Plank Dock，并把 UKUI 任务栏设为自动隐藏 |
| **WPS 演示文稿错位检测与修复** | [`wps-pptx-repair/`](wps-pptx-repair/) | Windows 做的 PPTX 拷到 UOS/麒麟 用 WPS 打开后文字跑位、溢出色块、行距变大、符号变字母 |

---

# 一、Plank Dock + UKUI 任务栏自动隐藏

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

---

# 二、WPS 演示文稿错位检测与修复（wps-pptx-repair）

**场景**：Windows 上做的 `.pptx`，拷到统信 UOS / 麒麟上用 **WPS 演示**打开后文字错位——标题下移、正文溢出色块、行距变大、断行奇怪、表格被撑开、✓ → ★ 变成字母/方框。

**原因**：不是文件坏了，而是**字体缺失**（宋体/微软雅黑/Calibri 在 Linux 上通常没有，WPS 换字体后字宽和行高全变）、**行高度量差异**（宋体约 1.2em，思源约 1.44em）、**中英文断行规则**、**PowerPoint 自动缩放残留**、**内边距/单元格边距默认值不同**等。

**工具**：交互式 shell 脚本，单文件自包含，只用系统自带 python3（无需 pip 装任何包，离线可用）。检测并修复 20 类隐患，默认只做安全修复，改完自动备份 + 出报告，可随时回滚。

### 用法

```bash
# 交互式向导（推荐）
curl -x http://127.0.0.1:38457 -fsSL \
  https://raw.githubusercontent.com/csy-11/plank-ukui-setup/main/wps-pptx-repair/wps_pptx_repair.sh \
  -o /tmp/wps_pptx_repair.sh && chmod +x /tmp/wps_pptx_repair.sh && /tmp/wps_pptx_repair.sh

# 只体检（不改文件）
curl -x http://127.0.0.1:38457 -fsSL \
  https://raw.githubusercontent.com/csy-11/plank-ukui-setup/main/wps-pptx-repair/wps_pptx_repair.sh \
  | bash -s -- /path/to/课件.pptx --scan

# 直接修复
curl -x http://127.0.0.1:38457 -fsSL \
  https://raw.githubusercontent.com/csy-11/plank-ukui-setup/main/wps-pptx-repair/wps_pptx_repair.sh \
  | bash -s -- /path/to/课件.pptx --fix -y
```

> 交互模式必须**先下载再运行**（`| bash` 会拿不到终端输入）；非交互的 `--scan` / `--fix` 才可以直接管道。

### 能力速览

- **字体**：缺失字体替换（宋体→思源宋体、微软雅黑→思源黑体、Calibri→Carlito…）、中文字体未显式指定 `<a:ea>`、主题字体缺 Hans 映射、符号字体（Wingdings/Webdings）缺失提示、目标字体缺字形；
- **版式**：文本框内边距缺省、PowerPoint 自动缩放残留（`fontScale`/`lnSpcReduction`）、`spAutoFit` 高度重算、不换行文本框宽度不足、表格单元格边距/行高、中文 lang 标记、行距固定为磅值；
- **提示**：手动换行、组合非等比缩放、竖排/文字变形、旧版 `.ppt` 二进制格式、非标准页面比例；
- **三种字体策略**：改写文件内字体名（可独立分发）/ fontconfig 系统别名（不改文件）/ 导入 Windows 字体（最保真）；
- **安全**：默认不覆盖原文件（输出 `xxx.fixed.pptx`），原文件自动备份，生成 `.report.md` / `.report.json`。

详细说明见 **[wps-pptx-repair/README.md](wps-pptx-repair/README.md)**（成因分析、20 条规则表、三种字体策略、命令行参数、回滚、FAQ）。

---

## License

MIT
