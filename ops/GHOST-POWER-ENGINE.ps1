$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot "_ENGINE-CORE.ps1")
function Info($m){ Write-Host ("INFO: " + $m) -ForegroundColor Cyan }
function Warn($m){ Write-Host ("WARN: " + $m) -ForegroundColor Yellow }
function Pass($m){ Write-Host ("PASS: " + $m) -ForegroundColor Green }

$repo = (Get-Location).Path
Info "Ghost Power Engine (observer-only) — NO WRITES"
Info "Repo = $repo"

if (-not (Test-Path (Join-Path $repo ".git"))) { throw "Not a git repo: $repo" }

# Git state (read-only)
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
$remote = (git remote -v | Select-String 'origin' | Select-Object -First 1).ToString().Trim()
$porcelain = git status --porcelain

Info "Branch = $branch"
Info "Origin = $remote"

if ($porcelain) { Warn "Working tree NOT clean:`n$porcelain" } else { Pass "Working tree clean" }

# Presence checks (read-only)
$must = @(
  "index.md",
  "command-board.html",
  "ops\HIGG-RUN.ps1",
  "protocols\HIGG_PROTOCOLS.html",
  "kingdom-solutions\index.html"
)

foreach ($p in $must) {
  $abs = Join-Path $repo $p
  if (Test-Path $abs) { Pass "Exists: $p" } else { Warn "Missing: $p" }
}

# Throne sweep config validation (read-only, external repo)
$throne = Join-Path $env:USERPROFILE "code\ghostfire-ops\docs\throne\SWEEP\config.json"
if (Test-Path $throne) {
  try { Get-Content -Raw $throne | ConvertFrom-Json | Out-Null; Pass "Throne sweep config JSON valid" }
  catch { Warn "Throne sweep config JSON INVALID: $($_.Exception.Message)" }
} else {
  Warn "Throne sweep config not found at expected path (skipping)"
}

Pass "GHOST POWER ENGINE COMPLETE (observer run)"