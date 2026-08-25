# komorebi

Config for [komorebi](https://github.com/LGUG2Z/komorebi), its bar, and the `whkd` hotkey
daemon.

| File | What it is |
|---|---|
| `komorebi.json` | Window manager config: Grid layout on all 10 workspaces, padding, border, theme |
| `komorebi.bar.json` | Status bar widgets |
| `whkdrc` | Hotkeys. `whkd` is the active hotkey daemon (komorebi is started with `--whkd`) |
| `toggle-reading-mode.ps1` | `alt + c` toggle, see below |

## How it's wired up

Two user-scope env vars point at *this folder*:

```powershell
$d = 'C:\Users\DaleEuinton\not_dropbox\personal_repos\dotfiles\komorebi'
[Environment]::SetEnvironmentVariable('KOMOREBI_CONFIG_HOME', $d, 'User')
[Environment]::SetEnvironmentVariable('WHKD_CONFIG_HOME',     $d, 'User')
```

`KOMOREBI_CONFIG_HOME` covers `komorebi.json` and `komorebi.bar.json`; `WHKD_CONFIG_HOME`
covers `whkdrc`. Both can be the same directory. Confirm with:

```
komorebic configuration
komorebic bar-configuration
komorebic whkdrc
```

Env vars are only visible to processes started *after* they were set, so restart komorebi
(`komorebic stop --whkd` then `komorebic start --whkd`) from a fresh shell after changing
them.

## Why `applications.json` is not in this repo

`komorebi.json` references it as `$Env:USERPROFILE/applications.json`, i.e. it lives at
`C:\Users\DaleEuinton\applications.json`, deliberately outside this repo.

It is the *application-specific configuration* — a ~62KB community-maintained catalogue of
per-app workarounds (which windows need force-managing, which have invisible borders, etc.)
shipped by the komorebi project and pulled down wholesale by `komorebic quickstart` /
`komorebic fetch-app-specific-configuration`. It's generated, not hand-edited, and it
churns on every upstream refresh. Committing it would bury the diffs of the files here
that actually get edited by hand.

If it goes missing, re-fetch it rather than looking for it in git history.

## Reading mode (`alt + c`)

`toggle-reading-mode.ps1` shrinks the focused workspace's tiling area to a centered column
(60% of the screen, gutters either side) and toggles it back off. Long terminal output — a
full-screen Claude Code session in particular — is much easier to read at ~1150px than at
1920px.

It works by flipping komorebi's per-workspace work area offset:

```
komorebic workspace-work-area-offset <monitor> <workspace> <pad> 0 <pad*2> 0
```

`right` must be `left * 2` — that is komorebi's convention for "keep the padding symmetric",
not a right-hand gap in its own right. Setting all four to `0` restores full width.

The one knob is `$Fraction` (default `0.6`) at the top of the script. The monitor width is
read from `komorebic state` at runtime, so it adapts to whatever display is attached.

Scope: per workspace, not per window count. It stays on for that workspace until toggled off,
and applies even if you open a second window (both then tile inside the narrow column).
`komorebic reload-configuration` clears it.
