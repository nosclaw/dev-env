# Global Engineering Standards

Applies to **all projects and all programming languages** (TypeScript, JavaScript, Python, Go, Swift, Rust, Java, Kotlin, etc.).
These rules are non-negotiable. Apply them during planning, implementation, and code review.

---

## 1. Security

- **No secrets in source code.** API keys, passwords, tokens, private keys, connection strings, and encryption keys must never be hardcoded in any source file. Inject via environment variables or a secrets manager.
- **No secrets in logs.** Private keys, mnemonics, passwords, session tokens, and full wallet addresses must never appear in log output. Truncate addresses to first-6/last-4 characters. Scrub sensitive fields before logging.
- **No secrets in version control.** `.env`, key files, certificate private keys, and database files must be in `.gitignore`. Audit `.gitignore` at project setup.
- **Validate all user input at the API/service boundary.** Never trust client-supplied data. Enforce length, format, and range on the server side — frontend validation is UX only.
- **Parameterized queries only.** Never concatenate user input into SQL, shell commands, or any query language. Use prepared statements or an ORM's parameter binding in every language.
- **Principle of least privilege.** Service accounts, database users, and API keys must have only the permissions they need. Never use a superuser connection for application queries.

---

## 2. No Magic Values

- **No magic numbers.** Every numeric literal with business meaning must be a named constant. Bad: `if count > 100`. Good: `const MAX_WALLET_COUNT = 100; if count > MAX_WALLET_COUNT`.
- **No magic strings.** Repeated string literals (status values, event names, route paths, config keys) must be constants or enums, not raw strings scattered across files.
- **No hardcoded URLs, ports, hostnames, or timeouts.** These are configuration — they belong in environment variables or a dedicated config module, never inline in business logic.
- **No hardcoded file paths.** Use path utilities (`path.join`, `os.path.join`, etc.) relative to a well-defined root, never absolute paths specific to one developer's machine.

---

## 3. Error Handling

- **Never swallow exceptions.** Empty catch blocks are forbidden. Every caught error must be either logged with context or re-thrown. Silent failure is worse than a crash.
- **Every async operation has an error path.** In all languages: unhandled promise rejections, uncaught goroutine panics, unhandled Swift errors, unchecked Rust Results are all bugs.
- **Error messages must include context.** Include the operation type, resource identifier, and failure reason. Bad: `"error occurred"`. Good: `"insertTransaction failed: idempotency key conflict for walletAddress=0x...abc botId=xyz"`.
- **Distinguish recoverable from fatal errors.** Transient errors (network timeout, rate limit) should be retried with backoff. Logic errors (invalid input, constraint violation) should fail fast and surface to the caller.
- **No generic catch-all handlers at the top level that hide bugs.** A global error handler is for last-resort logging and graceful shutdown — not a substitute for proper per-operation error handling.

---

## 4. Code Structure & Clarity

- **Single responsibility.** Each function, method, or module does one thing. A function that fetches data, transforms it, and writes it to three places should be three functions.
- **Function length.** Functions exceeding ~50 lines are a signal to decompose. There are legitimate exceptions (state machines, complex algorithms) but they require justification.
- **No dead code.** Commented-out code must not be committed. Delete it — version control preserves history. TODO/FIXME comments must not be committed unless they reference an open issue with an ID.
- **Explicit over implicit.** Prefer clear, readable code over clever one-liners. The next developer (including future you) should understand the intent without a debugger.
- **Consistent naming.** Follow the naming convention of the language and project. In typed languages: types are PascalCase, variables/functions are camelCase or snake_case per language convention. Never abbreviate unless the abbreviation is universally understood (`id`, `url`, `db`, `ctx`).
- **No boolean traps.** Functions with multiple boolean parameters are hard to read at the call site. Use named parameters, option structs, or enums instead.

---

## 5. Type Safety

- **Use the type system.** In typed languages (TypeScript, Go, Swift, Rust, Kotlin, Java), declare types explicitly. Avoid escape hatches: no `any` in TypeScript, no unchecked casts in Java/Kotlin, no `interface{}` without justification in Go, no `!` force-unwrap in Swift without a guard.
- **Prefer stricter types.** Use `unknown` instead of `any` (TypeScript). Use `Option`/`Result` instead of nullable returns (Rust, Swift). Use sum types / discriminated unions for states that exclude each other.
- **No implicit nulls in core domain logic.** Null/nil represents absence — make it explicit in the type signature so callers are forced to handle it.

