# Masarat.Transactions.Api — configuration and database

Connection string name: **`Transactions`** → database commonly named `masarattransactions`.

---

## Configuration

| Key | Value type | Example value | Description |
|-----|------------|---------------|-------------|
| `Logging:LogLevel:Default` | `string` | `Information` | Default Microsoft logging level. |
| `Logging:LogLevel:Microsoft.AspNetCore` | `string` | `Warning` | ASP.NET Core framework noise reduction. |
| `AllowedHosts` | `string` | `*` | Kestrel host filtering wildcard. |
| `ConnectionStrings:Transactions` | `string` (Npgsql) | `Host=localhost;Port=5432;Database=masarattransactions;...` | PostgreSQL for transactions, outbox, and idempotency. |
| `WalletGrpc:Address` | `string` (URI) | `http://localhost:5002` | gRPC address for embedded Wallets client (wallet/classification/fee data). |
| `LedgerGrpc:Address` | `string` (URI) | `http://localhost:5001` | Ledger gRPC endpoint. |
| `LedgerGrpc:MaxInFlightRequests` | `int` | `48` | Concurrent ledger calls cap. |
| `LedgerGrpc:AcquireTimeoutMs` | `int` | `200` | Wait timeout acquiring ledger call slot. |
| `Idempotency:RetentionDays` | `int` | `90` | Age after which idempotency rows may be purged by background cleanup. |
| `Maintenance:PendingRepairEnabled` | `bool` | `true` | Enables pending-transaction repair loop. |
| `Maintenance:PendingRepairScanIntervalSeconds` | `int` | `30` | Repair scanner interval. |
| `Maintenance:PendingRepairAgeSeconds` | `int` | `60` | Minimum age before a pending item is considered for repair. |
| `Maintenance:PendingRepairBatchSize` | `int` | `25` | Batch size per repair pass. |
| `Maintenance:IdempotencyCleanupEnabled` | `bool` | `true` | Enables idempotency retention cleanup. |
| `Maintenance:IdempotencyCleanupIntervalMinutes` | `int` | `360` | Interval between cleanup runs. |
| `WalletAuthorizationToken:Secret` | `string` | `change-me-...` | HMAC secret for short-lived wallet PIN step-up tokens (must match Wallets). |
| `WalletAuthorizationToken:ExpiryMinutes` | `int` | `5` | Token lifetime. |
| *(per classification)* | — | — | PIN step-up for debits follows Wallets **`OperationAuthMode`** on the wallet’s classification (not a key in this file). |
| `TransferBackpressure:Enabled` | `bool` | `true` | Limits concurrent in-process transfer handling. |
| `TransferBackpressure:MaxInFlightTransfers` | `int` | `320` | Max concurrent transfers. |
| `TransferBackpressure:AcquireTimeoutMs` | `int` | `80` | Timeout waiting for transfer slot. |
| `HandlerTiming:Enabled` | `bool` | `false` | Optional handler duration diagnostics. |
| `HandlerTiming:MinDurationMs` | `int` | `10` | Log threshold when enabled. |
| `HandlerTiming:LogFailuresAlways` | `bool` | `true` | Always log failures when timing enabled. |
| `Fees:FeeRevenueAccountId` | `Guid` (string) | system account GUID | Ledger liability account receiving fee revenue. |
| `Fees:MerchantSettlementAccountId` | `Guid` (string) | system account GUID | Merchant settlement ledger account. |
| `Fees:CashSettlementAccountId` | `Guid` (string) | system account GUID | Cash withdrawal settlement account. |
| `RabbitMQ:Host` | `string` | `localhost` | RabbitMQ host. |
| `RabbitMQ:Port` | `int` | `5672` | AMQP port. |
| `RabbitMQ:Username` | `string` | `guest` | AMQP user. |
| `RabbitMQ:Password` | `string` | `guest` | AMQP password. |
| `Messaging:Tuning:PrefetchCount` | `ushort` | `64` | MassTransit RabbitMQ prefetch. |
| `Messaging:Tuning:RetryCount` | `int` | `2` | Message retry count. |
| `Messaging:Tuning:RetryIntervalSeconds` | `int` | `2` | Delay between retries. |
| `Messaging:Tuning:TransferConsumerConcurrentLimit` | `int` | `22` | Concurrent transfer consumers. |
| `Messaging:Tuning:FundWalletConsumerConcurrentLimit` | `int` | `22` | Concurrent fund-wallet consumers. |
| `Observability:*` | various | see `appsettings.json` | OpenTelemetry / metrics (shared observability package). |
| `InternalLoggerOptions:*` | various | Loki URL, etc. | Serilog sinks (`AddCustomLogger`). |
| `Auth:RequireApiKey` / `Auth:ApiKey` | bool / string | — | Bound via `ApiKeyOptions` when section present (gRPC API key). |

