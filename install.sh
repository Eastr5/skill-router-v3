#!/bin/bash
# Skill Router v3 — One-click installer
# Supports: Trae, Claude Code, Cursor, VSCode+Cline
# Usage:
#   curl -sSL .../install.sh | bash              # Install both
#   curl -sSL .../install.sh | bash -s -- --package v3    # Install v3 only
#   curl -sSL .../install.sh | bash -s -- --package lite  # Install lite only

set -e

REPO_RAW="https://raw.githubusercontent.com/Eastr5/skill-router-v3/main"

# Parse arguments
PACKAGE="both"
while [[ $# -gt 0 ]]; do
  case $1 in
    --package)
      PACKAGE="$2"
      shift 2
      ;;
    --package=*)
      PACKAGE="${1#*=}"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

echo "🧭 Skill Router v3 Installer"
echo "=============================="
echo "📦 Package: $PACKAGE"
echo ""

# Detect platform
if [ -d "$HOME/.trae-cn" ]; then
    PLATFORM="trae"
    GLOBAL_SKILL_DIR="$HOME/.trae-cn/builtin/global/skills"
    PROJECT_SKILL_DIR="./.trae/skills"
elif [ -d "$HOME/.claude" ]; then
    PLATFORM="claude"
    GLOBAL_SKILL_DIR="$HOME/.claude/skills"
    PROJECT_SKILL_DIR="./.claude/skills"
elif [ -d ".cursor" ]; then
    PLATFORM="cursor"
    GLOBAL_SKILL_DIR=".cursor/skills"
    PROJECT_SKILL_DIR="./.cursor/skills"
elif [ -d ".cline" ]; then
    PLATFORM="cline"
    GLOBAL_SKILL_DIR=".cline/skills"
    PROJECT_SKILL_DIR="./.cline/skills"
else
    echo "⚠️  Could not detect platform. Falling back to Trae paths."
    PLATFORM="trae"
    GLOBAL_SKILL_DIR="$HOME/.trae-cn/builtin/global/skills"
    PROJECT_SKILL_DIR="./.trae/skills"
fi

echo "📦 Detected platform: $PLATFORM"
echo "📁 Global skills: $GLOBAL_SKILL_DIR"
echo "📁 Project skills: $PROJECT_SKILL_DIR"
echo ""

# Install v3
install_v3() {
    echo "⬇️  Installing skill-router-v3 (MST full)..."
    mkdir -p "$GLOBAL_SKILL_DIR/skill-router"
    curl -sSL "$REPO_RAW/skills/skill-router/SKILL.md" -o "$GLOBAL_SKILL_DIR/skill-router/SKILL.md"
    echo "   ✅ skill-router-v3 installed"
    
    # Also install companion skills
    for skill in figura tikz-diagrams-guide; do
        echo "⬇️  Installing $skill..."
        mkdir -p "$GLOBAL_SKILL_DIR/$skill"
        curl -sSL "$REPO_RAW/skills/$skill/SKILL.md" -o "$GLOBAL_SKILL_DIR/$skill/SKILL.md"
        echo "   ✅ $skill installed"
    done
    
    # Create state template in project
    mkdir -p "$PROJECT_SKILL_DIR"
    if [ ! -f "$PROJECT_SKILL_DIR/skill-router-state.yaml" ]; then
        curl -sSL "$REPO_RAW/templates/skill-router-state.yaml" -o "$PROJECT_SKILL_DIR/skill-router-state.yaml"
        echo "   ✅ State template created in project"
    fi
}

# Install lite
install_lite() {
    echo "⬇️  Installing skill-router-lite..."
    mkdir -p "$GLOBAL_SKILL_DIR/skill-router-lite"
    curl -sSL "$REPO_RAW/packages/skill-router-lite/SKILL.md" -o "$GLOBAL_SKILL_DIR/skill-router-lite/SKILL.md"
    echo "   ✅ skill-router-lite installed"
}

# Execute installation
case $PACKAGE in
  v3|full)
    install_v3
    ;;
  lite|light)
    install_lite
    ;;
  both|all|*)
    install_v3
    install_lite
    ;;
esac

echo ""
echo "🎉 Installation complete!"
echo ""
echo "⚠️  IMPORTANT: Restart your AI IDE to load the new skills."
echo ""
echo "🚀 Quick start:"
echo "   Just say '我该用啥' or 'which skill should I use' and the router will activate."
echo ""
echo "📚 Documentation:"
echo "   v3 (full):  https://github.com/Eastr5/skill-router-v3#readme"
echo "   lite (fast): https://github.com/Eastr5/skill-router-v3/tree/main/packages/skill-router-lite"
