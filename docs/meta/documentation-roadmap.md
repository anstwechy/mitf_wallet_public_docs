# Documentation roadmap & known gaps

Living checklist for **deepening** MITF wallet public documentation. Priorities reflect common **audit**, **integration**, and **ops** asks; owners are **`TBD`** inside Masarat.

---

## Coverage matrix (from stakeholder asks)

| Topic | Priority | Why it matters | Status |
| ----- | -------- | -------------- | ------ |
| Disaster recovery (backup, RTO/RPO) | High | Regulatory & customer due diligence | [DR runbook](../operations/disaster-recovery-runbook.md) (template) |
| Incident response (ledger, MQ, DB) | High | Operational readiness | [Playbook](../operations/incident-response-playbook.md) |
| Capacity planning | High | Infra sizing | [Guide](../operations/capacity-planning.md) |
| Schema / EF migrations in production | High | Safe releases | [Migration guide](../operations/schema-migration-guide.md) |
| API deprecation timeline | Medium | Integrator planning | [API changelog](../reference/api-changelog.md) |
| Multi-region deployment | Medium | Scale & residency | Called out in [capacity planning](../operations/capacity-planning.md); detail **TBD** |
| Cost estimation model | Medium | Finance | **TBD** — link FinOps model when public |
| Compliance certifications (SOC2, etc.) | Medium | RFPs | **TBD** — usually external artefact |
| Third-party dependency list (SBOM) | Medium | Security reviews | **TBD** — link security portal |
| Performance benchmarks by hardware | Low | Capacity evidence | [Load test runs](../load-testing/load-test-reference-runs.md) + **TBD** matrix |
| Feature flags | Low | If product uses flags | **TBD** — document in app repo first |

---

## Media & diagrams

- **Video walkthroughs** (Loom-style): placeholder policy in [Media & diagrams](media-and-diagrams.md).  
- **Interactive diagrams:** same page (Mermaid limits, Eraser.io).  

---

## MkDocs / site hygiene

| Idea | Notes |
| ---- | ----- |
| Dependency policy | [CI/CD patterns](../operations/cicd-deployment.md#documentation-site-dependency-policy-mkdocs) |
| RSS / JSON feeds | [Changelog](../changelog.md) |

---

## How to pick up work

1. Open a GitHub issue with label **documentation** and link the row above.  
2. Prefer **small PRs** (one runbook or one section).  
3. Replace **`TBD`** with named contacts only when approved for external docs.
