# dotfiles

Personal config, one subfolder per tool. Tools are pointed here via env vars rather than
symlinks, so nothing needs admin rights or a git repo sitting in `$USERPROFILE`.

| Folder | Tool | Wired up by |
|---|---|---|
| `komorebi/` | komorebi + komorebi-bar + whkd | `KOMOREBI_CONFIG_HOME`, `WHKD_CONFIG_HOME` |
| `nvim/` | neovim | `XDG_CONFIG_HOME` |

Add future tools (wezterm, git, ...) as sibling folders.

## XDG_CONFIG_HOME

`XDG_CONFIG_HOME` points at this repo root, so neovim reads `nvim/`. Plugin and state
data stay outside the repo in `%LOCALAPPDATA%\nvim-data`.

The variable is not nvim-specific: any XDG-aware tool will look for its config in
`<repo>\<toolname>`. That is intentional here, but it means a newly installed tool may
silently relocate its config into this repo (and write state files worth gitignoring).

Set on a new machine with:

    [Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', '<path to this repo>', 'User')

Only processes started afterwards see it, so restart terminals and editors.
