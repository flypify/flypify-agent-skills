# First-run setup for the Flypify agent skill pack (Windows PowerShell 5.1+ / PowerShell 7).
#
#   1. asks for your Flypify API key (hidden input) and checks its shape
#   2. verifies it against the Flypify Agent API (free calls, no credits)
#   3. saves it to .env (FLYPIFY_API_KEY=...), readable only by you
#   4. creates MASTER_CONTEXT.md from the template if it is missing
#   5. copies skills\ into .claude\skills\ and .cursor\skills\
#   6. asks: single agent or agent team (-Single / -Team skip the question)
#
# The key is never printed and never logged. Re-run with -Force to replace a saved key.
#   powershell -ExecutionPolicy Bypass -File scripts\setup.ps1
[CmdletBinding()]
param([switch]$Force, [switch]$Team, [switch]$Single)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$Api = if ($env:FLYPIFY_API_BASE) { $env:FLYPIFY_API_BASE } else { 'https://api.flypify.com/api/v1' }
$EnvPath = Join-Path $Root '.env'
$Utf8NoBom = New-Object System.Text.UTF8Encoding $false

try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch {}

Write-Host '=== Flypify agent skill pack: setup ==='
Write-Host ''

function Invoke-FlypifyGet {
    param([string]$Path, [string]$Key)
    # Returns @{ Status = <int>; Body = <object or $null> }. Status 0 = no connection.
    $headers = @{ Authorization = "Bearer $Key" }
    try {
        $resp = Invoke-WebRequest -Uri ($Api + $Path) -Headers $headers -UseBasicParsing -TimeoutSec 20
        $body = $null
        try { $body = $resp.Content | ConvertFrom-Json } catch {}
        return @{ Status = [int]$resp.StatusCode; Body = $body }
    } catch {
        $r = $_.Exception.Response
        if ($null -eq $r) { return @{ Status = 0; Body = $null } }
        $body = $null
        try {
            $reader = New-Object System.IO.StreamReader($r.GetResponseStream())
            $body = $reader.ReadToEnd() | ConvertFrom-Json
        } catch {}
        return @{ Status = [int]$r.StatusCode; Body = $body }
    }
}

function Get-ErrorCode($Body) {
    if ($null -eq $Body) { return '' }
    $e = $Body.error
    if ($e -is [string]) { return $e }
    if ($null -ne $e -and $e.code) { return [string]$e.code }
    return ''
}

