# Wallet platform — load test results

**What we tested:** End-to-end wallet operations in a Docker lab matching our service topology (APIs, ledger, database, message broker). Tests include **high concurrency**, **optional fault injection** (slow clients, timeouts, bad requests, duplicate retries), and **post-run money checks** against the ledger.

**Bottom line:** The system **completes planned work at target volumes**, **honours idempotency under deliberate duplicate traffic**, and **ledger-aligned money checks** stay within tolerance after fee compensation. Figures below are from **internal engineering runs** (March 2026, Docker reference environment); production capacity depends on your hardware and configuration.

**Detail:** [load-test-reference-runs.md](load-test-reference-runs.md) (exact compose files, chaos rates, and latency tables).

---

## Throughput (sustained transfers)

| Scenario | Setup | Transfer throughput* | Latency (transfer phase) | Note |
|----------|-------|----------------------|---------------------------|------|
| **A — 10k clean gate** | Enhancement-proof overlay: rotating pairing, no chaos, concurrency 96 | **~146 ops/s** | p50 ~**0.5s**, p95 ~**0.8s** | Primary “happy path” ceiling after recent hot-path work |
| **B — 10k resilience** | Final chaos overlay: legacy pairing, mixed fault injection, concurrency 160 | **~89 ops/s** | p50 ~**1.1s**, p95 ~**1.9s** | **ReplayMismatches = 0**; some failures and WARN are expected from injection |
| **E — 1M clean (Docker)** | `compose/loadtest/loadtest-1m-no-chaos.yml` — 100k wallets, 1M transfers, concurrency 160, **four** workers + API | **~83 ops/s** | p50 ~**1.8s**, p95 ~**2.7s** | **1M / 1M** success (historical run with **fewer** workers); re-benchmark; consistency **PASS** after fee adjustment (see reference doc) |
| **F — 1M chaos (Docker)** | `compose/loadtest/loadtest-1m-chaos.yml` — same scale + chaos; **four** workers + API (log used **one** worker) | **~143 ops/s** | p50 ~**0.85s**, p95 ~**1.6s** | **~983.7k / 1M** success (**ReplayMismatches = 0**); consistency **WARN** (~**57 LYD** residual after fee adj on sample) |

\* *Operations per second* over the **transfer phase** (batch-measured; **F** counts **successful** transfers / duration). Scenarios are not all directly comparable (pairing, concurrency, pools, chaos, workers, and scale differ).

**Detail:** **250k** (**C** / **D**) and **1M** (**E** / **F**) are documented in [load-test-reference-runs.md](load-test-reference-runs.md).

---

## Reliability under pressure


| Metric                          | Result                                                                                    |
| ------------------------------- | ----------------------------------------------------------------------------------------- |
| **Planned transfers (10k clean)** | **10,000 / 10,000** success — no silent drops |
| **Planned transfers (10k chaos)** | **9,891 / 10,000** success — remainder mapped to injected invalid/timeout behaviour |
| **Planned transfers (1M clean, Run E)** | **1,000,000 / 1,000,000** success |
| **Planned transfers (1M chaos, Run F)** | **983,715 / 1,000,000** success — failures align with injected invalid destinations, timeouts, and retryable errors (see reference doc) |
| **Idempotency under replay** | **0 mismatches** (e.g. **268** replays on 10k chaos; **30,193** replays on **1M** chaos Run **F**) |
| **Money consistency (sampled)** | **PASS** on clean runs (10k, **1M Run E**); **WARN** on chaos runs with small residual after fee compensation (**~0.77 LYD** on 10k; **~57 LYD** on **1M Run F** — see reference doc) |


---

## What this demonstrates

1. **Capacity:** In the reference Docker stack, the platform sustained **~83–150 sustained successful wallet-to-wallet transfers per second** over the transfer phase depending on scale, pairing, concurrency, chaos, and consumer count (see table above; **1M** clean **~83 ops/s**; **1M** chaos with **two** transaction consumers **~143 ops/s** on successes).
2. **Consistency:** We validate **ledger-aligned balances**, not only “screen” balances, so brief UI timing differences do not hide real drift.
3. **Resilience:** Under **injected stress** (timeouts, invalid traffic, **duplicate submissions**), the system **rejects bad input** and **honours idempotency** — clients see predictable outcomes, not duplicate movements.
4. **Controlled overload:** When ingress exceeds safe concurrency, the API **signals saturation** so clients can **back off and retry safely** instead of overloading the core.

---

*This summary is for planning and assurance discussions. For contractual SLAs or production sign-off, use measurements taken on your target deployment.*