# Admin System UI Standards

Applies to **authenticated management interfaces only** — dashboards, admin panels, back-office tools, and any UI requiring login.
Does **not** apply to public-facing pages (see `~/.gsd/STANDARDS-PUBLIC.md` for those).

Read `~/.gsd/STANDARDS.md` first — this file extends it.

---

## 1. Navigation & Layout

- **Collapsible sidebar.** Supports collapsed (icon-only) and expanded (icon + label) states. Smooth animation (200–300ms ease). A dedicated toggle button (`‹` / `›`) is always visible. Collapsed state persisted to user preferences.
- **Mobile sidebar.** Below 768px, becomes a drawer overlay — overlays content, does not push it.
- **Active menu item is highlighted.** Current page's item is visually distinct. Nested menus expand to show the active child.
- **Bottom-left user zone.** Sidebar footer contains: user avatar + display name + role/plan label. Clicking opens a popover menu with: Account Settings (⌘,), Language, Theme (light/dark/system), Help/Docs, Log out. Keyboard shortcuts shown inline.
- **Top bar.** Contains: breadcrumb navigation (required for pages deeper than 1 level), global search trigger (⌘K), notification bell with unread badge, workspace/org switcher for multi-tenant systems.
- **Page header.** Every page has a visible page title and optional subtitle. Primary action button (Create, Add, Import) placed top-right. Browser tab title matches page title.

---

## 2. Right Sheet for All Edit & Detail Pages

- **All create, edit, and detail secondary pages open as a Right Sheet** (slide-in panel from the right edge). Never navigate to a separate full page for editing a record. The list/table behind the sheet remains visible and in context.
- **Width:** 480px on desktop, 100% on mobile.
- **Animation:** slides in from right with ease-out (200ms open, 150ms close). Overlay backdrop dims content behind it.
- **Closing:** Esc key, clicking the backdrop, or the explicit Close (×) button. If there are unsaved changes, show a confirmation prompt before closing.
- **Header is fixed:** contains the record title (or "New [Entity]"), a Save/Submit button, and Close (×). Never scrolls away.
- **Footer (optional):** for forms with primary + destructive actions (Save + Delete), place destructive actions in the footer, visually separated from the primary CTA.
- **Nested sheets allowed up to one level deep.** Never stack more than two sheets.

---

## 3. Data Tables

- **Pagination required.** Default page size: 20 rows. User-selectable: 20 / 50 / 100. Current page and total count always visible.
- **Column sorting.** Click header to cycle: ascending → descending → default. Active sort direction always visible.
- **Global search.** Debounced 300ms. Prominent placement — not buried in a filter panel.
- **Column filters.** Contextual filter types: enum (checkbox list), date (range picker), number (min/max). Applied filters shown as removable tags below the search bar. "Clear all" button when any filter is active.
- **Column visibility.** User can show/hide columns via a column picker. Persisted per-user per-table.
- **Column resizing.** Drag-resizable columns.
- **Row selection.** Checkbox for single/multi-select. Bulk action bar appears above table when rows selected (count + available actions).
- **Virtual scrolling** for tables exceeding 500 rows.
- **Empty state:** illustration + description + primary action CTA. Never an empty container.
- **Loading state:** skeleton rows matching table structure. Not a full-page spinner.
- **Row hover actions:** Edit and per-row actions appear on hover (right-aligned). These open the Right Sheet.
- **Table state in URL.** Page, sort column, sort direction, and active filters reflected in URL query parameters — survives refresh, shareable.

---

## 4. Forms

- Required fields marked with `*`. Legend ("* Required") at the top of the form.
- **Validation:** per-field on blur, full-form on submit. Error messages directly below the invalid field in red. Never only in a top-level toast.
- **Submit button:** disabled + spinner while request is in flight. Re-enabled on failure. No double-submission.
- **Destructive confirmation forms** (delete account, purge data): require user to type a confirmation string before submit activates.
- **Multi-step forms** (more than 6 fields or logically distinct sections): step indicator (Step 1 of 3). Back navigation without losing data.
- **Auto-draft saving** for long forms: localStorage every 30s. Prompt to restore on next open.
- **Select inputs with more than 10 options** must support search/filter within the dropdown.
- **Date pickers** support direct keyboard input as well as the calendar UI.

