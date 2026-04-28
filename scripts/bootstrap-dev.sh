#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found. Install Python 3.10+ and retry." >&2
  exit 1
fi

if [[ ! -d .venv ]]; then
  echo "Creating venv at .venv ..."
  python3 -m venv .venv
fi

# shellcheck disable=SC1091
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo "Done. Activate and serve:"
echo "  source .venv/bin/activate"
echo "  mkdocs serve"
