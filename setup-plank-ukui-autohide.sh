#!/bin/bash
set -e

if [ "$(id -u)" -eq 0 ]; then
  echo "请不要用 sudo/root 运行此脚本。"
  exit 1
fi

if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
  echo "当前没有图形会话，请在桌面终端里运行。"
  exit 1
fi

echo "==> 更新软件源索引..."
sudo apt update

# ==========================================
# 1. 安装并配置 Plank
# ==========================================
echo "==> 安装 Plank..."
if ! dpkg -s plank >/dev/null 2>&1; then
  sudo apt install -y plank
fi

echo "==> 配置 Plank 开机自启..."
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
cat > "$AUTOSTART_DIR/plank.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Plank
Comment=Plank Dock
Exec=plank
Icon=plank
Terminal=false
Categories=Utility;
X-GNOME-Autostart-enabled=true
EOF

echo "==> 启动 Plank..."
if ! pgrep -x plank >/dev/null 2>&1; then
  nohup plank >/dev/null 2>&1 &
  sleep 2
fi

# ==========================================
# 2. 开启 UKUI 任务栏自动隐藏（版本自适应）
# ==========================================
echo "==> 检测 UKUI 面板版本并配置自动隐藏..."

PANEL_VER=$(dpkg-query -W -f='${Version}' ukui-panel 2>/dev/null || echo "unknown")
echo "    检测到 ukui-panel 版本: $PANEL_VER"

# 尝试新版配置键（V10 SP1 及更高版本常见）
if gsettings set org.ukui.panel.settings hidepanel true 2>/dev/null; then
  echo "    已使用 org.ukui.panel.settings 键启用自动隐藏。"
else
  # 回退到通用 toplevel 键
  gsettings set org.ukui.panel.toplevel auto-hide true 2>/dev/null && \
  echo "    已使用 org.ukui.panel.toplevel 键启用自动隐藏。" || \
  echo "    自动隐藏命令执行失败，可稍后在图形界面手动开启。"
fi

# 设置隐藏延迟（300 毫秒，避免误触）
gsettings set org.ukui.panel.toplevel hide-delay 300 2>/dev/null && \
echo "    已设置隐藏延迟为 300ms。" || true

# 重启面板使配置生效
echo "==> 重启 UKUI 面板..."
killall ukui-panel 2>/dev/null || true
sleep 1

# ==========================================
# 3. 打开 Plank 首选项
# ==========================================
echo "==> 打开 Plank 首选项..."
plank --preferences >/dev/null 2>&1 &

echo ""
echo "完成。"
echo "- Plank 已安装并启动。"
echo "- 任务栏自动隐藏已尝试启用（可能需要注销或重启才能稳定生效）。"
echo "- 如果任务栏没有自动隐藏，请进入：开始菜单 → 控制中心 → 个性化 → 任务栏，手动开启“自动隐藏任务栏”。"