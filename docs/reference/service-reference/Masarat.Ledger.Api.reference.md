# Masarat.Ledger.Api — configuration and database

Connection string name: **`Ledger`** → database commonly `MasaratLedger`.

---

## Configuration

| Key | Value type | Example value | Description |
|-----|------------|---------------|-------------|
| `Logging:LogLevel:*` | `string` | — | Standard logging. |
| `AllowedHosts` | `string` | `*` | Host filter. |
| `Ledger:AllowedCurrencies` | `string[]` | `["LYD","USD"]` | Currencies the ledger will accept for new accounts/entries. |
| `Ledger:DeferredInlineSnapshotAccountIds` | `Guid[]` (strings) | fee revenue account id | Accounts where snapshot updates may be deferred (performance). |
| `ConnectionStrings:Ledger` | `string` | Npgsql | Ledger PostgreSQL. |
| `RabbitMQ:*` | string / int | localhost | Event consumption (transfer completed, etc.). |
| `Messaging:Tuning:PrefetchCount` / `RetryCount` / `RetryIntervalSeconds` | int | 24, 2, 2 | MassTransit tuning. |
| `LedgerBackpressure:Enabled` | `bool` | `true` | Limit concurrent ledger work. |
| `LedgerBackpressure:MaxInFlightRequests` | `int` | `64` | In-flight cap. |
| `LedgerBackpressure:AcquireTimeoutMs` | `int` | `200` | Wait for slot. |
| `Observability:*` | various | — | Telemetry. |
| `InternalLoggerOptions:*` | various | — | Serilog / Loki. |
| `Auth:*` | — | — | API key for gRPC if enabled. |

---

## Database tables

Migrations history: **`__LedgerMigrationsHistory`**.

### `LedgerAccounts`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `Id` | `Guid` | `uuid`, PK | Account id (may be seeded for system accounts). |
| `WalletId` | `Guid` | `uuid` | Owning wallet (or system wallet for pooled/settlement). |
| `Type` | enum → string | text | Asset / Liability. |
| `Currency` | `string` | `varchar(3)` | ISO currency. |
| `CreatedAt` | `DateTime` | `timestamptz` | Created. |

### `LedgerEntries`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `Id` | `Guid` | `uuid`, PK | Entry id. |
| `AccountId` | `Guid` | `uuid` | Target account. |
| `Amount` | `decimal` | `numeric(18,4)` | Signed posting amount. |
| `Currency` | `string` | `varchar(3)` | Currency. |
| `TransactionId` | `Guid` | `uuid` | Business transaction id. |
| `IdempotencyKey` | `string` | `varchar(128)`, unique | Duplicate prevention. |
| `CreatedAt` | `DateTime` | `timestamptz` | Posted at. |
| `Description` | `string?` | `varchar(256)` | Audit label. |

### `LedgerBalanceSnapshots`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `AccountId` | `Guid` | `uuid`, PK | One row per account. |
| `WalletId` | `Guid` | `uuid` | Denormalized wallet for queries. |
| `Balance` | `decimal` | `numeric(18,4)` | Cached balance. |
| `Currency` | `string` | `varchar(3)` | Currency. |
| `LastTransactionId` | `Guid?` | `uuid` | Last tx applied to snapshot. |
| `UpdatedAt` | `DateTime` | `timestamptz` | Last update. |

### `LedgerProcessedSnapshotEvents`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `EventKey` | `string` | `varchar(160)`, PK | Idempotent processing key (tx + account dimension). |
| `TransactionId` | `Guid` | `uuid` | Source transaction. |
| `AccountId` | `Guid` | `uuid` | Affected account. |
| `ProcessedAt` | `DateTime` | `timestamptz` | When snapshot side-effect was recorded. |

> Rows are inserted via raw SQL in `LedgerBalanceSnapshotRepository` as well as modeled in EF for migrations.
