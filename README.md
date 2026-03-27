# nosclaw-dev-env

Team AI coding environment configuration. One command to set up everything.

## What this installs

- **skillshare** — skills manager that syncs to Claude Code, pi, Cursor, and other AI tools
- **GSD (pi)** — project management and auto-mode system
- **Engineering standards** — our coding rules (security, i18n, admin UI, SEO/GEO, etc.)
- **47+ AI coding skills** from OneKey, Callstack, and Vercel

## Quick Start

```bash
git clone git@github.com:nosclaw/dev-env.git
cd dev-env
bash setup.sh
```

That's it. Takes ~2 minutes.

## What gets installed where

| Location | Contents |
|----------|----------|
| `~/.gsd/preferences.md` | GSD global behavior rules |
| `~/.gsd/standards/` | Our engineering standards (STANDARDS.md, STANDARDS-ADMIN.md, STANDARDS-PUBLIC.md) |
| `~/.gsd/port-registry.json` | Per-machine port registry (starts empty, grows as you add projects) |
| `~/.config/skillshare/` | skillshare config + all installed skills |
| `~/.claude/skills/` | Skills synced to Claude Code (symlinks) |
| `~/.agents/skills/` | Skills synced to pi / universal tools (symlinks) |

## Skills included

| Source | Count | Coverage |
|--------|-------|----------|
| OneKey (`1k-*`) | 33 | TypeScript, React, Git, Security, i18n, Performance, Sentry, DeFi |
| Callstack | 5 | React Native best practices, GitHub workflows, RN upgrade |
| Vercel | 6 | React, React Native, Composition patterns, Web design, Vercel deploy |
| Nosclaw | 1 | Our own engineering standards |

## Starting a new project

```bash
cd my-project
mkdir -p .gsd
cp ~/.gsd/standards/PREFERENCES-TEMPLATE.md .gsd/PREFERENCES.md
# Edit .gsd/PREFERENCES.md — uncomment the skills for your stack
```

## Keeping skills up to date

```bash
skillshare update --all
skillshare sync
```

## Updating our standards

Standards are edited in this repo under `gsd/standards/`. After pulling:

```bash
git pull
bash setup.sh   # re-runs safely, existing port registry is preserved
```

Or just update the standards skill directly:

```bash
# After editing ~/.gsd/standards/*.md
skillshare install ~/.gsd/standards --force
skillshare sync
```

## Customizing targets

If you use different AI tools, edit `~/.config/skillshare/config.yaml` and add/remove targets:

```yaml
targets:
  cursor:
    path: /Users/<you>/.cursor/skills
    mode: symlink
  codex:
    path: /Users/<you>/.codex/skills
    mode: symlink
```

Then run `skillshare sync`.

## Requirements

- macOS
- [Homebrew](https://brew.sh)
- Node.js (for GSD/pi)
- Git with GitHub access
