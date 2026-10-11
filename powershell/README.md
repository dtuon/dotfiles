# powershell

| File | What it is |
|---|---|
| `profile.ps1` | The real profile. Versioned here, loaded via a stub. |
| `profile.local.ps1` | Optional, gitignored. Per-machine additions. |
| `utils/` | Standalone scripts, put on `PATH` by the profile. |

## How it's loaded

`$PROFILE` lives in a machine-specific location — on this machine, inside
Dropbox — so the real profile isn't kept there. `bootstrap\3-profile.ps1`
installs a stub at `$PROFILE.CurrentUserAllHosts` that dot-sources this folder's
`profile.ps1` via `$env:DOTFILES`. The stub never needs to change; edit
`profile.ps1` here.

Any pre-existing profile is backed up to `*.pre-dotfiles.bak` first.

## Navigation aliases

`profile.ps1` defines one `CD*` function per destination, each resolving an env
var at call time rather than at load time — so setting a var and opening a new
shell is enough, and an unset var produces a warning instead of a broken `cd`.

| Alias | Goes to | Via |
|---|---|---|
| `cdb` | code root | `BEDROCK` |
| `cdd` | Documents | `DOCS` |
| `cddf` | this repo | `DOTFILES` |
| `cde` | ether | `ETHER` |
| `cdh` | home | `$HOME` |
| `cdl` | logs | `ETHER\logs` |
| `cdp` | PRIMER | `REPOS_WORK\PRIMER` |
| `cdpr` | personal repos | `REPOS_PERSONAL` |
| `cdr` | work repos | `REPOS_WORK` |
| `cdt` | scratch notes | `TEMPDOCS` |
| `cdw` | workspace | `WORKSPACE` |

Kept in alphabetical order so it's easy to spot free letters. Unused as of
writing: `cdc cdf cdg cdi cdj cdk cdm cdn cdq cds cdu cdv cdx cdy cdz`.

## utils/

`profile.ps1` prepends `utils/` to `PATH`, so each script is callable by name
from anywhere without being imported.

| Script | What it does |
|---|---|
| `Hide-DotItems.ps1` | Sets the Hidden attribute on dot-prefixed items (and any `-Name` extras) in a directory. Idempotent, `-WhatIf`, and `-Unhide` to reverse. Run by `bootstrap\4-windows.ps1`. |

Hiding only has a visible effect if Explorer's "show hidden files" is off, which
`bootstrap\4-windows.ps1` sets.
