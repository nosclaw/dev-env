#!/usr/bin/env bash
# =============================================================================
# detect-stack.sh
# Auto-generates .gsd/PREFERENCES.md based on project stack detection.
# Called by GSD via git.worktree_post_create on worktree creation.
#
# Environment variables provided by GSD:
#   SOURCE_DIR   — original project root
#   WORKTREE_DIR — the new worktree directory (may differ from SOURCE_DIR)
# =============================================================================

set -euo pipefail

# Use SOURCE_DIR if available (GSD worktree mode), otherwise cwd
PROJECT_DIR="${SOURCE_DIR:-$(pwd)}"
GSD_DIR="$PROJECT_DIR/.gsd"
PREFS_FILE="$GSD_DIR/PREFERENCES.md"
TEMPLATE="$HOME/.gsd/standards/PREFERENCES-TEMPLATE.md"

# If PREFERENCES.md already exists, skip
if [ -f "$PREFS_FILE" ]; then
  exit 0
fi

mkdir -p "$GSD_DIR"

# =============================================================================
# Stack detection
# =============================================================================

# --- Languages / Runtimes ---
HAS_TS=false
HAS_PYTHON=false
HAS_GO=false
HAS_SWIFT=false
HAS_RUST=false
HAS_JAVA=false
HAS_KOTLIN=false

[ -f "$PROJECT_DIR/tsconfig.json" ] || find "$PROJECT_DIR" -maxdepth 2 -name "*.ts" | grep -q . 2>/dev/null && HAS_TS=true
[ -f "$PROJECT_DIR/setup.py" ] || [ -f "$PROJECT_DIR/pyproject.toml" ] || [ -f "$PROJECT_DIR/requirements.txt" ] && HAS_PYTHON=true
[ -f "$PROJECT_DIR/go.mod" ] && HAS_GO=true
[ -f "$PROJECT_DIR/Package.swift" ] && HAS_SWIFT=true
[ -f "$PROJECT_DIR/Cargo.toml" ] && HAS_RUST=true
find "$PROJECT_DIR" -maxdepth 3 -name "*.java" | grep -q . 2>/dev/null && HAS_JAVA=true
find "$PROJECT_DIR" -maxdepth 3 -name "*.kt" | grep -q . 2>/dev/null && HAS_KOTLIN=true

# --- Frameworks ---
HAS_REACT=false
HAS_REACT_NATIVE=false
HAS_NEXTJS=false
HAS_EXPO=false
HAS_VUE=false
HAS_NUXT=false

if [ -f "$PROJECT_DIR/package.json" ]; then
  PKG=$(cat "$PROJECT_DIR/package.json")
  echo "$PKG" | grep -q '"react"' && HAS_REACT=true
  echo "$PKG" | grep -q '"react-native"' && HAS_REACT_NATIVE=true
  echo "$PKG" | grep -q '"next"' && HAS_NEXTJS=true
  echo "$PKG" | grep -q '"expo"' && HAS_EXPO=true
  echo "$PKG" | grep -q '"vue"' && HAS_VUE=true
  echo "$PKG" | grep -q '"nuxt"' && HAS_NUXT=true
fi
[ -f "$PROJECT_DIR/app.json" ] && grep -q "expo" "$PROJECT_DIR/app.json" 2>/dev/null && HAS_EXPO=true

# --- Project type ---
HAS_ADMIN_UI=false
HAS_PUBLIC_PAGES=false
HAS_CRYPTO=false
HAS_DEFI=false

# Admin UI detection
[ -d "$PROJECT_DIR/app/(admin)" ] && HAS_ADMIN_UI=true
[ -d "$PROJECT_DIR/app/admin" ] && HAS_ADMIN_UI=true
[ -d "$PROJECT_DIR/src/admin" ] && HAS_ADMIN_UI=true
[ -d "$PROJECT_DIR/pages/admin" ] && HAS_ADMIN_UI=true
grep -rq "dashboard\|admin" "$PROJECT_DIR/src" --include="*.ts" --include="*.tsx" -l 2>/dev/null | head -1 | grep -q . && HAS_ADMIN_UI=true

# Public pages detection
[ -d "$PROJECT_DIR/app/(marketing)" ] && HAS_PUBLIC_PAGES=true
[ -d "$PROJECT_DIR/app/(public)" ] && HAS_PUBLIC_PAGES=true
[ -f "$PROJECT_DIR/public/robots.txt" ] && HAS_PUBLIC_PAGES=true
[ -f "$PROJECT_DIR/next-sitemap.config.js" ] && HAS_PUBLIC_PAGES=true

