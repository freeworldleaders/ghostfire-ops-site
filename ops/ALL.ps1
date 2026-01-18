param(
  [switch]$SkipAction,
  [switch]$SkipPublish,
  [switch]$AllowSelfCommit
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Info($m){ Write-Host $m -ForegroundColor Cyan }
function Pass($m){ Write-Host $m -ForegroundColor Green }
function Fail($m){ Write-Host $m -ForegroundColor Red; throw $m }

function RepoRoot {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { throw "Run inside a git repo (could not resolve repo root)." }
  return $root.Trim()
}

function RequireFile([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { throw "Missing: $path" }
}

function RunPwsh([string]$file, [string[]]$args = @()) {
  RequireFile $file
  Info ("RUN: " + $file + " " + ($args -join ' '))
  & pwsh -NoProfile -File $file @args
  if ($LASTEXITCODE -ne 0) { throw "FAILED ($LASTEXITCODE): $file" }

function EnsureCleanOrSelfCommit([string]$repo, [switch]$allow) {
  $dirty = git status --porcelain
  if (-not $dirty) { return }

  # If the only dirt is ops/ALL.ps1 and allow is set, self-commit it.
  $lines = @($dirty)
  $onlyAll = ($lines.Count -eq 1 -and $lines[0] -match '^\?\?\s+ops/ALL\.ps1}

$repo = RepoRoot
Set-Location $repo

$kingdom = Join-Path $repo "ops\KINGDOM.ps1"
$ghost   = Join-Path $repo "ops\GHOST-POWER-ENGINE.ps1"
$raw     = Join-Path $repo "ops\RAW-POWER-ENGINE.ps1"

RequireFile $kingdom
RequireFile $ghost
RequireFile $raw

Info "=== ALL: AUDIT ==="
RunPwsh $kingdom

if (-not $SkipAction) {
  Info "=== ALL: ACTION ==="
  RunPwsh $kingdom @("-Action")
} else {
  Info "=== ALL: ACTION (skipped) ==="
}

if (-not $SkipPublish) {
  Info "=== ALL: PUBLISH ==="
  RunPwsh $kingdom @("-Publish")
} else {
  Info "=== ALL: PUBLISH (skipped) ==="
}

Info "=== ALL: FINAL STATUS ==="
EnsureCleanOrSelfCommit -repo $repo -allow:$AllowSelfCommit
RunPwsh $ghost
RunPwsh $raw

Pass "ALL COMPLETE")

  if ($onlyAll -and $allow) {
    Info "AUTO: committing ops/ALL.ps1 (self-heal)"
    git add ops/ALL.ps1 | Out-Null
    git commit -m "Add ALL one-command runner" | Out-Null
    git push | Out-Null
    return
  }

  $lines | Out-Host
  Fail "Working tree is NOT clean after ALL."
}
}

$repo = RepoRoot
Set-Location $repo

$kingdom = Join-Path $repo "ops\KINGDOM.ps1"
$ghost   = Join-Path $repo "ops\GHOST-POWER-ENGINE.ps1"
$raw     = Join-Path $repo "ops\RAW-POWER-ENGINE.ps1"

RequireFile $kingdom
RequireFile $ghost
RequireFile $raw

Info "=== ALL: AUDIT ==="
RunPwsh $kingdom

if (-not $SkipAction) {
  Info "=== ALL: ACTION ==="
  RunPwsh $kingdom @("-Action")
} else {
  Info "=== ALL: ACTION (skipped) ==="
}

if (-not $SkipPublish) {
  Info "=== ALL: PUBLISH ==="
  RunPwsh $kingdom @("-Publish")
} else {
  Info "=== ALL: PUBLISH (skipped) ==="
}

Info "=== ALL: FINAL STATUS ==="
EnsureCleanOrSelfCommit -repo $repo -allow:$AllowSelfCommit
RunPwsh $ghost
RunPwsh $raw

Pass "ALL COMPLETE"