---

## 6. Database

- **All multi-table writes use transactions.** If two or more rows must be consistent, wrap them in a transaction. No exceptions.
- **Row-level user isolation.** Every query that returns user data must filter by `userId` (or equivalent owner identifier). This filter must be applied in the data access layer, not left to individual callers.
- **No SELECT * in production code.** Always name the columns you need. This prevents accidental data leakage and makes schema changes visible.
- **Indexes for every query pattern.** Add an index for any column used in WHERE, JOIN ON, or ORDER BY that will run at scale. Unindexed queries on large tables are bugs waiting to appear.
- **Schema changes via versioned migrations.** Never alter the database schema manually in any environment. All changes go through a migration file with a version number. Migrations must be idempotent and forward-only.

---

## 7. API Design

- **Uniform error response format.** All error responses use the same envelope:
  ```json
  { "error": { "code": "SNAKE_CASE_CODE", "message": "human readable", "details": {} } }
  ```
- **Authentication at the middleware layer.** Never check session/token validity inside an individual handler. A single middleware intercepts all protected routes.
- **CSRF protection on all state-changing endpoints.** POST, PUT, PATCH, DELETE must verify origin or use double-submit cookie. GET endpoints are read-only and exempt.
- **Idempotency for write operations.** Any operation that creates or modifies resources should support an idempotency key so clients can safely retry on network failure without duplicate execution.
- **Pagination on all list endpoints.** No endpoint returns an unbounded list. Default page size ≤ 50, maximum ≤ 200.
- **API versioning.** All APIs must be versioned (`/v1/`, `/v2/` or via Accept header). Deprecated fields and endpoints must go through a deprecation period — never deleted without notice.

---

## 8. Configuration & Environment

- **Environment-specific config is injected, not branched.** Avoid `if NODE_ENV === 'production'` scattered in business logic. Use environment variables to configure behavior; let the runtime decide.
- **Fail fast on missing required config.** At application startup, validate that all required environment variables are present and valid. If any are missing, exit immediately with a clear error message listing what is missing. Do not start in a degraded state.
- **Dev and production parity.** Dev should run the same stack as production (same DB engine, same server). Never use SQLite in dev and PostgreSQL in prod for a project that ships PostgreSQL.

---

## 9. Performance

- **No N+1 queries.** Never query inside a loop. Batch lookups, use JOINs, or use an in-memory map loaded by a single query.
- **Paginate or stream large datasets.** Never load an entire table into memory for processing. Use cursors, offsets, or streaming.
- **Cache expensive operations.** RPC calls, external API calls, and heavy computations that repeat with the same inputs must be cached with an explicit TTL. Cache invalidation must be intentional.
- **Async I/O.** Never block the event loop / main thread with synchronous file reads, network calls, or heavy computation. Use async/await, goroutines, threads, or worker processes as appropriate to the language.

---

## 10. Observability

- **Structured logging.** Log in a machine-parseable format (JSON or key=value). Include timestamp, log level, operation name, and relevant IDs (userId, requestId, resourceId) on every log line.
- **Log levels correctly.** DEBUG for internal state, INFO for normal operations, WARN for recoverable anomalies, ERROR for failures requiring attention. Never log everything as INFO.
- **Instrument failure paths.** The happy path is easy to monitor. Explicitly log: retries, fallbacks, timeouts, and degraded-mode activations. These are the signals you need at 3am.
- **Health/readiness endpoints.** Every service that can be deployed must expose at minimum a `/health` endpoint that returns 200 when the service is ready to handle traffic.
- **Request tracing.** Every inbound request gets a unique `requestId` (UUID). Propagate it through all downstream calls and include it in every log line and error response so failures can be traced end-to-end.

---

## 11. Git & Version Control

- **One logical change per commit.** A commit should be reviewable in isolation. Mixing a bug fix, a refactor, and a new feature in one commit makes history unreadable.
- **Conventional commit format.** `type(scope): description` — types: `feat`, `fix`, `refactor`, `docs`, `chore`, `perf`, `ci`, `build`, `test`.
- **No generated files in version control.** Build artifacts, compiled binaries, dependency directories (`node_modules`, `vendor`, `.venv`, `target/`), and `.next/` must be gitignored.
- **Feature branches, not direct commits to main.** All work happens on a branch. Main is always deployable.
- **PR size limit.** A single pull request should not exceed 400 lines of non-generated code changes. Large changes must be broken into sequential PRs.
- **At least one reviewer before merge.** No self-merging without review except for trivial chore commits.

