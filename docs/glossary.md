# Glossary

Short definitions for terms used across MITF wallet documentation. For behaviour detail, follow the links.

| Term | Meaning |
| ---- | ------- |
| **Backpressure** | Server-side signalling (for example `ResourceExhausted`) when load exceeds safe capacity; clients must back off per [transfer backpressure](architecture/transfer-backpressure-client-contract.md). |
| **Customer Gateway** | REST façade for mobile apps: app API keys, optional JWT, orchestration to Users / Wallets / Transactions — see [Customer Gateway reference](reference/service-reference/Masarat.Gateway.Customer.Api.reference.md). |
| **Deferred snapshot** | (If used in your deployment) a lag-tolerant read model or projection; confirm exact semantics in service code and ops notes. |
| **Domain event** | Message published to RabbitMQ after a state change (for example transfer completed); see [domain events](architecture/events.md). |
| **Idempotency key** | Client-supplied key so retries replay the same outcome (for example same `201` body for onboarding); see [API reference](reference/api.md). |
| **Ledger** | Double-entry accounting layer; wallet balances map to liability accounts; see [financial operations](reconciliation/financial-operations-and-reconciliation.md). |
| **Outbox** | Pattern for publishing messages **after** the database transaction commits, avoiding “message sent but DB rolled back”; see [outbox & ledger](architecture/outbox-and-ledger-consistency.md). |
| **RabbitMQ** | Broker used for asynchronous workflows and events in this platform. |
| **Reconciliation run** | Job comparing ledger (and related) data to external/bank sources; see [reconciliation job](reconciliation/reconciliation.md). |
| **Transaction authorization token** | Short-lived token from wallet PIN verification, used on debit paths when enforcement is enabled; see [system hardening](security/system-hardening.md). |
| **Wallet classification** | Category defining limits and allowed operations (merchant, withdrawal, PIN mode, …); see [API / wallet RPCs](reference/api.md). |
| **`x-bank-id`** | gRPC/HTTP metadata tying a call to a bank tenant; required on many Wallets and Transactions RPCs. |

---

## Add a term

Use the [documentation feedback](https://github.com/anstwechy/mitf_wallet_public_docs/issues/new?labels=documentation) link on any page or propose an edit via GitHub.
