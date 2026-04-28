# Full site index

Use the **sidebar** for the recommended order. This page is a **flat lookup** by title.

## Masarat leadership

| Page | Description |
| ---- | ----------- |
| [Executive & business overview](../stakeholders/executive-overview.md) | Commercial product story for Masarat leaders (non-technical) |
| [Operations & technology (leadership)](../stakeholders/operations-and-technology.md) | COO/CIO/SRE-oriented topology and operability |
| [Platform at a glance (stakeholders)](../stakeholders/index.md) | Leadership entry — outcomes and simple map (non-technical) |
| [Risk, compliance & finance (leadership)](../stakeholders/risk-compliance-and-finance.md) | Control themes for risk, AML, audit, finance (non-technical) |

---

## All other pages (A–Z by title)

| Page | Description |
| ---- | ----------- |
| [5-minute quickstart](../getting-started/quickstart.md) | Curl + auth onboarding for new integrators |
| [Accessibility](../accessibility.md) | Keyboard use, contrast, motion, reporting gaps |
| [AML bridge — tenant resolution](../integrations/aml-bridge-tenant-resolution.md) | How `BankId` is resolved for FlowGuard routing |
| [AML integration (overview)](../integrations/aml-integration.md) | Wallet → FlowGuard bridge components and config |
| [API changelog & deprecations](../reference/api-changelog.md) | Deprecation timeline and contract milestones |
| [API clients & collections](../reference/api-client-and-collections.md) | Postman, Insomnia, SDKs, OpenAPI workflow |
| [API reference](../reference/api.md) | REST/gRPC usage, grpcurl, auth, health |
| [Architecture Decision Records](../architecture/decisions/README.md) | ADR index and template |
| [Capacity planning](../operations/capacity-planning.md) | Infra sizing and benchmark hooks |
| [Changelog & releases](../changelog.md) | Release notes links and integration change tracking |
| [CI/CD & deployment patterns](../operations/cicd-deployment.md) | Blue/green, rollback, env parity, docs deps |
| [Configuration reference](../reference/configuration-reference.md) | Cross-service configuration and env vars |
| [Customer Gateway (service ref)](../reference/service-reference/Masarat.Gateway.Customer.Api.reference.md) | Gateway host settings |
| [Data lifecycle & retention](../operations/data-lifecycle.md) | Retention, archival, GDPR hooks, indexing |
| [Disaster recovery runbook](../operations/disaster-recovery-runbook.md) | Backup, RTO/RPO, restore, failover template |
| [Documentation roadmap](../meta/documentation-roadmap.md) | Known gaps and priority matrix |
| [Domain events](../architecture/events.md) | RabbitMQ event contracts |
| [Financial operations and reconciliation](../reconciliation/financial-operations-and-reconciliation.md) | Flows, ledger mapping, reversal (business audience) |
| [FlowGuard wallet / AML plan](../integrations/flowguard-wallet-aml.md) | Bridge, RabbitMQ contract, phases, ops matrix |
| [Gateway Management Web (service ref)](../reference/service-reference/Masarat.Gateway.Management.Web.reference.md) | Management web host |
| [Glossary](../glossary.md) | Domain terms (idempotency, outbox, …) |
| [gRPC services](../reference/grpc-services.md) | RPC and message listing |
| [Incident response playbook](../operations/incident-response-playbook.md) | Ledger drift, MQ backlog, DB failure triage |
| [KYC API (service ref)](../reference/service-reference/Masarat.Kyc.Api.reference.md) | KYC host reference |
| [Ledger API (service ref)](../reference/service-reference/Masarat.Ledger.Api.reference.md) | Ledger host reference |
| [LoadTest job (service ref)](../reference/service-reference/Masarat.LoadTest.Job.reference.md) | Load test worker reference |
| [Load test reference runs](../load-testing/load-test-reference-runs.md) | Recorded scenarios, metrics, comparisons |
| [Load testing operations](../operations/load-testing-operations.md) | How to run overlays and read diagnostics |
| [Local development setup](../getting-started/local-development.md) | venv + MkDocs bootstrap |
| [Logging](../operations/logging.md) | Structured logs, correlation, Loki/OTLP |
| [Media & diagrams](../meta/media-and-diagrams.md) | Video and interactive diagram policy |
| [Money movement — sequence diagrams](../architecture/money-movement-sequence-diagrams.md) | One sequence diagram per wallet financial journey (aligned with main repo README) |
| [Observability standards](../operations/observability-standards.md) | Dashboards, alerts, tracing, SLO hooks |
| [Offline packs (print / PDF)](../compliance/offline-packs.md) | Security & reconciliation chapters for offline audit binders |
| [Onboarding channel hardening](../security/onboarding-channel-hardening.md) | Onboarding-specific security |
| [OpenAPI in docs (advanced)](../reference/openapi-in-docs.md) | Roadmap for embedded Swagger/Redoc on GitHub Pages |
| [Outbox and ledger consistency](../architecture/outbox-and-ledger-consistency.md) | Messaging durability, ledger ambiguity, recovery |
| [Performance tuning](../operations/performance-tuning.md) | Knobs by deployment tier |
| [Platform capabilities](../architecture/platform-capabilities.md) | Consistency, durability, security, observability |
| [Platform resilience & DLQ](../operations/platform-resilience.md) | Degradation, DLQ, chaos cadence |
| [Production deployment](../operations/production-deployment.md) | Sizing, ports, secrets, pools, load |
| [Reconciliation job](../reconciliation/reconciliation.md) | Daily ledger vs bank export job |
| [Reconciliation job (service ref)](../reference/service-reference/Masarat.Reconciliation.Job.reference.md) | Reconciliation worker reference |
| [Reconciliation reporting (service ref)](../reference/service-reference/Masarat.Reconciliation.Reporting.reference.md) | Reporting host reference |
| [Reconciliation & consistency runbook](../operations/reconciliation-and-consistency-runbook.md) | Ops runbook for consistency checks |
| [Schema & migration (production)](../operations/schema-migration-guide.md) | EF Core / DB migration safety |
| [Security operations (rate limits, audit, secrets, mTLS)](../security/security-operations-advanced.md) | Gateway quotas, logging retention, rotation, mTLS |
| [Service reference index](../reference/service-reference/README.md) | Per-host settings and DB tables |
| [Stakeholder load test summary](../load-testing/stakeholder-load-test-summary.md) | Short throughput/consistency summary |
| [System hardening](../security/system-hardening.md) | API keys, PIN, tokens, secrets |
| [Transaction flows and ledger examples](../architecture/transaction-flows-and-ledger-examples.md) | Worked examples |
| [Transactions API (service ref)](../reference/service-reference/Masarat.Transactions.Api.reference.md) | Transactions host reference |
| [Transfer backpressure client contract](../architecture/transfer-backpressure-client-contract.md) | Ingress limits and client retry rules |
| [Troubleshooting (flowcharts)](../operations/troubleshooting.md) | Decision-style triage trees |
| [Users API (service ref)](../reference/service-reference/Masarat.Users.Api.reference.md) | Users host reference |
| [Wallets API (service ref)](../reference/service-reference/Masarat.Wallets.Api.reference.md) | Wallets host reference |
| [Webhooks API (service ref)](../reference/service-reference/Masarat.Webhooks.Api.reference.md) | Webhooks host reference |
