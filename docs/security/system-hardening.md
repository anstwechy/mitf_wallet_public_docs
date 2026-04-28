# System Hardening and Security

This document describes security controls and hardening for the Masarat (MITF) wallet and ledger system: **API key authentication**, **wallet PIN and transaction authorization**, **logging and secrets handling**, and **operational recommendations**.

---

## 1. API key authentication

Service-to-service and client access to the APIs can be protected with an **API key**. When enabled, every request (REST and gRPC) must include a valid key; otherwise the request is rejected with **401 Unauthenticated**.

### Where it applies

- **Users API** (port 5003), **Ledger API** (5001), **Wallets API** (5002), **Transactions API** (5004): each can enable API key auth via configuration.
- **REST:** `ApiKeyMiddleware` runs before the pipeline; **gRPC:** `ApiKeyGrpcInterceptor` validates the key on each call.

### Bypass (no key required)

- **Health endpoints** are always allowed without an API key: `GET /health` and `GET /health/ready`. This lets load balancers and orchestrators probe liveness/readiness without a key.
- If **RequireApiKey** is `false` or **ApiKey** is empty, API key check is **disabled** for that service (all requests allowed).

### How to send the key

| Channel | Header / metadata | Example |
|--------|-------------------|--------|
| REST | `X-Api-Key: <key>` | `curl -H "X-Api-Key: your-key" http://localhost:5002/...` |
| REST | `Authorization: ApiKey <key>` | `Authorization: ApiKey your-key` |
| gRPC | Metadata `x-api-key` | `grpcurl -H "x-api-key: your-key" ...` |
| gRPC | Metadata `authorization: ApiKey <key>` | Same as REST style |

Key comparison is **ordinal** (case-sensitive). Use the same key value in config and in client headers.

### Configuration

| Key | Description | Default |
|-----|-------------|---------|
| `Auth:ApiKey` | The shared secret key. Empty = no key enforced when RequireApiKey is false. | `""` |
| `Auth:RequireApiKey` | When `true`, require a valid API key on every request (except health). When `false`, key is not checked. | `true` |

Example (`appsettings.json`):

```json
{
  "Auth": {
    "ApiKey": "your-secure-api-key",
    "RequireApiKey": true
  }
}
```

**Production:** Set a strong, random API key (e.g. 32+ character secret) and keep `RequireApiKey: true`. Do not commit keys to source control; use environment variables or a secrets store.

---

## 2. Wallet PIN and transaction authorization

The system supports an optional **wallet PIN** and **transaction authorization tokens** so that debit operations (transfer, merchant payment, cash withdrawal, fund-wallet) can require the user to verify their PIN first. The design allows adding **dual signing** (e.g. mobile app approval) later without changing the high-level flow.

### Overview

- **Wallet PIN** — A 4–6 digit PIN set per wallet, stored as a PBKDF2 hash with per-wallet salt. Used to authorize sensitive operations.
- **Transaction authorization token** — A short-lived token (e.g. 5 minutes) issued by the **Wallets API** after successful **VerifyWalletPin**. The client sends this token when calling **Transfer**, **FundWallet**, **ProcessMerchantPayment**, or **ProcessCashWithdrawal** on the **Transactions API**. For wallets whose classification **`OperationAuthMode`** is **user PIN**, the Transactions API rejects debit requests that lack a valid token for the debited wallet; for **external OTP trusted session** classifications, the token is not required.

Flow:

1. **First PIN:** Customer/business gateway **`POST …/onboarding/accounts`** may include optional **`pin`**; the gateway calls Wallets **SetWalletPin** with a trusted user actor after provisioning. **Later changes** use **ChangeWalletPin** (Wallets API) with appropriate auth. Direct gRPC clients may still call **SetWalletPin** when they attach a valid **user** actor context.
2. Before a debit operation, the client calls **VerifyWalletPin** (Wallets API) with `wallet_id` and `pin`.
3. Wallets API validates the PIN (and lockout state), then returns a **transaction_authorization_token**.
4. The client calls the Transactions API (Transfer, FundWallet, ProcessMerchantPayment, or ProcessCashWithdrawal) and includes **transaction_authorization_token** in the request.
5. Transactions API validates the token when required (signature, expiry, and that the token’s wallet matches the debited wallet). If the wallet’s classification requires user PIN and no valid token is provided, the request is rejected.

### gRPC RPCs (Wallets API — port 5002)

