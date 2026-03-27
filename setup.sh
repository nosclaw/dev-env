#!/usr/bin/env bash
# =============================================================================
# Nosclaw Dev Environment Setup
# Installs and configures the full AI coding environment for team members.
# Usage: bash setup.sh
# =============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${YELLOW}→${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }

echo ""
echo "  Nosclaw Dev Environment Setup"
echo "  ================================"
echo ""

# =============================================================================
# 1. Check prerequisites
# =============================================================================
info "Checking prerequisites..."

command -v git >/dev/null 2>&1 || fail "git not found. Install Xcode Command Line Tools: xcode-select --install"
command -v brew >/dev/null 2>&1 || fail "Homebrew not found. Install from https://brew.sh"

log "Prerequisites OK"

# =============================================================================
# 2. Install skillshare
# =============================================================================
info "Installing skillshare..."

if command -v skillshare >/dev/null 2>&1; then
  log "skillshare already installed ($(skillshare --version))"
else
  brew install skillshare
  log "skillshare installed ($(skillshare --version))"
fi

# =============================================================================
# 3. Install GSD (pi)
# =============================================================================
info "Installing GSD (pi)..."

if command -v pi >/dev/null 2>&1 || npm list -g gsd-pi >/dev/null 2>&1; then
  log "GSD already installed"
else
  npm install -g gsd-pi
  log "GSD installed"
fi

# =============================================================================
# 4. Set up GSD standards
# =============================================================================
info "Setting up GSD standards..."

mkdir -p "$HOME_DIR/.gsd/standards"
cp -f "$REPO_DIR/gsd/standards/"* "$HOME_DIR/.gsd/standards/"
log "Standards copied to ~/.gsd/standards/"

# =============================================================================
# 5. Set up GSD preferences
# =============================================================================
info "Setting up GSD preferences..."

if [ -f "$HOME_DIR/.gsd/preferences.md" ]; then
  info "~/.gsd/preferences.md already exists — backing up to preferences.md.bak"
  cp "$HOME_DIR/.gsd/preferences.md" "$HOME_DIR/.gsd/preferences.md.bak"
fi

cp -f "$REPO_DIR/gsd/preferences.md" "$HOME_DIR/.gsd/preferences.md"
log "GSD preferences installed"

# =============================================================================
# 6. Initialize port registry (if not exists)
# =============================================================================
info "Setting up port registry..."

if [ ! -f "$HOME_DIR/.gsd/port-registry.json" ]; then
  cat > "$HOME_DIR/.gsd/port-registry.json" << 'EOF'
{
  "comment": "Global port registry. Each project gets a unique port starting from 50000. Never reuse ports across projects.",
  "nextPort": 50000,
  "projects": {}
}
EOF
  log "Port registry created at ~/.gsd/port-registry.json"
else
  log "Port registry already exists — skipping"
fi

# =============================================================================
# 7. Initialize skillshare (if not already configured)
# =============================================================================
info "Configuring skillshare..."

SKILLSHARE_DIR="$HOME_DIR/.config/skillshare"
mkdir -p "$SKILLSHARE_DIR/skills" "$SKILLSHARE_DIR/extras"

# Write config with actual HOME path substituted
sed "s|__HOME__|$HOME_DIR|g" "$REPO_DIR/skillshare/config.yaml" > "$SKILLSHARE_DIR/config.yaml"
log "skillshare config written to ~/.config/skillshare/config.yaml"

# =============================================================================
# 8. Install skills
# =============================================================================
info "Installing our standards skill..."
skillshare install "$HOME_DIR/.gsd/standards" --force

info "Installing OneKey skills (33 skills)..."
skillshare install github.com/OneKeyHQ/app-monorepo/.skillshare/skills --all

info "Installing Callstack agent-skills (5 skills)..."
skillshare install github.com/callstackincubator/agent-skills --all

info "Installing Vercel agent-skills (6 skills)..."
skillshare install github.com/vercel-labs/agent-skills --all

log "All skills installed"

# =============================================================================
# 9. Sync skills to all AI tools
# =============================================================================
info "Syncing skills to AI tools..."
skillshare sync
log "Skills synced"

# =============================================================================
# Done
# =============================================================================
echo ""
echo "  ================================"
echo -e "  ${GREEN}Setup complete!${NC}"
echo "  ================================"
echo ""
echo "  Installed:"
skillshare list 2>&1 | grep -c "→" | xargs -I{} echo "  • {} skills"
echo "  • GSD preferences → ~/.gsd/preferences.md"
echo "  • Standards       → ~/.gsd/standards/"
echo "  • Port registry   → ~/.gsd/port-registry.json"
echo "  • skillshare cfg  → ~/.config/skillshare/config.yaml"
echo ""
echo "  Next steps:"
echo "  1. For each new project, copy ~/.gsd/standards/PREFERENCES-TEMPLATE.md"
echo "     to the project's .gsd/PREFERENCES.md and uncomment relevant skills"
echo "  2. To update all skills later: skillshare update --all && skillshare sync"
echo ""
