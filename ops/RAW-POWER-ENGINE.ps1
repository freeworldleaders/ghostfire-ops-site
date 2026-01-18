$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot "_ENGINE-CORE.ps1")
# Raw = fastest hard gates. Exit code 0 ok, 1 fail.
function Ok($m){ Write-Host ("OK: " + $m) -ForegroundColor Green }
function Bad($m){ Write-Host ("BAD: " + $m) -ForegroundColor Red; $script:fail = $true }

$repo = (Get-Location).Path
if (-not (Test-Path (Join-Path $repo ".git"))) { Bad "Not a git repo"; }

$checks = @(
  "command-board.html",
  "ops\HIGG-RUN.ps1",
  "protocols\HIGG_PROTOCOLS.html",
  "kingdom-solutions\index.html"
)

foreach ($c in $checks) {
  $p = Join-Path $repo $c
  if (Test-Path $p) { Ok $c } else { Bad ("Missing " + $c) }
}
if ((Get-Variable -Name fail -Scope Script -ErrorAction SilentlyContinue).Value -eq $true) { exit 1 }
Ok "RAW POWER ENGINE PASS"
exit 0