# Masarat.Wallets.Api — configuration and database

Connection string name: **`Wallets`** → database commonly `MasaratWallets`.

---

## Configuration

| Key | Value type | Example value | Description |
|-----|------------|---------------|-------------|
| `Logging:LogLevel:Default` | `string` | `Information` | Default log level. |
| `Logging:LogLevel:Microsoft.AspNetCore` | `string` | `Warning` | Framework log level. |
| `AllowedHosts` | `string` | `*` | Host filter. |
| `ConnectionStrings:Wallets` | `string` | Npgsql connection string | Wallets + outbox + credentials DB. |
| `LedgerGrpc:Address` | `string` (URI) | `http://localhost:5001` | Ledger gRPC. |
| `LedgerGrpc:MaxInFlightRequests` | `int` | `48` | Concurrent ledger calls. |
| `LedgerGrpc:AcquireTimeoutMs` | `int` | `200` | Acquire timeout. |
| `Idempotency:RetentionDays` | `int` | `90` | Idempotency TTL hint (also `TtlHours` if set in options). |
| `WalletPin:MaxFailedAttempts` | `int` | `5` | Lockout threshold. |
| `WalletPin:LockoutMinutes` | `int` | `15` | Lockout duration. |
| `WalletPin:MinPinLength` / `MaxPinLength` | `int` | `4` / `6` | PIN length bounds. |
| `WalletAuthorizationToken:Secret` | `string` | shared secret | Must match Transactions for step-up tokens. |
| `WalletAuthorizationToken:ExpiryMinutes` | `int` | `5` | Token TTL. |
| `Fees:FeeRevenueAccountId` | `Guid?` | `null` in sample | Ledger fee revenue account; may be null in dev. |
| `Fees:MerchantSettlementAccountId` | `Guid?` | `null` | Merchant settlement account. |
| `Fees:CashSettlementAccountId` | `Guid?` | `null` | Cash settlement account. |
| `RabbitMQ:*` | string / int | localhost / guest | AMQP connection. |
| `Messaging:Tuning:PrefetchCount` | `ushort` | `24` | RabbitMQ prefetch. |
| `Messaging:Tuning:RetryCount` | `int` | `2` | Retry count. |
| `Messaging:Tuning:RetryIntervalSeconds` | `int` | `2` | Retry delay. |
| `Observability:*` | various | — | Telemetry. |
| `InternalLoggerOptions:*` | various | Loki | Structured logging. |
| `Auth:*` (if present) | — | — | `ApiKeyOptions` for gRPC API key. |

`WalletMessagingTuning` may add outbox-related keys via `WalletMessagingTuning.FromConfiguration` (see code).

---

## Database tables

Migrations history: **`__WalletsMigrationsHistory`**.

### `Wallets`

| Property | Type | PostgreSQL / constraints | Description |
|----------|------|---------------------------|-------------|
| `Id` | `Guid` | `uuid`, PK | Wallet id. |
| `WalletNumber` | `string` | `varchar(16)`, unique | Human-facing number. |
| `BankId` | `Guid` | `uuid` | Issuing bank. |
| `UserId` | `Guid` | `uuid` | Holder user. |
| `CreatedByUserId` | `Guid` | `uuid` | Creator user. |
| `HolderType` | enum → string | text | Resident / foreign. |
| `CreatorHasManagementAccess` | `bool` | `boolean` | Manager flag. |
| `ClassificationId` | `string` | `varchar(64)` | Classification code reference. |
| `LockedBalance` | `decimal` | `numeric(18,4)` | Reserved for in-flight ops. |
| `Status` | enum → string | text | Active / Suspended / Closed. |
| `Currency` | `string` | `varchar(3)` | ISO currency. |
| `CreatedAt` | `DateTime` | `timestamptz` | Created. |
| `LiabilityAccountId` | `Guid?` | `uuid` | Ledger liability link. |
| `EmployerId` | `Guid?` | `uuid` | Employer-issued wallet. |

### `WalletClassifications`

