# Logging for operation teams

Production-grade structured logging is configured across all major services (Users, Wallets, Ledger, Transactions, Customer Gateway APIs and Masarat.LoadTest.Job, Reconciliation.Job). This document describes where logs go, standard fields, and how to query them.

---

## Overview

- **Pipeline:** Serilog is the single logging pipeline. All services use the shared Observability logger (`AddCustomLogger()`).
- **Outputs:** Logs always go to **Console** (stdout) as **one JSON object per line** (compact format) so `docker compose logs` and log shippers see structured fields (Application, Environment, trace_id, CorrelationId, Level, Message, etc.). Optionally logs are also sent to:
  - **Loki** (when `InternalLoggerOptions:LogType` is `Loki` and `ConnectionString` is set)
  - **OTLP** (when `Observability:CollectorUrl` is set; logs are sent to the HTTP endpoint, typically port 4318)
  - **SQL Server / PostgreSQL / Elasticsearch** (when `LogType` is `Sql`, `PostGres`, or `Elastic` and `ConnectionString` is set)
- **Console-only:** When `InternalLoggerOptions` is missing, `LogType` is `Console`, or the log type is unknown, only the Console sink is used (plus optional OTLP). Workers can run in dev without Loki/SQL/Elastic.

---

## Standard fields

Every log event includes (where applicable):


| Field                          | Description                                                                          |
| ------------------------------ | ------------------------------------------------------------------------------------ |
| `Application` / `service.name` | Service identifier (e.g. `Masarat.Wallets.Api`, `Masarat.LoadTest.Job`)                 |
| `Environment`                  | Deployment environment (e.g. Development, Production)                                |
| `trace_id`                     | OpenTelemetry trace ID (when activity is present)                                    |
| `span_id`                      | OpenTelemetry span ID                                                                |
| `CorrelationId`                | Request-scoped ID for APIs; set in middleware and response header `X-Correlation-ID` |
| `LoadTestRunId`                   | Masarat.LoadTest.Job: ID for the current run (workers)                                 |
| `ReconciliationRunId`          | Reconciliation job: ID for the current reconciliation run                            |
| `Level`                        | Log level (Information, Warning, Error, etc.)                                        |
| `Message`                      | Log message template                                                                 |
| `Exception`                    | Exception type and stack trace when present                                          |


---

## Correlation ID

- **APIs:** Each HTTP/gRPC request gets a correlation ID. It is generated if not provided, or read from the `X-Correlation-ID` request header.
- **Response:** The response includes the header `X-Correlation-ID` so clients can use it for support or debugging.
- **Propagation:** To correlate across services, send the same value in `X-Correlation-ID` on outbound calls. gRPC clients can add metadata `x-correlation-id` so server-side error logs include it.
- **Workers:** Background jobs use `LoadTestRunId` or `ReconciliationRunId` in LogContext so all logs for a run can be filtered by that ID.

---

## Query examples

### gRPC call logging

Each gRPC request is logged at Information level by `GrpcLoggingInterceptor`: **Method**, **StatusCode**, and **DurationMs**. When **Masarat.LoadTest.Job** (or any client) calls Wallets or Transactions via gRPC, you will see lines like:

- `gRPC call completed. Method: /wallet.WalletService/CreateWallet, Status: OK, DurationMs: 42`
- `gRPC call completed. Method: /transaction.TransactionService/FundWallet, Status: OK, DurationMs: 31`

Use these to correlate load-test activity with API-side logs.

---

### Loki (LogQL)

- By service: `{Application="Masarat.Wallets.Api"}`
- By correlation ID: `{Application=~"Masarat.*"} | json | CorrelationId="<guid>"`
- By trace: `{Application=~"Masarat.*"} | json | trace_id="<trace-id>"`
- By run: `{Application="Masarat.LoadTest.Job"} | json | LoadTestRunId="<guid>"`

