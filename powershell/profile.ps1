# PowerShell profile. Loaded by a stub at $PROFILE -- see powershell\README.md.
#
# Every path here comes from an env var set by bootstrap\1-env.ps1, so this file
# is machine-independent. If you find yourself typing a C:\ path below, add it to
# Get-EnvMap in bootstrap\lib.ps1 instead.

# --- Editors ------------------------------------------------------------------

# Neovim as the external editor for Claude Code, git, gh, etc.
$env:VISUAL = 'nvim'
$env:EDITOR = 'nvim'

# --- Navigation ---------------------------------------------------------------
#
# One function per destination, each reading an env var. Aliases are kept in
# alphabetical order below so it's easy to spot which letters are still free.

function Set-LocationFromEnv {
    param(
        [Parameter(Mandatory)][string] $EnvVar,
        [string] $SubPath
    )

    # Session value first, then the stored user-scope one. The fallback matters
    # in a shell whose parent process started before bootstrap\1-env.ps1 ran.
    $base = [Environment]::GetEnvironmentVariable($EnvVar)
    if ([string]::IsNullOrWhiteSpace($base)) {
        $base = [Environment]::GetEnvironmentVariable($EnvVar, 'User')
    }
    if ([string]::IsNullOrWhiteSpace($base)) {
        Write-Warning "$EnvVar is not set. Run bootstrap\1-env.ps1 and open a new shell."
        return
    }

    $target = if ($SubPath) { Join-Path $base $SubPath } else { $base }
    if (-not (Test-Path -LiteralPath $target)) {
        Write-Warning "$EnvVar resolves to a path that doesn't exist: $target"
        return
    }

    Set-Location -LiteralPath $target
}

function CDBedrock       { Set-LocationFromEnv BEDROCK }
function CDDocuments     { Set-LocationFromEnv DOCS }
function CDEther         { Set-LocationFromEnv ETHER }
function CDHome          { Set-Location -LiteralPath $HOME }
function CDLogs          { Set-LocationFromEnv ETHER 'logs' }
function CDPrimer        { Set-LocationFromEnv REPOS_WORK 'PRIMER' }
function CDPersonalRepos { Set-LocationFromEnv REPOS_PERSONAL }
function CDRepos         { Set-LocationFromEnv REPOS_WORK }
function CDTemp          { Set-LocationFromEnv TEMPDOCS }
function CDWorkspace     { Set-LocationFromEnv WORKSPACE }
function CDDotfiles      { Set-LocationFromEnv DOTFILES }

# Putting the aliases in alphabetical order so it's easy to spot which letters
# are available. Free: cdc cdf cdg cdi cdj cdk cdm cdn cdq cds cdu cdv cdx cdy cdz
Set-Alias -Name cdb   -Value CDBedrock
Set-Alias -Name cdd   -Value CDDocuments
Set-Alias -Name cddf  -Value CDDotfiles
Set-Alias -Name cde   -Value CDEther
Set-Alias -Name cdh   -Value CDHome
Set-Alias -Name cdl   -Value CDLogs
Set-Alias -Name cdp   -Value CDPrimer
Set-Alias -Name cdpr  -Value CDPersonalRepos
Set-Alias -Name cdr   -Value CDRepos
Set-Alias -Name cdt   -Value CDTemp
Set-Alias -Name cdw   -Value CDWorkspace

# --- Utils --------------------------------------------------------------------

# Everything in powershell\utils\ is available as a command, without being
# imported up front.
if ($env:DOTFILES) {
    $utils = Join-Path $env:DOTFILES 'powershell\utils'
    if ((Test-Path $utils) -and ($env:PATH -notlike "*$utils*")) {
        $env:PATH = "$utils;$env:PATH"
    }
}

# --- Third party --------------------------------------------------------------

# Chocolatey tab completion. Needs this import or `choco` completion won't work.
# See https://ch0.co/tab-completion
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path $ChocolateyProfile) {
    Import-Module $ChocolateyProfile
}

# --- Per-machine extras -------------------------------------------------------

# Optional, gitignored. For anything that genuinely only applies to this box.
$localProfile = Join-Path $PSScriptRoot 'profile.local.ps1'
if (Test-Path $localProfile) { . $localProfile }
