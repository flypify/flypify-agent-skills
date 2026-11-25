# Install (or remove) the Flypify agent team: ten specialists from team\.
#
#   scripts\team.ps1           install: team\<name>.md ->
#                                .claude\agents\flypify-<name>.md       (Claude Code subagents)
#                                .claude\skills\flypify-<name>\SKILL.md (Claude Code skills)
#                                .cursor\skills\flypify-<name>\SKILL.md (Cursor skills)
#                              and records "team" in .flypify-mode so sync-skill keeps them
#   scripts\team.ps1 -Remove   back to a single agent
#   -Quiet                     print nothing on success
param([switch]$Remove, [switch]$Quiet)
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$TeamDir = Join-Path $Root 'team'
if (-not (Test-Path $TeamDir)) { Write-Error "team.ps1: no team\ folder at $Root"; exit 1 }

$count = 0
foreach ($src in Get-ChildItem -Path $TeamDir -Filter '*.md' -File) {
    if ($src.BaseName -eq 'README') { continue }
    $name = "flypify-$($src.BaseName)"
    $agent = Join-Path $Root ".claude\agents\$name.md"
    $skillDirs = @((Join-Path $Root ".claude\skills\$name"), (Join-Path $Root ".cursor\skills\$name"))
    if ($Remove) {
        if (Test-Path $agent) { Remove-Item $agent -Force }
        foreach ($d in $skillDirs) { if (Test-Path $d) { Remove-Item $d -Recurse -Force } }
    } else {
        New-Item -ItemType Directory -Force (Split-Path $agent) | Out-Null
        Copy-Item $src.FullName $agent -Force
        foreach ($d in $skillDirs) {
            New-Item -ItemType Directory -Force $d | Out-Null
            Copy-Item $src.FullName (Join-Path $d 'SKILL.md') -Force
        }
    }
    $count++
}

$modeFile = Join-Path $Root '.flypify-mode'
if ($Remove) {
    Set-Content -Path $modeFile -Value 'single' -Encoding ascii
    if (-not $Quiet) { Write-Host "Removed $count Flypify specialists. Mode: single agent." }
} else {
    Set-Content -Path $modeFile -Value 'team' -Encoding ascii
    if (-not $Quiet) {
        Write-Host "Installed $count Flypify specialists (.claude\agents, .claude\skills, .cursor\skills). Mode: agent team."
        Write-Host "Restart your agent once so it loads them. In Claude Code, /agents lists them."
    }
}
