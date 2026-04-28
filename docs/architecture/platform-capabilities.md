# Platform capabilities (consistency, durability, security)

This document summarizes **what the codebase and runtime actually provide** today: financial correctness, resilience under failure and load, security boundaries, and operability. Use it with [Outbox and ledger consistency](outbox-and-ledger-consistency.md) for delivery semantics and recovery ownership.

---

## 1. Financial correctness (ledger and orchestration)

| Capability | Where it shows up |
| ---------- | ----------------- |
| **Double-entry invariant** | `PostJournal` requires the sum of leg amounts to be **zero**; currency must match each account. |
| **Ledger entry idempotency** | Unique `IdempotencyKey` on `LedgerEntries`; gRPC returns `LedgerSubmissionOutcome` (success, duplicate, reject, transient, unknown). |
| **Atomic multi-leg journals** | One `PostJournal` applies all legs in a single handler/repository transaction. |
| **Balance snapshots** | `LedgerBalanceSnapshot` updated with postings; optional deferred accounts for hot paths. |
| **Processed snapshot deduplication** | `LedgerProcessedSnapshotEvents` records processed async work keys so replay does not double-apply snapshot side effects. |
| **Orchestrated money flows** | Transactions validates wallets, classifications, fees, and balance **before** calling Ledger; persists `Transaction` rows with status transitions. |
| **Reversal idempotency** | **Transactions** persists `ReverseTransactionIdempotency` rows (shared persistence types) so retries do not double-reverse. |

---

## 2. Messaging consistency and durability

| Capability | Where it shows up |
| ---------- | ----------------- |
| **Transactional outbox** | **Wallets** and **Transactions** use MassTransit **EF Core outbox** (PostgreSQL), so publish intent is **durable in the same database commit** as business rows. |
| **Outbox tuning** | Isolation level, query delay/limit, message delivery limit, duplicate detection window (Wallets); Postgres outbox on Transactions with bus outbox. |
| **Consumer concurrency** | Configurable prefetch, retry intervals, and per-consumer concurrent limits (e.g. transfer and fund-wallet consumers). |
| **Async command path** | High-volume flows can be queued to RabbitMQ; completion events drive downstream ledger snapshot work and webhooks. |
| **Explicit consistency contract** | [Outbox and ledger consistency](outbox-and-ledger-consistency.md) defines at-least-once delivery, inbox + domain idempotency, non-atomic ledger RPC, and internal `UnknownNeedsReconciliation` semantics. |

---

## 3. Load protection and tail-latency control

| Capability | Where it shows up |
| ---------- | ----------------- |
| **Ledger ingress backpressure** | `LedgerConcurrencyGate` + options cap **in-flight reads and writes**; gRPC interceptor can fail fast when saturated. |
| **Transactions transfer gate** | `TransferConcurrencyGate` and `TransferBackpressureOptions` cap concurrent transfer work (see [transfer backpressure client contract](transfer-backpressure-client-contract.md)). |
| **Hosted maintenance** | `PendingTransactionRepairService` and `IdempotencyRetentionCleanupService` reduce stuck or over-retained idempotency state. |
| **Customer Gateway rate limits** | Partitioned limits (auth bootstrap, reads, transaction writes, operation status polling). |

---

## 4. Security and tenant isolation

| Capability | Where it shows up |
| ---------- | ----------------- |
| **API key auth** | Core APIs: REST middleware + gRPC interceptor; health routes excluded ([system hardening](../security/system-hardening.md)). |
| **Bank-scoped context** | Transactions requires `x-bank-id`; shared **ApiCommon** carries actor/bank context into handlers and downstream calls. |
| **Wallet PIN** | PBKDF2 hashing, lockout, optional **short-lived transaction authorization token** for debits when enforcement is enabled. |
| **Customer Gateway** | Per-app credentials (`AppId` + API key), optional **JWT** for end-user identity, **persona / app-type** route filters (customer / business / merchant), audit and correlation middleware. |

---

## 5. Observability and production operations

| Capability | Where it shows up |
| ---------- | ----------------- |
| **OpenTelemetry** | Traces, metrics, logs to OTLP collector → Tempo, Prometheus, Loki; Grafana datasources. |
| **Structured logging** | Serilog JSON; correlation IDs; gRPC call duration logging ([logging](../operations/logging.md)). |
| **External configuration** | Optional Consul KV. |
| **Reconciliation** | **Reconciliation.Job** exports ledger entries and matches to bank statements; separate from internal ledger/local repair paths ([reconciliation](../reconciliation/reconciliation.md)). |
| **Load and chaos testing** | Compose overlays under `compose/loadtest/`, **Masarat.LoadTest.Job** (direct gRPC and optional **customer gateway** journeys), reference numbers in [load test reference runs](../load-testing/load-test-reference-runs.md). |

---

## 6. Bounded contexts and integration style

| Service / worker | Persistence | Typical sync | Typical async |
| ---------------- | ----------- | ------------ | ------------- |
| **Ledger** | `MasaratLedger` | gRPC from Wallets/Transactions | Consumes completion events for snapshot updates |
| **Wallets** | `MasaratWallets` | gRPC | Outbox publish; inbox consumers |
| **Transactions** | Shared wallets DB for transactions + wallet reads | gRPC | Outbox + multiple command consumers |
| **Users** | `MasaratUsers` | REST + gRPC | MassTransit consumers |
| **Customer Gateway** | None (stateless orchestration) | HTTP to Users; gRPC to Wallets/Transactions | — |
| **LoadTest.Job** | — | gRPC and/or HTTP to gateway | — |
| **Reconciliation** | `MasaratReconciliation` | gRPC `ExportEntries` | Scheduled job |

---

## Related documentation

- [Documentation index](../README.md) — all guides and references on this site  
- [Financial operations and reconciliation](../reconciliation/financial-operations-and-reconciliation.md) — flows and reversal  
- [Production deployment](../operations/production-deployment.md) — sizing and deployment  
- [Domain events](events.md) — published domain events  
