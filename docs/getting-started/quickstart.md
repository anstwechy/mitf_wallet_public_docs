# 5-minute quickstart (integrators)

Goal: run one **authenticated** REST call against the stack you already have (local or shared dev), then know where to read next.

!!! tip "Prerequisites"
    - **Users API** reachable (default local: `http://localhost:5003`). Ports for all services are in [API reference](../reference/api.md).
    - JSON body and `curl` (or any HTTP client).
    - If your environment enables API key auth, have a valid key (header below).

---

## 1. Health check (~30 s)

```bash
curl -sS http://localhost:5003/health
```

Expect HTTP 200. For readiness (DB + messaging), use `/health/ready` when your deployment exposes it — see [API reference — Health](../reference/api.md#health).

---

## 2. Create a wallet via onboarding (~2 min)

This hits **POST** `/onboarding/accounts` on the **Users** service. Replace `BankId` with a bank GUID your environment accepts (see the onboarding example under **REST APIs** in the [API reference](../reference/api.md#rest-apis)).

**Without** API key (typical local dev when auth middleware is off):

```bash
curl -X POST http://localhost:5003/onboarding/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "NationalId": "12345678901234",
    "FullName": "Quickstart User",
    "BankId": "00000000-0000-4000-8000-000000000001",
    "CustomerType": "Resident",
    "ClassificationId": "STANDARD_RESIDENT"
  }'
```

**With** API key (when `Auth:RequireApiKey` or equivalent is on — use your real key):

=== "X-Api-Key"

    ```bash
    curl -X POST http://localhost:5003/onboarding/accounts \
      -H "Content-Type: application/json" \
      -H "X-Api-Key: YOUR_API_KEY" \
      -d '{"NationalId":"12345678901234","FullName":"Quickstart User","BankId":"00000000-0000-4000-8000-000000000001","CustomerType":"Resident","ClassificationId":"STANDARD_RESIDENT"}'
    ```

=== "Authorization: ApiKey"

    ```bash
    curl -X POST http://localhost:5003/onboarding/accounts \
      -H "Content-Type: application/json" \
      -H "Authorization: ApiKey YOUR_API_KEY" \
      -d '{"NationalId":"12345678901234","FullName":"Quickstart User","BankId":"00000000-0000-4000-8000-000000000001","CustomerType":"Resident","ClassificationId":"STANDARD_RESIDENT"}'
    ```

**Success (201):** body includes `userId`, `walletId`, and `walletNumber`. Optionally send **`Idempotency-Key`** on retries — same key returns the same 201 body within the documented TTL ([API reference](../reference/api.md)).

**Errors:** 400 with `error` or `errors` — see [API reference](../reference/api.md#rest-apis).

---

## 3. Through the Customer Gateway (optional)

Bank mobile apps usually talk to the **Customer Gateway** (REST + app API key + optional JWT), not directly to Users. Base URL and headers depend on your `appsettings`; see [System hardening](../security/system-hardening.md) and [Customer Gateway reference](../reference/service-reference/Masarat.Gateway.Customer.Api.reference.md). Conceptually:

```http
POST {gatewayBaseUrl}/...   # route as per your OpenAPI / gateway docs
X-Api-Key: <per-app key>
Authorization: Bearer <JWT>   # when user context is required for writes
```

---

## Next steps (~2 min reading)

| Topic | Link |
| ----- | ---- |
| Full REST + gRPC tables, grpcurl, `x-bank-id` | [API reference](../reference/api.md) |
| Async money RPCs and polling | [Transfer backpressure](../architecture/transfer-backpressure-client-contract.md) |
| Events and webhooks | [Domain events](../architecture/events.md), [Webhooks in API ref](../reference/api.md#webhooks-api-wallet-events) |
| Release-related doc updates | [Changelog & releases](../changelog.md) |
