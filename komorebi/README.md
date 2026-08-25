# komorebi

Config for [komorebi](https://github.com/LGUG2Z/komorebi), its bar, and the `whkd` hotkey
daemon.

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
churns on every upstream refresh. Committing it would bury the diffs of the three files
here that actually get edited by hand.

If it goes missing, re-fetch it rather than looking for it in git history.

## Other stray komorebi files in `$USERPROFILE`

`~/komorebi.ahk` — the AutoHotkey hotkey script from komorebi's quickstart. Not in use:
`whkd` is the active hotkey daemon (see `whkdrc`), komorebi is started with `--whkd` rather
than `--ahk`, and the only running AutoHotkey process is an unrelated personal script,
`dales_hotkeys.ahk`, in the Startup folder. Left in place, unversioned.

Note: while the config home was `$USERPROFILE`, `komorebic check` reported "Found
komorebi.ahk; this file will be autoloaded by komorebi" — that only takes effect if komorebi
is started with the ahk flag, so it never was. Now that the config home has moved, the
message is gone.
