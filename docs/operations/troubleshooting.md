# Troubleshooting (decision trees)

Use these **flowcharts** when triaging common symptoms. Pair with [incident response](incident-response-playbook.md) for severity and comms.

**Summary:** Start from HTTP auth/rate-limit issues, then downstream timeouts; for transfers, distinguish backpressure from async polling; for reconciliation, narrow data vs mapping problems.

---

## HTTP 4xx/5xx from mobile app → Customer Gateway

```mermaid
flowchart TD
  A[Client error or timeout] --> B{401/403?}
  B -->|Yes| C[Check App API key + JWT validity]
  B -->|No429?| D[Gateway rate limits — see security ops supplement]
  B -->|No| E{504/timeout?}
  E -->|Yes| F[Downstream gRPC/HTTP timeout — check resilience config]
  E -->|No| G{5xx from app code?}
  G -->|Yes| H[Check service logs + correlation id]
  C --> I[See logging runbook]
  D --> I
  F --> I
  H --> I
```

For log fields and correlation IDs, see the [logging runbook](logging.md).

---

## Transfer “stuck” or unknown status

```mermaid
flowchart TD
  A[Transfer submitted] --> B{Immediate error?}
  B -->|ResourceExhausted| C[Backpressure — backoff per contract](../architecture/transfer-backpressure-client-contract.md)
  B -->|No| D[Got request_id?]
  D -->|Yes| E[Poll GetRequestStatus until terminal]
  D -->|No| F[Check gateway + Transactions logs]
  E --> G{Terminal failure?}
  G -->|Yes| H[Idempotent retry with new key if business allows]
  G -->|No success| I[Investigate queue + ledger]
```

---

## Reconciliation exceptions

```mermaid
flowchart TD
  A[Exceptions in run] --> B[Open run detail + export slice]
  B --> C{Data entry timing?}
  C -->|Yes| D[Clock-skew / batch boundary — adjust window]
  C -->|No| E{Amount mismatch?}
  E -->|Yes| F[Ledger vs bank feed — escalate engineering]
  E -->|No| G[Bad mapping / config — review job settings]
```

---

## Where to look first

| Signal | First checks |
| ------ | ------------ |
| Slow API | Gateway latency, DB slow queries, Rabbit depth — TBD dashboards. |
| Errors spike | [Logging](logging.md), correlation id across Users / Wallets / Transactions. |
| Disk full | Postgres volumes, log retention — [data lifecycle](data-lifecycle.md). |

## Related

- [Performance tuning](performance-tuning.md)  
- [Reconciliation & consistency runbook](reconciliation-and-consistency-runbook.md)  
