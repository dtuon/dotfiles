<#
.SYNOPSIS
    Point Windows' PowerShell profile at the copy in this repo.
.DESCRIPTION
    $PROFILE lives in a machine-specific place (and on this machine, inside
    Dropbox). Rather than keep the real profile there, we install a small stub
    that dot-sources powershell\profile.ps1 from this repo. The profile itself is
    then versioned, and the stub never needs to change again.

    Any existing profile is backed up to *.pre-dotfiles.bak before being replaced.
    Idempotent: a no-op if the stub is already in place.
.EXAMPLE
    .\3-profile.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param()

. "$PSScriptRoot\lib.ps1"

$root = Get-DotfilesRoot
$stub = @"
# Stub. The real profile is versioned in the dotfiles repo; edit it there.
# Installed by bootstrap\3-profile.ps1 -- see powershell\README.md.

# Prefer the session value, but fall back to the stored user-scope one: a shell
# whose parent process predates bootstrap\1-env.ps1 won't have inherited it.
`$dotfilesRoot = if (`$env:DOTFILES) { `$env:DOTFILES }
                else { [Environment]::GetEnvironmentVariable('DOTFILES', 'User') }

if (`$dotfilesRoot) {
    `$env:DOTFILES = `$dotfilesRoot
    `$dotfilesProfile = Join-Path `$dotfilesRoot 'powershell\profile.ps1'
    if (Test-Path `$dotfilesProfile) { . `$dotfilesProfile }
    else { Write-Warning "No profile at `$dotfilesProfile" }
} else {
    Write-Warning 'DOTFILES is not set. Run bootstrap\1-env.ps1 from the dotfiles repo.'
}
"@

function Install-Stub {
    param([string] $Path, [string] $Content)

    if (Test-Path $Path) {
        $existing = (Get-Content $Path -Raw -ErrorAction SilentlyContinue)
        if ($existing -and $existing.Trim() -eq $Content.Trim()) {
            Write-Host "  = $Path" -ForegroundColor DarkGray
            return
        }
        # Never overwrite an existing backup: on a re-run that would replace the
        # original profile with a stub written by an earlier run.
        $backup = "$Path.pre-dotfiles.bak"
        if (Test-Path $backup) {
            Write-Host "  backup already exists, keeping it" -ForegroundColor DarkGray
        }
        elseif ($PSCmdlet.ShouldProcess($Path, "back up to $(Split-Path $backup -Leaf)")) {
            Copy-Item $Path $backup
            Write-Host "  backed up -> $backup" -ForegroundColor DarkGray
        }
    }

    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) {
        if ($PSCmdlet.ShouldProcess($dir, 'create directory')) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }

    if ($PSCmdlet.ShouldProcess($Path, 'install dotfiles profile stub')) {
        Set-Content -Path $Path -Value $Content -Encoding utf8NoBOM
        Write-Host "  + $Path" -ForegroundColor Green
    }
}

Write-Host "`nInstalling PowerShell profile stub" -ForegroundColor Cyan
Write-Host "  real profile: $root\powershell\profile.ps1`n" -ForegroundColor DarkGray

Install-Stub -Path $PROFILE.CurrentUserAllHosts -Content $stub

# The host-specific profile also runs, and on this machine held the old
# hardcoded-path version. Neutralise it so nothing is defined twice.
$hostProfile = $PROFILE.CurrentUserCurrentHost
if (Test-Path $hostProfile) {
    $marker = "# Intentionally empty. The profile now lives in the dotfiles repo and is`n" +
              "# loaded by the stub in profile.ps1 (CurrentUserAllHosts) in this folder."
    Install-Stub -Path $hostProfile -Content $marker
}

Write-Host "`nOpen a new shell to pick it up.`n" -ForegroundColor Cyan
