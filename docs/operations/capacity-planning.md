# Capacity planning

How teams **size** infrastructure for MITF wallet workloads. Pair with [load test reference runs](../load-testing/load-test-reference-runs.md) and [performance tuning](performance-tuning.md).

---

## Inputs

| Input | Source |
| ----- | ------ |
| Expected **DAU / MAU** | Product — TBD |
| Peak **transactions per minute** | Business forecast + historical — TBD |
| **Async latency** tolerance | Product SLO — TBD |
| **Multi-bank** isolation | Architecture — tenants per cluster |

---

## Sizing model (outline)

1. **Traffic funnel:** mobile → gateway → gRPC fan-out (Users, Wallets, Transactions).  
2. **CPU bound vs IO bound:** profile hottest RPCs under load test.  
3. **Database:** estimate row growth (transactions, ledger entries, idempotency rows) — link [data lifecycle](data-lifecycle.md).  
4. **Messaging:** sustained publish rate + peak backlog from slow consumers.  
5. **Headroom:** target **≤70%** sustained utilisation at peak — TBD policy.

---

## Hardware benchmarks

Maintain an internal table (example shell):

| Scenario | Hardware profile | TPS achieved | Notes |
| -------- | ---------------- | ------------ | ----- |
| Reference load test A | TBD | TBD | Link to run id |
| Soak test | TBD | TBD | |

Publish summaries in [load testing](../load-testing/load-test-reference-runs.md) when approved for external readers.

---

## Multi-region (when required)

| Concern | Question | Doc / owner |
| ------- | -------- | ----------- |
| Data residency | Must ledger stay in-country? | Legal — TBD |
| Active-active vs DR | Write path conflicts? | Architecture — TBD |
| Latency | Cross-region gRPC | TBD |

See [disaster recovery](disaster-recovery-runbook.md) for failover narrative.

## Related

- [Stakeholder load test summary](../load-testing/stakeholder-load-test-summary.md)  
- [Operations & technology (leadership)](../stakeholders/operations-and-technology.md)  
