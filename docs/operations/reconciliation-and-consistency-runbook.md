# Reconciliation and internal consistency — operator runbook

This runbook ties together **bank–ledger reconciliation**, **internal consistency repair** (`UnknownNeedsReconciliation`), and **supporting background jobs**. Use it for monitoring, escalation, and knowing when automation stops and humans intervene.

---

## 1. Components

| Control | Service | What it does |
|--------|---------|----------------|
| Bank vs ledger match | `Masarat.Reconciliation.Job` | `ExportEntries` + bank feed; persists `ReconciliationRuns` / `ReconciliationExceptions`. |
| Internal consistency | `Masarat.Reconciliation.Job` | `RepairUnknownNeedsReconciliationBatch` against Transactions API. |
| Pending transaction repair | `Masarat.Transactions.Api` | Completes **Pending** rows when ledger already has entries. |
| Orphaned ledger accounts | `Masarat.Wallets.Api` | Detects ledger accounts without local wallet rows. |
| Deferred snapshot repair | `Masarat.Ledger.Api` | Corrects snapshot drift for deferred accounts. |
| Bank-facing export (reporting) | `Masarat.Reconciliation.Reporting` | Settlement-scoped HTTP export for operators (not the matcher DB). |

---

## 2. Metrics and logs (suggested)

Wire dashboards/alerts to your OTLP backend (Serilog sink + OpenTelemetry meters where enabled).

**Counters / gauges to watch**

- Reconciliation job: last successful `RunDate`, `ExceptionCount` per run, job failures (`Status = Failed`).
- Internal consistency: `ManualReviewCount`, `DeferredCount`, failed runs.
- Transactions: `transactions.pending_repair.recovered` (meter), `transactions.pending_repair.candidates_scanned`, pending **transaction** age in DB (SQL/report).
- Wallets: `wallets.orphaned_ledger.wallets_missing_local` (meter), orphan warnings in logs.
- Ledger: `ledger.deferred_snapshot.repairs` (meter) when verification fixes snapshots.
- Reporting: HTTP responses with `X-Masarat-Export-Truncated: true` (incomplete multi-page export).

**Log queries**

- `Orphaned ledger accounts detected for wallet` — wallet creation / ledger mismatch.
- `Exceeded the configured reconciliation export page limit` — replaced by truncation + header; search for `export truncated` / `ExportTruncated`.
- `Pending transaction repair` — recovered pending rows.

---

## 3. Retry boundaries

| Layer | Typical behavior | When it stops |
|-------|------------------|----------------|
| Client / gateway | Retries idempotent HTTP/gRPC with backoff | After policy exhausts; do not retry non-idempotent POST blindly. |
| MassTransit consumers | `UseMessageRetry` where configured | Message lands in error queue / DLQ — ops replay or fix data. |
| Ledger RPC | Timeouts + duplicate / unknown outcomes | `UnknownNeedsReconciliation` or explicit reconciliation-style handling. |
| Bank reconciliation | Daily catch-up + manual `/runs/retry` | Persistent `MissingInBank` / `MissingInLedger` — Finance + bank/provider. |

**Rule of thumb:** If the **idempotency key** is reused and outcome is still ambiguous after retries, route to **internal consistency** or **bank reconciliation**, not endless client retry.

---

## 4. Escalation

1. **Spike in `UnknownNeedsReconciliation` or internal consistency `ManualReview`** — Engineering + Compliance; freeze risky product changes until root cause (ledger outage, bad deploy, provider).
2. **Reconciliation exceptions (bank vs ledger)** — Finance owns triage per `docs/reconciliation/financial-operations-and-reconciliation.md`.
3. **Orphaned ledger accounts** — Engineering; retry wallet creation with same idempotency key or manual ledger/account alignment.
4. **Export truncated** (`X-Masarat-Export-Truncated: true`) — Widen date range, increase `Reporting:MaxExportPages`, or paginate at client; do not treat totals as complete.

---

## 5. Correlation for support

gRPC: send metadata **`x-correlation-id`** (or rely on W3C trace context if propagated). It is included in **gRPC server logs** when present (`CorrelationId` log scope).

---

## 6. References

- `docs/reconciliation/reconciliation.md` — matcher job.
- `docs/architecture/outbox-and-ledger-consistency.md` — ledger/local consistency model.
- `docs/reconciliation/financial-operations-and-reconciliation.md` — business narrative.
