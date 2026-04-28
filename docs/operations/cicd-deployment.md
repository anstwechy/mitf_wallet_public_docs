# CI/CD & deployment patterns

Patterns for **safe releases**, **migrations**, **rollback**, **environment parity**, and **dependency hygiene** (including this MkDocs site).

---

## Blue / green or rolling (application)

| Pattern | When | Steps (outline) |
| ------- | ---- | --------------- |
| **Rolling** | Stateless APIs, backward-compatible DB | Increase new version, drain old pods — TBD orchestrator. |
| **Blue/green** | Need instant switch | Stand by green; switch LB; keep blue for fast rollback — TBD. |
| **Canary** | Risky change | Percentage traffic to new build — TBD mesh/ingress features. |

Coordinate with [schema migration guide](schema-migration-guide.md) so **DB** and **app** versions stay compatible.

---

## Database migration safety

See [Schema migration guide](schema-migration-guide.md). Production checklist:

- [ ] Expand-only phase complete in lower envs.  
- [ ] Backup verified (point-in-time if applicable).  
- [ ] Roll-forward plan documented; DBA on call.  
- [ ] Application feature flags (if any) align with migration — TBD.  

---

## Rollback procedures

| Layer | Rollback lever | Caveat |
| ----- | -------------- | ------ |
| Kubernetes / VMs | Revert to previous image | Old binary must work with **current** DB schema. |
| Database | Forward migration or restore | **Restore** = DR event — [DR runbook](disaster-recovery-runbook.md). |
| Config / secrets | Revert Git revision + redeploy | Watch caches and rolling restart order. |

---

## Environment parity checklist

| Check | Dev | Staging | Prod |
| ----- | --- | ------- | ---- |
| Same major Postgres version | ☐ | ☐ | ☐ |
| Feature flags matrix documented | ☐ | ☐ | ☐ |
| RabbitMQ policy equivalents | ☐ | ☐ | ☐ |
| Secrets **not** copied from prod | — | — | ☐ |

---

## Documentation site dependency policy (MkDocs)

This repository pins Python packages in [`requirements.txt`](https://github.com/anstwechy/mitf_wallet_public_docs/blob/main/requirements.txt).

| Package | Cadence | Owner |
| ------- | ------- | ----- |
| `mkdocs-material` | TBD (e.g. quarterly review) | TBD |
| `mkdocs` + plugins | After security advisories | TBD |
| Theme major upgrades | Test `mkdocs serve` + link check | TBD |

## Related

- [Production deployment](production-deployment.md)  
- [Disaster recovery runbook](disaster-recovery-runbook.md)  
