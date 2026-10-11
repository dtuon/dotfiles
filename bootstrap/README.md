# bootstrap

Scripts that take a fresh Windows machine to a working one. Run them in number
order; every one is idempotent and supports `-WhatIf`, so an interrupted pass
can just be re-run.

| File | What it does |
|---|---|
| `local.example.ps1` | Template for the per-machine paths. Copy to `local.ps1`. |
| `local.ps1` | **The only file you edit per machine.** Gitignored. |
| `lib.ps1` | Shared helpers. Dot-sourced by the others, not run directly. |
| `1-env.ps1` | Writes every path as a user-scope env var. Run this first. |
| `2-packages.ps1` | `winget install` the package manifest. |
| `3-profile.ps1` | Installs a stub at `$PROFILE` pointing at `powershell\profile.ps1`. |
| `4-windows.ps1` | Explorer settings, hides dotted items in the home directory. |
| `check.ps1` | Verifies the wiring, and lints the repo for hardcoded paths. |

## How paths stay machine-independent

Nothing in this repo contains an absolute path. Instead:

1. `local.ps1` states the two or three paths that genuinely differ per machine.
2. `lib.ps1`'s `Get-EnvMap` derives every other path from those plus the repo's
   own location (which is auto-detected from `$PSScriptRoot`, never configured).
3. `1-env.ps1` writes that map to user-scope env vars.
4. Every config reads the env vars — PowerShell via `$env:X`, Lua via
   `vim.env.X`, komorebi/whkd via `$Env:X`, AutoHotkey via `EnvGet("X")`.

Env vars are the one config mechanism all of those tools share, which is why
they're the interface rather than, say, a shared JSON file.

### Adding a new path

Add it to `Get-EnvMap` in `lib.ps1`, not to the config that needs it. If it has
to differ per machine, add a key to `local.example.ps1` and derive it. Then
re-run `1-env.ps1`.

### The env vars

Set by `1-env.ps1`. The first three have names chosen by the tools that read
them; the rest are ours.

| Var | Points at |
|---|---|
| `XDG_CONFIG_HOME` | repo root (so neovim finds `nvim/`) |
| `KOMOREBI_CONFIG_HOME` | `komorebi/` |
| `WHKD_CONFIG_HOME` | `komorebi/` |
| `DOTFILES` | repo root |
| `DROPBOX_ROOT` | the Dropbox folder holding `Documents\`, `Desktop\`, `ether\` |
| `BEDROCK` | code root |
| `REPOS_PERSONAL` | `$BEDROCK\repos-dtuon` |
| `REPOS_WORK` | `$BEDROCK\repos-dale-primer-e` |
| `DOCS` | `$DROPBOX_ROOT\Documents` |
| `ETHER` | `$DROPBOX_ROOT\ether` |
| `WORKSPACE` | `$DROPBOX_ROOT\Desktop\workspace` |
| `TEMPDOCS` | `$WORKSPACE\temp` — scratch notes, read by `nvim/lua/notes.lua` |

Two rules worth keeping:

- **Fall back, never break.** A consumer should degrade when its var is unset,
  the way `notes.lua` falls back to nvim's data dir. A half-set-up machine
  should lose one feature, not refuse to start a shell.
- **Paths only.** Machine *preferences* — reading-mode width, which apps float —
  belong in the tool's own config, not here.

## Keeping it portable

`check.ps1` greps every tracked file for drive-letter paths and this machine's
user name, and exits non-zero on a hit. That's what stops the repo drifting back
to hardcoded paths. To run it on every commit:

```powershell
$hook = "$env:DOTFILES\.git\hooks\pre-commit"
@'
#!/bin/sh
pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/bootstrap/check.ps1" -LintOnly || exit 1
'@ | Set-Content $hook -Encoding utf8NoBOM
```
