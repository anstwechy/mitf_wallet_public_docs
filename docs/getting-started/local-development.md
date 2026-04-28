# Local development setup

One-command bootstrap for **building this documentation site** on your machine. For wallet **service** repos, follow their own READMEs.

---

## Prerequisites

- **Python 3.10+** (3.12 matches CI)  
- **Git** (for accurate “last updated” dates in builds)

---

## Bootstrap (recommended)

From the repository root (`mitf_wallet_public_docs`):

=== "Windows (PowerShell)"

    ```powershell
    .\scripts\bootstrap-dev.ps1
    .\.venv\Scripts\Activate.ps1
    mkdocs serve
    ```

=== "macOS / Linux"

    ```bash
    chmod +x scripts/bootstrap-dev.sh
    ./scripts/bootstrap-dev.sh
    source .venv/bin/activate
    mkdocs serve
    ```

The scripts create a **`.venv`**, install `requirements.txt`, and print next steps.

---

## Manual setup

```bash
python -m venv .venv
# Windows: .venv\Scripts\activate
# Unix:    source .venv/bin/activate
pip install -r requirements.txt
mkdocs serve
```

Open the URL MkDocs prints (usually `http://127.0.0.1:8000`).

---

## Useful commands

| Command | Purpose |
| ------- | ------- |
| `mkdocs build --strict` | CI-parity local build |
| `mkdocs serve --dirtyreload` | Faster reload while editing (optional) |

## Related

- [Repository README](https://github.com/anstwechy/mitf_wallet_public_docs/blob/main/README.md)  
- [Documentation roadmap](../meta/documentation-roadmap.md)  
