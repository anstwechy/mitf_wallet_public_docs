# Offline compliance packs (print & PDF)

Use this hub when you need **Security** and **Reconciliation** chapters for an **offline** audit binder, PDF archive, or air-gapped review. The published site does not ship pre-built PDFs; you generate them in seconds from the live HTML.

!!! tip "Why not a single auto-PDF in CI?"
    High-fidelity PDF pipelines (headless Chrome, LaTeX, or commercial exporters) add weight and differ by OS and fonts. Browser **Print → Save as PDF** uses the same layout integrators see online and respects Material&rsquo;s print stylesheet.

---

## Quick method (recommended)

1. Open the section you need in the **published site** or a local `mkdocs serve` build.
2. Use your browser&rsquo;s print dialog (**Ctrl+P** / **⌘P**).
3. Choose **Save as PDF** (or a virtual PDF printer).
4. In print options, enable **Background graphics** if diagrams or code blocks must match the on-screen theme.

Material hides navigation chrome when printing, so you get a readable single-column document.

---

## Security (print these pages)

| Topic | Page |
| ----- | ---- |
| System hardening (API keys, PINs, tokens, ops) | [System hardening](../security/system-hardening.md) |
| Onboarding channel | [Onboarding channel hardening](../security/onboarding-channel-hardening.md) |

---

## Reconciliation (print these pages)

| Topic | Page |
| ----- | ---- |
| Financial operations narrative | [Financial operations](../reconciliation/financial-operations-and-reconciliation.md) |
| Reconciliation job | [Reconciliation job](../reconciliation/reconciliation.md) |

---

## Optional: operations runbook (often requested with reconciliation)

| Topic | Page |
| ----- | ---- |
| Reconciliation & consistency runbook | [Runbook](../operations/reconciliation-and-consistency-runbook.md) |

---

## Evidence trail

- **Last updated** and **version badge** appear at the bottom of each page (git dates + docs bundle label).
- **Change stream:** [Changelog & releases](../changelog.md); after each deploy, syndication files live at the site root as `feed_rss_updated.xml` and `feed_json_updated.json` (also linked from the top banner).

If you need **official** stamped PDFs from Masarat, track that through your programme office or account team and reference the export timestamp and site version badge in your audit workpapers.
