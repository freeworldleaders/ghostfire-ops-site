param(
  [switch]$Publish
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function RepoRoot {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { throw "Run inside a git repo." }
  $root.Trim()
}

$repo = RepoRoot
Set-Location $repo

$tmpDir = Join-Path $repo "tmp"
New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

$now    = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
$sha    = (git rev-parse --short HEAD).Trim()

$checks = @(
  @{ name="KINGDOM.ps1";     ok=(Test-Path (Join-Path $repo "ops\KINGDOM.ps1")) },
  @{ name="ALL.ps1";         ok=(Test-Path (Join-Path $repo "ops\ALL.ps1")) },
  @{ name="HIGG-RUN.ps1";    ok=(Test-Path (Join-Path $repo "ops\HIGG-RUN.ps1")) },
  @{ name="Command Board";   ok=(Test-Path (Join-Path $repo "command-board.html")) }
)

$allOk = -not ($checks | Where-Object { -not $_.ok })

$status = [ordered]@{
  name   = "GHOSTFIRE OPS"
  time   = $now
  repo   = $repo
  branch = $branch
  sha    = $sha
  ok     = $allOk
  checks = $checks
}

$json = ($status | ConvertTo-Json -Depth 6)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# always local (ignored)
$outLocal = Join-Path $tmpDir "status.json"
[System.IO.File]::WriteAllText($outLocal, $json, $utf8NoBom)
Write-Host "OK: wrote $outLocal"

# optional publish (tracked/public)
if ($Publish) {
  $pubDir = Join-Path $repo "public"
  New-Item -ItemType Directory -Path $pubDir -Force | Out-Null
  $outPub = Join-Path $pubDir "status.json"
  [System.IO.File]::WriteAllText($outPub, $json, $utf8NoBom)
  Write-Host "OK: wrote $outPub"
}
