param(
  [switch]$Action,
  [switch]$Publish
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$script:fail = $false

function Info($m){ Write-Host ("INFO: " + $m) -ForegroundColor Cyan }
function Pass($m){ Write-Host ("PASS: " + $m) -ForegroundColor Green }

$root = (Get-Location).Path
if (-not (Test-Path (Join-Path $root ".git"))) { throw "Run at repo root: $root" }

if ($Publish) {
  Info "KINGDOM: PUBLISH mode"
  pwsh -NoProfile -File (Join-Path $root "ops\KINGDOM-ENGINE.ps1") -CommitPush
  exit 0
}

if ($Action) {
  Info "KINGDOM: ACTION mode"
  pwsh -NoProfile -File (Join-Path $root "ops\POWER-ENGINE.ps1")
  exit 0
}

Info "KINGDOM: READ-ONLY mode (default)"
pwsh -NoProfile -File (Join-Path $root "ops\GHOST-POWER-ENGINE.ps1")
pwsh -NoProfile -File (Join-Path $root "ops\RAW-POWER-ENGINE.ps1")
Pass "KINGDOM COMPLETE"