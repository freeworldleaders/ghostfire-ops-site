$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not (Get-Variable -Name fail -Scope Script -ErrorAction SilentlyContinue)) {
  $script:fail = $false
}

function Info($m){ Write-Host ("INFO: " + $m) -ForegroundColor Cyan }
function Pass($m){ Write-Host ("PASS: " + $m) -ForegroundColor Green }
function Warn($m){ Write-Host ("WARN: " + $m) -ForegroundColor Yellow }
function Fail($m){ Write-Host ("FAIL: " + $m) -ForegroundColor Red; $script:fail = $true }

function FailIf([bool]$cond,[string]$msg){ if ($cond) { Fail $msg } }
function AssertNoFail([string]$msg){
  if ((Get-Variable -Name fail -Scope Script -ErrorAction SilentlyContinue).Value -eq $true) { throw $msg }
}