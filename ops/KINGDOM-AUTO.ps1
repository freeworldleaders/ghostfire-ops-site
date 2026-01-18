param(
  [switch]$Write,
  [switch]$NoHigg,
  [switch]$NoMirror
)$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot "_ENGINE-CORE.ps1")
function Ensure-Dir([string]$absDir) {
  if (-not (Test-Path $absDir)) { New-Item -ItemType Directory -Force $absDir | Out-Null }
}

function Mirror-Folder([string]$srcRel, [string]$dstRel) {
  $root = RepoRoot
  $src = Join-Path $root $srcRel
  $dst = Join-Path $root $dstRel

  if (-not (Test-Path $src)) { return }

  Ensure-Dir $dst
  Get-ChildItem -LiteralPath $dst -Force -ErrorAction SilentlyContinue |
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

  Copy-Item -Recurse -Force (Join-Path $src '*') $dst
}

function Info($m){ Write-Host ("INFO: " + $m) -ForegroundColor Cyan }
function Pass($m){ Write-Host ("PASS: " + $m) -ForegroundColor Green }
function Warn($m){ Write-Host ("WARN: " + $m) -ForegroundColor Yellow }
function Fail($m){ Write-Host ("FAIL: " + $m) -ForegroundColor Red; $script:fail = $true }

function RepoRoot {
  $here = (Get-Location).Path
  if (-not (Test-Path (Join-Path $here ".git"))) { throw "Run at repo root (missing .git): $here" }
  $here
}

function ExistsRel([string]$rel) { Test-Path (Join-Path (RepoRoot) $rel) }

function BuildNavLinks {
  $links = New-Object System.Collections.Generic.List[object]
  $add = {
    param($label,$href,$exists)
    if ($exists) { $links.Add([pscustomobject]@{Label=$label;Href=$href}) }
  }

  & $add "Home" "/" $true
  & $add "Command Board" "/command-board.html" (ExistsRel "command-board.html")
  & $add "Engines" "/engines/" (ExistsRel "engines\index.html")
  & $add "Canon Docs" "/kingdom-solutions/" (ExistsRel "kingdom-solutions\index.html")
  & $add "HIGG Protocols" "/protocols/HIGG_PROTOCOLS.html" (ExistsRel "protocols\HIGG_PROTOCOLS.html")
  & $add "About" "/about.html" (ExistsRel "about.html")
  & $add "Creators" "/creators.html" (ExistsRel "creators.html")
  & $add "Trust & Safety" "/trust-safety.html" (ExistsRel "trust-safety.html")
  & $add "FAQ" "/faq.html" (ExistsRel "faq.html")
  & $add "Upload" "/upload.html" (ExistsRel "upload.html")

  $links
}

function MdNavBlock($links) {
  $md = ($links | ForEach-Object { "[$($_.Label)]($($_.Href))" }) -join " · "
  @"
<!-- KINGDOM_NAV -->
**Navigation:** $md

---
"@
}

function HtmlNavBlock($links) {
  $html = ($links | ForEach-Object { "<a href=""$($_.Href)"">$($_.Label)</a>" }) -join " &middot; "
@"
<!-- KINGDOM_NAV -->
<div style="max-width:1100px;margin:0 auto;padding:12px 16px;">
  <div style="border:1px solid rgba(229,231,235,.14);border-radius:14px;padding:10px 12px;background:rgba(255,255,255,.02);">
    <div style="font-size:13px;opacity:.9;">
      <b>Navigation:</b> $html
    </div>
  </div>
</div>
<!-- /KINGDOM_NAV -->
"@
}

function ReplaceOrInsertMdNav([string]$rel,[string]$nav) {
  $root = RepoRoot
  $abs = Join-Path $root $rel
  if (-not (Test-Path $abs)) { return }

  $raw = Get-Content -Raw $abs

  # Replace existing block
  if ($raw -match '(?s)<!--\s*KINGDOM_NAV\s*-->.*?---\s*') {
    $new = [regex]::Replace($raw,'(?s)<!--\s*KINGDOM_NAV\s*-->.*?---\s*',($nav -replace '\$','$$'),1)
  } else {
    # Insert after YAML front matter if present, else prepend
    if ($raw -match '^(?s)\s*---\s*\r?\n.*?\r?\n---\s*\r?\n') {
      $m = [regex]::Match($raw,'^(?s)\s*---\s*\r?\n.*?\r?\n---\s*\r?\n')
      $prefix = $m.Value
      $rest   = $raw.Substring($m.Length)
      $new    = $prefix + "`r`n" + $nav + "`r`n" + $rest
    } else {
      $new = $nav + "`r`n" + $raw
    }
  }

  if ($Write) {
    # Write UTF8 no BOM
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($abs,$new,$utf8NoBom)
  }
  Pass "Nav updated: $rel"
}

function ReplaceOrInsertHtmlNav([string]$rel,[string]$nav) {
  $root = RepoRoot
  $abs = Join-Path $root $rel
  if (-not (Test-Path $abs)) { return }

  $raw = Get-Content -Raw $abs

  # Replace existing KINGDOM_NAV block
  if ($raw -match '(?s)<!--\s*KINGDOM_NAV\s*-->.*?<!--\s*/KINGDOM_NAV\s*-->') {
    $new = [regex]::Replace($raw,'(?s)<!--\s*KINGDOM_NAV\s*-->.*?<!--\s*/KINGDOM_NAV\s*-->',$nav,1)
  } else {
    # Insert after </header> if present, else after <body>, else prepend
    if ($raw -match '(?is)</header>') {
      $new = [regex]::Replace($raw,'(?is)</header>',"</header>`r`n$nav",1)
    } elseif ($raw -match '(?is)<body[^>]*>') {
      $m = [regex]::Match($raw,'(?is)<body[^>]*>')
      $i = $m.Index + $m.Length
      $new = $raw.Substring(0,$i) + "`r`n$nav`r`n" + $raw.Substring($i)
    } else {
      $new = $nav + "`r`n" + $raw
    }
  }

  if ($Write) {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($abs,$new,$utf8NoBom)
  }
  Pass "Nav updated: $rel"
}

# ---------- RUN ----------
$root = RepoRoot
Info "KINGDOM-AUTO running at $root"
if (-not $NoMirror -and $Write) {
  # If you keep canonical assets under /public, mirror to root so GitHub Pages paths work.
  if (Test-Path (Join-Path $root "public\kingdom-solutions")) { Mirror-Folder "public/kingdom-solutions" "kingdom-solutions" }
  if (Test-Path (Join-Path $root "public\protocols"))        { Mirror-Folder "public/protocols" "protocols" }
}

$links = BuildNavLinks
$mdNav = MdNavBlock $links
$htmlNav = HtmlNavBlock $links

# Update nav across known files if they exist
ReplaceOrInsertMdNav "index.md" $mdNav

# Root pages (only if present)
$pages = @("about.html","creators.html","trust-safety.html","faq.html","upload.html","command-board.html","engines/index.html")
foreach ($p in $pages) { ReplaceOrInsertHtmlNav $p $htmlNav }

# HIGG gate run (optional)
if (-not $NoHigg) {
  $higg = Join-Path $root "ops\HIGG-RUN.ps1"
  if (Test-Path $higg) {
    Info "Running HIGG..."
    pwsh -NoProfile -File $higg
    Pass "HIGG complete"
  } else {
    Warn "HIGG runner missing (ops/HIGG-RUN.ps1)"
  }
}
if ($script:fail -eq $true) { throw "KINGDOM-AUTO FAILED (see FAIL lines)" }
Pass "KINGDOM-AUTO COMPLETE"