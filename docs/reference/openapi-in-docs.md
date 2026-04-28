# OpenAPI / Swagger in documentation (advanced)

Integrators often want **Try it** against a live OpenAPI description without leaving the docs site. Today this repository **does not** embed a hosted OpenAPI file in GitHub Pages, because the wallet services publish specs **from running instances** (Development) as described in the [API reference — Swagger UI (Development)](api.md#swagger-ui-development).

---

## What works today

- Run the stack locally (or use a shared dev environment), then open **`/swagger`** on each HTTP API and **`/openapi/v1.json`** for the machine-readable spec.
- Use those UIs for interactive exploration and QA.

Full URLs and ports are in [API reference — Swagger UI (Development)](api.md#swagger-ui-development).

---

## Embedding an explorer on this site (optional roadmap)

To show **Swagger UI** or **Redoc** *inside* `mitf_wallet_public_docs`:

1. **Publish a stable OpenAPI JSON** next to the docs — e.g. commit an exported `openapi/gateway.json` on each docs release, or pull from a CDN you control.
2. Add a MkDocs page that loads [Swagger UI](https://github.com/swagger-api/swagger-ui) or [Redoc](https://github.com/Redocly/redoc) from a trusted CDN and points `url` / `spec` at that JSON (watch **CORS**: the spec must be served with appropriate headers for browser reads).
3. Restrict to **non-production** definitions if your security policy forbids exposing production URL shapes.

Until that pipeline exists, keep using the **Development** URLs documented on the API page.

---

## Related

- [API reference](api.md) — REST, gRPC, auth, health
- [API versioning](api.md#api-versioning) — how contract changes are communicated
