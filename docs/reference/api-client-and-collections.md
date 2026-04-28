# API clients, Postman, Insomnia, and SDKs

Ways integrators can work with MITF wallet HTTP APIs beyond raw **curl** and markdown tables.

---

## OpenAPI / Swagger

- **Local / dev:** each HTTP service exposes **`/openapi/v1.json`** and **`/swagger`** in Development — [API reference — Swagger UI (Development)](api.md#swagger-ui-development).  
- **Hosted interactive docs:** see [OpenAPI in docs (advanced)](openapi-in-docs.md).

---

## Postman / Insomnia

| Artefact | Status | Location |
| -------- | ------ | -------- |
| Postman collection | **TBD** — generate from OpenAPI or maintain by hand | Link internal repo or attach to GitHub Release |
| Insomnia export | **TBD** | |

Suggested collection folders: **Customer Gateway** (mobile), **Users** (onboarding), **Webhooks**, **Health**.

---

## Generated SDKs

| Language | Generator / package | Status |
| -------- | --------------------- | ------ |
| TypeScript | OpenAPI Generator / kiota — TBD | Not published from this repo |
| Python | same | TBD |
| C# | NSwag / OpenAPI — TBD | TBD |

When SDKs exist, document **versioning** alongside server semver and link to [API versioning](api.md#api-versioning).

---

## Test data generators

**Seed scripts** and synthetic national IDs / banks for non-production — TBD location (internal repo). Do **not** reuse production PII in samples.

## Related

- [5-minute quickstart](../getting-started/quickstart.md)  
- [Configuration reference](configuration-reference.md)  
