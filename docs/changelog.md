# Changelog & releases

Use this page to track **documentation** and **integration-facing** changes over time.

## This documentation site

- **[GitHub Releases — mitf_wallet_public_docs](https://github.com/anstwechy/mitf_wallet_public_docs/releases)** — release notes and tags for this repo (MkDocs content, nav, and reference updates).
- **Source:** [Repository on GitHub](https://github.com/anstwechy/mitf_wallet_public_docs); each release should summarize what integrators and operators need to re-read (API tables, security, operations).

!!! note "Platform and API binaries"
    Behavioral and contract changes to running wallet services (Users, Wallets, Transactions, Gateway, etc.) are shipped from the **application repositories**, not from this docs repo alone. Your team may publish separate release notes there; link them from your internal runbooks or add a subsection below when a stable public URL exists.

### Suggested release practice

When you tag a docs release, mention:

- Any new or renamed REST paths, headers, or gRPC RPCs.
- Breaking changes to idempotency, async polling, or error shapes.
- New operational requirements (config keys, probes, migrations).

For how we describe API evolution in this site, see **API versioning** in [API reference](reference/api.md#api-versioning).