# Crypto / DeFi detection
if [ -f "$PROJECT_DIR/package.json" ]; then
  PKG=$(cat "$PROJECT_DIR/package.json")
  echo "$PKG" | grep -qE '"ethers"|"@solana/web3.js"|"viem"|"wagmi"|"@web3-react"' && HAS_CRYPTO=true
  echo "$PKG" | grep -qE '"@uniswap|"@aave|"@compound"' && HAS_DEFI=true
fi

# Sentry detection
HAS_SENTRY=false
if [ -f "$PROJECT_DIR/package.json" ]; then
  grep -q '"@sentry/' "$PROJECT_DIR/package.json" && HAS_SENTRY=true
fi
[ -f "$PROJECT_DIR/sentry.client.config.ts" ] || [ -f "$PROJECT_DIR/sentry.server.config.ts" ] && HAS_SENTRY=true

# Analytics detection
HAS_ANALYTICS=false
[ -f "$PROJECT_DIR/package.json" ] && grep -qE '"mixpanel|"amplitude|"posthog|"segment"' "$PROJECT_DIR/package.json" 2>/dev/null && HAS_ANALYTICS=true

# =============================================================================
# Generate PREFERENCES.md
# =============================================================================

cat > "$PREFS_FILE" << 'YAML_EOF'
---
version: 1
skill_rules:

  # ── Our engineering standards (always required) ───────────────────────
  - when: any implementation task
    use:
      - standards
YAML_EOF

# Admin UI
if [ "$HAS_ADMIN_UI" = true ]; then
  cat >> "$PREFS_FILE" << 'YAML_EOF'

  # ── Admin / dashboard UI ──────────────────────────────────────────────
  - when: dashboard, admin interface, authenticated pages, management UI
    use:
      - standards
YAML_EOF
fi

# Public pages
if [ "$HAS_PUBLIC_PAGES" = true ]; then
  cat >> "$PREFS_FILE" << 'YAML_EOF'

  # ── Public pages (SEO / GEO) ──────────────────────────────────────────
  - when: public pages, landing page, marketing, SEO, GEO, documentation
    use:
      - standards
YAML_EOF
fi

# TypeScript / React (always if TS project)
if [ "$HAS_TS" = true ]; then
  cat >> "$PREFS_FILE" << 'YAML_EOF'

  # ── TypeScript / React ────────────────────────────────────────────────
  - when: writing, reviewing, or refactoring any TypeScript or React code
    use:
      - 1k-coding-patterns
      - 1k-code-quality

  - when: async operations, Promises, error handling, try/catch
    use:
      - 1k-error-handling
      - 1k-coding-patterns

  - when: adding or modifying any user-visible text, labels, messages
    use:
      - 1k-i18n

  - when: displaying dates, times, or numbers to users
    use:
      - 1k-date-formatting
YAML_EOF
fi

# React Native
if [ "$HAS_REACT_NATIVE" = true ] || [ "$HAS_EXPO" = true ]; then
  cat >> "$PREFS_FILE" << 'YAML_EOF'

  # ── React Native / Expo ───────────────────────────────────────────────
  - when: React Native, Expo, mobile, iOS, Android, native modules
    use:
      - react-native-best-practices
      - react-native-skills
      - 1k-cross-platform
      - 1k-ui-recipes

  - when: performance optimization, lists, animations, bundle size
    use:
      - react-native-best-practices
      - 1k-performance
YAML_EOF
fi

# Next.js / Web React
if [ "$HAS_NEXTJS" = true ] && [ "$HAS_REACT_NATIVE" = false ]; then
  cat >> "$PREFS_FILE" << 'YAML_EOF'

  # ── Next.js / React web ───────────────────────────────────────────────
  - when: React, Next.js, rerenders, server components, bundle optimization
    use:
      - react-best-practices
      - vercel-react-best-practices

  - when: component architecture, compound components, reusable component API
    use:
      - composition-patterns

  - when: performance optimization, slow renders, large lists, memoization
    use:
      - 1k-performance
      - react-best-practices

  - when: UI review, accessibility audit, design review, web UX guidelines
    use:
      - web-design-guidelines
