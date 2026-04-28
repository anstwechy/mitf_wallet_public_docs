# Service reference (configuration and database)

This folder holds **one markdown file per deployable host** documenting:

1. **Configuration** — flattened JSON keys (`Section:SubKey`), CLR-oriented value types, example values from default `appsettings.json` where present, and what each setting does.
2. **Database** — PostgreSQL tables owned by that host’s EF Core context (plus MassTransit inbox/outbox tables when applicable). For each table: columns (property name), logical type, PostgreSQL type or constraints, and a short explanation.

**Notes**

- Example values are illustrative; override secrets and URLs per environment.
- Some domain types store as `string` in PostgreSQL (enum names).
- Management portal adds standard **ASP.NET Core Identity** tables (`AspNetUsers`, `AspNetRoles`, claims, logins, tokens, user roles) — see `Masarat.Gateway.Management.Web.reference.md` for the custom audit table; Identity columns follow Microsoft’s default schema.

**Files**

| File | Host |
|------|------|
| `Masarat.Transactions.Api.reference.md` | Transactions gRPC API |
| `Masarat.Wallets.Api.reference.md` | Wallets gRPC API |
| `Masarat.Users.Api.reference.md` | Users gRPC API |
| `Masarat.Ledger.Api.reference.md` | Ledger gRPC API |
| `Masarat.Kyc.Api.reference.md` | KYC HTTP API |
| `Masarat.Reconciliation.Job.reference.md` | Reconciliation worker + shared reconciliation DB |
| `Masarat.Reconciliation.Reporting.reference.md` | Bank-facing reporting API |
| `Masarat.Webhooks.Api.reference.md` | Webhooks HTTP API |
| `Masarat.Gateway.Customer.Api.reference.md` | Customer gateway |
| `Masarat.Gateway.Management.Web.reference.md` | Management Blazor portal |
| `Masarat.LoadTest.Job.reference.md` | Load test worker |

`Masarat.Reconciliation.Api` shares the **Reconciliation** database and job libraries; configure it like the job for DB connection and mock bank settings.
