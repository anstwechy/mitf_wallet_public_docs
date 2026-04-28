# Accessibility & inclusive reading

These docs aim to meet common **financial-sector expectations** for readable, operable content. The site is built on [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/), which provides accessible navigation patterns out of the box. This page records what we rely on and how to report gaps.

---

## Keyboard & navigation

| Action | How |
| ------ | --- |
| Skip to main content | Use the **Skip to content** link at the top of each page (appears when tabbing). |
| Search | Open search from the header; **Esc** closes the overlay. |
| Side navigation | **Tab** / **Shift+Tab** through links; **Enter** activates. |
| Code blocks | When **Copy** appears on a block, it is reachable by keyboard and has an accessible label from the theme. |

---

## Visual design & contrast

- **Dual palettes:** light (**default**) and dark (**slate**) both use Material&rsquo;s primary/accent system with Masarat-specific tuning ([extra.css](https://github.com/anstwechy/mitf_wallet_public_docs/blob/main/docs/stylesheets/extra.css)).
- **Links** are underlined in body copy to distinguish them from plain text without relying on colour alone.
- **Focus styles:** browser default focus is augmented where custom components are used (see site stylesheet).

If you use **high-contrast** or **forced-colours** modes, report any unreadable control via GitHub (below).

---

## Motion

Decorative motion (e.g. gradient background animation) is reduced when the reader enables **prefers-reduced-motion** at the OS level.

---

## Reporting issues

- **General doc fixes:** use **Was this page helpful?** at the bottom of any page, or [open a documentation issue](https://github.com/anstwechy/mitf_wallet_public_docs/issues/new?labels=documentation).
- **Accessibility-specific:** open an issue with label **accessibility** (create it if your repo does not list it yet) and include page URL, browser, assistive technology, and expected vs actual behaviour.

We do not replace a formal **WCAG audit** or VPAT; this statement supports integrators and internal compliance teams who need transparency on intent and on how to escalate problems.

---

## Diagrams (Mermaid) & alt text

- **Mermaid** renders as vector graphics in the browser. Screen-reader users may not receive a full automatic description. For **important** diagrams, add a **one- or two-sentence summary** immediately before or after the diagram.
- **Colour:** do not rely on colour alone to distinguish states in new diagrams; use labels or shapes where possible.

---

## Contrast (WCAG-oriented)

The **teal / orange** theme is tuned for readability, but **WCAG 2.x contrast** for every interactive state has not been certified in this repo. If you need **formal AA/AAA** evidence:

1. Run an automated pass (axe, Lighthouse, or equivalent) on key templates.  
2. Manually verify **focus**, **hover**, and **active** states on header, search, tabs, and admonitions.  
3. File issues with repro steps and screenshots.

---

## Screen readers

Recommended smoke tests (quarterly or before major theme upgrades):

- **NVDA** (Windows) or **VoiceOver** (macOS/iOS) — navigate home, a long table page (for example [API reference](reference/api.md)), and the search dialog.  
- Confirm **headings** and **landmarks** make sense (Material provides main landmark and heading hierarchy from markdown).  

Report defects with **browser + OS + AT version**.