Additional MassTransit outbox tuning may be supplied via `TransactionsMessagingTuning` environment keys (see `TransactionsMessagingTuning.FromConfiguration`).

---

## Database tables

Migrations history table: **`__TransactionsMigrationsHistory`**.

### `Transactions`

| Property | Type | PostgreSQL / constraints | Description |
|----------|------|---------------------------|-------------|
| `Id` | `Guid` | `uuid`, PK | Transaction id (matches ledger use). |
| `Type` | enum → string | `varchar(32)` | P2P, Merchant, Withdrawal, etc. |
| `Status` | enum → string | `varchar(32)` | Pending, Completed, Failed, Reversed. |
| `Amount` | `decimal` | `numeric(18,4)` | Principal amount. |
| `Fee` | `decimal` | `numeric(18,4)` | Fee portion. |
| `Currency` | `string` | `varchar(3)` | ISO currency. |
| `FromWalletId` | `Guid?` | `uuid` | Source wallet. |
| `ToWalletId` | `Guid?` | `uuid` | Destination wallet. |
| `ReportingBankId` | `Guid?` | `uuid` | Bank for reporting. |
| `ReportingUserId` | `Guid?` | `uuid` | User for reporting metrics. |
| `CreatedAt` | `DateTime` | `timestamptz` | Creation time (UTC). |
| `CompletedAt` | `DateTime?` | `timestamptz` | Terminal transition time. |
| `ErrorMessage` | `string?` | `varchar(1024)` | Failure/reversal reason. |
| `ReversalOfTransactionId` | `Guid?` | `uuid` | Original tx when this is a reversal. |
| `Reference` | `string?` | `varchar(128)` | External reference. |
| `Channel` | `string?` | `varchar(64)` | Channel label. |
| `Counterparty` | `string?` | `varchar(128)` | Counterparty label. |
| `Purpose` | `string?` | `varchar(256)` | Purpose / memo. |
| `ActorId` | `string?` | `varchar(128)` | Acting principal id. |
| `ActorType` | `string?` | `varchar(64)` | Acting principal type. |

### `TransactionRequestStatuses`

| Property | Type | PostgreSQL / constraints | Description |
|----------|------|---------------------------|-------------|
| `RequestId` | `Guid` | `uuid`, PK | Async operation correlation id. |
| `OperationType` | enum → string | `varchar(64)` | Which command type was enqueued. |
| `IdempotencyKey` | `string` | `varchar(128)`, unique with `OperationType` | Client idempotency key. |
| `State` | enum → string | `varchar(32)` | Queued, Processing, Succeeded, Failed, UnknownNeedsReconciliation, etc. |
| `TransactionId` | `Guid?` | `uuid` | Linked transaction when known. |
| `ErrorMessage` | `string?` | `varchar(1024)` | Failure detail. |
| `ErrorCode` | `string?` | `varchar(64)` | Stable error code. |
| `ActorId` | `string?` | `varchar(128)` | Actor for ownership checks. |
| `ActorType` | `string?` | `varchar(64)` | Actor type. |
| `CreatedAt` | `DateTime` | `timestamptz` | Row creation. |
| `UpdatedAt` | `DateTime` | `timestamptz` | Last state change. |
| `StartedAt` | `DateTime?` | `timestamptz` | First processing tick. |
| `CompletedAt` | `DateTime?` | `timestamptz` | Terminal time. |

