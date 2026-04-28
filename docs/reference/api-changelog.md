# API changelog & deprecations

Tracks **integration-facing** API and contract milestones (REST, gRPC, webhooks, headers). This file complements [Changelog & releases](../changelog.md) (repo-wide) and [API versioning](api.md#api-versioning).

!!! tip "Source of truth"
    Production behaviour is defined by **deployed services** and internal release notes. Maintain this table when you ship user-visible contract changes.

---

## Active deprecations

| Area | Item | Deprecated from | Removal no earlier than | Migration |
| ---- | ---- | --------------- | ----------------------- | --------- |
| — | *None recorded in public docs yet* | — | — | — |

---

## Historical entries (template)

| Version / date | Change | Breaking? |
| -------------- | ------ | --------- |
| *YYYY-MM-DD* | *Example: `walletLabel` added to onboarding response (optional)* | No |

---

## How to add a row

1. Confirm with engineering + product.  
2. Add to **Active deprecations** (with **Removal no earlier than**).  
3. Update integrator comms and [API reference](api.md) in the same PR when possible.  
4. On removal, move row to **Historical** and bump [API changelog](../changelog.md) / GitHub Release.
