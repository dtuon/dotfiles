<#
.SYNOPSIS
    Verify this machine is wired up, and that the repo contains no machine-specific paths.
.DESCRIPTION
    Two independent checks:

    1. ENV   -- every env var in Get-EnvMap is set, matches what local.ps1 implies,
                and (where it is a path that must pre-exist) actually resolves.

    2. LINT  -- no tracked file in the repo contains an absolute Windows path or
                this machine's user name. This is the check that keeps the repo
                portable over time: it turns "remember not to hardcode paths"
                into something you can run.

    Exits non-zero if anything fails, so it works in a pre-commit hook or CI.
.PARAMETER LintOnly
    Skip the env checks. Useful in a hook, where the machine is already set up.
.EXAMPLE
    .\check.ps1
.EXAMPLE
    .\check.ps1 -LintOnly
#>
[CmdletBinding()]
param(
    [switch] $LintOnly
)

Set-StrictMode -Version Latest
. "$PSScriptRoot\lib.ps1"

$root     = Get-DotfilesRoot
$problems = [System.Collections.Generic.List[string]]::new()

function Write-Result {
    param([bool] $Ok, [string] $Message, [string] $Detail)
    if ($Ok) {
        Write-Host "  PASS  " -ForegroundColor Green -NoNewline
        Write-Host $Message
    } else {
        Write-Host "  FAIL  " -ForegroundColor Red -NoNewline
        Write-Host $Message
        if ($Detail) { Write-Host "        $Detail" -ForegroundColor DarkGray }
    }
}

# ---------------------------------------------------------------- 1. env vars
if (-not $LintOnly) {
    Write-Host "`nENV -- user env vars vs bootstrap\local.ps1" -ForegroundColor Cyan

    try {
        $envMap   = Get-EnvMap
        $mustExist = Get-MustExistKeys

        foreach ($name in $envMap.Keys) {
            $want = $envMap[$name]
            $have = [Environment]::GetEnvironmentVariable($name, 'User')

            if ([string]::IsNullOrEmpty($have)) {
                Write-Result $false "$name is not set" "expected: $want  --  run bootstrap\1-env.ps1"
                $problems.Add("env:$name unset")
                continue
            }
            if ($have.TrimEnd('\','/') -ne $want.TrimEnd('\','/')) {
                Write-Result $false "$name does not match local.ps1" "stored:   $have`n        expected: $want"
                $problems.Add("env:$name stale")
                continue
            }
            if ($mustExist -contains $name -and -not (Test-Path -LiteralPath $have)) {
                Write-Result $false "$name points at a missing path" $have
                $problems.Add("env:$name missing path")
                continue
            }
            Write-Result $true "$name"
        }
    }
    catch {
        Write-Result $false "could not load per-machine config" $_.Exception.Message
        $problems.Add('local.ps1')
    }
}

# --------------------------------------------------------------- 2. path lint
Write-Host "`nLINT -- tracked files must not contain machine-specific paths" -ForegroundColor Cyan

# Absolute drive-letter paths, and this machine's user name. Both are things that
# should have come from an env var instead.
#
# \x5C is a literal backslash, written as a hex escape: an escaped backslash
# inside the character class is easy to lose when editing, and losing it makes
# the pattern silently match forward-slash paths only.
$patterns = @(
    @{ Name = 'absolute path'; Regex = '[A-Za-z]:[\x5C/](?:Users|Program Files)' }
    @{ Name = 'user name';     Regex = [regex]::Escape($env:USERNAME) }
)

# Generated or credential files are gitignored, so git ls-files already excludes
# them. README prose is linted too: stale example paths are how this rots.
Push-Location $root
try {
    $tracked = @(git ls-files 2>$null)
}
finally {
    Pop-Location
}

if (-not $tracked) {
    Write-Result $false 'could not list tracked files' 'is this a git repo?'
    $problems.Add('git ls-files')
}

$hits = [System.Collections.Generic.List[string]]::new()
foreach ($rel in $tracked) {
    $full = Join-Path $root $rel
    if (-not (Test-Path -LiteralPath $full)) { continue }

    # Skip binaries and lockfiles.
    if ($rel -match '\.(db|db-shm|db-wal|png|jpg|ico|ttf|otf)$') { continue }
    if ($rel -eq 'nvim/lazy-lock.json') { continue }

    # The example per-machine config must contain example paths; that is its job.
    if ($rel -eq 'bootstrap/local.example.ps1') { continue }

    # @() so a single-line file is still an array under strict mode.
    $lines = @(Get-Content -LiteralPath $full -ErrorAction SilentlyContinue)
    for ($i = 0; $i -lt $lines.Count; $i++) {
        foreach ($p in $patterns) {
            if ($lines[$i] -match $p.Regex) {
                $hits.Add("$rel`:$($i + 1)  [$($p.Name)]  $($lines[$i].Trim())")
                break
            }
        }
    }
}

if ($hits.Count -eq 0) {
    Write-Result $true "$($tracked.Count) tracked files, no hardcoded paths"
} else {
    Write-Result $false "$($hits.Count) hardcoded path(s) found"
    $hits | ForEach-Object { Write-Host "        $_" -ForegroundColor Yellow }
    Write-Host "`n        Replace with an env var from Get-EnvMap (bootstrap\lib.ps1)." -ForegroundColor DarkGray
    Write-Host "        If a literal path is genuinely correct, add an exclusion above.`n" -ForegroundColor DarkGray
    $problems.Add("lint:$($hits.Count)")
}

# ------------------------------------------------------------------- summary
if ($problems.Count -eq 0) {
    Write-Host "`nAll checks passed.`n" -ForegroundColor Green
    exit 0
}

Write-Host "`n$($problems.Count) problem(s): $($problems -join ', ')`n" -ForegroundColor Red
exit 1
