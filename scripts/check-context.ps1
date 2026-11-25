# PowerShell twin of check-context.sh: the context banner, for running by hand on Windows.
# (Claude Code's SessionStart hook runs the .sh through bash, which Claude Code on
# Windows already requires.) Informational only: never blocks, always exits 0.
$ErrorActionPreference = 'SilentlyContinue'
$Root = Split-Path -Parent $PSScriptRoot

$skills = @()
$sk = Join-Path $Root '.claude\skills'
if (Test-Path $sk) {
    $skills = @(Get-ChildItem -Path $sk -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } | ForEach-Object { $_.Name })
}

$envPath = Join-Path $Root '.env'
$envOk = (Test-Path $envPath) -and (Select-String -Path $envPath -Pattern '^FLYPIFY_API_KEY=flypify_live_' -Quiet)
$shellOk = ($env:FLYPIFY_API_KEY -like 'flypify_live_*')
$ctxOk = Test-Path (Join-Path $Root 'MASTER_CONTEXT.md')

$update = ''
if ((Get-Command git) -and (git -C $Root remote get-url origin 2>$null)) {
    $env:GIT_TERMINAL_PROMPT = '0'
    $job = Start-Job -ScriptBlock { param($r) git -C $r fetch origin --quiet 2>$null } -ArgumentList $Root
    if (-not (Wait-Job $job -Timeout 10)) { Stop-Job $job }
    Remove-Job $job -Force
    $up = git -C $Root rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null
    if (-not $up) { $up = 'origin/main' }
    $behind = git -C $Root rev-list --count "HEAD..$up" 2>$null
    if ($behind -match '^\d+$') {
        if ([int]$behind -gt 0) { $update = "$behind commit(s) behind ${up}: run git pull to update the skills." }
        else { $update = "Up to date with $up." }
    }
}

Write-Host ''
Write-Host '-------------------------------------------------------------------'
Write-Host ' Flypify agent skills: context check'
Write-Host '-------------------------------------------------------------------'
if ($skills.Count -gt 0) { Write-Host " Skills: $($skills -join ' ')  (in .claude\skills\)" }
else { Write-Host ' Skills: none synced yet: run scripts\sync-skill.ps1' }
if ($envOk) { Write-Host ' ok   .env holds a Flypify key' } else { Write-Host ' --   .env missing or empty: run scripts\setup.ps1' }
if ($shellOk) { Write-Host ' ok   FLYPIFY_API_KEY is set in this session' }
else { Write-Host ' --   FLYPIFY_API_KEY is not set in this session, so every flypify MCP call answers 401 (key not exported, not a bad key).' }
if ($ctxOk) { Write-Host ' ok   MASTER_CONTEXT.md' } else { Write-Host ' --   MASTER_CONTEXT.md missing: copy MASTER_CONTEXT.template.md to MASTER_CONTEXT.md' }
if ($update) { Write-Host " $update" }
Write-Host ''
Write-Host ' Start: skills\flypify\SKILL.md  |  Prompts: prompts\PROMPT-PACK.md'
Write-Host ' Money rule: quote every credit or ad spend and wait for a yes.'
Write-Host '-------------------------------------------------------------------'
exit 0
