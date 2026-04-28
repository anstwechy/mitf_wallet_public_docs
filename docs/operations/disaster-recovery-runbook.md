# Disaster recovery runbook

Business-continuity reference for **backup**, **restore**, **failover**, and recovery objectives. Replace every `TBD` with values owned by your **platform / SRE** team and keep them in sync with actual backups and vendor SLAs.

---

## Scope

| Component | In scope for this runbook | Notes |
| --------- | --------------------------- | ----- |
| PostgreSQL (per service) | TBD | List clusters / instances. |
| RabbitMQ | TBD | Cluster topology, vhosts, policies. |
| Application secrets | TBD | Vault / Key Vault / parameter store. |
| Object / blob storage (if any) | TBD | Receipts, exports, … |

---

## Recovery objectives

| Metric | Target (fill in) | Measurement |
| ------ | ------------------ | ----------- |
| **RPO** (Recovery Point Objective) | TBD (e.g. max acceptable data loss window) | From last successful backup or replica lag. |
| **RTO** (Recovery Time Objective) | TBD (e.g. max time to restore service) | Incident clock from “failed” to “read/write restored”. |

!!! danger "Regulatory sign-off"
    RPO/RTO and actual drill results may require **risk** and **compliance** approval; this page is a template only.

---

## Backup procedures

Document **who** runs backups, **how often**, and **where** they land.

| Data store | Method (snapshot / logical / PITR) | Frequency | Retention | Encryption | Verify restore (last drill) |
| ---------- | ----------------------------------- | --------- | --------- | ---------- | --------------------------- |
| Postgres primary | TBD | TBD | TBD | TBD | TBD |
| RabbitMQ definitions / messages | TBD | TBD | TBD | TBD | TBD |

---

## Restore procedures (high level)

1. **Stop ingress** (load balancer / gateway) if partial corruption is suspected — TBD playbook link.  
2. **Restore database** from validated backup to a **clean instance**; replay or skip WAL / PITR per DBA runbook — TBD.  
3. **Reconcile RabbitMQ** (purge poison queues, rebuild consumers) — coordinate with [incident response playbook](incident-response-playbook.md).  
4. **Replay outbox / idempotency** — follow [outbox & ledger consistency](../architecture/outbox-and-ledger-consistency.md) and engineering guidance.  
5. **Smoke tests**: health, single onboarding, single transfer in non-prod mirror first.  
6. **Communicate** status to stakeholders per comms tree — TBD.

---

## Failover

| Scenario | Trigger | Steps | Owner |
| -------- | ------- | ----- | ----- |
| AZ failure | TBD | TBD (DNS, k8s, DB replica promote) | TBD |
| Region failure | TBD | TBD (cold/warm standby) | TBD |

---

## Tests and audits

- **Tabletop:** TBD (quarterly / annual).  
- **Full restore drill:** TBD.  
- **Evidence:** Store drill reports where auditors expect them — TBD.

## Related

- [Production deployment](production-deployment.md)  
- [Logging](logging.md)  
- [Incident response playbook](incident-response-playbook.md)  
