<#
.SYNOPSIS
    Install packages via winget, grouped by purpose.
.DESCRIPTION
    The list below is the set actually installed on this machine, with a reason
    per entry so future-you can tell what is still load-bearing. Install order
    within a group does not matter.

    Idempotent: winget skips anything already present. Safe to re-run after an
    interrupted pass.
.PARAMETER Group
    Install only these groups. Default: all except 'optional'.
.PARAMETER List
    Print the manifest and exit without installing.
.EXAMPLE
    .\2-packages.ps1 -List
.EXAMPLE
    .\2-packages.ps1 -Group core,dev
.EXAMPLE
    .\2-packages.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet('core', 'dev', 'windowing', 'work', 'optional')]
    [string[]] $Group = @('core', 'dev', 'windowing', 'work'),

    [switch] $List
)

Set-StrictMode -Version Latest

$packages = @(
    # --- core: shell, browser, files. Want these on any machine. ---
    @{ Group = 'core'; Id = 'Microsoft.PowerShell';    Name = 'PowerShell 7';   Why = 'pwsh. The profile and every script here target 7, not 5.1.' }
    @{ Group = 'core'; Id = 'Mozilla.Firefox';         Name = 'Firefox';        Why = 'Primary browser.' }
    @{ Group = 'core'; Id = '7zip.7zip';               Name = '7-Zip';          Why = 'Archives.' }
    @{ Group = 'core'; Id = 'Greenshot.Greenshot';     Name = 'Greenshot';      Why = 'Screenshots.' }
    @{ Group = 'core'; Id = 'Spotify.Spotify';         Name = 'Spotify';        Why = 'Music. Floated in komorebi.json.' }
    @{ Group = 'core'; Id = 'Twingate.Client';         Name = 'Twingate';       Why = 'VPN. Needed to reach internal resources.' }

    # --- dev: editor, VCS, toolchain. ---
    @{ Group = 'dev'; Id = 'Git.Git';                      Name = 'Git';             Why = 'Required before cloning this repo, so in practice installed by hand first.' }
    @{ Group = 'dev'; Id = 'GitHub.cli';                   Name = 'GitHub CLI';      Why = 'gh. Auth + PRs. Config in gh/.' }
    @{ Group = 'dev'; Id = 'JesseDuffield.lazygit';        Name = 'lazygit';         Why = 'Git TUI. Config in lazygit/.' }
    @{ Group = 'dev'; Id = 'jj-vcs.jj';                    Name = 'jujutsu';         Why = 'Alternative VCS, used on some personal repos.' }
    @{ Group = 'dev'; Id = 'Neovim.Neovim';                Name = 'Neovim';          Why = 'Editor. Config in nvim/ via XDG_CONFIG_HOME.' }
    @{ Group = 'dev'; Id = 'Microsoft.VisualStudioCode';   Name = 'VS Code';         Why = 'Secondary editor, and what some tools shell out to.' }
    @{ Group = 'dev'; Id = 'Anthropic.ClaudeCode';         Name = 'Claude Code';     Why = 'CLI agent. Uses $env:VISUAL = nvim, set in the profile.' }
    @{ Group = 'dev'; Id = 'tree-sitter.tree-sitter-cli';  Name = 'tree-sitter CLI'; Why = 'Needed by nvim-treesitter to build grammars from source.' }
    @{ Group = 'dev'; Id = 'BrechtSanders.WinLibs.POSIX.UCRT'; Name = 'WinLibs GCC'; Why = 'A C compiler on PATH. Also required by nvim-treesitter.' }
    @{ Group = 'dev'; Id = 'JohnMacFarlane.Pandoc';        Name = 'Pandoc';          Why = 'Document conversion, mostly markdown -> docx/pdf.' }

    # --- windowing: the tiling setup. Config in komorebi/ and autohotkeys/. ---
    @{ Group = 'windowing'; Id = 'LGUG2Z.komorebi';        Name = 'komorebi';   Why = 'Tiling WM. Reads KOMOREBI_CONFIG_HOME.' }
    @{ Group = 'windowing'; Id = 'LGUG2Z.whkd';            Name = 'whkd';       Why = 'Hotkey daemon for komorebi. Reads WHKD_CONFIG_HOME.' }
    @{ Group = 'windowing'; Id = 'AutoHotkey.AutoHotkey';  Name = 'AutoHotkey'; Why = 'Capslock->Esc and the non-komorebi hotkeys. See autohotkeys/.' }

    # --- work: PRIMER / Primer-e build + release toolchain. ---
    @{ Group = 'work'; Id = 'Microsoft.VisualStudio.Community'; Name = 'Visual Studio'; Why = 'C# development. See MANUAL.md for the keybinding setup.' }
    @{ Group = 'work'; Id = 'Microsoft.SqlPackage';             Name = 'SqlPackage';    Why = 'DACPAC deploy/extract for the licence tracker DB.' }
    @{ Group = 'work'; Id = 'WiXToolset.WiXToolset';            Name = 'WiX Toolset';   Why = 'Builds the PRIMER MSI installer.' }
    @{ Group = 'work'; Id = 'Microsoft.NuGet';                  Name = 'NuGet CLI';     Why = 'Package restore outside of VS/dotnet.' }

    # --- optional: install on demand, not part of a standard setup. ---
    @{ Group = 'optional'; Id = 'PowerSoftware.AnyBurn'; Name = 'AnyBurn'; Why = 'ISO/disc images. Only needed when building the virtual lab.' }
)

if ($List) {
    $packages |
        ForEach-Object { [pscustomobject]$_ } |
        Sort-Object Group, Name |
        Format-Table Group, Name, Id, Why -Wrap -AutoSize
    return
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget not found. Install 'App Installer' from the Microsoft Store first."
}

$selected = $packages | Where-Object { $Group -contains $_.Group }
Write-Host "`nInstalling $($selected.Count) package(s) from group(s): $($Group -join ', ')`n" -ForegroundColor Cyan

$failed = @()
foreach ($pkg in $selected) {
    if (-not $PSCmdlet.ShouldProcess($pkg.Name, "winget install $($pkg.Id)")) { continue }

    Write-Host "-> $($pkg.Name) [$($pkg.Id)]" -ForegroundColor Yellow
    winget install --id $pkg.Id --exact --source winget `
        --accept-package-agreements --accept-source-agreements --silent

    # 0 = installed. -1978335189 = no applicable upgrade, i.e. already current.
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189) {
        Write-Host "   ok" -ForegroundColor Green
    } else {
        Write-Host "   FAILED (exit $LASTEXITCODE)" -ForegroundColor Red
        $failed += $pkg
    }
}

if ($failed) {
    Write-Host "`n$($failed.Count) package(s) failed:" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  $($_.Name) [$($_.Id)]" -ForegroundColor Red }
    Write-Host "Re-run to retry; already-installed packages are skipped.`n" -ForegroundColor DarkGray
} else {
    Write-Host "`nAll requested packages present." -ForegroundColor Cyan
}

Write-Host "Not available via winget -- see MANUAL.md: Accessibility Insights." -ForegroundColor DarkGray
