# Copy every skill in skills\ to .claude\skills\ (Claude Code) and .cursor\skills\ (Cursor).
# Both targets are git-ignored generated copies: edit skills\<name>\ and run this again.
#   -Quiet   print nothing on success
[CmdletBinding()]
param([switch]$Quiet)

$Root = Split-Path -Parent $PSScriptRoot
$Src = Join-Path $Root 'skills'
if (-not (Test-Path $Src)) { Write-Host "sync-skill: no skills folder at $Root"; exit 0 }

$count = 0
foreach ($rel in @('.claude\skills', '.cursor\skills')) {
    $target = Join-Path $Root $rel
    New-Item -ItemType Directory -Force -Path $target | Out-Null
    foreach ($dir in Get-ChildItem -Path $Src -Directory) {
        $dest = Join-Path $target $dir.Name
        if (Test-Path $dest) { Remove-Item -Recurse -Force -Path $dest }
        Copy-Item -Recurse -Path $dir.FullName -Destination $dest
        if ($rel -eq '.claude\skills') { $count++ }
    }
}
if (-not $Quiet) { Write-Host "Synced $count skill(s) to .claude\skills\ and .cursor\skills\." }

# Agent team mode (see skills\flypify\agent-team.md): keep the specialists installed.
$modeFile = Join-Path $Root '.flypify-mode'
if ((Test-Path $modeFile) -and ((Get-Content $modeFile -TotalCount 1).Trim() -eq 'team')) {
    & (Join-Path $PSScriptRoot 'team.ps1') -Quiet:$Quiet
}
exit 0
