param(
  [switch]$SkipSystemSkills,
  [switch]$SkipPrimaryRuntime
)

$ErrorActionPreference = "Stop"

$BundleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$CodexHome = Join-Path $HOME ".codex"
$AgentsHome = Join-Path $HOME ".agents"
$InstallRoot = Join-Path $CodexHome "portable-codex-migration"
$MarketplaceName = "codex-portable-migration"

$PluginNames = @(
  "build-ios-apps",
  "build-macos-apps",
  "build-web-apps",
  "build-web-data-visualization",
  "documents",
  "hyperframes",
  "presentations",
  "product-design",
  "remotion",
  "snap2ui",
  "spreadsheets",
  "superpowers"
)

function Ensure-Directory {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
  }
}

function Copy-DirectoryContents {
  param(
    [string]$Source,
    [string]$Destination
  )

  if (-not (Test-Path -LiteralPath $Source)) {
    throw "Missing source directory: $Source"
  }

  Ensure-Directory $Destination
  Get-ChildItem -LiteralPath $Source -Force | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $Destination -Recurse -Force
  }
}

function Backup-IfExists {
  param([string]$Path)
  if (Test-Path -LiteralPath $Path) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backup = "$Path.bak-codex-portable-$stamp"
    Copy-Item -LiteralPath $Path -Destination $backup -Force
    return $backup
  }
  return $null
}

Write-Host "Codex portable migration bundle: $BundleRoot"
Write-Host "Target CODEX_HOME: $CodexHome"

Ensure-Directory $CodexHome
Ensure-Directory $AgentsHome
Ensure-Directory (Join-Path $AgentsHome "skills")
Ensure-Directory (Join-Path $CodexHome "skills")
Ensure-Directory $InstallRoot
Ensure-Directory (Join-Path $InstallRoot "plugins")

Write-Host "Copying agent skills..."
Copy-DirectoryContents -Source (Join-Path $BundleRoot "skills\agents") -Destination (Join-Path $AgentsHome "skills")

Write-Host "Copying codex skills..."
Copy-DirectoryContents -Source (Join-Path $BundleRoot "skills\codex") -Destination (Join-Path $CodexHome "skills")

if (-not $SkipSystemSkills) {
  $systemSource = Join-Path $BundleRoot "skills\system\.system"
  if (Test-Path -LiteralPath $systemSource) {
    Write-Host "Copying bundled system skill snapshot..."
    Copy-DirectoryContents -Source $systemSource -Destination (Join-Path $CodexHome "skills\.system")
  }
}

Write-Host "Copying portable plugins..."
foreach ($plugin in $PluginNames) {
  Copy-DirectoryContents -Source (Join-Path $BundleRoot "plugins\$plugin") -Destination (Join-Path $InstallRoot "plugins\$plugin")
}

if (-not $SkipPrimaryRuntime) {
  $runtimeSource = Join-Path $BundleRoot "runtime\codex-primary-runtime"
  if (Test-Path -LiteralPath $runtimeSource) {
    $runtimeDestination = Join-Path $HOME ".cache\codex-runtimes\codex-primary-runtime"
    Write-Host "Copying primary runtime to $runtimeDestination ..."
    Copy-DirectoryContents -Source $runtimeSource -Destination $runtimeDestination
  }
}

Write-Host "Writing local marketplace..."
$marketplacePlugins = @()
foreach ($plugin in $PluginNames) {
  $marketplacePlugins += [ordered]@{
    name = $plugin
    source = [ordered]@{
      source = "local"
      path = "./plugins/$plugin"
    }
    policy = [ordered]@{
      installation = "AVAILABLE"
      authentication = "ON_INSTALL"
    }
    category = "Portable"
  }
}

$marketplace = [ordered]@{
  name = $MarketplaceName
  plugins = $marketplacePlugins
}

$marketplacePath = Join-Path $InstallRoot "marketplace.json"
$marketplace | ConvertTo-Json -Depth 20 | Set-Content -Encoding UTF8 -Path $marketplacePath

Write-Host "Updating Codex config..."
$configPath = Join-Path $CodexHome "config.toml"
Ensure-Directory (Split-Path -Parent $configPath)
if (-not (Test-Path -LiteralPath $configPath)) {
  New-Item -ItemType File -Path $configPath | Out-Null
}

$backupPath = Backup-IfExists $configPath
$config = Get-Content -Encoding UTF8 -Raw -Path $configPath
$append = New-Object System.Collections.Generic.List[string]

$marketplaceHeader = "[marketplaces.$MarketplaceName]"
if ($config -notmatch [regex]::Escape($marketplaceHeader)) {
  $quotedInstallRoot = $InstallRoot | ConvertTo-Json -Compress
  $append.Add("")
  $append.Add($marketplaceHeader)
  $append.Add("source_type = `"local`"")
  $append.Add("source = $quotedInstallRoot")
}

foreach ($plugin in $PluginNames) {
  $pluginHeader = "[plugins.`"$plugin@$MarketplaceName`"]"
  if ($config -notmatch [regex]::Escape($pluginHeader)) {
    $append.Add("")
    $append.Add($pluginHeader)
    $append.Add("enabled = true")
  }
}

if ($append.Count -gt 0) {
  Add-Content -Encoding UTF8 -Path $configPath -Value ($append -join [Environment]::NewLine)
}

Write-Host ""
Write-Host "Migration installed."
Write-Host "Marketplace root: $InstallRoot"
Write-Host "Marketplace file: $marketplacePath"
if ($backupPath) {
  Write-Host "Config backup: $backupPath"
}
Write-Host ""
Write-Host "Next step: restart Codex, then open Plugins or start a new thread."
