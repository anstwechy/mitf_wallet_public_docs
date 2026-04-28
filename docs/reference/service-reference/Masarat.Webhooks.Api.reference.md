# Masarat.Webhooks.Api — configuration and database

There is **no `appsettings.json` in source**; defaults are in `Program.cs`. Supply configuration via **`appsettings.json`**, **environment variables**, or **Docker secrets** at deploy time.

---

## Configuration

| Key | Value type | Default if missing | Description |
|-----|------------|--------------------|-------------|
| `ConnectionStrings:Webhooks` | `string` (Npgsql) | `Host=localhost;Port=5432;Database=MasaratWebhooks;Username=postgres;Password=postgres` | Webhook subscriptions database. |
| `RabbitMQ:Host` | `string` | `localhost` | RabbitMQ hostname. |
| `RabbitMQ:Username` | `string` | `guest` | AMQP user. |
| `RabbitMQ:Password` | `string` | `guest` | AMQP password. |
| *(Port)* | `ushort` | **5672 implied by overload** | `Program.cs` calls `cfg.Host(host, "/", ...)` without port — use `RabbitMQ:Host` with port in host string or extend code to read `RabbitMQ:Port`. |

MassTransit `PrefetchCount` and retry interval are **hardcoded** in `Program.cs` (prefetch 10, retry 3 × 5s) unless you change code.

---

## Database tables

Migrations run at startup via `Database.MigrateAsync()`.

### `WebhookSubscriptions`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `Id` | `Guid` | `uuid`, PK | Subscription id. |
| `WalletId` | `Guid` | `uuid`, indexed with `EventType` | Wallet scope. |
| `CallbackUrl` | `string` | `varchar(2048)` | HTTPS/HTTP POST target. |
| `Secret` | `string` | `varchar(512)` | HMAC / signing secret. |
| `EventType` | `string` | `varchar(64)` | Event name filter. |
| `IsActive` | `bool` | `boolean` | Delivery enabled. |
| `CreatedAt` | `DateTime` | `timestamptz` | Created. |
