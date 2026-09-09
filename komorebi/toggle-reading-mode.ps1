<#
  Toggle "reading mode" on the focused komorebi workspace: shrink the tiling
  area to a centered column so a single window's text is easier to read, and
  switch the layout to Rows (the narrow column is effectively a vertical
  monitor). Toggling back restores the previous layout.
  Toggle is per-workspace and persists until toggled off (or komorebi restarts).
  Bound to alt + c in whkdrc.
#>
[CmdletBinding()]
param(
    # Fraction of the work area the centered column should occupy.
    [ValidateRange(0.2, 1.0)]
    [double]$Fraction = 0.6,

    # Layout to use while reading mode is on.
    [string]$ReadingLayout = 'rows',

    # Layout to fall back to if no previous layout was recorded.
    [string]$FallbackLayout = 'grid'
)

# Where the pre-reading-mode layout of each workspace is remembered. Runtime
# state, not config, so it lives outside this repo.
$StorePath = Join-Path $Env:LOCALAPPDATA 'komorebi\reading-mode-layouts.json'

function Get-Store {
    if (Test-Path $StorePath) {
        try { return (Get-Content -Raw $StorePath | ConvertFrom-Json) } catch { }
    }
    return [pscustomobject]@{}
}

function Set-Store($store) {
    $dir = Split-Path $StorePath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $store | ConvertTo-Json -Depth 5 | Set-Content -Encoding utf8 $StorePath
}

# komorebic layout names are kebab-case; state reports them PascalCase.
function ConvertTo-LayoutName($pascal) {
    ($pascal -creplace '(?<!^)([A-Z])', '-$1').ToLower()
}

$state = komorebic state | ConvertFrom-Json

$mIdx = $state.monitors.focused
$mon  = $state.monitors.elements[$mIdx]
$wIdx = $mon.workspaces.focused
$ws   = $mon.workspaces.elements[$wIdx]

$key    = "$mIdx/$wIdx"
$store  = Get-Store
$offset = $ws.work_area_offset
$isOn   = $null -ne $offset -and $offset.left -gt 0

if ($isOn) {
    komorebic workspace-work-area-offset $mIdx $wIdx 0 0 0 0

    $previous = $store.$key
    if (-not $previous) { $previous = $FallbackLayout }
    komorebic change-layout $previous

    $store.PSObject.Properties.Remove($key)
    Set-Store $store
}
else {
    # Remember the current layout so toggling off can restore it. Custom
    # layouts aren't nameable on the CLI, so they fall back on restore.
    if ($ws.layout.Default) {
        $store | Add-Member -NotePropertyName $key `
                            -NotePropertyValue (ConvertTo-LayoutName $ws.layout.Default) -Force
        Set-Store $store
    }

    # komorebi Rect uses right/bottom as width/height.
    $width = $mon.work_area_size.right
    $pad   = [int][math]::Round($width * (1 - $Fraction) / 2)
    komorebic workspace-work-area-offset $mIdx $wIdx $pad 0 ($pad * 2) 0

    komorebic change-layout $ReadingLayout
}
