#!/usr/bin/env bash
# =============================================================================
# Nosclaw Dev Environment Setup
# Supports: macOS, Linux
# Usage: bash setup.sh
# =============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log()     { echo -e "${GREEN}✓${NC} $1"; }
info()    { echo -e "${YELLOW}→${NC} $1"; }
fail()    { echo -e "${RED}✗${NC} $1"; exit 1; }
section() { echo -e "\n${BLUE}▶${NC} $1"; }

# Detect OS
OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *)      fail "Unsupported OS: $OS" ;;
esac

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║   Nosclaw Dev Environment Setup      ║"
echo "  ╚══════════════════════════════════════╝"
echo "  Platform: $PLATFORM"
echo ""

# =============================================================================
# 1. Check prerequisites
# =============================================================================
section "Checking prerequisites"

command -v git >/dev/null 2>&1 || fail "git not found. Install git first."
command -v curl >/dev/null 2>&1 || fail "curl not found. Install curl first."

# Node.js check
if ! command -v node >/dev/null 2>&1; then
  fail "Node.js not found. Install from https://nodejs.org (v18+)"
fi

NODE_VERSION=$(node -e "process.stdout.write(process.versions.node)")
NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
if [ "$NODE_MAJOR" -lt 18 ]; then
  fail "Node.js $NODE_VERSION is too old. Need v18+. Install from https://nodejs.org"
fi

# npm check
command -v npm >/dev/null 2>&1 || fail "npm not found. Install Node.js from https://nodejs.org"

log "Prerequisites OK (Node.js $NODE_VERSION)"

# =============================================================================
# 2. Install skillshare
# =============================================================================
section "Installing skillshare"

if command -v skillshare >/dev/null 2>&1; then
  log "skillshare already installed ($(skillshare --version))"
else
  if [ "$PLATFORM" = "macos" ] && command -v brew >/dev/null 2>&1; then
    # macOS with Homebrew — preferred
    brew install skillshare
  else
    # macOS without Homebrew, or Linux — use official install script
    curl -fsSL https://raw.githubusercontent.com/runkids/skillshare/main/install.sh | sh
    # Ensure it's in PATH for this session
    export PATH="$PATH:/usr/local/bin"
  fi

  command -v skillshare >/dev/null 2>&1 || fail "skillshare install failed — try manually: https://github.com/runkids/skillshare"
  log "skillshare installed ($(skillshare --version))"
fi

# =============================================================================
# 3. Install GSD (pi)
# =============================================================================
section "Installing GSD (pi)"

if npm list -g gsd-pi >/dev/null 2>&1; then
  log "GSD already installed"
else
  # Use --prefix to avoid permission issues on Linux
  npm install -g gsd-pi 2>&1 || {
    info "Retrying with sudo (Linux may need this for global npm installs)..."
    sudo npm install -g gsd-pi
  }
  log "GSD installed"
fi

# =============================================================================
# 4. Set up GSD standards + detect-stack script
# =============================================================================
section "Setting up GSD standards"

mkdir -p "$HOME_DIR/.gsd/standards"
cp -f "$REPO_DIR/gsd/standards/"* "$HOME_DIR/.gsd/standards/"
log "Standards → ~/.gsd/standards/"

# Install stack detection script
cp -f "$REPO_DIR/scripts/detect-stack.sh" "$HOME_DIR/.gsd/detect-stack.sh"
chmod +x "$HOME_DIR/.gsd/detect-stack.sh"
log "Stack detector → ~/.gsd/detect-stack.sh"

# =============================================================================
# 5. Set up GSD preferences
# =============================================================================
section "Setting up GSD preferences"

if [ -f "$HOME_DIR/.gsd/preferences.md" ]; then
  info "Backing up existing preferences.md → preferences.md.bak"
  cp "$HOME_DIR/.gsd/preferences.md" "$HOME_DIR/.gsd/preferences.md.bak"
fi

cp -f "$REPO_DIR/gsd/preferences.md" "$HOME_DIR/.gsd/preferences.md"
log "GSD preferences → ~/.gsd/preferences.md"

# =============================================================================
# 6. Initialize port registry (if not exists)
# =============================================================================
section "Setting up port registry"

if [ ! -f "$HOME_DIR/.gsd/port-registry.json" ]; then
  cat > "$HOME_DIR/.gsd/port-registry.json" << 'EOF'
{
  "comment": "Global port registry. Each project gets a unique port starting from 50000. Never reuse ports across projects.",
  "nextPort": 50000,
  "projects": {}
}
EOF
  log "Port registry → ~/.gsd/port-registry.json"
else
  log "Port registry already exists — skipping"
fi

# =============================================================================
# 7. Configure skillshare
# =============================================================================
section "Configuring skillshare"

SKILLSHARE_CONFIG_DIR="$HOME_DIR/.config/skillshare"
mkdir -p "$SKILLSHARE_CONFIG_DIR/skills" "$SKILLSHARE_CONFIG_DIR/extras"

# Substitute __HOME__ placeholder with actual home directory
sed "s|__HOME__|$HOME_DIR|g" "$REPO_DIR/skillshare/config.yaml" > "$SKILLSHARE_CONFIG_DIR/config.yaml"
log "skillshare config → ~/.config/skillshare/config.yaml"

# =============================================================================
# 8. Install skills
# =============================================================================
section "Installing skills"

info "Our standards skill..."
skillshare install "$HOME_DIR/.gsd/standards" --force

info "OneKey skills (33 skills — TypeScript/React/Git/Security/i18n/Performance)..."
skillshare install github.com/OneKeyHQ/app-monorepo/.skillshare/skills --all

info "Callstack agent-skills (5 skills — React Native, GitHub workflows, RN upgrade)..."
skillshare install github.com/callstackincubator/agent-skills --all

info "Vercel agent-skills (6 skills — React, RN, composition patterns, web design)..."
skillshare install github.com/vercel-labs/agent-skills --all

info "UI UX Pro Max"
skillshare install github.com/nextlevelbuilder/ui-ux-pro-max-skill/.claude/skills --all

log "All skills installed"

# =============================================================================
# 9. Sync skills to AI tools
# =============================================================================
section "Syncing skills to AI tools"

skillshare sync
log "Skills synced to configured targets"

# =============================================================================
# Done
# =============================================================================
SKILL_COUNT=$(skillshare list 2>&1 | grep -c "→" || echo "?")

echo ""
echo "  ╔══════════════════════════════════════╗"
echo -e "  ║   ${GREEN}Setup complete!${NC}                      ║"
echo "  ╚══════════════════════════════════════╝"
echo ""
echo "  Installed:"
echo "  • $SKILL_COUNT skills  → ~/.config/skillshare/skills/"
echo "  • GSD preferences     → ~/.gsd/preferences.md"
echo "  • Standards           → ~/.gsd/standards/"
echo "  • Port registry       → ~/.gsd/port-registry.json"
echo "  • skillshare config   → ~/.config/skillshare/config.yaml"
echo ""
echo "  Starting a new project:"
echo "  1. cp ~/.gsd/standards/PREFERENCES-TEMPLATE.md <project>/.gsd/PREFERENCES.md"
echo "  2. Edit PREFERENCES.md — uncomment skills for your stack"
echo ""
echo "  Keeping skills up to date:"
echo "  skillshare update --all && skillshare sync"
echo ""
