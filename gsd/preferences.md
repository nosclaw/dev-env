---
version: 1
mode: team
models:
  research: claude-sonnet-4-6
  planning: claude-sonnet-4-6
  execution: claude-sonnet-4-6
  execution_simple: claude-haiku-4-6
  completion: claude-sonnet-4-6
  subagent: claude-sonnet-4-6
skill_staleness_days: 0
uat_dispatch: false
unique_milestone_ids: true
cmux:
  enabled: false
  notifications: false
  sidebar: false
  splits: false
  browser: false
phases:
  skip_research: true
  skip_reassess: false
  skip_slice_research: true
  reassess_after_slice: true
parallel:
  enabled: true
  max_workers: 3
  merge_strategy: per-milestone
  auto_merge: confirm
git:
  push_branches: true
  pre_merge_check: auto
  auto_pr: true
  pr_target_branch: main
  worktree_post_create: ~/.gsd/detect-stack.sh
experimental:
  rtk: true
custom_instructions:
  - "Do not perform web searches unless the task explicitly requires up-to-date information (e.g. latest library releases, current events). Use lsp, read, rg, and get_library_docs instead."
  - "Verification means: the project compiles without errors (type errors, build errors, etc. depending on the language). Do not write unit tests as acceptance criteria unless explicitly requested."
  - "When planning milestones from a PRD or requirements document, generate ALL milestone CONTEXT.md files automatically in a single pass without asking for human confirmation between milestones. Read the full document first, derive the complete milestone breakdown, then write all CONTEXT.md files sequentially. Do not pause for per-milestone approval — treat the PRD as the authoritative source of truth."
  - "Never use common ports (3000, 8080, 8000, 4000, 5000, etc.) for dev servers. Each project must use a unique port starting from 50000, registered in ~/.gsd/port-registry.json. When starting a new project, read the registry, assign the next available port, increment nextPort, and save the registry. Always configure both the dev server and production server scripts to use the assigned port."
  - "Always follow the global engineering standards in the 'standards' skill (managed by skillshare). Read ~/.gsd/standards/STANDARDS.md at the start of any implementation task. If the project has an admin UI, also read ~/.gsd/standards/STANDARDS-ADMIN.md. If it has public pages, also read ~/.gsd/standards/STANDARDS-PUBLIC.md."

# GSD Skill Preferences
# See ~/.gsd/agent/extensions/gsd/docs/preferences-reference.md for full documentation.
