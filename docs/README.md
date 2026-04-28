# 💳 MITF Wallet — documentation {: .wallet-lead}

Technical docs for the **MITF wallet** platform — APIs, architecture, operations, security, and integrations. Everything below lives under the `docs/` folder in [mitf_wallet_public_docs](https://github.com/anstwechy/mitf_wallet_public_docs).

---

## Start here

| Goal | Go to |
| ----- | ----- |
| **Masarat executives & department heads** | [Platform at a glance — leadership](stakeholders/index.md) |
| **New developer — 5-minute quickstart** (curl + auth) | [Quickstart](getting-started/quickstart.md) |
| First technical visit / tour | [Welcome & guided tours](getting-started/welcome.md) |
| Flat A–Z of every page | [Full A–Z index](getting-started/all-pages.md) |
| **Changelog & releases** (integrators tracking updates) | [Changelog & releases](changelog.md) |
| Build this site locally | [Repository README](https://github.com/anstwechy/mitf_wallet_public_docs/blob/main/README.md) |

---

## Who should read what?

```mermaid
flowchart TB
  subgraph integrator["Integrator or app team"]
    API[API reference]
    GRPC[gRPC services]
    BP[Backpressure contract]
    API --> GRPC --> BP
  end

  subgraph ops["Ops or SRE"]
    PD[Production deployment]
    LOG[Logging]
    RB[Runbooks]
    PD --> LOG --> RB
  end

  subgraph fin["Finance or compliance"]
    FO[Financial operations]
    RJ[Reconciliation job]
    AML[FlowGuard integration]
    FO --> RJ
    RJ --> AML
  end
```

---

## Quick picks by role

| If you are… | Start here |
| ----------- | ---------- |
| **Integrating** (REST/gRPC, auth, async polling) | [Quickstart](getting-started/quickstart.md), [API reference](reference/api.md), [gRPC services](reference/grpc-services.md), [Transfer backpressure](architecture/transfer-backpressure-client-contract.md), [Changelog & releases](changelog.md) |
| **Operating** (deploy, logs, load tests) | [Production deployment](operations/production-deployment.md), [Logging](operations/logging.md), [Load testing operations](operations/load-testing-operations.md) |
| **Configuring** services | [Configuration reference](reference/configuration-reference.md), [Per-service reference](reference/service-reference/README.md) |
| **Finance / audit** | [Financial operations](reconciliation/financial-operations-and-reconciliation.md), [Reconciliation job](reconciliation/reconciliation.md) |

---

## Topic folders

| Folder | What's inside |
| ------ | ------------- |
| [**stakeholders/**](stakeholders/index.md) | **Masarat leadership** — platform powers, executive / risk / ops tracks |
| [**getting-started/**](getting-started/welcome.md) | Quickstart, welcome tour, full A–Z index |
| [**Changelog & releases**](changelog.md) | Release notes links for integrators |
| [**architecture/**](architecture/platform-capabilities.md) | Platform capabilities, events, consistency, flows, backpressure |
| [**operations/**](operations/production-deployment.md) | Deploy, logging, load tests, runbooks |
| [**reference/**](reference/api.md) | API, gRPC, config keys, [service-reference/](reference/service-reference/README.md) |
| [**security/**](security/system-hardening.md) | Hardening and onboarding-channel notes |
| [**reconciliation/**](reconciliation/reconciliation.md) | Finance narrative + reconciliation job |
| [**load-testing/**](load-testing/load-test-reference-runs.md) | Reference runs + stakeholder summary |
| [**integrations/**](integrations/aml-integration.md) | AML bridge, FlowGuard plan, tenant resolution |
| [**compliance/**](compliance/offline-packs.md) | Offline packs (print / PDF) for security & reconciliation chapters |
| [**accessibility**](accessibility.md) | Keyboard use, contrast, motion, how to report gaps |

!!! note "Different from FlowGuard AML docs"
    This site uses a **teal / emerald** theme and coral accents so it is visually distinct from the purple FlowGuard documentation set.
