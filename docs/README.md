# Masarat Wallet — documentation

Technical documentation for the MITF wallet platform. Paths below are relative to this `docs/` folder.

**Repository:** This site is built from the [`docs/`](https://github.com/anstwechy/mitf_wallet_public_docs/tree/main/docs) folder in [mitf_wallet_public_docs](https://github.com/anstwechy/mitf_wallet_public_docs). For clone, build, and GitHub Pages setup, see the [repository README](https://github.com/anstwechy/mitf_wallet_public_docs/blob/main/README.md).

---

## By role

| If you are… | Start here |
| ----------- | ---------- |
| **Integrating** (REST/gRPC, auth, async polling) | [API reference](reference/api.md), [gRPC services](reference/grpc-services.md), [Transfer backpressure](architecture/transfer-backpressure-client-contract.md) |
| **Operating** (deploy, logs, load tests) | [Production deployment](operations/production-deployment.md), [Logging](operations/logging.md), [Load testing operations](operations/load-testing-operations.md) |
| **Configuring** services | [Configuration reference](reference/configuration-reference.md), [Per-service reference](reference/service-reference/README.md) |
| **Finance / audit** | [Financial operations and reconciliation](reconciliation/financial-operations-and-reconciliation.md), [Reconciliation job](reconciliation/reconciliation.md) |

---

## Directory map

| Directory | Purpose |
| --------- | ------- |
| [**architecture/**](architecture/) | Platform capabilities, domain events, consistency contract, transaction examples, backpressure contract |
| [**operations/**](operations/) | Production deployment, logging, load-test runbooks |
| [**reference/**](reference/) | API, gRPC listing, configuration keys, [service-reference/](reference/service-reference/) (per-host settings and DB tables) |
| [**security/**](security/) | API keys, PINs, tokens, hardening |
| [**reconciliation/**](reconciliation/) | Bank reconciliation job and business-facing finance narrative |
| [**load-testing/**](load-testing/) | Reference run results and stakeholder summaries |
| [**integrations/**](integrations/) | External system integration plans (for example FlowGuard AML) |

---

## All guides (A–Z)

| Document | Description |
| -------- | ----------- |
| [API reference](reference/api.md) | REST/gRPC usage, grpcurl, auth, health |
| [Configuration reference](reference/configuration-reference.md) | Cross-service configuration and env vars |
| [Domain events](architecture/events.md) | RabbitMQ event contracts |
| [Financial operations and reconciliation](reconciliation/financial-operations-and-reconciliation.md) | Flows, ledger mapping, reversal (business audience) |
| [FlowGuard AML integration](integrations/flowguard-wallet-aml.md) | Wallet to FlowGuard monitoring: bridge, RabbitMQ contract, phases, ops matrix |
| [gRPC services](reference/grpc-services.md) | RPC and message listing |
| [Load test reference runs](load-testing/load-test-reference-runs.md) | Recorded scenarios, metrics, comparisons |
| [Load testing operations](operations/load-testing-operations.md) | How to run overlays and read diagnostics |
| [Logging](operations/logging.md) | Structured logs, correlation, Loki/OTLP |
| [Outbox and ledger consistency](architecture/outbox-and-ledger-consistency.md) | Messaging durability, ledger ambiguity, recovery ownership |
| [Platform capabilities](architecture/platform-capabilities.md) | Consistency, durability, security, observability |
| [Production deployment](operations/production-deployment.md) | Sizing, ports, secrets, pools, load |
| [Reconciliation job](reconciliation/reconciliation.md) | Daily ledger vs bank export job |
| [Stakeholder load test summary](load-testing/stakeholder-load-test-summary.md) | Short throughput/consistency summary |
| [System hardening](security/system-hardening.md) | API keys, PIN, tokens, secrets |
| [Transaction flows and ledger examples](architecture/transaction-flows-and-ledger-examples.md) | Worked examples |
| [Transfer backpressure client contract](architecture/transfer-backpressure-client-contract.md) | Ingress limits and client retry rules |
