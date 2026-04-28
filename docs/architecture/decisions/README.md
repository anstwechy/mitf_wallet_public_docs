# Architecture Decision Records (ADRs)

ADRs capture **why** the MITF wallet platform chose an approach, not only **what** it does. They complement narrative architecture pages ([platform capabilities](../platform-capabilities.md), [outbox](../outbox-and-ledger-consistency.md), …).

## Index

| ADR | Title | Status |
| --- | ----- | ------ |
| [0001](0001-outbox-and-transactional-messaging.md) | Transactional outbox & messaging | Accepted (doc pointer) |
| [Template](0000-template.md) | — | Use for new ADRs |

## How to add an ADR

1. Copy [0000-template.md](0000-template.md) to the next number (for example `0002-postgresql-per-service.md`).
2. Fill **Context**, **Decision**, **Consequences**, and links to code or runbooks.
3. Add a row to the table above and reference it from relevant ops/integrator pages.

Suggested future ADRs (not yet written): PostgreSQL vs alternatives, RabbitMQ topology, MassTransit usage, Customer Gateway vs direct service access, AML bridge boundaries.

## Related

- [Documentation roadmap](../../meta/documentation-roadmap.md) — planned doc gaps
- [Platform capabilities](../platform-capabilities.md)
