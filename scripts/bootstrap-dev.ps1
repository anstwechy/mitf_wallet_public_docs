#Requires -Version 5.1
<#.
  Bootstrap Python venv and install MkDocs dependencies for mitf_wallet_public_docs.
  Run from repository root: .\scripts\bootstrap-dev.ps1
#>
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
  Write-Error "Python is not on PATH. Install Python 3.10+ and retry."
}

$venvPath = Join-Path $root ".venv"
if (-not (Test-Path $venvPath)) {
  Write-Host "Creating venv at .venv ..."
  python -m venv .venv
}

$pip = Join-Path $venvPath "Scripts/pip.exe"
$py = Join-Path $venvPath "Scripts/python.exe"
& $pip install --upgrade pip
& $pip install -r (Join-Path $root "requirements.txt")

Write-Host ""
Write-Host "Done. Activate and serve:"
Write-Host "  .\.venv\Scripts\Activate.ps1"
Write-Host "  mkdocs serve"
