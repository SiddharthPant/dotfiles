# Copy helpers dot-sourced by mise.toml run_windows tasks. Sources are relative to the repo root.
# Windows gets plain copies instead of links, and a copy that has diverged from the repo is never overwritten.
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path

function Test-SameContent([string]$A, [string]$B) {
  (Get-FileHash -LiteralPath $A).Hash -eq (Get-FileHash -LiteralPath $B).Hash
}

# -Seed: the destination is mutable local state, so an existing file is left alone without a warning
function Copy-Dotfile([string]$Source, [string]$Destination, [switch]$Seed) {
  $src = Join-Path $root $Source
  $item = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
  if (-not $item) {
    New-Item -ItemType Directory -Force -Path (Split-Path $Destination) | Out-Null
    Copy-Item -LiteralPath $src -Destination $Destination
    "copied $Destination"
  } elseif ($item.LinkType) {
    Write-Warning "$Destination is a $($item.LinkType); remove it to get a copy"
  } elseif (Test-SameContent $src $Destination) {
    "ok $Destination"
  } elseif ($Seed) {
    "ok $Destination (local)"
  } else {
    Write-Warning "$Destination differs from $Source; not overwriting"
  }
}

# Remove a copy only while it still matches the repo, so local edits are never lost
function Remove-Dotfile([string]$Source, [string]$Destination) {
  $src = Join-Path $root $Source
  $item = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
  if ($item -and -not $item.LinkType -and (Test-SameContent $src $Destination)) {
    Remove-Item -LiteralPath $Destination
    "removed $Destination"
  } else {
    "skip $Destination"
  }
}

$WindowsTerminalSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
