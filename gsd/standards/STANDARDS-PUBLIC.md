# Public-Facing UI Standards

Applies to **public pages only** — any page accessible without authentication: marketing sites, landing pages, product pages, blogs, documentation.
Does **not** apply to authenticated dashboards, admin panels, or internal tools.

Read `~/.gsd/STANDARDS.md` first — this file extends it.

---

## 1. SEO — Search Engine Optimization

- **Every public page has a unique `<title>` and `<meta name="description">`.** Titles under 60 characters. Descriptions under 160 characters. Never leave them as framework defaults.
- **Semantic HTML structure.** Use `<main>`, `<nav>`, `<header>`, `<footer>`, `<article>`, `<section>`, `<aside>` appropriately. Do not build pages out of `<div>` and `<span>` only.
- **Heading hierarchy.** One `<h1>` per page. Headings descend in order (H1 → H2 → H3) without skipping levels.
- **All images have `alt` attributes.** Decorative images use `alt=""`. Meaningful images have descriptive alt text.
- **Canonical tags on every public page.** `<link rel="canonical">` prevents duplicate content penalties from URL parameters or trailing slashes.
- **Open Graph and Twitter Card meta tags.** Every public page defines at minimum: `og:title`, `og:description`, `og:image`, `og:url`, `twitter:card`. Social sharing previews must be tested.
- **Structured data (JSON-LD).** Add Schema.org markup: `WebSite` on homepage, `Article` on blog posts, `FAQPage` on FAQ sections, `Product` on product pages, `Organization` on about/contact.
- **sitemap.xml is auto-generated.** Includes all public pages with `<lastmod>`. Referenced in `robots.txt`. Submitted to Google Search Console.
- **robots.txt is explicit.** Disallow authenticated routes, internal API endpoints, and admin paths. Allow all public content.
- **Server-side rendering or static generation for public pages.** CSR alone is not acceptable — crawlers do not reliably execute JavaScript.
- **Core Web Vitals targets.** LCP < 2.5s, CLS < 0.1, INP < 200ms. Measure with Lighthouse before launch.
- **URLs are human-readable and stable.** Lowercase, hyphenated slugs (`/blog/how-to-trade`). Once public, never change a URL without a 301 redirect.
- **Internal links use descriptive anchor text.** `"how batch trading works"` not `"click here"`.

---

## 2. GEO — Generative Engine Optimization

- **Structure content for AI comprehension.** Key answers must appear in plain text near the top of the relevant section — not hidden behind tabs, accordions, or JavaScript interactions.
- **Direct answers, not just navigation.** Each page should answer a specific question completely within itself.
- **FAQ sections with explicit Q&A structure.** Use `<dt>`/`<dd>` or heading + paragraph pairs. Pair with `FAQPage` JSON-LD.
- **Clear, factual language.** Avoid vague marketing copy ("best-in-class"). Use concrete, verifiable claims ("supports 100 wallets", "EVM and Solana compatible").
- **No core content behind JavaScript rendering.** AI crawlers do not reliably execute JavaScript. Key content must be in server-rendered HTML.
- **`llms.txt` at the site root.** Plain-text summary of what the product does, key pages, and API documentation URLs. Helps LLMs understand and cite the product accurately.
- **Structured data doubles as GEO signal.** JSON-LD `FAQPage`, `HowTo`, `Article`, `Product` are consumed by AI summarization pipelines.
- **Content freshness signals.** Include `<meta name="article:modified_time">` or JSON-LD `dateModified` on content pages.

---

## 3. Performance

- **Core Web Vitals are a hard requirement** (see SEO section). Measure on every release.
- **Images are optimized.** Use modern formats (WebP, AVIF). Serve responsive sizes via `srcset`. Lazy-load below-the-fold images.
- **Fonts are optimized.** Preload critical fonts. Use `font-display: swap`. Prefer variable fonts to reduce HTTP requests.
- **No render-blocking resources above the fold.** Critical CSS is inlined or preloaded. Non-critical JS is deferred or async.
- **Third-party scripts are audited.** Every analytics, chat, or marketing script adds weight and latency. Justify each one. Load them after the page is interactive.

---

## 4. Accessibility (Public Pages)

- **WCAG 2.1 AA compliance** is the minimum bar for all public pages.
- **Keyboard navigation.** Every interactive element is reachable and operable by keyboard alone.
- **Focus ring is always visible.** Never `outline: none` without a styled replacement.
- **Screen reader support.** All images have alt text. Form inputs have labels. Error messages are announced via `aria-live`. Modal dialogs trap focus correctly.
- **Color is not the only signal.** Never convey information by color alone (e.g. a red border is not sufficient — add an icon or text).
- **Skip navigation link.** A "Skip to main content" link is the first focusable element on every page.
