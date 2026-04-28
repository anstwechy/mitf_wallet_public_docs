# Load testing operations

How to run load tests, which overlays to use, and how to interpret **async diagnostics** in batch logs. For canonical run results and comparisons, see [Load test reference runs](../load-testing/load-test-reference-runs.md). For deployment sizing and firewall notes, see [Production deployment](production-deployment.md) (load-related sections).

---

## Running overlays

1. **Base stack:** From the **wallet application** repository root (not this docs-only repo), start services with Docker Compose per that project’s README and `docker-compose.yml`.
2. **Load profile:** Apply a file under `compose/loadtest/` (for example `loadtest-250k-no-chaos.yml`) in addition to the base `docker-compose.yml`. Exact merge syntax depends on your Docker Compose version; the project script wraps common cases.
3. **Automation:** Use `scripts/run-loadtests.ps1` to drive multi-scenario runs when configured.
4. **Worker modes (`Masarat.LoadTest.Job`):**
   - **Direct gRPC:** Set `LoadTest__LoadTest__Enabled=true` (and related user/wallet/transaction addresses) for classic API-only journeys.
   - **Customer Gateway:** Set `LoadTest__CustomerGatewayLoadTest__Enabled=true`, `LoadTest__CustomerGatewayLoadTest__BaseUrl`, per-persona app IDs/keys, and optional `LoadTest__CustomerGatewayLoadTest__Profile`. See `docker-compose.yml` environment block for `masarat.loadtest.job`.

Default compose enables **Customer Gateway mixed traffic** so management dashboards populate quickly after startup. Set `LoadTest__CustomerGatewayLoadTest__Enabled=false` to keep the job idle for demos.

---

## Async diagnostic maxima

The load job logs percentiles and **max** for async transfer phases:

- **max** is the **largest single successful request’s** server-reported component among samples (queue wait, processing, or end-to-end server total), not the polling cap on the client.
- Under chaos or heavy backlog, a **few** requests can sit in RabbitMQ or behind consumer/DB pressure for **many minutes** while **p50/p95** stay moderate. That produces very large **max** values with rare tails.
- The job logs **p99** and typically emits a **warning** when any sample exceeds a threshold (e.g. **2 minutes**); treat that as a signal to inspect queue depth, consumer count, Postgres pool size, and ledger/transfer backpressure settings ([Transfer backpressure client contract](../architecture/transfer-backpressure-client-contract.md)).

When comparing runs, prefer **p95/p99** and throughput for regression detection; use **max** for tail-risk and backlog postmortems.

---

## Postgres messaging hygiene (inbox / outbox / idle transactions)

After very large runs (for example **1M transfers** with many Transactions workers), check whether symptoms are **transient** (load-only) or **creeping** (ops issue).

1. **Run a snapshot** on database **`MasaratWallets`** using [`scripts/sql/masaratwallets-messaging-health-snapshot.sql`](../../scripts/sql/masaratwallets-messaging-health-snapshot.sql) (from host: `docker exec -i masarat-db psql -U postgres -d MasaratWallets -f - < scripts/sql/masaratwallets-messaging-health-snapshot.sql`, or copy the file into the container and `psql -f`).
2. **`TransactionsInboxState` row count** often reaches **hundreds of thousands** while messages are still flying; after load stops, count should **fall** as MassTransit’s inbox cleanup deletes rows. If it **stays high for days**, increase observability (see below) and consider tuning **`Messaging:Tuning`** on **Transactions.Api** (same keys as Wallets outbox: `OutboxQueryDelayMs`, `OutboxQueryMessageLimit`, `OutboxIsolationLevel`, `OutboxDuplicateDetectionWindowMinutes`, `OutboxMessageDeliveryLimit`; optional `OutboxDisableInboxCleanupService` only for debugging — do not leave disabled in production).
3. **`idle in transaction`** sessions on `MasaratWallets` often correlate with **long consume pipelines**: the EF outbox wraps the consumer in a DB transaction; while the handler **awaits gRPC** (for example Ledger), the backend can appear **idle in transaction**. A **non-zero** count under stress is not automatically a leak, but **large** or **long-lived** `xact_age` values warrant checking pool sizes, `max_connections`, and whether any code path holds a transaction open longer than necessary.
4. **Inbox cleanup deadlocks** (`TransactionsInboxState`, `InboxCleanupService`) may appear in logs as **retried** warnings. Treat **spikes** or **failures after retries** as the real problem; occasional retries under peak load are a known contention pattern.

**Grafana / metrics:** Point a Postgres data source at the same queries in the script (single-stat or time series if you record outputs on a schedule), or use **postgres_exporter** custom queries for `COUNT(*)` on `TransactionsInboxState` and `COUNT(*) FROM pg_stat_activity WHERE state = 'idle in transaction' AND datname = 'MasaratWallets'`.

---

## Consistency checks in the job

Sampled wallet balance sums and fee adjustments are logged as **PASS** or **WARN** depending on tolerance. Residuals under chaos are expected to be small relative to gross volume; see narrative in [load test reference runs](../load-testing/load-test-reference-runs.md) for interpretation.

---

## Related docs

- [Load test reference runs](../load-testing/load-test-reference-runs.md) — recorded runs and analysis  
- [Stakeholder load test summary](../load-testing/stakeholder-load-test-summary.md) — short executive summary  
- [Transfer backpressure client contract](../architecture/transfer-backpressure-client-contract.md) — client and ingress expectations  
