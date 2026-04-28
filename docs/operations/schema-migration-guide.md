# Schema migration guide (production operators)

Guidance for **database schema changes** (including EF Core migrations) when running MITF wallet services in production. Replace **`TBD`** with your org’s tools (Flyway, round-robin deploy, etc.).

---

## Principles

1. **Backwards-compatible first:** expand (add nullable columns, new tables), then contract in a **later** release after all apps read/write the new shape.  
2. **No destructive surprises:** dropping columns or tightening NOT NULL without a phased rollout causes outages.  
3. **One-way door checklist:** get peer + DBA + (if needed) compliance sign-off before irreversible migrations.

---

## EF Core migrations (typical flow)

| Phase | Action |
| ----- | ------ |
| Dev | Generate migration; review SQL; run against disposable DB in CI — TBD pipeline link. |
| Staging | Apply migration; run **integration + smoke** tests; measure lock time on representative data size. |
| Prod window | **Maintenance window** or **online migration** strategy — TBD (see below). |
| Verify | Application health, row counts, index usage, replication lag — TBD dashboards. |
| Rollback | Prefer **forward-fix** migration; **restore from backup** only with [DR runbook](disaster-recovery-runbook.md). |

---

## Online vs maintenance window

| Approach | When to use | Notes |
| -------- | ----------- | ----- |
| **Expand-only + dual-write** | High availability required | Two deploy phases; old code reads both shapes until cutover. |
| **Maintenance window** | Rare destructive change | Stop traffic or put gateway in **read-only** if supported — TBD. |
| **Blue/green + shadow** | Large tables | TBD link [CI/CD patterns](cicd-deployment.md). |

---

## Idempotency and data validity

- Migrations must tolerate **retry** if the runner crashes mid-flight — use transactional DDL where the database supports it; document exceptions (PostgreSQL, …).  
- After migration, validate **idempotency** keys and **ledger** consistency per [reconciliation runbook](reconciliation-and-consistency-runbook.md).

---

## Version coupling

Document which **app version** requires which **migration revision**. Store mapping in release notes or internal wiki — TBD.

## Related

- [Production deployment](production-deployment.md)  
- [API versioning — semantics](../reference/api.md#api-versioning)  
- [CI/CD & deployment patterns](cicd-deployment.md)  