| RPC | Request | Response | Description |
|-----|---------|----------|-------------|
| SetWalletPin | wallet_id, pin | success, error_message | Set or overwrite the PIN for the wallet. Requires **user** actor context when `x-bank-id` is present. PIN must match **WalletPin** rules (e.g. 4–6 digits). |
| ChangeWalletPin | wallet_id, current_pin, new_pin | success, error_message | Change the PIN; requires current PIN. |
| VerifyWalletPin | wallet_id, pin | success, transaction_authorization_token, error_message | Verify PIN and get a short-lived token for use in Transaction RPCs. On failure, failed-attempt count increases; after MaxFailedAttempts the wallet is locked for LockoutMinutes. |

PIN rules (configurable via **WalletPin**):

- **MinPinLength** / **MaxPinLength** — e.g. 4–6 digits.
- **PIN must contain only digits** (0–9). SetWalletPin and ChangeWalletPin reject non-numeric characters (e.g. letters or symbols).
- **MaxFailedAttempts** — e.g. 5 failed attempts before lockout.
- **LockoutMinutes** — e.g. 15 minutes lockout after too many failures.

**Lockout behaviour:** Failed **VerifyWalletPin** attempts increment a per-wallet counter. When the counter reaches **MaxFailedAttempts**, the wallet is locked until **LockedUntilUtc** (now + LockoutMinutes). A **successful** VerifyWalletPin resets the failed-attempt count and clears the lockout. Setting or changing the PIN (SetWalletPin / ChangeWalletPin) also clears any existing lockout for that wallet.

### Transaction requests (Transactions API — port 5004)

The following request messages include an optional **transaction_authorization_token** field:

- **TransferRequest** — `transaction_authorization_token` (optional). Validated against `from_wallet_id`.
- **FundWalletRequest** — `transaction_authorization_token` (optional). Validated against `wallet_id`.
- **ProcessMerchantPaymentRequest** — `transaction_authorization_token` (optional). Validated against `wallet_id`.
- **ProcessCashWithdrawalRequest** — `transaction_authorization_token` (optional). Validated against `wallet_id`.

When the debited wallet’s classification requires user PIN, the Transactions API returns an error if the token is missing, invalid, expired, or does not match the debited wallet. When the classification does not require a token and none is sent, the request is allowed (no token check). If a token **is** sent, it is still validated when non-empty. If a token is required but the shared **Secret** is not configured (empty), the API returns: *"Transaction authorization is not configured."* — both Wallets and Transactions must use the same non-empty secret when PIN tokens are used.

### Configuration (Wallet PIN and token)

**Wallets API**

- **WalletPin** — PIN policy and lockout.
  - `MaxFailedAttempts` (default 5)
  - `LockoutMinutes` (default 15)
  - `MinPinLength` (default 4)
  - `MaxPinLength` (default 6)
- **WalletAuthorizationToken** — Token issuance (must match Transactions API secret).
  - `Secret` — Shared secret. Interpreted as **plain UTF-8** (not Base64). Use a strong, random value in production; same value must be set in both Wallets and Transactions APIs.
  - `ExpiryMinutes` (default 5)

**Transactions API**

- **WalletAuthorizationToken** — Same `Secret` and `ExpiryMinutes` as Wallets API (tokens are validated here).
- **PIN token requirement** — Not a Transactions JSON flag. It follows each wallet’s **classification** **`OperationAuthMode`** (stored in Wallets, editable via management): **user PIN** → debit RPCs require a valid `transaction_authorization_token`; **external OTP trusted session** → token not required on debit.

Example (Wallets API):

```json
{
  "WalletPin": {
    "MaxFailedAttempts": 5,
    "LockoutMinutes": 15,
    "MinPinLength": 4,
    "MaxPinLength": 6
  },
  "WalletAuthorizationToken": {
    "Secret": "change-me-in-production-use-strong-secret",
    "ExpiryMinutes": 5
  }
}
```

Example (Transactions API):

```json
{
  "WalletAuthorizationToken": {
    "Secret": "change-me-in-production-use-strong-secret",
    "ExpiryMinutes": 5
  }
}
```

### Security (PIN and token)

**PIN storage and verification**

- PINs are **never stored or logged** in plain form. They are hashed with **PBKDF2-HMAC-SHA256** (RFC 2898): **100,000 iterations**, **32-byte random salt** per wallet, **32-byte hash** (SHA-256). Salt is generated with cryptographically secure `RandomNumberGenerator` when setting or changing the PIN.
- PIN verification uses **timing-safe comparison** (`CryptographicOperations.FixedTimeEquals`) when comparing the computed hash to the stored hash to reduce timing-attack risk.
- PIN length and character set are enforced at the API: digits only (0–9), length between MinPinLength and MaxPinLength.

**Transaction authorization token**

