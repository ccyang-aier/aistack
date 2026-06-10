$ErrorActionPreference = "Stop"

$BundleRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$RequiredPlugins = @(
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

$RequiredCodexSkills = @(
  "hatch-pet",
  "pdf",
  "playwright",
  "playwright-interactive"
)

$RequiredAgentSkills = @(
  "brandkit",
  "design-taste-frontend",
  "find-skills",
  "full-output-enforcement",
  "gpt-taste",
  "high-end-visual-design",
  "image-to-code",
  "imagegen-frontend-mobile",
  "imagegen-frontend-web",
  "impeccable",
  "industrial-brutalist-ui",
  "minimalist-ui",
  "redesign-existing-projects",
  "stitch-design-taste"
)

$errors = New-Object System.Collections.Generic.List[string]

foreach ($plugin in $RequiredPlugins) {
  $manifest = Join-Path $BundleRoot "plugins\$plugin\.codex-plugin\plugin.json"
  if (-not (Test-Path -LiteralPath $manifest)) {
    $errors.Add("Missing plugin manifest: $manifest")
  }
}

foreach ($skill in $RequiredCodexSkills) {
  $entry = Join-Path $BundleRoot "skills\codex\$skill\SKILL.md"
  if (-not (Test-Path -LiteralPath $entry)) {
    $errors.Add("Missing codex skill: $entry")
  }
}

foreach ($skill in $RequiredAgentSkills) {
  $entry = Join-Path $BundleRoot "skills\agents\$skill\SKILL.md"
  if (-not (Test-Path -LiteralPath $entry)) {
    $errors.Add("Missing agent skill: $entry")
  }
}

$runtime = Join-Path $BundleRoot "runtime\codex-primary-runtime\runtime.json"
if (-not (Test-Path -LiteralPath $runtime)) {
  $errors.Add("Missing primary runtime metadata: $runtime")
}

if ($errors.Count -gt 0) {
  Write-Host "Package validation failed:"
  foreach ($errorItem in $errors) {
    Write-Host " - $errorItem"
  }
  exit 1
}

Write-Host "Package validation passed."
Write-Host "Bundle root: $BundleRoot"
