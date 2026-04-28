# Masarat.Gateway.Customer.Api — configuration

This host is **HTTP-only** (REST/OpenAPI); it proxies to Users, Wallets, Transactions, and Kyc. **No owned EF database.**

---

## Configuration

| Key | Value type | Example value | Description |
|-----|------------|---------------|-------------|
| `Logging:LogLevel:*` | `string` | — | ASP.NET logging. |
| `AllowedHosts` | `string` | `*` | Host filter. |
| `Auth:RequireApiKey` | `bool` | `true` | Global API key middleware (when enabled). |
| `Auth:ApiKey` | `string` | `""` | Shared key if using simple API key auth. |
| `CustomerGateway:RequireUserContextForWrites` | `bool` | `true` | Require authenticated user on mutating routes. |
| `CustomerGateway:AllowUserIdHeaderFallback` | `bool` | `false` | **Must stay false in Production** — dev-only user impersonation. |
| `CustomerGateway:RequireWalletPinForLogin` | `bool` | `true` | PIN required for login/bootstrap flows when enabled. |
| `CustomerGateway:EnableBusinessPooledAccounts` | `bool` | `false` | Feature flag for business pooled-account routes. |
| `CustomerGateway:EnableBusinessSubWallets` | `bool` | `false` | Feature flag for sub-wallet flows. |
| `CustomerGateway:EnableMerchantAcceptanceRoutes` | `bool` | `false` | Feature flag for merchant acceptance. |
| `CustomerGateway:OnboardingProvisioningPollAttempts` | `int` | `3` | Poll count waiting for async provisioning. |
| `CustomerGateway:OnboardingProvisioningPollDelayMs` | `int` | `300` | Delay between polls. |
| `CustomerGateway:UserAuthentication:Enabled` | `bool` | `true` | JWT bearer auth for customers. |
| `CustomerGateway:UserAuthentication:Issuer` | `string` | `Masarat.Internal` | JWT issuer. |
| `CustomerGateway:UserAuthentication:Audience` | `string` | `Masarat.CustomerGateway` | JWT audience. |
| `CustomerGateway:UserAuthentication:SigningKey` | `string` | long secret | Symmetric signing key (min 32 bytes effective). |
| `CustomerGateway:UserAuthentication:AccessTokenExpiryMinutes` | `int` | `15` | Access token TTL. |
| `CustomerGateway:UserAuthentication:RefreshTokenExpiryDays` | `int` | `30` | Refresh token TTL. |
| `CustomerGateway:UserAuthentication:RequireHttpsMetadata` | `bool` | `true` | Metadata policy for JWT validation. |
| `CustomerGateway:RateLimiting:PermitLimit` | `int` | `2400` | Default fixed-window permits per window. |
| `CustomerGateway:RateLimiting:WindowSeconds` | `int` | `60` | Window length. |
| `CustomerGateway:RateLimiting:QueueLimit` | `int` | `0` | Queued request cap (0 = reject when full). |
| `CustomerGateway:RateLimiting:AuthBootstrap:PermitLimit` | `int?` | `1200` | Override for auth bootstrap routes. |
| `CustomerGateway:RateLimiting:AuthBootstrap:QueueLimit` | `int?` | `0` | Queue for auth bootstrap. |
| `CustomerGateway:RateLimiting:OperationStatus:PermitLimit` | `int?` | `4800` | Async operation status polling. |
| `CustomerGateway:RateLimiting:OperationStatus:QueueLimit` | `int?` | `0` | Queue for status routes. |
| `CustomerGateway:RateLimiting:TransactionWrite:PermitLimit` | `int?` | `1800` | Transfer/payment writes. |
| `CustomerGateway:RateLimiting:TransactionWrite:QueueLimit` | `int?` | `0` | Queue for writes. |
| `CustomerGateway:RateLimiting:Read:PermitLimit` | `int?` | `2400` | General read routes. |
| `CustomerGateway:RateLimiting:Read:QueueLimit` | `int?` | `0` | Queue for reads. |
| `CustomerGateway:Downstream:UsersBaseUrl` | `string` (URI) | `http://localhost:5003` | HTTP base for Users (if used). |
| `CustomerGateway:Downstream:UsersGrpcAddress` | `string` (URI) | `http://localhost:5003` | Users gRPC. |
| `CustomerGateway:Downstream:WalletGrpcAddress` | `string` (URI) | `http://localhost:5002` | Wallets gRPC. |
| `CustomerGateway:Downstream:TransactionsGrpcAddress` | `string` (URI) | `http://localhost:5004` | Transactions gRPC. |
| `CustomerGateway:Downstream:KycGrpcAddress` | `string` (URI) | `http://localhost:5008` | KYC gRPC. |
| `CustomerGateway:Downstream:DownstreamApiKey` | `string?` | `""` | Optional API key sent to downstream gRPC services. |
| `CustomerGateway:DownstreamResilience:ReadTimeoutMs` | `int` | `1500` | Default gRPC read deadline (code default if omitted). |
| `CustomerGateway:DownstreamResilience:WriteTimeoutMs` | `int` | `4000` | Default gRPC write deadline. |
| `CustomerGateway:DownstreamResilience:HttpWriteTimeoutMs` | `int` | `5000` | HTTP client write timeout. |
| `CustomerGateway:DownstreamResilience:MaxRetryAttempts` | `int` | `2` | Polly retries for transient failures. |
| `CustomerGateway:DownstreamResilience:BaseDelayMs` | `int` | `150` | Backoff base. |
| `CustomerGateway:DownstreamResilience:BreakDurationSeconds` | `int` | `20` | Circuit breaker open duration. |
| `CustomerGateway:DownstreamResilience:MinimumThroughput` | `int` | `8` | Min samples before breaker evaluates. |
| `CustomerGateway:DownstreamResilience:FailureRatio` | `double` | `0.5` | Breaker failure ratio threshold. |
| `CustomerGateway:DevelopmentAuthOverride:Enabled` | `bool` | `false` | **Development only** — bypass with fixed bearer. |
| `CustomerGateway:DevelopmentAuthOverride:BearerToken` | `string` | `QA_DEV` | Magic bearer value when override enabled. |
| `CustomerGateway:DevelopmentAuthOverride:NationalId` / `FullName` / `LinkedBankAccountId` | string | — | Synthetic user claims. |
| `CustomerGateway:DevelopmentAuthOverride:DefaultAppId` / `DefaultAppApiKey` | `string?` | — | Fill missing app headers when using dev bearer. |
| `CustomerGateway:Apps` | `array` | see `appsettings.json` | Registered mobile apps (AppId, AppType, BankId, ApiKey, Enabled). |

`appsettings.Development.json` / `Production.json` may override subsets (JWT signing, flags).

---

## Database tables

None — stateless API gateway.
