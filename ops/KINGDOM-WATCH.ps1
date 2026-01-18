param(
  [int]$DebounceMs = 800
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Info($m){ Write-Host ("INFO: " + $m) -ForegroundColor Cyan }
function Warn($m){ Write-Host ("WARN: " + $m) -ForegroundColor Yellow }

$root = (Get-Location).Path
if (-not (Test-Path (Join-Path $root ".git"))) { throw "Run at repo root: $root" }

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $root
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

# Filter noise
$ignore = @("\.git\", "\node_modules\", "\tmp\")
$last = Get-Date "2000-01-01"

$action = {
  $path = $Event.SourceEventArgs.FullPath
  foreach ($ig in $ignore) { if ($path -like "*$ig*") { return } }

  $now = Get-Date
  if (($now - $script:last).TotalMilliseconds -lt $DebounceMs) { return }
  $script:last = $now

  Info "Change detected: $path"
  try {
    pwsh -NoProfile -File (Join-Path $root "ops\KINGDOM-AUTO.ps1") -Write | Out-Null
    Info "Auto refresh complete"
  } catch {
    Warn $_.Exception.Message
  }
}

Register-ObjectEvent $watcher Changed -Action $action | Out-Null
Register-ObjectEvent $watcher Created -Action $action | Out-Null
Register-ObjectEvent $watcher Renamed -Action $action | Out-Null
Register-ObjectEvent $watcher Deleted -Action $action | Out-Null

Info "KINGDOM-WATCH running. Ctrl+C to stop."
while ($true) { Start-Sleep -Seconds 2 }