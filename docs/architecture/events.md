# Domain Events (RabbitMQ)

The system publishes the following events to RabbitMQ via MassTransit. Downstream systems can subscribe by creating queues and bindings to the exchanges used by MassTransit.

For delivery guarantees, duplicate-handling rules, async request acceptance semantics, and ledger ambiguity recovery, see [Outbox and ledger consistency](outbox-and-ledger-consistency.md). This file focuses on event contracts and their intended business meaning.

---

## WalletCreatedEvent

**Published when:** A new wallet is created (e.g. via onboarding or batch wallet creation).

**Payload:**

| Field           | Type     | Description                    |
|----------------|----------|--------------------------------|
| `WalletId`     | `Guid`   | The new wallet's ID.           |
| `UserId`       | `Guid`   | Owner user ID.                 |
| `ClassificationId` | `string` | Wallet classification code. |
| `CreatedAt`    | `DateTime` | UTC creation time.          |

**Use cases:** Notifications, analytics, syncing to a read model or external system.

**Contract (C#):** `Masarat.MessagingContracts.WalletCreatedEvent`

---

## TransferCompletedEvent

**Published when:** A wallet-to-wallet transfer has completed successfully (debit and credit both applied).

**Payload:**

| Field           | Type     | Description                    |
|----------------|----------|--------------------------------|
| `TransactionId`| `Guid`   | Unique transfer transaction ID. |
| `FromWalletId` | `Guid`   | Source wallet ID.              |
| `ToWalletId`   | `Guid`   | Destination wallet ID.        |
| `Amount`       | `decimal`| Transfer amount.              |
| `Currency`     | `string` | Currency code (e.g. LYD).     |
| `CompletedAt`  | `DateTime` | UTC completion time.       |
| `Fee`          | `decimal` | Fee charged on the transfer in the same currency. |
| `FeeRevenueAccountId` | `Guid?` | Fee-revenue ledger account to update asynchronously when a fee was posted. |

**Use cases:** Notifications, audit logs, reconciliation, reporting, and deferred fee-revenue snapshot updates in the Ledger API.

**Contract (C#):** `Masarat.MessagingContracts.TransferCompletedEvent`

---

## WalletFundedEvent

**Published when:** A wallet is funded (topped up) from the current account and the credit has been applied successfully. Not published on idempotency replay.

**Payload:**

| Field          | Type       | Description                    |
|----------------|------------|--------------------------------|
| `TransactionId`| `Guid`     | Unique funding transaction ID. |
| `WalletId`     | `Guid`     | Funded wallet ID.              |
| `Amount`       | `decimal`  | Funded amount.                 |
| `Currency`     | `string`   | Currency code (e.g. LYD).      |
| `FundedAt`     | `DateTime` | UTC time of funding.          |

**Use cases:** Notifications, audit logs, reconciliation, reporting.

**Contract (C#):** `Masarat.MessagingContracts.WalletFundedEvent`

---

## MerchantPaymentCompletedEvent

**Published when:** A merchant payment completes successfully (wallet debited, merchant settlement and fee accounts credited).

**Payload:**

| Field              | Type       | Description                        |
|--------------------|------------|------------------------------------|
| `TransactionId`    | `Guid`     | Unique transaction ID.             |
| `WalletId`         | `Guid`     | Debited wallet ID.                 |
| `Amount`           | `decimal`  | Payment amount.                    |
| `Fee`              | `decimal`  | Fee charged.                       |
| `Currency`         | `string`   | Currency code (e.g. LYD).          |
| `MerchantReference`| `string?`  | Optional merchant reference.      |
| `CompletedAt`      | `DateTime` | UTC completion time.               |

**Use cases:** Notifications, audit logs, merchant settlement reporting.

**Contract (C#):** `Masarat.MessagingContracts.MerchantPaymentCompletedEvent`

---

## CashWithdrawalCompletedEvent

**Published when:** A cash withdrawal completes successfully (wallet debited, cash settlement and fee accounts credited).

**Payload:**

| Field         | Type       | Description               |
|---------------|------------|---------------------------|
| `TransactionId` | `Guid`   | Unique transaction ID.    |
| `WalletId`     | `Guid`   | Debited wallet ID.       |
| `Amount`       | `decimal`| Withdrawal amount.        |
| `Fee`          | `decimal`| Fee charged.              |
| `Currency`     | `string` | Currency code (e.g. LYD). |
| `CompletedAt`  | `DateTime` | UTC completion time.   |

**Use cases:** Notifications, audit logs, cash reconciliation.

**Contract (C#):** `Masarat.MessagingContracts.CashWithdrawalCompletedEvent`

---

## TransactionReversedEvent

**Published when:** A prior transaction is successfully **reversed** (compensating journal applied and reversal recorded).

**Payload:**

| Field | Type | Description |
| ----- | ---- | ----------- |
| `ReversalTransactionId` | `Guid` | ID of the reversal transaction. |
| `OriginalTransactionId` | `Guid` | ID of the transaction that was reversed. |
| `FromWalletId` | `Guid?` | Original source wallet, if applicable. |
| `ToWalletId` | `Guid?` | Original destination wallet, if applicable. |
| `Amount` | `decimal` | Reversed amount. |
| `Fee` | `decimal` | Fee leg associated with the reversal context. |
| `Currency` | `string` | Currency code (e.g. LYD). |
| `OccurredAtUtc` | `DateTime` | UTC time of reversal completion. |

**Use cases:** Notifications, audit trails, downstream ledger or reporting sync.

**Contract (C#):** `Masarat.MessagingContracts.TransactionReversedEvent`

---

## WalletClassificationDeactivatedEvent

**Published when:** A wallet classification is deactivated (no longer available for new wallets).

**Payload:**

| Field            | Type       | Description                      |
|------------------|------------|----------------------------------|
| `ClassificationId` | `Guid`   | The classification's ID.        |
| `Code`           | `string`   | Classification code (e.g. STANDARD_RESIDENT). |
| `DeactivatedAt`  | `DateTime` | UTC deactivation time.         |

**Use cases:** Notifications, syncing product catalog, disabling downstream features.

**Contract (C#):** `Masarat.MessagingContracts.WalletClassificationDeactivatedEvent`

---

## Subscribing to events

1. **MassTransit / RabbitMQ:** Events are published to the default MassTransit exchange/topology. Create a consumer in your service that implements `IConsumer<WalletCreatedEvent>`, `IConsumer<TransferCompletedEvent>`, `IConsumer<WalletFundedEvent>`, `IConsumer<MerchantPaymentCompletedEvent>`, `IConsumer<CashWithdrawalCompletedEvent>`, `IConsumer<TransactionReversedEvent>`, and/or `IConsumer<WalletClassificationDeactivatedEvent>`, register it with MassTransit, and ensure your service connects to the same RabbitMQ (or configure the same message contract names).

2. **Queue binding (generic AMQP):** If not using MassTransit, bind a queue to the exchange used for these message types. The exact exchange and routing key depend on your MassTransit configuration (e.g. entity name formatter). Inspect RabbitMQ management UI (default http://localhost:15672) after publishing an event to see the exchange and message format.

3. **In-repo consumers exist for some events:** for example, the **Ledger** API consumes `TransferCompletedEvent`, `MerchantPaymentCompletedEvent`, and `CashWithdrawalCompletedEvent` for balance snapshot follow-ups; **Webhooks** consumes several events for outbound delivery. **WalletFundedEvent** is consumed by Webhooks (not by Ledger). External services can still subscribe using the same contracts.