---

## 5. Feedback & Confirmation

- Every async operation shows a loading state (button spinner, skeleton, or progress bar).
- **Success:** toast notification — top-right, auto-dismiss after 3s.
- **Failure:** toast with error summary + optional "View details" to expand full error.
- **Dangerous / irreversible operations** (delete, purge, revoke): modal confirmation dialog. Must name the resource and state the consequence explicitly. ("This will permanently delete wallet 0x...abc and all associated transactions. This cannot be undone.")
- **Bulk operation results:** summary toast ("5 deleted, 1 failed") with option to view failure details.
- **Long-running operations** (export, import, batch): progress indicator, background execution, notification on completion.

---

## 6. Search & Filtering

- **⌘K command palette:** globally accessible. Searches pages, actions, and records. Fully keyboard-navigable (arrow keys + Enter). Shows recently visited pages when empty.
- **Advanced filter builder:** multi-condition combinations (AND/OR). Each condition is a removable tag. Saved filter presets ("views") named by user.
- **Filter state is always visible.** Active filters shown as tags in the filter bar — never hidden in a collapsed panel by default.

---

## 7. Keyboard & Accessibility

- Core shortcuts: ⌘K (search), ⌘N (new), ⌘S (save), Esc (close sheet/modal).
- Shortcuts displayed in tooltips and menu items.
- All modals and sheets closable with Esc.
- Tab order follows visual reading order. Focus ring always visible (never `outline: none` without a replacement).
- All interactive elements reachable by keyboard.

---

## 8. Empty & Error States

- **Empty list:** illustration + description + primary action CTA.
- **Load failure:** error message + Retry button.
- **No permission:** explain why access is restricted + path to request access. Never a blank page or raw 403.
- **Network offline:** persistent top banner. Auto-dismisses when connection restores.
- **404:** friendly message + Back to home link.

---

## 9. Notifications

- Notification bell in top bar with unread count badge.
- Notification center (Right Sheet or dropdown): categorized by type (system, operation result, alert). Mark as read, mark all as read, delete.
- Critical alerts surface as a dismissible banner at the top of the relevant page — not only in the notification center.

---

## 10. Data Import & Export

- **Export:** CSV and Excel. Respects current filter state. Large exports are async — notify when ready to download.
- **Import:** template download → file upload → preview with validation → error rows highlighted with reason → confirm. Failed rows downloadable as error report.

---

## 11. Permissions & Security

- Unauthorized features are **visually disabled (grayed out) with a tooltip explaining why** — not hidden entirely. Users need to know the feature exists and what permission is required.
- Sensitive information (keys, tokens, mnemonics) is **masked by default**. Show/hide toggle to reveal. Revealing is logged to the audit trail.
- Session expiry warning: banner shown 5 minutes before expiry with "Stay logged in" button.
- Sensitive operations (export all data, delete account, view private key) logged to audit trail with timestamp, actor, and IP.

---

## 12. Animation & Micro-interactions

- Page transitions: 150ms fade or slide.
- Right Sheet open: 200ms ease-out slide from right. Close: 150ms ease-in.
- Modal open: 150ms scale-up from center + backdrop fade. Close: 100ms.
- Toast enter: 200ms slide-in from top-right. Exit: 150ms fade.
- Tooltip: 300ms delay before show (prevents flicker). Instant hide.
- Number changes (balance updates, counters): count-up animation 300ms.
- Sidebar collapse/expand: 250ms ease, icon labels fade, layout reflows smoothly.
- All animations respect `prefers-reduced-motion` — reduce to instant or simple fade.

---

## 13. Performance

- Page initial render: ≤ 300ms to interactive for cached data.
- List data cached on navigation — returning to a list does not trigger a full reload.
- Search debounce: 300ms.
- Optimistic updates: apply result immediately in UI, revert on API failure.
