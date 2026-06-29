# Install / update claude-remote-watchdog (Windows / PowerShell).
#
# Downloads the files listed in manifest.txt straight from the repo and
# writes them under ~/.claude/. Re-run any time to update — it overwrites
# the command and script in place.
#
# Remote one-liner (no clone needed):
#   irm https://raw.githubusercontent.com/odysseyalive/claude-remote-watchdog/main/install.ps1 | iex
#
# NOTE: the watchdog itself needs tmux + bash, which on Windows only exist
# under WSL. This installer lands the files in your Windows-side ~/.claude;
# to actually run the watchdog, use the bash installer inside WSL instead:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/odysseyalive/claude-remote-watchdog/main/install.sh)"
#
# Override the source with $env:BRANCH or $env:REPO_URL for testing.

$ErrorActionPreference = 'Stop'

$Branch  = if ($env:BRANCH)   { $env:BRANCH }   else { 'main' }
$RepoUrl = if ($env:REPO_URL) { $env:REPO_URL } else { "https://raw.githubusercontent.com/odysseyalive/claude-remote-watchdog/$Branch" }
$InstallRoot = Join-Path $HOME '.claude'

Write-Host "claude-remote-watchdog installer"
Write-Host "================================"
Write-Host "Source: $RepoUrl"
Write-Host ""

# Download the manifest, then every file it lists.
$manifest = (Invoke-WebRequest -Uri "$RepoUrl/manifest.txt" -UseBasicParsing).Content

foreach ($rawline in ($manifest -split "`r?`n")) {
    $line = $rawline.Trim()
    if ($line -eq '' -or $line.StartsWith('#')) { continue }

    # Split into fields; an optional leading flag is shifted off.
    $fields = $line -split '\s+'
    $flag = ''
    if ($fields[0] -eq 'exec' -or $fields[0] -eq 'keep') {
        $flag = $fields[0]
        $fields = $fields[1..($fields.Count - 1)]
    }
    $src = $fields[0]
    $rel = if ($fields.Count -ge 2) { $fields[1] } else { '' }
    if (-not $src -or -not $rel) {
        Write-Warning "Skipping malformed manifest line: $line"
        continue
    }

    $dest = Join-Path $InstallRoot ($rel -replace '/', [IO.Path]::DirectorySeparatorChar)

    if ($flag -eq 'keep' -and (Test-Path $dest)) {
        Write-Host "Keeping existing $rel (preserving your edits)..."
        continue
    }

    $destDir = Split-Path -Parent $dest
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    Invoke-WebRequest -Uri "$RepoUrl/$src" -OutFile $dest -UseBasicParsing
    Write-Host "Installed: ~/.claude/$rel"
    # The 'exec' flag is a no-op on Windows (no unix executable bit).
}

Write-Host ""
Write-Host "Installed! Run the watchdog inside WSL, where tmux lives:"
Write-Host ""
Write-Host "  One-time check:   /remote-watchdog"
Write-Host "  Auto-monitor:     /loop 5m /remote-watchdog"
Write-Host "  Dry run:          ~/.claude/scripts/remote-watchdog.sh --dry-run"
Write-Host ""
Write-Host "  Update later:     re-run this installer"
Write-Host ""
