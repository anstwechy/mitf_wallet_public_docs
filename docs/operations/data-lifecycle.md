# Data lifecycle

Retention, **archival**, **GDPR-style** requests, and **indexing** notes. Legal retention often **overrides** technical defaults — fill `TBD` with compliance-approved numbers.

---

## Retention (illustrative)

| Data class | Typical location | Default retention | Legal / policy hold |
| ---------- | ---------------- | ----------------- | ------------------- |
| Transaction / ledger facts | Postgres | TBD years | TBD |
| Idempotency records | Service DB | TBD (align TTL with API docs — e.g. 24h for some keys) | |
| Domain events / queue | RabbitMQ | Operational (not long-term archive) | TBD |
| Application logs | Loki / ELK / cloud logging | TBD | TBD |
| Audit logs | TBD store | TBD | TBD |

Cross-check **idempotency** TTL language in [API reference](../reference/api.md).

---

## Archival

| Strategy | Use when | Implementation |
| -------- | -------- | ---------------- |
| Cold storage export | Multi-year retention, rare access | TBD (S3 Glacier, Azure Archive) |
| Partition / table rotation | Large ledger history | TBD monthly partitions |
| Legal hold | Litigation | TBD process — block purge jobs |

---

## GDPR / subject rights (if applicable)

Map product capabilities honestly:

| Request | Supported? | Mechanism | Gap / manual process |
| ------- | ---------- | --------- | ---------------------- |
| Export | TBD | TBD | |
| Erasure | TBD | Often constrained for ledger — legal review | |
| Rectification | TBD | | |

---

## Database indexing & performance

- Maintain a **living list** of first-class indexes per service (migration names + purpose) — TBD link to internal doc.  
- Before **large migrations**, estimate lock time and index build strategy (`CONCURRENTLY` on Postgres where applicable).  

## Related

- [Schema migration guide](schema-migration-guide.md)  
- [Security operations (audit retention)](../security/security-operations-advanced.md)  
- [Financial operations narrative](../reconciliation/financial-operations-and-reconciliation.md)  
