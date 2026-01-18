$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot "_ENGINE-CORE.ps1")
function Info($m){ Write-Host ("INFO: " + $m) -ForegroundColor Cyan }
function Pass($m){ Write-Host ("PASS: " + $m) -ForegroundColor Green }
function Fail($m){ Write-Host ("FAIL: " + $m) -ForegroundColor Red; $script:fail = $true }

$repo = (Get-Location).Path
Info "Repo = $repo"

# 1) Run HIGG gates
$higg = Join-Path $repo "ops\HIGG-RUN.ps1"
if (Test-Path $higg) {
  Info "Running HIGG..."
  pwsh -NoProfile -File $higg
  Pass "HIGG complete"
} else {
  Fail "Missing ops\HIGG-RUN.ps1"
}

# 2) Open Command Board (local file + public URL best-effort)
$cb = Join-Path $repo "command-board.html"
if (Test-Path $cb) {
  Info "Opening command-board.html"
  Start-Process $cb | Out-Null
  Pass "Command Board opened (local)"
} else {
  Fail "Missing command-board.html"
}
if ((Get-Variable -Name fail -Scope Script -ErrorAction SilentlyContinue).Value -eq $true) { throw "POWER ENGINE FAILED (see FAIL lines above)" }
Pass "POWER ENGINE COMPLETE"