### Idempotency tables (same shape unless noted)

**`TransferIdempotency`**, **`FundWalletIdempotency`**, **`MerchantPaymentIdempotency`**, **`CashWithdrawalIdempotency`**, **`FundWalletFromPooledAccountIdempotency`**

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `IdempotencyKey` | `string` | `varchar(128)`, PK | Client-supplied key. |
| `TransactionId` | `Guid` | `uuid` | Committed transaction id for replay. |
| `CreatedAt` | `DateTime` | `timestamptz` | Insert time (retention). |

**`ReverseTransactionIdempotency`**

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `IdempotencyKey` | `string` | `varchar(128)`, PK | Client key for reversal command. |
| `TransactionId` | `Guid` | `uuid` | New reversal transaction id. |
| `OriginalTransactionId` | `Guid` | `uuid` | Transaction being reversed. |
| `CreatedAt` | `DateTime` | `timestamptz` | Insert time. |

### `PooledAccounts`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `Id` | `Guid` | `uuid`, PK | Pool id (used as synthetic wallet id toward ledger). |
| `BankId` | `Guid` | `uuid` | Owning bank. |
| `Type` | enum → string | text | Corporate / MasaratPool. |
| `EmployerId` | `Guid?` | `uuid` | Optional employer for corporate pools. |
| `LiabilityAccountId` | `Guid` | `uuid` | Ledger liability account. |
| `Currency` | `string` | `varchar(3)` | Pool currency. |
| `Name` | `string?` | `varchar(256)` | Display name. |
| `CreatedAt` | `DateTime` | `timestamptz` | Created. |

### MassTransit — `TransactionsInboxState`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `Id` | `long` | `bigint`, identity, PK | Inbox row id. |
| `MessageId` | `Guid` | `uuid` | Consumed message id. |
| `ConsumerId` | `Guid` | `uuid` | Consumer type id. |
| `Received` / `Consumed` / `Delivered` / `ExpirationTime` | `DateTime?` | `timestamptz` | Inbox lifecycle. |
| `ReceiveCount` | `int` | `integer` | Delivery attempts. |
| `LockId` | `Guid` | `uuid` | Processing lock. |
| `LastSequenceNumber` | `long?` | `bigint` | Ordering helper. |
| `RowVersion` | `byte[]` | `bytea` | Concurrency token. |

### MassTransit — `TransactionsOutboxMessage`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `SequenceNumber` | `long` | `bigint`, identity, PK | Outbox message order. |
| `OutboxId` | `Guid?` | `uuid`, FK | Parent outbox state. |
| `MessageId` | `Guid` | `uuid` | Logical message id. |
| `ContentType` | `string` | `varchar(256)` | Serializer content type. |
| `MessageType` | `string` | text | CLR message type name. |
| `Body` | `string` | text | Serialized payload. |
| `Headers` / `Properties` | `string?` | text | MassTransit headers/properties JSON. |
| `DestinationAddress` / `ResponseAddress` / `FaultAddress` / `SourceAddress` | `string?` | `varchar(256)` | Routing URIs. |
| `SentTime` / `EnqueueTime` / `ExpirationTime` | `DateTime` / `DateTime?` | `timestamptz` | Scheduling. |
| `InboxMessageId` / `InboxConsumerId` | `Guid?` | `uuid` | Optional inbox correlation. |
| `ConversationId` / `CorrelationId` / `InitiatorId` / `RequestId` | `Guid?` | `uuid` | Saga / request correlation. |

### MassTransit — `TransactionsOutboxState`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `OutboxId` | `Guid` | `uuid`, PK | Outbox batch id. |
| `Created` / `Delivered` | `DateTime` / `DateTime?` | `timestamptz` | Dispatch lifecycle. |
| `LastSequenceNumber` | `long?` | `bigint` | Last published sequence. |
| `LockId` | `Guid` | `uuid` | Delivery lock. |
| `RowVersion` | `byte[]` | `bytea` | Concurrency token. |
