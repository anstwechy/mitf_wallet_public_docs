# Performance tuning

Configuration and topology **knobs** by approximate deployment size. Values are **starting points** — measure with load tests ([load testing](load-testing-operations.md)) and production metrics.

---

## Deployment tiers (conceptual)

| Tier | Rough profile | Examples |
| ---- | ------------- | -------- |
| **Small** | Single AZ, modest concurrency, dev / pilot | TBD pod counts / VM sizes. |
| **Medium** | Production single region, HA DB, several banks | TBD. |
| **Large** | High throughput, strict latency SLOs, optional multi-AZ | TBD. |

---

## Gateway / HTTP edge

Customer Gateway exposes **rate limiting** and downstream timeouts — see [Customer Gateway reference](../reference/service-reference/Masarat.Gateway.Customer.Api.reference.md) and [configuration reference](../reference/configuration-reference.md).

| Knob | Small | Medium | Large | Risk if mis-set |
| ---- | ----- | ------ | ----- | ---------------- |
| `RateLimiting:*PermitLimit` | Start at defaults | TBD | TBD | User-facing 429s or thundering herd. |
| `DownstreamResilience:*TimeoutMs` | Default | Tighten writes carefully | May need higher for cold DB | Timeouts mask backend saturation. |
| `DownstreamResilience:MaxRetryAttempts` | 2 (default) | TBD | Too high amplifies overload | Retry storms. |

---

## gRPC / Transactions / Wallets

| Concern | Tuning idea | Doc |
| ------- | ----------- | --- |
| Async money RPCs | Client poll interval for `GetRequestStatus` — avoid hot loops | [Backpressure](../architecture/transfer-backpressure-client-contract.md) |
| Database pools | Pool min/max per service | [Production deployment](production-deployment.md) |
| Messaging prefetch | Consumer prefetch vs fair dispatch | TBD internal RabbitMQ policy |

---

## Ledger / Postgres

| Knob | Notes |
| ---- | ----- |
| Index maintenance | After large backfills, run **ANALYZE** / rebuild as per DBA — see [data lifecycle](data-lifecycle.md). |
| Connection limits | Sum of all service pools must be < `max_connections` — TBD. |

---

## Checklist before “scaling up hardware”

1. Confirm **saturation resource** (CPU, disk IOPS, DB connections, queue depth).  
2. Review **p95/p99** latency breakdown (gateway vs DB vs broker).  
3. Re-run **representative load** with same scenario as [reference runs](../load-testing/load-test-reference-runs.md).  

## Related

- [Observability standards](observability-standards.md)  
- [Platform resilience](platform-resilience.md)  
