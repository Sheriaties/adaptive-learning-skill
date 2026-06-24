#!/usr/bin/env bash
# adaptive-learning-skill installer
# 用法:
#   bash install.sh                    # 自动检测生态
#   bash install.sh --target=claude    # 强制装到 Claude Code
#   bash install.sh --target=openclaw  # 强制装到 OpenClaw
#   bash install.sh --target=hermes    # 强制装到 Hermes
#   bash install.sh --update           # 已装过的情况下拉最新
#
# 远程一键装:
#   curl -fsSL https://raw.githubusercontent.com/Sheriaties/adaptive-learning-skill/main/install.sh | bash

set -euo pipefail

REPO_URL="https://github.com/Sheriaties/adaptive-learning-skill.git"
SKILL_NAME="adaptive-learning"

# ---------- 解析参数 ----------
TARGET=""
UPDATE=0
for arg in "$@"; do
  case "$arg" in
    --target=*) TARGET="${arg#--target=}" ;;
    --update)   UPDATE=1 ;;
    -h|--help)
      sed -n '2,12p' "$0"
      exit 0
      ;;
  esac
done

# ---------- 自动检测生态 ----------
auto_detect() {
  # 优先级: Hermes > OpenClaw > Claude Code（Hermes 是最新的）
  if [ -d "$HOME/.hermes" ]; then
    echo "hermes"
  elif [ -d "$HOME/.openclaw" ]; then
    echo "openclaw"
  elif [ -d "$HOME/.claude" ]; then
    echo "claude"
  else
    echo ""
  fi
}

if [ -z "$TARGET" ]; then
  TARGET="$(auto_detect)"
  if [ -z "$TARGET" ]; then
    echo "❌ 未检测到任何受支持的 agent 框架（找不到 ~/.claude / ~/.openclaw / ~/.hermes）。"
    echo ""
    echo "请先安装下面任一框架，或者通过 --target 强制指定一个："
    echo "  - Claude Code: https://github.com/anthropics/claude-code"
    echo "  - OpenClaw:    https://github.com/openclaw/openclaw"
    echo "  - Hermes:      https://github.com/NousResearch/hermes-agent"
    exit 1
  fi
  echo "🔍 自动检测到: $TARGET"
fi

# ---------- 计算安装路径 ----------
case "$TARGET" in
  claude)
    SKILLS_DIR="$HOME/.claude/skills"
    INSTALL_PATH="$SKILLS_DIR/$SKILL_NAME"
    ECOSYSTEM_NAME="Claude Code"
    ;;
  openclaw)
    SKILLS_DIR="$HOME/.openclaw/workspace/skills"
    INSTALL_PATH="$SKILLS_DIR/$SKILL_NAME"
    ECOSYSTEM_NAME="OpenClaw"
    ;;
  hermes)
    SKILLS_DIR="$HOME/.hermes/skills"
    INSTALL_PATH="$SKILLS_DIR/$SKILL_NAME"
    ECOSYSTEM_NAME="Hermes Agent"
    ;;
  *)
    echo "❌ 未知 target: $TARGET（应为 claude / openclaw / hermes）"
    exit 1
    ;;
esac

# ---------- 检查 git ----------
if ! command -v git >/dev/null 2>&1; then
  echo "❌ 找不到 git 命令。请先安装 git。"
  exit 1
fi

# ---------- clone 或 pull ----------
mkdir -p "$SKILLS_DIR"

if [ -d "$INSTALL_PATH/.git" ]; then
  echo "📦 已存在 $INSTALL_PATH，拉取最新版本..."
  git -C "$INSTALL_PATH" pull --ff-only
elif [ -e "$INSTALL_PATH" ]; then
  echo "❌ $INSTALL_PATH 存在但不是 git 仓库。请手动检查后重试。"
  exit 1
else
  echo "📦 clone 到 $INSTALL_PATH..."
  git clone --depth 1 "$REPO_URL" "$INSTALL_PATH"
fi

# ---------- Claude Code: 自动注册触发器 ----------
register_claude_trigger() {
  local claude_md="$HOME/.claude/CLAUDE.md"
  local marker="adaptive-learning skill"

  # 已注册则跳过（幂等）
  if [ -f "$claude_md" ] && grep -q "$marker" "$claude_md"; then
    echo "✅ ~/.claude/CLAUDE.md 中已存在触发器，跳过注册"
    return
  fi

  mkdir -p "$HOME/.claude"
  cat >> "$claude_md" <<'EOF'

# adaptive-learning skill
- **adaptive-learning** (`~/.claude/skills/adaptive-learning/SKILL.md`) - 自适应学习工作流，资料搜集→理解验证→Obsidian 知识整合。Trigger: `/adaptive-learning`
When the user types `/adaptive-learning`, invoke the Skill tool with `skill: "adaptive-learning"` before doing anything else.
Also invoke when user expresses learning intent with phrases like: 想深入学习、想搞懂、系统学习、学习...架构、想深度学、从零开始学。
EOF

  echo "✅ 已在 ~/.claude/CLAUDE.md 注册触发器"
}

case "$TARGET" in
  claude)
    register_claude_trigger
    ;;
  openclaw|hermes)
    # OpenClaw/Hermes 自动发现 ~/.openclaw/workspace/skills/ 或 ~/.hermes/skills/，
    # 不需要额外注册。
    :
    ;;
esac

# ---------- 完成提示 ----------
cat <<EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✨ adaptive-learning skill 已装好（$ECOSYSTEM_NAME）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

安装位置: $INSTALL_PATH

下一步：在你的 agent 里直接说「我想学 X」（任意概念），首次触发时
会有 3 个 onboarding 问题（Vault 路径、状态目录、session 尾巴字符），
回答完即可开始学习。**不需要手写任何配置文件。**

如需重装或更新: bash $INSTALL_PATH/install.sh --update
项目主页:       $REPO_URL

EOF
