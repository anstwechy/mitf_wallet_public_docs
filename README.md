# MITF Wallet — public documentation

This repository publishes the **MITF wallet** technical documentation with [MkDocs](https://www.mkdocs.org/) and the [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) theme.

**Live site:** [https://anstwechy.github.io/mitf_wallet_public_docs/](https://anstwechy.github.io/mitf_wallet_public_docs/)

## Build locally

**Bootstrap (recommended):** from repo root run `.\scripts\bootstrap-dev.ps1` (Windows) or `./scripts/bootstrap-dev.sh` (macOS/Linux), activate the `.venv` it creates, then `mkdocs serve`.

Or manually:

```bash
python -m venv .venv
.\.venv\Scripts\activate   # Windows
# source .venv/bin/activate  # macOS / Linux
pip install -r requirements.txt
mkdocs serve
```

Open [http://127.0.0.1:8000/](http://127.0.0.1:8000/) to preview. More detail: [Local development setup](docs/getting-started/local-development.md).

## Deploy

Pushes to `main` run [`.github/workflows/pages.yml`](.github/workflows/pages.yml), which builds the site and deploys to **GitHub Pages**.

1. In the GitHub repo: **Settings → Pages → Build and deployment → Source:** choose **GitHub Actions**.
2. Merge to `main`; the workflow uploads the `site/` output and publishes it.

Markdown sources live under [`docs/`](docs/). **Masarat leadership** content lives under [`docs/stakeholders/`](docs/stakeholders/) (executive, risk/finance, and operations/technology tracks).
