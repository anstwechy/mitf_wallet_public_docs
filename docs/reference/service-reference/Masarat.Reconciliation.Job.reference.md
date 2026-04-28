# Masarat.Reconciliation.Job (and Reconciliation.Api) — configuration and database

Connection string name: **`Reconciliation`** → database commonly `MasaratReconciliation`.  
The **Reconciliation.Api** host references the same job assembly and DB context.

---

## Configuration

| Key | Value type | Example value | Description |
|-----|------------|---------------|-------------|
| `Logging:LogLevel:*` | `string` | `Information` | Worker logging. |
| `Observability:ServiceName` | `string` | `Masarat.Reconciliation.Job` | Telemetry service name. |
| `Observability:Environment` | `string` | `Development` | Deployment environment label. |
| `Observability:CollectorUrl` | `string` (URI) | `http://localhost:4317` | OTLP collector (if wired). |
| `ConnectionStrings:Reconciliation` | `string` | Npgsql | Reconciliation + internal consistency tables. |
| `RabbitMQ:Host` / `Port` / `Username` / `Password` | string / int | localhost / guest | Optional messaging if host registers MT. |
| `Reconciliation:LedgerGrpcAddress` | `string` (URI) | `http://localhost:5001` | Ledger client for nightly reconciliation. |
| `Reconciliation:RunAtUtcHour` | `int` | `2` | UTC hour (0–23) for the next scheduled wake after catch-up; invalid values clamped. |
| `Reconciliation:MaxCatchUpDays` | `int` | `30` | Days back (incl. yesterday) to scan for missing **Completed** runs on each wake. |
| `Reconciliation:AbandonedRunAgeHours` | `int` | `2` | Drop stuck **Running** rows older than this before retry; `0` disables. |
| `Reconciliation:BankAmountMatchTolerance` | `decimal` | `0` | Allowed \|ledger − bank\| for a match (same currency). |
| `Reconciliation:MockBank:Entries` | `array` of objects | `[]` | Synthetic bank lines; use `ValueDate` (UTC) to pin a line to one reconciliation day. |
| `Reconciliation:MockBank:IncludeUndatedEntries` | `bool` | `true` | When `true`, lines without `ValueDate` are returned for every run date. |
| `InternalConsistency:Enabled` | `bool` | `true` | Background repair polling to Transactions gRPC. |
| `InternalConsistency:PollIntervalSeconds` | `int` | `60` | Delay between repair iterations. |
| `InternalConsistency:BatchSize` | `int` | `50` | Batch passed to `RepairUnknownNeedsReconciliationBatchAsync`. |
| `InternalConsistency:TransactionsGrpcAddress` | `string` (URI) | `http://localhost:5004` | Transactions API for repair RPC. |

`MockBankEntryConfig` entries (when used) typically include amount/date/reference fields — see `MockBankStatementProvider` for binding shape.

---

## Database tables

### `ReconciliationRuns`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `Id` | `Guid` | `uuid`, PK | Run id. |
| `RunDate` | `DateOnly` | `date` | Business date reconciled. |
| `StartedAt` | `DateTime` | `timestamptz` | Run start. |
| `CompletedAt` | `DateTime?` | `timestamptz` | Run end. |
| `Status` | `string` | `varchar(32)` | Running / Completed / Failed. |
| `TotalExported` | `int` | `integer` | Rows exported from ledger side. |
| `MatchedCount` | `int` | `integer` | Matched rows. |
| `ExceptionCount` | `int` | `integer` | Exception rows. |
| `ErrorMessage` | `string?` | `varchar(2000)` | Failure reason. |

### `ReconciliationExceptions`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `Id` | `Guid` | `uuid`, PK | Exception row id. |
| `RunId` | `Guid` | `uuid`, indexed | Parent run. |
| `ExceptionType` | `string` | `varchar(64)` | MissingInBank / MissingInLedger / AmountMismatch. |
| `InternalReference` | `string?` | `varchar(256)` | Internal txn reference. |
| `BankReference` | `string?` | `varchar(256)` | Bank statement reference. |
| `ExpectedAmount` | `decimal?` | `numeric(18,4)` | Expected side. |
| `ActualAmount` | `decimal?` | `numeric(18,4)` | Actual side. |
| `Message` | `string?` | `varchar(1000)` | Human explanation. |

### `InternalConsistencyRuns`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `Id` | `Guid` | `uuid`, PK | Run id. |
| `StartedAt` | `DateTime` | `timestamptz` | Start. |
| `CompletedAt` | `DateTime?` | `timestamptz` | End. |
| `Status` | `string` | `varchar(32)` | Running / Completed / Failed. |
| `ScannedCount` | `int` | `integer` | Items scanned in batch RPC. |
| `RepairedCount` | `int` | `integer` | Auto-repaired. |
| `DeferredCount` | `int` | `integer` | Deferred. |
| `ManualReviewCount` | `int` | `integer` | Needs manual review. |
| `ErrorMessage` | `string?` | `varchar(2000)` | Failure text. |

### `InternalConsistencyIssues`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `Id` | `Guid` | `uuid`, PK | Issue id. |
| `RunId` | `Guid` | `uuid` | Parent consistency run. |
| `RequestId` | `Guid` | `uuid` | Async request id from Transactions. |
| `IssueType` | `string` | `varchar(64)` | e.g. MissingTransactionId, RepairedFromLedgerTruth. |
| `Resolution` | `string` | `varchar(32)` | Repaired / Deferred / ManualReviewRequired. |
| `OperationType` | `string` | `varchar(64)` | Command type. |
| `IdempotencyKey` | `string` | `varchar(128)` | Client idempotency key. |
| `TransactionId` | `Guid?` | `uuid` | Related transaction if any. |
| `Message` | `string?` | `varchar(1000)` | Detail. |
| `RecordedAt` | `DateTime` | `timestamptz` | Insert time. |
