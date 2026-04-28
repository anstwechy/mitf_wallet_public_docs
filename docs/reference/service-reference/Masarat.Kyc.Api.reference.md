# Masarat.Kyc.Api — configuration and database

Connection string name: **`Kyc`** → database commonly `MasaratKyc`.

---

## Configuration

| Key | Value type | Example value | Description |
|-----|------------|---------------|-------------|
| `Logging:LogLevel:*` | `string` | — | Standard logging. |
| `AllowedHosts` | `string` | `*` | Host filter. |
| `ConnectionStrings:Kyc` | `string` | Npgsql | KYC PostgreSQL. |
| `Auth:RequireApiKey` | `bool` | `true` | Require HTTP API key when enabled. |
| `Auth:ApiKey` | `string` | `""` | Shared API key (set in env/secret store). |
| `Observability:*` | various | — | Telemetry flags. |
| `InternalLoggerOptions:*` | various | Loki | Serilog. |

---

## Database tables

Table names use **snake_case** per EF mapping.

### `kyc_field_definitions`

| Property | Type | PostgreSQL / constraints | Description |
|----------|------|---------------------------|-------------|
| `Id` | `Guid` | `uuid`, PK | Field definition id. |
| `Key` | `string` | `varchar(128)`, unique | Stable machine key. |
| `Label` | `string` | `varchar(512)` | Human label. |
| `DataType` | enum → string | `varchar(32)` | String, number, date, etc. |
| `Sensitive` | `bool` | `boolean` | PII / sensitive flag (domain property; persisted by EF convention). |
| `CreatedAt` | `DateTime` | `timestamptz` | Created. |

### `kyc_templates`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `Id` | `Guid` | `uuid`, PK | Template id. |
| `Key` | `string` | `varchar(128)`, unique | Template key (referenced from wallet classifications). |
| `DisplayName` | `string` | `varchar(512)` | UI name. |
| `RequiresManualReview` | `bool` | `boolean` | Workflow flag (domain; EF convention). |
| `IsActive` | `bool` | `boolean` | Selectable template. |
| `CreatedAt` / `UpdatedAt` | `DateTime` | `timestamptz` | Audit. |

### `kyc_template_fields` (join)

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `KycTemplateId` | `Guid` | `uuid`, PK part | FK → `kyc_templates`. |
| `KycFieldDefinitionId` | `Guid` | `uuid`, PK part | FK → `kyc_field_definitions`. |
| `IsRequired` | `bool` | `boolean` | Required on submission. |
| `SortOrder` | `int` | `integer` | Display / capture order. |

### `kyc_submissions`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `Id` | `Guid` | `uuid`, PK | Submission id. |
| `UserId` | `Guid` | `uuid` | Submitter. |
| `KycTemplateId` | `Guid` | `uuid` | Template FK. |
| `Status` | enum → string | `varchar(32)` | Pending / Approved / Rejected. |
| `SubmittedAt` | `DateTime` | `timestamptz` | Submission time. |
| `ReviewedAt` | `DateTime?` | `timestamptz` | Review completion. |
| `ReviewedBy` | `string?` | `varchar(256)` | Reviewer id/email. |
| `RejectReason` | `string?` | `varchar(2048)` | Rejection explanation. |

Unique index: (`UserId`, `KycTemplateId`).

### `kyc_submission_values`

| Property | Type | PostgreSQL | Description |
|----------|------|------------|-------------|
| `Id` | `Guid` | `uuid`, PK | Value row id. |
| `KycSubmissionId` | `Guid` | `uuid` | Parent submission. |
| `KycFieldDefinitionId` | `Guid` | `uuid` | Which field. |
| `Value` | `string` | `varchar(8192)` | Captured value (text). |