# -- step 1: the key ----------------------------------------------------------
$Key = ''
$Save = $true
$existing = ''
if (Test-Path $EnvPath) {
    $line = Get-Content $EnvPath | Where-Object { $_ -match '^FLYPIFY_API_KEY=flypify_live_' } | Select-Object -First 1
    if ($line) { $existing = ($line -replace '^FLYPIFY_API_KEY=', '').Trim().Trim('"').Trim("'") }
}
if ($existing -and -not $Force) {
    Write-Host '.env already holds a Flypify key. Checking it (run with -Force to replace it).'
    $Key = $existing
    $Save = $false
} else {
    Write-Host 'You need a Flypify plan and an API key:'
    Write-Host '  1. Pick a plan:   https://flypify.com/pricing'
    Write-Host '  2. Create a key:  https://flypify.com/account  ->  "AI agent access (MCP)"'
    Write-Host '     It starts with flypify_live_ . Treat it like a password.'
    Write-Host ''
    if ([Console]::IsInputRedirected) {
        $Key = [Console]::In.ReadLine()
    } else {
        $secure = Read-Host -AsSecureString 'Paste your key (input hidden, Enter to skip)'
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
        try { $Key = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
        finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
    }
    if ($null -eq $Key) { $Key = '' }
    $Key = $Key -replace '\s', ''
}

if (-not $Key) {
    Write-Host 'Skipped. Run scripts\setup.ps1 again when you have a key.'
} else {
    if ($Key -notmatch '^flypify_live_[A-Za-z0-9_-]+$') {
        Write-Host "That doesn't look like a Flypify key (it should start with flypify_live_). Nothing was saved."
        exit 1
    }

    # -- step 2: verify (free: /me and /stores cost no credits or reveals) ----
    Write-Host 'Checking the key with Flypify ...'
    $me = Invoke-FlypifyGet -Path '/me' -Key $Key
    switch ($me.Status) {
        200 {
            $plan = if ($me.Body -and $me.Body.plan) { $me.Body.plan } else { 'unknown' }
            $st = Invoke-FlypifyGet -Path '/stores' -Key $Key
            $stores = '?'
            if ($st.Status -eq 200 -and $st.Body) { $stores = @($st.Body.stores).Count }
            Write-Host "OK. Plan: $plan. Stores: $stores."
        }
        401 {
            $code = Get-ErrorCode $me.Body
            Write-Host "Flypify rejected that key (401 $code). It may be mistyped, revoked or deleted."
            Write-Host 'Create a new one at https://flypify.com/account -> "AI agent access (MCP)". Nothing was saved.'
            exit 1
        }
        { $_ -eq 402 -or $_ -eq 403 } {
            $code = Get-ErrorCode $me.Body
            Write-Host "The key works but the account has no active paid plan ($($me.Status) $code)."
            Write-Host 'Pick a plan at https://flypify.com/pricing, then run this again. Nothing was saved.'
            exit 1
        }
        0 { Write-Host 'Could not reach Flypify (offline or blocked). Saving the key anyway; run this again to check it.' }
        default { Write-Host "Flypify answered HTTP $($me.Status). Saving the key anyway; run this again later to check it." }
    }

    # -- step 3: save to .env -------------------------------------------------
    if ($Save) {
        $lines = @()
        if (Test-Path $EnvPath) { $lines = @(Get-Content $EnvPath | Where-Object { $_ -notmatch '^FLYPIFY_API_KEY=' }) }
        $lines += "FLYPIFY_API_KEY=$Key"
        [IO.File]::WriteAllText($EnvPath, (($lines -join "`n") + "`n"), $Utf8NoBom)
        try {
            # Owner-only: drop inherited permissions, grant the current user read/write.
            & icacls $EnvPath /inheritance:r /grant:r "$($env:USERNAME):(R,W)" *> $null
        } catch {}
        Write-Host 'Saved to .env (git-ignored, owner-only).'
    }
    $Key = $null
}
Write-Host ''

# -- step 4: MASTER_CONTEXT.md ------------------------------------------------
$ctx = Join-Path $Root 'MASTER_CONTEXT.md'
if (-not (Test-Path $ctx)) {
    Copy-Item (Join-Path $Root 'MASTER_CONTEXT.template.md') $ctx
    Write-Host 'Created MASTER_CONTEXT.md. Your agent fills it in as you work.'
} else {
    Write-Host 'MASTER_CONTEXT.md already exists. Left as is.'
}

# -- step 5: skills -----------------------------------------------------------
& (Join-Path $PSScriptRoot 'sync-skill.ps1')
Write-Host ''

# -- step 6: single agent or agent team ----------------------------------------
$modeFile = Join-Path $Root '.flypify-mode'
$current = if (Test-Path $modeFile) { (Get-Content $modeFile -TotalCount 1).Trim() } else { '' }
$mode = if ($Team) { 'team' } elseif ($Single) { 'single' } else { '' }
if (-not $mode -and $current) {
    Write-Host "Mode: $current (switch with scripts\team.ps1 or scripts\team.ps1 -Remove)."
} elseif (-not $mode -and [Environment]::UserInteractive -and -not [Console]::IsInputRedirected) {
    Write-Host 'How do you want to run Flypify?'
    Write-Host '  1) Single agent: one agent runs the whole launch loop (default)'
    Write-Host '  2) Agent team: a lead plus 10 specialists (Winners Research, Brand Spy, Supplier'
    Write-Host '     Sourcing, Store Builder, Listicles, Static and Video Ad Studio, Meta Campaigns,'
    Write-Host '     Split Tests, Store Insights)'
    $pick = Read-Host 'Choose 1 or 2 [1]'
    $mode = if ($pick -eq '2') { 'team' } else { 'single' }
} elseif (-not $mode) {
    Write-Host 'Mode not chosen yet: your agent will ask (single agent or agent team) on first use.'
}
if ($mode -eq 'team') {
    & (Join-Path $PSScriptRoot 'team.ps1')
} elseif ($mode -eq 'single') {
    if ($current -eq 'team') { & (Join-Path $PSScriptRoot 'team.ps1') -Remove }
    else { Set-Content -Path $modeFile -Value 'single' -Encoding ascii; Write-Host 'Mode: single agent. Switch any time with scripts\team.ps1' }
}
Write-Host ''

Write-Host @'
Next steps
  Claude Code: load the key into this PowerShell session, then start Claude Code here:
      Get-Content .env | ForEach-Object { if ($_ -match '^(\w+)=(.*)$') { Set-Item "env:$($Matches[1])" $Matches[2] } }
      claude
    Then run /mcp and check that "flypify" is connected.
  Codex:   see setup\chatgpt-and-codex.md
  Cursor:  set FLYPIFY_API_KEY the same way, then open this folder (see setup\cursor.md)

  First prompt to try:
    Use Flypify. Check my account and stores, then find 5 winners in {your niche}
    and tell me which one to launch.
'@
