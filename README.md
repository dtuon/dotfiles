# dotfiles

Personal config, one subfolder per tool. Tools are pointed here via env vars rather than
symlinks, so nothing needs admin rights or a git repo sitting in `$USERPROFILE`.

| Folder | Tool | Wired up by |
|---|---|---|
| `komorebi/` | komorebi + komorebi-bar + whkd | `KOMOREBI_CONFIG_HOME`, `WHKD_CONFIG_HOME` |

Add future tools (nvim, wezterm, git, ...) as sibling folders.
