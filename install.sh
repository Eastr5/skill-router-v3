#!/bin/bash
# Skill Router v3 — One-click installer
# Supports: Trae, Claude Code, Cursor, VSCode+Cline

set -e

REPO_RAW="https://raw.githubusercontent.com/your-username/skill-router-v3/main"
SKILLS=("skill-router" "figura" "tikz-diagrams-guide")

echo "🧭 Skill Router v3 Installer"
echo "=============================="

# Detect platform
if [ -d "$HOME/.trae-cn" ]; then
    PLATFORM="trae"
    SKILL_DIR="$HOME/.trae-cn/builtin/global/skills"
elif [ -d "$HOME/.claude" ]; then
    PLATFORM="claude"
    SKILL_DIR="$HOME/.claude/skills"
elif [ -d ".cursor" ]; then
    PLATFORM="cursor"
    SKILL_DIR=".cursor/skills"
elif [ -d ".cline" ]; then
    PLATFORM="cline"
    SKILL_DIR=".cline/skills"
else
    echo "⚠️  Could not detect platform. Falling back to current directory: ./.trae/skills"
    PLATFORM="unknown"
    SKILL_DIR="./.trae/skills"
fi

echo "📦 Detected platform: $PLATFORM"
echo "📁 Installing to: $SKILL_DIR"
echo ""

# Install each skill
for skill in "${SKILLS[@]}"; do
    echo "⬇️  Installing $skill..."
    mkdir -p "$SKILL_DIR/$skill"
    curl -sSL "$REPO_RAW/skills/$skill/SKILL.md" -o "$SKILL_DIR/$skill/SKILL.md"
    echo "   ✅ $skill installed"
done

echo ""
echo "🎉 Installation complete!"
echo ""
echo "⚠️  IMPORTANT: Restart your AI IDE to load the new skills."
echo ""
echo "🚀 Quick start:"
echo "   Just say '我该用啥' or 'which skill should I use' and the router will activate."
