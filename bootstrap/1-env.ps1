<#
.SYNOPSIS
    Set every per-machine path as a user-scope env var.
.DESCRIPTION
    This is the keystone script: all configs in this repo read paths from env
    vars rather than hardcoding them, and this is what populates those vars from
    bootstrap\local.ps1.

    Idempotent. Run it again after editing local.ps1.
.EXAMPLE
    .\1-env.ps1 -WhatIf
.EXAMPLE
    .\1-env.ps1
#>
[CmdletBinding(SupportsShouldProcess)]
param()

. "$PSScriptRoot\lib.ps1"

$envMap = Get-EnvMap

Write-Host "`nSetting user env vars from bootstrap\local.ps1" -ForegroundColor Cyan
Write-Host "  (+ added, ~ changed, = already correct)`n" -ForegroundColor DarkGray

foreach ($name in $envMap.Keys) {
    Set-UserEnv -Name $name -Value $envMap[$name]
}

Write-Host "`nDone. Env vars are only visible to processes started afterwards," -ForegroundColor Cyan
Write-Host "so restart terminals, editors, and komorebi:" -ForegroundColor Cyan
Write-Host "  komorebic stop --whkd; komorebic start --whkd`n" -ForegroundColor DarkGray
Write-Host "Verify with: .\check.ps1" -ForegroundColor DarkGray
