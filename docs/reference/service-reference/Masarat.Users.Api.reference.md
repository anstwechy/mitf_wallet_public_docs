# Masarat.Users.Api — configuration and database

Connection string name: **`Users`** → database commonly `MasaratUsers`.

---

## Configuration

| Key | Value type | Example value | Description |
|-----|------------|---------------|-------------|
| `Logging:LogLevel:*` | `string` | `Information` / `Warning` | Standard logging. |
| `AllowedHosts` | `string` | `*` | Host filter. |
| `ConnectionStrings:Users` | `string` | Npgsql string | Users database. |
| `WalletGrpc:Address` | `string` (URI) | `http://localhost:5002` | Downstream Wallets gRPC (onboarding / linkage). |
| `RabbitMQ:Host` / `Port` / `Username` / `Password` | string / int | localhost, guest | MassTransit RabbitMQ. |
| `Messaging:Tuning:PrefetchCount` | `ushort` | `24` | Consumer prefetch. |
| `Messaging:Tuning:RetryCount` | `int` | `2` | Retries. |
| `Messaging:Tuning:RetryIntervalSeconds` | `int` | `2` | Retry spacing. |
| `OnboardingRateLimiting:PermitLimit` | `int` | `30` | Fixed-window limit for onboarding endpoints. |
| `OnboardingRateLimiting:WindowSeconds` | `int` | `60` | Window size seconds. |
| `Observability:*` | various | — | OpenTelemetry. |
| `InternalLoggerOptions:*` | various | Loki | Serilog. |
| `Auth:RequireApiKey` / `Auth:ApiKey` | bool / string | — | gRPC API key (`ApiKeyOptions`). |

---

## Database tables

Migrations history: default EF **`__EFMigrationsHistory`** unless overridden in `UseNpgsql`.

### `Users`

| Property | Type | PostgreSQL / constraints | Description |
|----------|------|---------------------------|-------------|
| `Id` | `Guid` | `uuid`, PK | User id. |
| `NationalId` | `string` | `varchar(64)`, unique | National ID or passport number. |
| `FullName` | `string` | `varchar(256)` | Display / legal name. |
| `KycStatus` | enum → string | text | Pending / Approved / Rejected. |
| `CustomerType` | enum → string | text | Resident / Foreign. |
| `LinkedBankAccountId` | `string?` | `varchar(64)` | Optional bank account link. |
| `CreatedAt` | `DateTime` | `timestamptz` | Created (UTC). |
