# Masarat.LoadTest.Job — configuration

Worker host; **no EF `DbContext`**. Options bind from section **`LoadTest`** (`LoadTestServiceOptions`). Nested objects mirror `appsettings.json`.

---

## Configuration (summary)

The file is large; keys below follow **`LoadTest:`** prefix. Value types match `LoadTestServiceOptions` and nested types in `Masarat.LoadTest.Job`.

### Core service URLs and scenario

| Key | Value type | Example | Description |
|-----|------------|---------|-------------|
| `LoadTest:UserServiceAddress` | `string` (URI) | `http://localhost:5003` | Users gRPC HTTP/2 address. |
| `LoadTest:WalletServiceAddress` | `string` (URI) | `http://localhost:5002` | Wallets gRPC. |
| `LoadTest:TransactionServiceAddress` | `string` (URI) | `http://localhost:5004` | Transactions gRPC. |
| `LoadTest:BankId` | `Guid` (string) | default bank UUID | Tenant for all operations. |
| `LoadTest:FundAmount` | `decimal` | `100` | Default fund per wallet in batch flows. |
| `LoadTest:TransferAmount` | `decimal` | `50` | Default P2P transfer amount. |
| `LoadTest:Currency` | `string` | `LYD` | ISO currency. |
| `LoadTest:UseBogusSyntheticFullNames` | `bool` | `true` | Generate realistic names. |
| `LoadTest:SyntheticDataLocale` | `string` | `en` | Bogus locale. |
| `LoadTest:CashWithdrawalAmount` / `MerchantPaymentAmount` | `decimal` | `15` / `20` | Scenario amounts. |
| `LoadTest:MerchantReference` | `string` | `BATCH-MERCHANT-001` | Merchant payment reference. |
| `LoadTest:TestPin` | `string` | `1234` | PIN for synthetic users. |
| `LoadTest:CreatePooledAccount` | `bool` | `true` | Create employer pool when employer configured. |
| `LoadTest:FundFromPoolAmount` | `decimal` | `0` | Fund from pool after create (0 skips). |
| `LoadTest:ReverseLastTransaction` | `bool` | `true` | Whether to issue reversal step. |
| `LoadTest:Employer:NationalId` / `FullName` | `string` | — | Employer persona for pooled flows. |
| `LoadTest:SupWalletCustomers` | `array` of `{ NationalId, FullName }` | — | Extra customers for SUP wallet scenarios. |
| `LoadTest:EligibleCustomers` | `array` of `{ NationalId, FullName, CustomerType }` | — | Resident/foreign pool for provisioning. |

### Customer Gateway load test (`LoadTest:CustomerGatewayLoadTest:*`)

| Key pattern | Value type | Description |
|-------------|------------|-------------|
| `Enabled` | `bool` | When true, run HTTP gateway journeys instead of/in addition to raw gRPC batch. |
| `BaseUrl` | `string` (URI) | Customer gateway base URL. |
| `GatewayApiKey` | `string` | API key header for gateway. |
| `Profile` | `string` | Named profile preset (`standard_midscale`, etc.). |
| `Mode` | `string` | Run mode (`normal`, etc.). |
| `Persona` / `PersonaSequence` | `string` / `string[]` | Which personas to simulate. |
| `VirtualUserCount` / `MaxConcurrency` / `IterationsPerUser` | `int` | Load shape. |
| `ThinkTimeMinMs` / `ThinkTimeMaxMs` | `int` | Delay between steps. |
| `RefreshAfterStepCount` | `int` | Token refresh cadence. |
| `OperationPollMaxAttempts` / `OperationPollDelayMs` | `int` | Async op polling. |
| `RetryOnTooManyRequests*` | `int` | Backoff for HTTP 429. |
| `HttpTimeoutSeconds` / `HttpMaxConnectionsPerServer` / `HttpPooledConnectionLifetimeSeconds` | `int` | HttpClient tuning. |
| `InitialFundAmount` | `decimal` | Gateway journey funding. |
| `AdditionalProvisionCurrencies` | `string[]` | Extra currencies to provision. |
| `DefaultPin` | `string` | PIN for gateway flows. |
| `IncludeCustomerOnboarding` / `IncludeManagedWalletCreation` / `IncludeBusinessPooledAccounts` / `IncludeBusinessSubWallets` / `IncludeMerchantAcceptance` | `bool` | Feature toggles for journeys. |
| `CustomerSubPersonaWeights` / `BusinessSubPersonaWeights` | object map string→int | Weighted persona selection. |
| `CustomerGatewayLoadTest:Customer` / `:Business` / `:Merchant` | nested object | Per-persona AppId, AppKey, BankId, VirtualUserCount, concurrency, classification, holder type, name/id prefixes, etc. |

### Nested batch load (`LoadTest:LoadTest:*`)

Used when inner load profile is enabled (high-volume gRPC batch / soak):

| Key pattern | Value type | Description |
|-------------|------------|-------------|
| `LoadTest:LoadTest:Enabled` | `bool` | Enable inner batch driver. |
| `LoadTest:LoadTest:WalletCount` / `TransferCount` | `int` | Volume targets. |
| `LoadTest:LoadTest:WarmupWalletCount` | `int` | Pre-warm wallets. |
| `LoadTest:LoadTest:SoakRounds` / `SoakDelaySeconds` | `int` | Soak test pacing. |
| `LoadTest:LoadTest:MaxConcurrency` / `ProvisionConcurrency` / `FundingConcurrency` | `int` | Parallelism caps. |
| `LoadTest:LoadTest:TransferAmount` | `decimal` | Transfer amount in batch mode. |
| `LoadTest:LoadTest:FundEachSourceWallet` | `decimal` | Per-wallet fund in batch. |
| `LoadTest:LoadTest:AuthorizationTokenSecret` | `string` | Must align with Wallets token secret when minting tokens. |
| `LoadTest:LoadTest:Chaos:*` | `int` / `decimal` | Delay/timeout/duplicate percentages for chaos injection. |
| `LoadTest:LoadTest:TransferSlo:*` | `int` / `bool` | Latency SLO thresholds and `FailOnBreach`. |

### Logging / observability

| Key | Value type | Example | Description |
|-----|------------|---------|-------------|
| `InternalLoggerOptions:ConsoleFormat` | `string` | `Human` | Serilog console template (`Human` vs JSON). |
| `Observability:ServiceName` | `string` | `Masarat.LoadTest.Job` | Telemetry service name. |
| `Observability:Environment` | `string` | `Production` | Environment label. |
| `Observability:CollectorUrl` | `string` (URI) | `http://localhost:4317` | OTLP endpoint. |

---

## Database tables

None — the job drives remote services only.
