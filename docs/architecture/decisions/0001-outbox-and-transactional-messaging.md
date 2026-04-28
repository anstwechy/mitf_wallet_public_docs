# ADR 0001: Transactional outbox & messaging consistency

- **Date:** (fill when formalised)  
- **Status:** Accepted (documentation anchor)  
- **Deciders:** Platform / engineering  

## Context

Wallet money movement must remain **consistent** with **published events** (downstream AML, webhooks, analytics). Publishing before commit risks orphaned messages; commit without publish risks silent loss of notifications.

## Decision

Use the **transactional outbox** pattern (and related consistency guarantees) so messaging is tied to durable ledger/DB state as described in platform documentation.

## Consequences

**Positive:** Clear recovery story; aligns audit expectations with technical behaviour.  

**Negative:** Operators must understand backlog and replay semantics — see runbooks.  

## References

- [Outbox & ledger consistency](../outbox-and-ledger-consistency.md)  
- [Reconciliation & consistency runbook](../../operations/reconciliation-and-consistency-runbook.md)  
- [Domain events](../events.md)  
