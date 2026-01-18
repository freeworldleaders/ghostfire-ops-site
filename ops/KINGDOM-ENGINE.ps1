param(
  [switch]$CommitPush,
  [switch]$NoHigg,
  [switch]$NoMirror
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Info($m){ Write-Host ("INFO: " + $m) -ForegroundColor Cyan }
function Pass($m){ Write-Host ("PASS: " + $m) -ForegroundColor Green }

$repo = (Get-Location).Path
if (-not (Test-Path (Join-Path $repo ".git"))) { throw "Run at repo root: $repo" }

Info "KINGDOM-ENGINE start"
pwsh -NoProfile -File (Join-Path $repo "ops\KINGDOM-AUTO.ps1") -Write -NoHigg:$NoHigg -NoMirror:$NoMirror

git add -A | Out-Null

if (-not (git status --porcelain)) {
  Pass "No changes detected"
  exit 0
}

if ($CommitPush) {
  $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  git commit -m "Kingdom auto-update ($stamp)"
  git push
  Pass "Committed + pushed"
} else {
  Info "Changes staged but NOT committed (run with -CommitPush to publish)"
  git status --porcelain
}