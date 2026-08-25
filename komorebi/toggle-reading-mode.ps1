<#
  Toggle "reading mode" on the focused komorebi workspace: shrink the tiling
  area to a centered column so a single window's text is easier to read.
  Toggle is per-workspace and persists until toggled off (or komorebi restarts).
  Bound to alt + c in whkdrc.
#>
[CmdletBinding()]
param(
    # Fraction of the work area the centered column should occupy.
    [ValidateRange(0.2, 1.0)]
    [double]$Fraction = 0.6
)

$state = komorebic state | ConvertFrom-Json

$mIdx = $state.monitors.focused
$mon  = $state.monitors.elements[$mIdx]
$wIdx = $mon.workspaces.focused
$ws   = $mon.workspaces.elements[$wIdx]

$offset = $ws.work_area_offset
$isOn   = $null -ne $offset -and $offset.left -gt 0

if ($isOn) {
    komorebic workspace-work-area-offset $mIdx $wIdx 0 0 0 0
}
else {
    # komorebi Rect uses right/bottom as width/height.
    $width = $mon.work_area_size.right
    $pad   = [int][math]::Round($width * (1 - $Fraction) / 2)
    komorebic workspace-work-area-offset $mIdx $wIdx $pad 0 ($pad * 2) 0
}
