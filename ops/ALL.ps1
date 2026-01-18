param(
  [switch]$SkipAction,
  [switch]$SkipPublish
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Info([string]$m){ Write-Host $m -ForegroundColor Cyan }
function Pass([string]$m){ Write-Host $m -ForegroundColor Green }
function Fail([string]$m){ Write-Host $m -ForegroundColor Red; throw $m }

function RepoRoot {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { throw "Run inside a git repo (could not resolve repo root)." }
  $root.Trim()
}

function RequireFile([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { throw "Missing: $path" }
}

function RunPwsh([string]$file, [string[]]$args = @()) {
  RequireFile $file
  $argLine = if ($args.Count) { ' ' + ($args -join ' ') } else { '' }
  Info ("RUN: " + $file + $argLine)
  & pwsh -NoProfile -File $file @args
  $code = $LASTEXITCODE
  if ($code -ne 0) { throw "FAILED ($code): $file" }
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
  RunPwsh $kingdom @('-Action')
} else {
  Info "=== ALL: ACTION (skipped) ==="
}

if (-not $SkipPublish) {
  Info "=== ALL: PUBLISH ==="
  RunPwsh $kingdom @('-Publish')
} else {
  Info "=== ALL: PUBLISH (skipped) ==="
}

Info "=== ALL: FINAL STATUS ==="
$dirtyLines = @(git status --porcelain)

# Ignore ops/ALL.ps1 itself (so first-run creation doesn't false-fail)
$dirtyLines = $dirtyLines | Where-Object { param(
  [switch]$SkipAction,
  [switch]$SkipPublish
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Info([string]$m){ Write-Host $m -ForegroundColor Cyan }
function Pass([string]$m){ Write-Host $m -ForegroundColor Green }
function Fail([string]$m){ Write-Host $m -ForegroundColor Red; throw $m }

function RepoRoot {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { throw "Run inside a git repo (could not resolve repo root)." }
  $root.Trim()
}

function RequireFile([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { throw "Missing: $path" }
}

function RunPwsh([string]$file, [string[]]$args = @()) {
  RequireFile $file
  $argLine = if ($args.Count) { ' ' + ($args -join ' ') } else { '' }
  Info ("RUN: " + $file + $argLine)
  & pwsh -NoProfile -File $file @args
  $code = $LASTEXITCODE
  if ($code -ne 0) { throw "FAILED ($code): $file" }
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
  RunPwsh $kingdom @('-Action')
} else {
  Info "=== ALL: ACTION (skipped) ==="
}

if (-not $SkipPublish) {
  Info "=== ALL: PUBLISH ==="
  RunPwsh $kingdom @('-Publish')
} else {
  Info "=== ALL: PUBLISH (skipped) ==="
}

Info "=== ALL: FINAL STATUS ==="
$dirty = git status --porcelain
if ($dirty) { $dirty | Out-Host; Fail "Working tree is NOT clean after ALL." }

RunPwsh $ghost
RunPwsh $raw

Pass "ALL COMPLETE" -notmatch '^\?\?\s+ops/ALL\.ps1RunPwsh $ghost
RunPwsh $raw

Pass "ALL COMPLETE" -and param(
  [switch]$SkipAction,
  [switch]$SkipPublish
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Info([string]$m){ Write-Host $m -ForegroundColor Cyan }
function Pass([string]$m){ Write-Host $m -ForegroundColor Green }
function Fail([string]$m){ Write-Host $m -ForegroundColor Red; throw $m }

function RepoRoot {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { throw "Run inside a git repo (could not resolve repo root)." }
  $root.Trim()
}

function RequireFile([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { throw "Missing: $path" }
}

function RunPwsh([string]$file, [string[]]$args = @()) {
  RequireFile $file
  $argLine = if ($args.Count) { ' ' + ($args -join ' ') } else { '' }
  Info ("RUN: " + $file + $argLine)
  & pwsh -NoProfile -File $file @args
  $code = $LASTEXITCODE
  if ($code -ne 0) { throw "FAILED ($code): $file" }
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
  RunPwsh $kingdom @('-Action')
} else {
  Info "=== ALL: ACTION (skipped) ==="
}

if (-not $SkipPublish) {
  Info "=== ALL: PUBLISH ==="
  RunPwsh $kingdom @('-Publish')
} else {
  Info "=== ALL: PUBLISH (skipped) ==="
}

Info "=== ALL: FINAL STATUS ==="
$dirty = git status --porcelain
if ($dirty) { $dirty | Out-Host; Fail "Working tree is NOT clean after ALL." }

RunPwsh $ghost
RunPwsh $raw

Pass "ALL COMPLETE" -notmatch '^\s*M\s+ops/ALL\.ps1RunPwsh $ghost
RunPwsh $raw

Pass "ALL COMPLETE" }

if ($dirtyLines.Count -gt 0) { $dirtyLines | Out-Host; Fail "Working tree is NOT clean after ALL (excluding ops/ALL.ps1)." }RunPwsh $ghost
RunPwsh $raw

Pass "ALL COMPLETE"