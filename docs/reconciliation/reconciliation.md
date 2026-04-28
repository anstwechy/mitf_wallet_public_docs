# Reconciliation Service

Daily reconciliation job that exports ledger entries for the previous day, matches them against bank statement entries, and stores run results and exceptions in the Reconciliation database.

## Components

- **Ledger API**: gRPC method `ExportEntries(ExportEntriesRequest)` returns all ledger entries in a date range (UTC). Response includes `idempotency_key`, amount, currency per entry (used as internal reference for matching). Reversal operations post new journal entries (e.g. idempotency key `reverse-{transactionId}`); these are included in the export like any other journal.
- **IBankStatementProvider**: Abstraction for bank statement data. Implementations:
  - **MockBankStatementProvider**: Returns entries from config `Reconciliation:MockBank:Entries` (or empty). Use for development and tests.
  - **Real implementation**: Add a class that implements `IBankStatementProvider` (e.g. MT940/942 parser + bank API), register it in `Program.cs` instead of `MockBankStatementProvider`.
- **Masarat.Reconciliation.Job**: Worker runs **catch-up** on each wake for recent calendar days without a **Completed** run (see `Reconciliation:MaxCatchUpDays`), then sleeps until the next `RunAtUtcHour` (default 2:00 UTC). Exports ledger, fetches bank entries via `IBankStatementProvider`, matches by **reference** (ledger `IdempotencyKey` = bank `Reference`) and amount/currency (optional `BankAmountMatchTolerance`), then persists `ReconciliationRun` (TotalExported, MatchedCount, ExceptionCount) and `ReconciliationExceptions` (per-exception rows). Retries remove prior **Failed** runs (and abandoned **Running** runs when configured) for that date before inserting a new attempt.

## Matching rules

- **Reference**: Ledger entry’s `IdempotencyKey` is matched to bank statement line’s `Reference`. When integrating a real bank, ensure the reference sent in payments (e.g. transaction ID or idempotency key) is what appears on the statement.
- **Match**: Same reference and same amount (and currency) → counted as matched.
- **MissingInBank**: Ledger entry has no bank line with that reference.
- **MissingInLedger**: Bank line has no ledger entry with that reference.
- **AmountMismatch**: Same reference but amount or currency differs.

## Configuration

**Reconciliation job** (`appsettings.json` or environment):

- `ConnectionStrings:Reconciliation` – PostgreSQL connection.
- `Reconciliation:LedgerGrpcAddress` – Ledger gRPC endpoint.
- `Reconciliation:RunAtUtcHour` – Hour in UTC for the scheduled wake (default 2); values outside 0–23 are clamped.
- `Reconciliation:MaxCatchUpDays` – How many days back (including yesterday) to scan for incomplete dates (default 30).
- `Reconciliation:AbandonedRunAgeHours` – Stale **Running** rows older than this are removed before retry (default 2); use `0` to disable automatic removal of stuck **Running** rows.
- `Reconciliation:BankAmountMatchTolerance` – Optional absolute tolerance for ledger vs bank amount (default 0).
- `Observability:CollectorUrl` – Optional OTLP endpoint for traces/logs (e.g. in Docker: `http://otelcollector:4318`).
- `Reconciliation:MockBank` – Optional mock lines for testing, e.g.:
  ```json
  "MockBank": {
    "IncludeUndatedEntries": false,
    "Entries": [
      { "Reference": "key-debit-123", "Amount": -100, "Currency": "LYD", "ValueDate": "2026-04-10T00:00:00Z" },
      { "Reference": "key-credit-123", "Amount": 100, "Currency": "LYD", "ValueDate": "2026-04-10T00:00:00Z" }
    ]
  }
  ```
  Lines with `ValueDate` are returned only when that UTC calendar day equals the reconciliation `runDate`. Undated lines are included only when `IncludeUndatedEntries` is `true` (default `true` for backward compatibility).

## Database

- **MasaratReconciliation**: Tables `ReconciliationRuns` (run summary) and `ReconciliationExceptions` (MissingInBank, MissingInLedger, AmountMismatch with reference and amounts). Migrations run on startup.

## Adding a real bank implementation

1. Implement `IBankStatementProvider`: e.g. call your bank API or parse MT940/942 files, map each statement line to `BankStatementEntry(Reference, Amount, Currency, ValueDate)`.
2. Register it in `Program.cs`: e.g. `builder.Services.AddSingleton<IBankStatementProvider, RealBankStatementProvider>();` (and remove or conditionally skip the mock registration).
3. Ensure **Reference** in bank data matches what you store in the ledger (e.g. idempotency key or transaction ID) so the matcher can pair them.

