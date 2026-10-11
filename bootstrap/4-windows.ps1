<#
.SYNOPSIS
    Windows Explorer and shell tweaks.
.DESCRIPTION
    The handful of OS settings worth scripting. Everything that can only be done
    by clicking is in MANUAL.md instead.

    Idempotent, and supports -WhatIf.
.EXAMPLE
    .\4-windows.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param()

. "$PSScriptRoot\lib.ps1"

$advanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

# name -> @(value, description)
$settings = [ordered]@{
    HideFileExt      = @(0, 'Show file extensions')
    Hidden           = @(2, 'Do not show hidden files (so hiding dotfiles actually hides them)')
    ShowSuperHidden  = @(0, 'Keep protected OS files hidden')
}

Write-Host "`nExplorer settings" -ForegroundColor Cyan
$changed = $false

foreach ($name in $settings.Keys) {
    $want, $desc = $settings[$name]
    $have = (Get-ItemProperty -Path $advanced -Name $name -ErrorAction SilentlyContinue).$name

    if ($have -eq $want) {
        Write-Host "  = $desc" -ForegroundColor DarkGray
        continue
    }
    if ($PSCmdlet.ShouldProcess($name, "set to $want ($desc)")) {
        Set-ItemProperty -Path $advanced -Name $name -Value $want -Type DWord
        Write-Host "  ~ $desc" -ForegroundColor Green
        $changed = $true
    }
}

# Hide the dotted config dirs that tools scatter through the home directory.
Write-Host "`nHome directory tidy" -ForegroundColor Cyan
$hideScript = Join-Path (Get-DotfilesRoot) 'powershell\utils\Hide-DotItems.ps1'
if (Test-Path $hideScript) {
    & $hideScript -WhatIf:$WhatIfPreference -Verbose:$VerbosePreference
} else {
    Write-Warning "Missing $hideScript"
}

if ($changed) {
    Write-Host "`nExplorer must restart for its settings to apply:" -ForegroundColor Yellow
    Write-Host "  Stop-Process -Name explorer -Force`n" -ForegroundColor DarkGray
}
