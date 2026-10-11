# dotfiles

Personal config and new-machine setup. One subfolder per tool. Tools are pointed
here via env vars rather than symlinks, so nothing needs admin rights or a git
repo sitting in `$USERPROFILE`.

**Setting up a new machine? Start at [SETUP.md](SETUP.md).**

| Folder | Tool | Wired up by |
|---|---|---|
| `bootstrap/` | the setup scripts themselves | run in number order |
| `powershell/` | pwsh profile + standalone utils | stub at `$PROFILE` reading `DOTFILES` |
| `nvim/` | neovim | `XDG_CONFIG_HOME` |
| `komorebi/` | komorebi + komorebi-bar + whkd | `KOMOREBI_CONFIG_HOME`, `WHKD_CONFIG_HOME` |
| `autohotkeys/` | AutoHotkey v2 | copied into the Startup folder |
| `lazygit/` | lazygit | default location via `XDG_CONFIG_HOME` |
| `gh/` | GitHub CLI | default location |
| `github-copilot/` | Copilot | default location |

Add future tools as sibling folders.

| Doc | What's in it |
|---|---|
| [SETUP.md](SETUP.md) | Ordered new-machine checklist |
| [MANUAL.md](MANUAL.md) | Steps that can't be scripted |
| [TODO.md](TODO.md) | Ideas not built yet |
| [bootstrap/README.md](bootstrap/README.md) | How the env-var scheme works |

## No absolute paths

Every path in this repo comes from an env var, so the same commit works on a
machine with a different Windows user name, or where Dropbox sits
somewhere else. Per-machine values live in one gitignored file,
`bootstrap/local.ps1`; everything else is derived from it.

`bootstrap/check.ps1` enforces this — it fails if any tracked file contains a
drive-letter path. Full explanation, and the list of env vars, in
[bootstrap/README.md](bootstrap/README.md).

```powershell
.\bootstrap\check.ps1   # verify this machine, and lint the repo
```

## Not in this repo

- **Secrets.** `gh/hosts.yml` and `github-copilot/auth.db*` are gitignored. Sign
  in with `gh auth login` on a new machine rather than copying them.
- **Generated config.** `komorebi/applications.json` is a large, churning,
  upstream-maintained catalogue — re-fetch it, see `komorebi/README.md`.
- **Plugin and runtime state.** Neovim's lives in `%LOCALAPPDATA%\nvim-data`,
  komorebi's reading-mode state in `%LOCALAPPDATA%\komorebi`.
- **Scratch notes.** `TEMPDOCS` names a per-machine notes folder, synced by
  Dropbox rather than versioned here. See `nvim/README.md`.
