# Media & interactive diagrams

Guidance for **video** embeds and **richer** visuals without bloating the core technical narrative.

---

## Video walkthroughs

| Placement | Recommendation |
| --------- | ---------------- |
| **Home / getting started** | Optional hero link to a short (≤10 min) walkthrough hosted on YouTube / Masarat-owned CDN. |
| **Complex flows** | Link out from [money movement](../architecture/money-movement-sequence-diagrams.md) or onboarding — avoid autoplay. |

Privacy: prefer **privacy-enhanced** embed parameters and disclose cookie behaviour if required by legal.

---

## Mermaid diagrams

- **Alt text:** Mermaid fences do not always expose rich alt text to assistive tech. Surround important diagrams with a **short prose summary** in the preceding paragraph (see [Accessibility](../accessibility.md)).  
- **Click handlers:** native Mermaid in MkDocs is static SVG/JS — “clickable” nodes require custom JS; treat as **advanced** and test accessibility if added.

---

## External tools (e.g. Eraser.io, Excalidraw)

Use for **design reviews**; export **PNG/SVG** into `docs/assets/` when a diagram must be versioned with the doc PR. Link the editable source in the PR description for maintainers.

## Related

- [Documentation roadmap](documentation-roadmap.md)  
