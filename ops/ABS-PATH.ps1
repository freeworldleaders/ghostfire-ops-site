# ops/ABS-PATH.ps1
# Deterministic absolute path + safe write helpers.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-RepoRoot {
  param([string]$Start = (Get-Location).Path)

  $p = Resolve-Path $Start
  while ($true) {
    if (Test-Path (Join-Path $p ".git")) { return $p.Path }
    $parent = Split-Path $p.Path -Parent
    if (-not $parent -or $parent -eq $p.Path) { throw "Repo root not found (no .git) starting at: $Start" }
    $p = Resolve-Path $parent
  }
}

function Get-AbsPath {
  param(
    [Parameter(Mandatory=$true)][string]$RelativePath,
    [string]$RepoRoot = (Get-RepoRoot)
  )

  # Normalize input: strip leading .\ or ./ so Join-Path doesn't do weirdness
  $rel = $RelativePath -replace '^[.\\/]+', ''
  $abs = Join-Path $RepoRoot $rel
  return (Resolve-Path -LiteralPath (Split-Path $abs -Parent) -ErrorAction SilentlyContinue)?.Path `
    ? (Join-Path (Resolve-Path (Split-Path $abs -Parent)).Path (Split-Path $abs -Leaf)) `
    : $abs
}

function Ensure-ParentDir {
  param([Parameter(Mandatory=$true)][string]$AbsPath)
  $dir = Split-Path $AbsPath -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
}

function Write-Utf8NoBom {
  param(
    [Parameter(Mandatory=$true)][string]$RelativePath,
    [Parameter(Mandatory=$true)][string]$Content
  )
  $root = Get-RepoRoot
  $abs  = Get-AbsPath -RelativePath $RelativePath -RepoRoot $root
  Ensure-ParentDir -AbsPath $abs
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($abs, $Content, $utf8NoBom)
  return $abs
}

Export-ModuleMember -Function Get-RepoRoot, Get-AbsPath, Ensure-ParentDir, Write-Utf8NoBom
