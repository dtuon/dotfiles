<#
.SYNOPSIS
    Hide dot-prefixed files and folders, plus any named extras.
.DESCRIPTION
    Tools scatter .gitconfig, .ssh, .cache, .vscode and friends through the home
    directory, where Explorer shows them all. This sets the Hidden attribute on
    anything starting with a dot, and on any additional names passed in.

    Idempotent: items already hidden are left alone, so this is safe to run from
    bootstrap on every pass. Supports -WhatIf.

    Note this only affects Explorer if "show hidden files" is off --
    bootstrap\4-windows.ps1 sets that.
.PARAMETER Path
    Directory to tidy. Defaults to the home directory.
.PARAMETER Name
    Extra items to hide that aren't dot-prefixed, e.g. 'bedrock', 'source'.
    Accepts wildcards.
.PARAMETER Unhide
    Reverse: clear the Hidden attribute instead of setting it.
.EXAMPLE
    Hide-DotItems.ps1 -WhatIf
.EXAMPLE
    Hide-DotItems.ps1 -Name 'source','IntelGraphicsProfiles'
.EXAMPLE
    Hide-DotItems.ps1 -Name '.ssh' -Unhide
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]   $Path = $HOME,
    [string[]] $Name = @(),
    [switch]   $Unhide
)

Set-StrictMode -Version Latest

if (-not (Test-Path -LiteralPath $Path)) {
    throw "No such directory: $Path"
}

# -Force so we can see items that are already hidden and skip them.
$items = @(Get-ChildItem -LiteralPath $Path -Filter '.*' -Force)

foreach ($pattern in $Name) {
    $items += @(Get-ChildItem -LiteralPath $Path -Filter $pattern -Force)
}

$items = $items | Sort-Object FullName -Unique
$verb  = if ($Unhide) { 'unhide' } else { 'hide' }
$count = 0

foreach ($item in $items) {
    $isHidden = $item.Attributes.HasFlag([IO.FileAttributes]::Hidden)

    # Already in the desired state.
    if ($isHidden -ne $Unhide.IsPresent) {
        Write-Verbose "already $(if ($isHidden) { 'hidden' } else { 'visible' }): $($item.Name)"
        continue
    }

    if ($PSCmdlet.ShouldProcess($item.FullName, $verb)) {
        try {
            $item.Attributes = if ($Unhide) {
                $item.Attributes -band (-bnot [IO.FileAttributes]::Hidden)
            } else {
                $item.Attributes -bor [IO.FileAttributes]::Hidden
            }
            Write-Host "  $verb $($item.Name)" -ForegroundColor Green
            $count++
        }
        catch {
            Write-Warning "could not $verb $($item.Name): $($_.Exception.Message)"
        }
    }
}

if ($count -eq 0 -and -not $WhatIfPreference) {
    Write-Host "  = nothing to $verb in $Path" -ForegroundColor DarkGray
}