YAML_EOF
elif [ "$HAS_REACT" = true ] && [ "$HAS_REACT_NATIVE" = false ]; then
  cat >> "$PREFS_FILE" << 'YAML_EOF'

  # ── React web ─────────────────────────────────────────────────────────
  - when: React, rerenders, component optimization, bundle
    use:
      - react-best-practices
      - composition-patterns

  - when: performance optimization, slow renders, large lists
    use:
      - 1k-performance
      - react-best-practices
YAML_EOF
fi

# Git & PR (always)
cat >> "$PREFS_FILE" << 'YAML_EOF'

  # ── Git & PR (always) ─────────────────────────────────────────────────
  - when: creating commits, branches, or pull requests
    use:
      - 1k-git-workflow
      - 1k-create-pr

  - when: reviewing a pull request or code review
    use:
      - 1k-code-review-pr

  - when: adding, upgrading, or removing dependencies
    use:
      - 1k-pkg-upgrade-review
YAML_EOF

# Sentry
if [ "$HAS_SENTRY" = true ]; then
  cat >> "$PREFS_FILE" << 'YAML_EOF'

  # ── Error monitoring ──────────────────────────────────────────────────
  - when: Sentry, production errors, crash analysis, error monitoring
    use:
      - 1k-sentry
      - 1k-sentry-analysis
YAML_EOF
fi

# Crypto / DeFi
if [ "$HAS_CRYPTO" = true ]; then
  cat >> "$PREFS_FILE" << 'YAML_EOF'

  # ── Security / Crypto ─────────────────────────────────────────────────
  - when: security audit, pre-release review, crypto key handling, wallet operations
    use:
      - 1k-auditing-pre-release-security
      - 1k-code-review-pr
YAML_EOF
fi

if [ "$HAS_DEFI" = true ]; then
  cat >> "$PREFS_FILE" << 'YAML_EOF'

  # ── DeFi ──────────────────────────────────────────────────────────────
  - when: DeFi module, earn, borrow, lending, blockchain routing
    use:
      - 1k-defi-module-integration
YAML_EOF
fi

# Analytics
if [ "$HAS_ANALYTICS" = true ]; then
  cat >> "$PREFS_FILE" << 'YAML_EOF'

  # ── Analytics ─────────────────────────────────────────────────────────
  - when: analytics events, tracking, telemetry
    use:
      - 1k-analytics
YAML_EOF
fi

# Close YAML
echo "---" >> "$PREFS_FILE"

# Append detection summary as comment block
cat >> "$PREFS_FILE" << EOF

# Auto-generated by detect-stack.sh
# Detected stack:
#   TypeScript:    $HAS_TS
#   React:         $HAS_REACT
#   React Native:  $HAS_REACT_NATIVE
#   Next.js:       $HAS_NEXTJS
#   Expo:          $HAS_EXPO
#   Admin UI:      $HAS_ADMIN_UI
#   Public pages:  $HAS_PUBLIC_PAGES
#   Crypto/Web3:   $HAS_CRYPTO
#   DeFi:          $HAS_DEFI
#   Sentry:        $HAS_SENTRY
#   Analytics:     $HAS_ANALYTICS
#   Python:        $HAS_PYTHON
#   Go:            $HAS_GO
#   Swift:         $HAS_SWIFT
#   Rust:          $HAS_RUST
#
# To customize: edit this file manually.
# To regenerate: delete this file and run detect-stack.sh again.
EOF

echo "✓ Generated .gsd/PREFERENCES.md (detected stack: $(
  PARTS=()
  [ "$HAS_NEXTJS" = true ] && PARTS+=("Next.js")
  [ "$HAS_REACT_NATIVE" = true ] && PARTS+=("React Native")
  [ "$HAS_EXPO" = true ] && PARTS+=("Expo")
  [ "$HAS_REACT" = true ] && [ "$HAS_REACT_NATIVE" = false ] && [ "$HAS_NEXTJS" = false ] && PARTS+=("React")
  [ "$HAS_PYTHON" = true ] && PARTS+=("Python")
  [ "$HAS_GO" = true ] && PARTS+=("Go")
  [ "$HAS_SWIFT" = true ] && PARTS+=("Swift")
  [ "$HAS_RUST" = true ] && PARTS+=("Rust")
  [ "$HAS_CRYPTO" = true ] && PARTS+=("Crypto/Web3")
  [ ${#PARTS[@]} -eq 0 ] && PARTS+=("unknown")
  IFS=', '; echo "${PARTS[*]}"
))"
