# Observability standards

Templates and conventions for **metrics**, **dashboards**, **alerts**, **tracing**, and **SLOs**. Export artefacts (Grafana JSON, Prometheus rules) should live in your **infra repo** or **internal wiki** — link them from the table below.

---

## Dashboard templates

| Dashboard | Covers | Export location |
| --------- | ------ | ---------------- |
| Money path overview | Gateway, Transactions, queue depth, error rate | TBD `.json` |
| Ledger / Postgres | Connections, slow queries, replication | TBD |
| RabbitMQ | Ready/unacked, rates, memory | TBD |
| Reconciliation | Run duration, exception count | TBD |

---

## Suggested alerting rules (Prometheus-style)

Illustrative only — validate labels and thresholds in your environment.

| Alert | Expression sketch | Severity |
| ----- | ------------------- | -------- |
| Pending request age | Histogram of `GetRequestStatus` “in progress” too old — TBD metric | High |
| Reconciliation exception spike | `rate(exceptions[15m]) > TBD` | High |
| DB connection saturation | `(connections / max_connections) > TBD` | High |
| Queue depth | `depth > TBD` for critical queues | Medium |

---

## Distributed tracing

| Step | Practice |
| ---- | -------- |
| Propagation | Forward **correlation id** / W3C trace context from gateway through gRPC — TBD implementation. |
| Sampling | TBD (always-on for errors, % for success). |
| Example trace | Document one **P2P transfer** trace across GW → Transactions → Ledger — TBD screenshot/link. |

See also [Logging](logging.md).

---

## SLO / SLI (formal targets)

| SLI | Definition | SLO target | Error budget policy |
| --- | ---------- | ---------- | ------------------- |
| Availability | TBD (e.g. successful health checks) | TBD % | TBD |
| Latency | TBD p95 for key RPC | TBD ms | TBD |
| Correctness | Reconciliation diff rate | TBD | TBD |

## Related

- [Troubleshooting](troubleshooting.md)  
- [Incident response](incident-response-playbook.md)  
