---
name: nosclaw-standards
description: >
  Nosclaw engineering standards. Use during any implementation task.
  Covers: security, error handling, code quality, database, API design,
  i18n, theming (dark/light mode), ports, and observability.
  Also includes admin UI standards (Right Sheet, tables, forms) and
  public page standards (SEO, GEO) — load the relevant sub-files based
  on project type.
targets:
  - claude
  - universal
---

# Nosclaw Engineering Standards

Core engineering standards that apply to **all projects and all languages**.

## When to Apply

- **Always:** Read `STANDARDS.md` at the start of any implementation task.
- **Admin/dashboard projects:** Also read `STANDARDS-ADMIN.md`.
- **Public-facing pages:** Also read `STANDARDS-PUBLIC.md`.

## Files

| File | Scope |
|------|-------|
| `STANDARDS.md` | All projects — security, code quality, DB, API, i18n, theming, ports |
| `STANDARDS-ADMIN.md` | Authenticated dashboards and admin UIs |
| `STANDARDS-PUBLIC.md` | Public pages — SEO, GEO, performance, accessibility |
| `PREFERENCES-TEMPLATE.md` | Template for project-level skill composition |