---

## 12. Dependency Management

- **Lock files are committed.** `package-lock.json`, `yarn.lock`, `Cargo.lock`, `go.sum`, `poetry.lock` — always committed. Never `.gitignore` lock files.
- **Pin dependency versions in production.** Use exact versions or tight ranges. Avoid `*` or `latest`.
- **No abandoned packages.** Before adding a dependency, check last commit date, open issues, and download trends. Do not add packages with no activity in 2+ years unless there is no alternative.
- **Standard library first.** If the standard library can solve the problem adequately, do not introduce a third-party dependency.
- **Audit regularly.** Run `npm audit`, `cargo audit`, `pip-audit`, `govulncheck`, or equivalent as part of CI. Address HIGH and CRITICAL vulnerabilities before they reach production.

---

## 13. Ports & Local Services

- **Never use common ports** (3000, 8080, 8000, 4000, 5000, 8888, 9000, etc.) for dev servers.
- **Each project gets a unique port** starting from 50000, registered in `~/.gsd/port-registry.json`.
- When starting a new project: read the registry, assign `nextPort`, increment it, save the registry, and configure both dev and production server scripts to use that port.

---

## 14. Internationalization (i18n)

- **All user-facing text must be externalized.** No hardcoded strings in UI components, API error messages surfaced to users, push notifications, or email templates. Every string goes through an i18n lookup key.
- **Default language is English.** All translation keys must have an English (`en`) value as the baseline. English is the fallback when a translation is missing.
- **i18n from day one, not as an afterthought.** Even if only one language ships initially, the architecture must support adding languages without touching component code. Retrofitting i18n onto a codebase is expensive.
- **Use established i18n libraries per platform.** Do not roll custom translation systems. Prefer: `next-intl` or `react-i18next` (React/Next.js), `i18next` (Node.js), `Localizable.strings` + `String(localized:)` (iOS/macOS), `strings.xml` (Android), `go-i18n` (Go), `gettext` (Python/generic).
- **ICU message format for plurals and variables.** Use ICU syntax (`{count, plural, one {# item} other {# items}}`) not string concatenation. Never build sentences by joining translated fragments.
- **Translation files are structured and versioned.** Store translations in `/locales/{lang}/{namespace}.json` (or platform equivalent). All locale files are committed to the repository.
- **Dates, times, numbers, and currencies must be locale-aware.** Use `Intl.DateTimeFormat`, `Intl.NumberFormat`, `Intl.RelativeTimeFormat` (JS), or equivalent platform APIs. Never format dates or numbers with raw string manipulation.
- **RTL layout support.** Design layouts that can flip for right-to-left languages (Arabic, Hebrew). Use logical CSS properties (`margin-inline-start` not `margin-left`).
- **User locale preference is persisted.** Store the user's chosen language in their profile/settings and respect it across sessions and devices.

---

## 15. UI Appearance & Theming

> Applies to all UI projects (public and admin).

- **Dark mode and light mode are both required.** Every UI project must implement both themes from the start. The user's OS preference is detected automatically (`prefers-color-scheme`) and can be overridden in settings.
- **Theme is applied at the root level.** Use CSS custom properties (variables), a theme provider (React), or platform equivalents (SwiftUI `ColorScheme`, Android `DayNight` theme). Never hardcode colors inline.
- **Semantic color tokens, not raw values.** Define tokens by role (`surface`, `on-surface`, `primary`, `error`, `warning`). The token maps to different raw values in light vs dark mode.
- **Typography scale is defined once.** Font sizes, weights, and line heights are a named scale. Never set arbitrary `font-size: 13.5px` inline.
- **Minimum contrast ratios.** WCAG AA: 4.5:1 for body text, 3:1 for large text and UI components. Verify both light and dark modes.
- **Responsive layout.** UI must work from 375px (mobile) to 1920px (large desktop). Use relative units (`rem`, `%`, `fr`). Test at 375px, 768px, 1280px, and 1920px.
- **Animations respect `prefers-reduced-motion`.** All transitions must be suppressed or simplified when the user has enabled reduced motion.
- **User theme preference is persisted.** Restore before first paint to avoid flash of wrong theme.
- **Icons use a consistent system.** One icon library per project. SVG icons have `aria-hidden="true"` when decorative, or `aria-label` when meaningful.
