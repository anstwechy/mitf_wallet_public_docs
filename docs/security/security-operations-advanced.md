# Security operations (rate limits, audit logs, secrets, mTLS)

Operational security topics **beyond** [system hardening](system-hardening.md). Numbers are **`TBD`** until aligned with legal and infra owners.

---

## Rate limiting (Customer Gateway)

Gateway supports **per-route** windows (read, transaction writes, auth bootstrap, operation status). Keys live under `CustomerGateway:RateLimiting:*` in [Customer Gateway reference](../reference/service-reference/Masarat.Gateway.Customer.Api.reference.md).

| Policy key | Purpose (summary) | Notes |
| ---------- | ------------------- | ----- |
| `PermitLimit` / `WindowSeconds` | Fixed-window cap | Raising limits without scaling backends can cause overload. |
| `AuthBootstrap` | Login / bootstrap burst | Often stricter than general read. |
| `TransactionWrite` | Transfer / payment routes | Coordinate with [backpressure](../architecture/transfer-backpressure-client-contract.md) semantics. |
| `OperationStatus` | Poll endpoints for async ops | Higher limits expected; still bound abuse. |

**429 responses:** clients should **back off exponentially** and surface human-readable errors — TBD client guidance.

---

## Audit logging — retention & archival

| Log type | Primary store | Retention (online) | Archive | Tamper evidence |
| -------- | ------------- | ------------------ | ------- | --------------- |
| Application structured logs | TBD | TBD | TBD | TBD |
| Security / admin audit | TBD | TBD (often longer) | TBD | TBD |

Map to regulatory wording where **audit trail** is cited — coordinate with compliance before shortening retention.

---

## Secret rotation

| Secret class | Rotation cadence | Procedure owner | Zero-downtime pattern |
| ------------- | ---------------- | ----------------- | --------------------- |
| JWT signing key (gateway) | TBD | TBD | Dual-key validation window — TBD |
| Per-app API keys | TBD | TBD | Staggered re-issue to mobile clients |
| DB passwords | TBD | DBA | Connection pool recycle order |
| Downstream `DownstreamApiKey` | TBD | TBD | |

Document emergency rotation for suspected compromise — TBD playbook link.

---

## mTLS between services (production hardening)

Today, **edge** trust often centres on **API keys** and **JWT** ([system hardening](system-hardening.md)). **mTLS** for east-west gRPC/HTTP is a **recommended** uplift for high-assurance environments.

| Step | Action |
| ---- | ------ |
| 1 | Issue service identities (SPIFFE, internal CA, cloud mesh) — TBD. |
| 2 | Enforce client certs on gRPC channels between gateway and core services. |
| 3 | Rotate leaf certs automatically — TBD. |
| 4 | Update threat model and penetration test scope. |

!!! note "Docs vs implementation"
    This section describes a **target state**. Actual toggles and versions belong in the **application** deployment repo when implemented.

## Related

- [Onboarding channel hardening](onboarding-channel-hardening.md)  
- [System hardening](system-hardening.md)  
- [Incident response playbook](../operations/incident-response-playbook.md)  
