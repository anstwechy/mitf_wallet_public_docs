# Platform resilience

Surfaces **resilience** topics referenced across wallet docs: circuit breaking, **graceful degradation**, **dead-letter queues**, and **chaos** cadence. Implementation details are **`TBD`** where they depend on your hosting (k8s, Service Bus policies, Polly configs beyond gateway).

---

## Circuit breaking

**Gateway:** Customer Gateway documents Polly for downstream calls ([resilience keys](../reference/service-reference/Masarat.Gateway.Customer.Api.reference.md)). Tune `BreakDurationSeconds`, `FailureRatio`, `MinimumThroughput` with [performance tuning](performance-tuning.md).

**Other services:** Document service-specific breakers — TBD (HTTP clients, gRPC policies).

!!! note "Backpressure vs circuit breaker"
    **Transactional backpressure** ([client contract](../architecture/transfer-backpressure-client-contract.md)) signals capacity on specific RPCs. **Circuit breakers** stop calling a failing dependency for a cool-down period — complementary mechanisms.

---

## Graceful degradation

Answer these with architecture + on-call:

| Dependency down | Can reads work? | Can writes work? | Expected user experience |
| --------------- | --------------- | ---------------- | ----------------------- |
| **Ledger** | TBD | TBD | TBD |
| **Transactions queue** | TBD | TBD | TBD |
| **Users (onboarding)** | TBD | TBD | TBD |

Prefer **fail closed** for money movement when invariants cannot be checked.

---

## Dead-letter queue (DLQ)

| Topic / queue | DLQ name | Monitor (alert) | Runbook | Replay owner |
| --------------- | -------- | ---------------- | ------- | -------------- |
| TBD | TBD | Oldest message age | [Incident playbook](incident-response-playbook.md) | TBD |

Detection ideas: **queue length**, **redeliver count**, **consumer logs** — wire to [observability standards](observability-standards.md).

---

## Chaos or fault injection (cadence)

| Activity | Frequency | Scope | Last run |
| -------- | --------- | ----- | -------- |
| Kill random pod | TBD | Non-prod first | TBD |
| Broker partition simulation | TBD | TBD | TBD |
| Latency injection on gRPC | TBD | TBD | TBD |

Complement scheduled chaos with **game days** after major releases.

## Related

- [Production deployment](production-deployment.md)  
- [Load testing operations](load-testing-operations.md)  
