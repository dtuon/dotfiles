<#
.SYNOPSIS
    Windows Explorer and shell tweaks, plus the WSL2 install Docker needs.
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
$changed      = $false
$rebootNeeded = $false

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

# WSL2. Not a winget package, so it cannot live in 2-packages.ps1 with the
# Docker Desktop entry that needs it. Docker installs fine without WSL -- it
# just will not run until this is done and the machine has rebooted.
Write-Host "`nWSL2 (required by Docker Desktop)" -ForegroundColor Cyan

$wslReady = $false
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    wsl --status *> $null
    $wslReady = ($LASTEXITCODE -eq 0)
}

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin  = ([Security.Principal.WindowsPrincipal]$identity).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)

if ($wslReady) {
    Write-Host "  = WSL already installed" -ForegroundColor DarkGray
} elseif (-not $isAdmin) {
    # Everything else in this script is HKCU, so don't force elevation on the
    # whole run just for this. Say what is missing and carry on.
    Write-Warning "WSL is not installed, and 'wsl --install' needs an elevated shell. Run this in an admin terminal, or by hand: wsl --install --no-launch"
} elseif ($PSCmdlet.ShouldProcess('WSL2', 'wsl --install --no-launch')) {
    # --no-launch: Docker needs the WSL2 platform, not a distro. Without it the
    # default Ubuntu install stops to prompt for a username.
    wsl --install --no-launch
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  + WSL2 installed" -ForegroundColor Green
        $rebootNeeded = $true
    } else {
        Write-Host "  FAILED (exit $LASTEXITCODE)" -ForegroundColor Red
    }
}

if ($changed) {
    Write-Host "`nExplorer must restart for its settings to apply:" -ForegroundColor Yellow
    Write-Host "  Stop-Process -Name explorer -Force`n" -ForegroundColor DarkGray
}

if ($rebootNeeded) {
    Write-Host "`nWSL needs a reboot before Docker Desktop will start." -ForegroundColor Yellow
    Write-Host "  After rebooting: docker run hello-world`n" -ForegroundColor DarkGray
}
