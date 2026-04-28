# Masarat.Reconciliation.Reporting — configuration

This host generates **bank-facing** reconciliation reports; it uses **gRPC to Transactions and Ledger** and does not own a Masarat EF database context in this solution (stateless reporting service).

---

## Configuration

| Key | Value type | Example value | Description |
|-----|------------|---------------|-------------|
| `Logging:LogLevel:*` | `string` | `Information` / `Warning` | ASP.NET logging. |
| `AllowedHosts` | `string` | `*` | Host filter. |
| `Reporting:TransactionsGrpcAddress` | `string` (URI) | `http://localhost:5004` | Transactions service for exports. |
| `Reporting:LedgerGrpcAddress` | `string` (URI) | `http://localhost:5001` | Ledger for balances / entries as needed. |
| `Reporting:ExportPageSize` | `int` | `1000` | Page size per export RPC iteration. |
| `Reporting:MaxExportPages` | `int` | `1000` | Safety cap on pagination loops. |
| `BankAccountMappings:Accounts` | `array` of objects | see `appsettings.json` | Maps bank + settlement type (+ optional account key) to display banking metadata (account number, bank name). |
| `BankAccountMappings:Accounts[n]:BankId` | `Guid?` | UUID | Bank scope for mapping row. |
| `BankAccountMappings:Accounts[n]:SettlementType` | `string` | `Merchant` | Settlement category (e.g. Merchant, CashWithdrawal). |
| `BankAccountMappings:Accounts[n]:AccountKey` | `string?` | ledger account GUID string | Optional ledger account key filter. |
| `BankAccountMappings:Accounts[n]:BankAccountNumber` | `string` | IBAN-style | Shown on reports. |
| `BankAccountMappings:Accounts[n]:BankName` | `string` | — | Institution name on reports. |
| `BankAccountMappings:Accounts[n]:BankDisplayName` | `string` | — | UI / picker label; falls back to `BankName` if empty. |

---

## Database tables

None owned by this service (no `DbContext` in reporting project).
