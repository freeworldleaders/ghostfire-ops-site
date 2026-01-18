$ErrorActionPreference = "Stop"

function Pass($m){ Write-Host ("PASS: " + $m) -ForegroundColor Green }
function Fail($m){ Write-Host ("FAIL: " + $m) -ForegroundColor Red; $script:fail = $true }

$repo = (Get-Location).Path
Pass "Repo = $repo"

$docsRoot = Join-Path $repo "public\kingdom-solutions"
if (-not (Test-Path $docsRoot)) { Fail "Missing $docsRoot" } else { Pass "Docs root exists" }

$required = @(
  "PRD.html","API_SPEC.html","ARCHITECTURE.html","DATA_SCHEMA.html","TRUST_SAFETY.html",
  "CREATOR_AGREEMENT.html","LAUNCH_PLAN.html","MANIFESTO.html","ROADMAP.html","index.html"
)
foreach($f in $required){
  $p = Join-Path $docsRoot $f
  if (Test-Path $p) { Pass "Docs file: $f" } else { Fail "Missing docs file: $f" }
}

if (Test-Path (Join-Path $repo "command-board.html")) { Pass "command-board.html present" } else { Fail "Missing command-board.html" }

$proto = Join-Path $repo "public\protocols\HIGG_PROTOCOLS.html"
if (Test-Path $proto) { Pass "HIGG_PROTOCOLS.html present" } else { Fail "Missing $proto" }

$throne = Join-Path $env:USERPROFILE "code\ghostfire-ops\docs\throne\SWEEP\config.json"
if (Test-Path $throne) {
  try {
    Get-Content -Raw $throne | ConvertFrom-Json | Out-Null
    Pass "Throne sweep config JSON valid"
  } catch {
    Fail "Throne sweep config JSON invalid: $($_.Exception.Message)"
  }
} else {
  Write-Host "WARN: throne sweep config not found at expected path (skipping)" -ForegroundColor Yellow
}

if ($script:fail) { throw "HIGG RUN FAILED (see FAIL lines above)" }
Pass "HIGG RUN COMPLETE (ALL GREEN)"