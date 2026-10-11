# Shared helpers for the bootstrap scripts. Dot-source, don't run.
#
#   . "$PSScriptRoot\lib.ps1"

Set-StrictMode -Version Latest

# Repo root, derived from this file's location. Never configured per machine.
$script:DotfilesRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

function Get-DotfilesRoot { $script:DotfilesRoot }

# Set a user-scope env var, and mirror it into the current session so the rest of
# the bootstrap run can use it without a restart. Idempotent: a no-op if the
# stored value already matches.
function Set-UserEnv {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string] $Name,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Value
    )

    $current = [Environment]::GetEnvironmentVariable($Name, 'User')
    if ($current -eq $Value) {
        Write-Host "  = $Name" -ForegroundColor DarkGray
        Set-Item -Path "Env:$Name" -Value $Value
        return
    }

    if ($PSCmdlet.ShouldProcess($Name, "set user env var to '$Value'")) {
        [Environment]::SetEnvironmentVariable($Name, $Value, 'User')
        Set-Item -Path "Env:$Name" -Value $Value
        $verb = if ([string]::IsNullOrEmpty($current)) { '+' } else { '~' }
        Write-Host "  $verb $Name -> $Value" -ForegroundColor Green
    }
}

# Load bootstrap/local.ps1 and return its settings as a hashtable.
# This is the ONLY place per-machine paths enter the repo.
function Get-LocalConfig {
    [CmdletBinding()]
    param()

    $local   = Join-Path $PSScriptRoot 'local.ps1'
    $example = Join-Path $PSScriptRoot 'local.example.ps1'

    if (-not (Test-Path $local)) {
        throw @"
No per-machine config found at:
  $local

Create it by copying the example and editing the two paths at the top:
  Copy-Item '$example' '$local'
  nvim '$local'
"@
    }

    $cfg = & $local
    if ($cfg -isnot [hashtable]) {
        throw "bootstrap/local.ps1 must return a hashtable (see local.example.ps1)."
    }

    foreach ($required in 'DropboxRoot', 'Bedrock') {
        if (-not $cfg.ContainsKey($required) -or [string]::IsNullOrWhiteSpace($cfg[$required])) {
            throw "bootstrap/local.ps1 is missing required key '$required'."
        }
    }

    $cfg
}

# Resolve the full env-var map for this machine: every path the configs read.
# Pure function of local.ps1 + the repo location, so it is the single source of
# truth for both `1-env.ps1` (which writes them) and `check.ps1` (which verifies).
function Get-EnvMap {
    [CmdletBinding()]
    param([hashtable] $Config = (Get-LocalConfig))

    $root    = Get-DotfilesRoot
    $dropbox = $Config.DropboxRoot.TrimEnd('\', '/')
    $bedrock = $Config.Bedrock.TrimEnd('\', '/')

    # ContainsKey, not property access: strict mode throws on a missing key.
    $reposPersonal = if ($Config.ContainsKey('ReposPersonal') -and $Config.ReposPersonal) {
        $Config.ReposPersonal
    } else { Join-Path $bedrock 'repos-dtuon' }

    $reposWork = if ($Config.ContainsKey('ReposWork') -and $Config.ReposWork) {
        $Config.ReposWork
    } else { Join-Path $bedrock 'repos-dale-primer-e' }

    $workspace = Join-Path $dropbox 'Desktop\workspace'

    [ordered]@{
        # --- Names chosen by the tools. Do not rename. ---
        XDG_CONFIG_HOME      = $root
        KOMOREBI_CONFIG_HOME = Join-Path $root 'komorebi'
        WHKD_CONFIG_HOME     = Join-Path $root 'komorebi'

        # --- Names chosen here. Read by profile.ps1, notes.lua, the .ahk file. ---
        DOTFILES       = $root
        DROPBOX_ROOT   = $dropbox
        BEDROCK        = $bedrock
        REPOS_PERSONAL = $reposPersonal
        REPOS_WORK     = $reposWork
        DOCS           = Join-Path $dropbox 'Documents'
        ETHER          = Join-Path $dropbox 'ether'
        WORKSPACE      = $workspace
        TEMPDOCS       = Join-Path $workspace 'temp'
    }
}

# Env vars whose value is a path that must already exist for things to work.
# WORKSPACE/TEMPDOCS are excluded: notes.lua creates TEMPDOCS on demand.
$script:MustExist = @(
    'XDG_CONFIG_HOME', 'KOMOREBI_CONFIG_HOME', 'WHKD_CONFIG_HOME',
    'DOTFILES', 'DROPBOX_ROOT', 'BEDROCK', 'DOCS'
)
function Get-MustExistKeys { $script:MustExist }
