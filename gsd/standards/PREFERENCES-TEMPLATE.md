# Project PREFERENCES.md Template

Copy to `.gsd/PREFERENCES.md`. Uncomment the skills relevant to your stack.

## Skills are managed by skillshare

```bash
skillshare update --all   # update all skills
skillshare sync           # sync to Claude/pi/other tools
skillshare list           # see all available skills
```

---

```yaml
---
version: 1
skill_rules:

  # ── 我们自己的工程规范（必须）────────────────────────────────────────
  - when: any implementation task
    use:
      - standards                  # STANDARDS.md — all languages, all projects

  # 有管理端 / dashboard
  # - when: dashboard, admin interface, authenticated pages, management UI
  #   use:
  #     - standards                # also contains STANDARDS-ADMIN.md — read it

  # 有公开页面
  # - when: public pages, landing page, marketing, SEO, documentation
  #   use:
  #     - standards                # also contains STANDARDS-PUBLIC.md — read it

  # ── TypeScript / React（所有前端项目必须）────────────────────────────
  - when: writing, reviewing, or refactoring any TypeScript or React code
    use:
      - 1k-coding-patterns
      - 1k-code-quality

  - when: async operations, Promises, error handling, try/catch
    use:
      - 1k-error-handling
      - 1k-coding-patterns

  # ── i18n & formatting ────────────────────────────────────────────────
  - when: adding or modifying any user-visible text, labels, messages, or UI strings
    use:
      - 1k-i18n

  - when: displaying dates, times, or numbers to users
    use:
      - 1k-date-formatting

  # ── Git & PR ─────────────────────────────────────────────────────────
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

  # ── Performance ──────────────────────────────────────────────────────
  - when: performance optimization, slow renders, large lists, memoization, bundle size
    use:
      - 1k-performance

  # ── React / Next.js（Web 项目）───────────────────────────────────────
  # - when: React, Next.js, rerenders, server components, bundle optimization
  #   use:
  #     - react-best-practices         # Vercel — rerenders, server, bundle
  #     - vercel-react-best-practices  # OneKey — same scope, complementary rules
  #     - composition-patterns         # Vercel — compound components, React 19

  # ── React Native（移动端项目）────────────────────────────────────────
  # - when: React Native, mobile, iOS, Android, native modules, Expo
  #   use:
  #     - react-native-best-practices  # Callstack — JS/Native/Bundle optimization
  #     - react-native-skills          # Vercel — list perf, animations, navigation
  #     - 1k-cross-platform            # OneKey — .native.ts/.web.ts patterns
  #     - 1k-ui-recipes                # OneKey — iOS/Android UI edge cases

  # RN upgrade / brownfield
  # - when: upgrading React Native version, brownfield migration
  #   use:
  #     - upgrading-react-native
  #     - react-native-brownfield-migration

  # ── UI design review ─────────────────────────────────────────────────
  # - when: UI review, accessibility audit, design review, web UX guidelines
  #   use:
  #     - web-design-guidelines

  # ── Error monitoring ─────────────────────────────────────────────────
  # - when: Sentry, production errors, crash analysis
  #   use:
  #     - 1k-sentry
  #     - 1k-sentry-analysis

  # ── Security（加密 / 金融类项目）─────────────────────────────────────
  # - when: security audit, crypto key handling, wallet operations, pre-release
  #   use:
  #     - 1k-auditing-pre-release-security

  # ── Analytics ────────────────────────────────────────────────────────
  # - when: analytics events, tracking, telemetry
  #   use:
  #     - 1k-analytics

  # ── State management ─────────────────────────────────────────────────
  # - when: state management, Jotai, Redux, Zustand, atoms, global state
  #   use:
  #     - 1k-state-management

  # ── GitHub Actions / CI ──────────────────────────────────────────────
  # - when: GitHub Actions, CI/CD, build artifacts, simulator builds
  #   use:
  #     - github-actions             # Callstack — RN simulator/emulator artifacts

  # ── Figma 设计实现 ───────────────────────────────────────────────────
  # - when: implementing designs from Figma, UI components from specs
  #   use:
  #     - 1k-implementing-figma-designs

  # ── Vercel 部署 ──────────────────────────────────────────────────────
  # - when: deploying to Vercel, vercel.json configuration
  #   use:
  #     - deploy-to-vercel

  # ── DeFi / 区块链 ────────────────────────────────────────────────────
  # - when: DeFi module, earn/borrow, blockchain routing
  #   use:
  #     - 1k-defi-module-integration
---
```