### Elasticsearch (KQL / query DSL)

- By service: `Application: "Masarat.Wallets.Api"`
- By correlation: `CorrelationId: "<guid>"`
- By trace: `trace_id: "<trace-id>"`

### OTLP / generic backends

Use the same field names (`Application`, `CorrelationId`, `trace_id`, `LoadTestRunId`, `ReconciliationRunId`) in your query UI.

---

## Configuration

### Observability (all services)


| Key                          | Description                                         | Example                      |
| ---------------------------- | --------------------------------------------------- | ---------------------------- |
| `Observability:ServiceName`  | Service name in logs and traces                     | `Masarat.Wallets.Api`        |
| `Observability:Environment`  | Environment label                                   | `Production`                 |
| `Observability:CollectorUrl` | OTLP collector URL (traces/metrics 4317; logs 4318) | `http://otel-collector:4317` |


### InternalLoggerOptions (APIs; optional for workers)


| Key                                      | Description                                                          | Example            |
| ---------------------------------------- | -------------------------------------------------------------------- | ------------------ |
| `InternalLoggerOptions:LogType`          | `Console`, `Loki`, `Sql`, `PostGres`, `Elastic`                      | `Loki`             |
| `InternalLoggerOptions:ConnectionString` | Required when LogType is not Console (Loki URL, DB connection, etc.) | `http://loki:3100` |
| `InternalLoggerOptions:TableName`        | Table prefix for SQL sinks                                           | `Logs`_            |


### Optional API request logging


| Key | Description | Default |
| --- | --- | --- |
| `Observability:ApiLogging:EnableRequestLogging` | Log each request (method, path, status, duration) | `false` |
| `Observability:ApiLogging:LogRequestHeaders` | Include request headers (redacted per RedactHeaders) | `false` |
| `Observability:ApiLogging:LogRequestBody` | Include request body (not recommended in production) | `false` |
| `Observability:ApiLogging:LogResponseBody` | Include response body (not recommended in production) | `false` |
| `Observability:ApiLogging:RedactHeaders` | Header names to redact (e.g. Authorization, Cookie) | `["Authorization","Cookie","X-Api-Key"]` |
| `Observability:ApiLogging:RedactBodyProperties` | JSON property names to redact in body logs | `["password","pin","apiKey","token","authorization"]` |
| `Observability:ApiLogging:ExcludePaths` | Paths to exclude from request logging | `["/health","/health/ready","/metrics","/hc"]` |


For production, use `EnableRequestLogging: true` with body logging off and keep default path exclusions so health and metrics are not logged.

### Log levels

- Default minimum level is **Information**. Framework namespaces (Microsoft.*, System.*) are overridden to **Warning** to reduce noise.
- To change verbosity per environment, set `Logging:LogLevel:Default` in appsettings (e.g. `Debug` in Development). Serilog is configured to use the same minimum level and overrides in code; for finer control you can add Serilog section in config if using Serilog.Settings.Configuration.

---

## Runbook

### When errors spike

1. **Identify service:** Filter by `Application` or `service.name` for the affected service.
2. **Find a failing request:** Look for `Level=Error` (or Warning) and note `CorrelationId` or `trace_id`.
3. **Follow the request:** Use that `CorrelationId` or `trace_id` to see all log lines for that request across services.
4. **Workers:** Filter by `LoadTestRunId` or `ReconciliationRunId` to see the full run (start, progress, completion or failure, duration).

### Startup and shutdown

- **Started:** Each service logs once at startup with `ServiceName`, `Environment`, `LogSink`, and whether `CollectorUrl` is set (category `Masarat.Operational`).
- **Shutting down:** Each service logs once when stopping with `ServiceName`. Use these to confirm graceful shutdown and ordering.

### Dependency failures

- RabbitMQ and DB connection retries are logged with structured fields. Final failure is logged at Error. Search by `Application` and level `Error` to find dependency issues.