| Property | Type | PostgreSQL / constraints | Description |
|----------|------|---------------------------|-------------|
| `Id` | `Guid` | `uuid`, PK | Surrogate key. |
| `Code` | `string` | `varchar(64)`, unique | e.g. `STANDARD_RESIDENT`. |
| `DisplayName` | `string` | `varchar(256)` | UI label. |
| `Description` | `string?` | `varchar(512)` | Help text. |
| `IsActive` | `bool` | `boolean` | Selectable for new wallets. |
| `AllowResidentCreator` / `AllowBusinessCreator` | `bool` | `boolean` | Who may create. |
| `AllowResidentHolder` / `AllowForeignHolder` | `bool` | `boolean` | Holder eligibility. |
| `ResidentKycTemplate` / `ForeignKycTemplate` | `string` | `varchar(128)` | KYC template keys. |
| `KycCaptureMode` | enum → string | text | When KYC is captured. |
| `AllowCreatorManagementAccess` | `bool` | `boolean` | Post-create manager access. |
| `AllowMultipleWalletsPerHolder` | `bool` | `boolean` | Multi-wallet policy. |
| `CanSendInterBank` / `CanReceiveInterBank` | `bool` | `boolean` | Inter-bank rules. |
| `AllowP2P` / `AllowMerchant` / `AllowWithdrawal` | `bool` | `boolean` | Product permissions. |
| `MaxBalance` / `PerTransactionMax` | `decimal?` | `numeric(18,4)` | Limits. |
| `AllowedCurrencies` | JSON list | `text` | Serialized ISO codes. |
| `OperationAuthMode` | enum → string | text | PIN vs trusted session for sensitive ops. |
| `CreatedAt` | `DateTime` | `timestamptz` | Created. |

### `FeeRules`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `Id` | `Guid` | `uuid`, PK | Rule id. |
| `ClassificationId` | `Guid` | `uuid` | FK to classification row id. |
| `TransactionType` | enum → string | text | Operation this fee applies to. |
| `Percentage` / `MinAmount` / `FixedAmount` | `decimal?` | `numeric(18,4)` | Fee formula parts. |
| `Currency` | `string` | `varchar(3)` | Fee currency. |

### `PooledAccounts`

Same columns as Transactions service `PooledAccounts` (this DB is separate; schema mirrors for wallet-side pool CRUD).

### Idempotency: `TransferIdempotency`, `CreateWalletIdempotency`, `FundWalletIdempotency`, `MerchantPaymentIdempotency`, `CashWithdrawalIdempotency`, `FundWalletFromPooledAccountIdempotency`

- **CreateWallet**: `IdempotencyKey` (PK), `WalletId`, `CreatedAt`.
- **Others (except reverse)**: `IdempotencyKey` (PK), `TransactionId`, `CreatedAt`.

### `WalletBalanceReservations`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `ReservationKey` | `string` | `varchar(160)`, PK | Deterministic reservation id. |
| `WalletId` | `Guid` | `uuid` | Wallet. |
| `Amount` | `decimal` | `numeric(18,4)` | Reserved amount. |
| `Status` | `string` | `varchar(16)` | Active / Released / Completed. |
| `CreatedAt` / `UpdatedAt` | `DateTime` | `timestamptz` | Lifecycle. |
| `ReleasedAt` | `DateTime?` | `timestamptz` | Release time. |

### `WalletCredentials`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `WalletId` | `Guid` | `uuid`, PK | Wallet. |
| `PinHash` | `byte[]` | `bytea` (max 64) | PIN hash bytes. |
| `Salt` | `byte[]` | `bytea` (max 64) | Salt. |
| `FailedAttempts` | `int` | `integer` | Failed PIN count. |
| `LockedUntilUtc` | `DateTime?` | `timestamptz` | Lockout end. |
| `CreatedAt` / `UpdatedAt` | `DateTime` | `timestamptz` | Audit. |

### `UserWalletCredentials`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `BankId` / `UserId` | `Guid` | `uuid`, composite PK | User-scoped PIN (bank + user). |
| `PinHash` / `Salt` | `byte[]` | `bytea` | Hash + salt. |
| `FailedAttempts` | `int` | `integer` | Failed attempts. |
| `LockedUntilUtc` | `DateTime?` | `timestamptz` | Lockout. |
| `CreatedAt` / `UpdatedAt` | `DateTime` | `timestamptz` | Audit. |

### MassTransit — `WalletsInboxState`, `WalletsOutboxMessage`, `WalletsOutboxState`

Same conceptual columns as **Transactions** inbox/outbox tables (`TransactionsInboxState` / `TransactionsOutboxMessage` / `TransactionsOutboxState`); see `Masarat.Transactions.Api.reference.md` for field meanings.