- Tokens are **HMAC-SHA256 signed**. Payload: **version byte** (1) + **wallet ID** (16 bytes) + **expiry** (UTC ticks, 8 bytes). Token format is opaque to clients; internally it is `base64url(payload).base64url(signature)`.
- The Transactions API validates: token present and well-formed, **signature** (using the shared secret), **expiry** (token not expired), and **wallet match** (token’s wallet ID equals the debited wallet). Signature comparison is **timing-safe**.
- The shared **Secret** must be identical in Wallets and Transactions and must be a strong value in production (e.g. 256-bit random string). It is used as UTF-8 bytes.

**Lockout and operational security**

- **Lockout** after too many failed VerifyWalletPin attempts reduces brute-force risk. Successful verification (or setting/changing PIN) resets the failed-attempt count and lockout so legitimate users are not left locked out after a typo.
- **OperationAuthMode** on each wallet classification controls whether debits require a recent **VerifyWalletPin** token. Use management / Wallets APIs to align classifications with your bank’s step-up policy (e.g. user PIN vs external OTP trusted session).

### Dual signing (future)

The same **transaction_authorization_token** flow is intended to support dual signing later: the token would be issued only after both PIN verification and a second factor (e.g. mobile app approval). The Transactions API contract (send token with Transfer, FundWallet, etc.) stays the same; only the conditions for issuing the token change.

---

## 3. Logging and sensitive data

Structured logging is used across services. To avoid leaking secrets and PII:

### Request/response logging (Observability)

When **Observability:ApiLogging:EnableRequestLogging** is enabled:

- **Headers:** If `LogRequestHeaders` is true, **sensitive headers are redacted**. The default **RedactHeaders** list is: `Authorization`, `Cookie`, `X-Api-Key`. Redacted values appear as `[REDACTED]`.
- **Body:** `LogRequestBody` and `LogResponseBody` default to **false**. Enabling them can log PII or payment data; **not recommended in production**. If body logging is enabled, `RedactBodyProperties` can mask sensitive JSON fields (for example `password`, `pin`, `token`) with `[REDACTED]`.
- **ExcludePaths:** Health and metrics paths are excluded from request logging by default: `/health`, `/health/ready`, `/metrics`, `/hc`. Add other sensitive paths as needed.

Configuration (see [Logging](../operations/logging.md) for full Observability options):

```json
{
  "Observability": {
    "ApiLogging": {
      "EnableRequestLogging": false,
      "LogRequestHeaders": false,
      "LogRequestBody": false,
      "LogResponseBody": false,
      "RedactHeaders": ["Authorization", "Cookie", "X-Api-Key"],
      "RedactBodyProperties": ["password", "pin", "apiKey", "token", "authorization"],
      "ExcludePaths": ["/health", "/health/ready", "/metrics", "/hc"]
    }
  }
}
```

### General practices

- **No secrets in logs:** API keys, PINs, and transaction authorization tokens must not be written to log messages or structured properties. The pipeline does not log request bodies by default; keep body logging disabled in production.
- **Correlation ID:** Use `X-Correlation-ID` for tracing; it is not sensitive and is safe to log.

---

## 4. Bank context (x-bank-id)

Transaction and wallet RPCs that act on behalf of a bank require the **x-bank-id** header (gRPC metadata) set to the calling bank’s GUID. This is an **authorization context** (which bank is performing the operation), not a substitute for API key or PIN. Ensure only trusted clients and services can call these APIs and that they send the correct bank ID for their context.

---

## 5. Operational recommendations

| Area | Recommendation |
|------|----------------|
| **TLS** | Use HTTPS/TLS for all API and gRPC traffic in production. Terminate TLS at a reverse proxy or load balancer if needed. |
| **Secrets** | Do not store API key, WalletAuthorizationToken secret, or database connection strings in source control. Use environment variables, a secrets manager, or vault. |
| **API key** | In production, set **Auth:RequireApiKey** to `true` and use a strong **Auth:ApiKey** on all services that expose APIs. |
| **Wallet PIN secret** | Use a strong, random **WalletAuthorizationToken:Secret** (e.g. 256-bit) and the same value in Wallets and Transactions when using transaction authorization. |
| **Health endpoints** | Health (`/health`, `/health/ready`) are unauthenticated by design for probes. Do not expose sensitive operations on these paths. |
| **Swagger / OpenAPI** | Swagger UI is typically enabled in Development. Restrict or disable it in production to avoid exposing API structure. |
| **Network** | Restrict network access to APIs and databases (firewall, private networks). Use mTLS or API key for service-to-service calls. |

For runbooks and log queries, see [Logging](../operations/logging.md). For API and gRPC details, see [API reference](../reference/api.md) and [gRPC services](../reference/grpc-services.md).
