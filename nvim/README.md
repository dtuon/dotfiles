# nvim

Neovim config. Read from this folder because `XDG_CONFIG_HOME` points at the repo root —
see the root README.

| File | What it is |
|---|---|
| `init.lua` | lazy.nvim bootstrap, then `options` → `notes` → plugin specs |
| `lua/options.lua` | Editor options and `mapleader` |
| `lua/notes.lua` | Scratch/notes helpers, see below |
| `lua/plugins/` | One file per plugin, loaded by `lazy.setup("plugins")` |
| `lazy-lock.json` | Plugin lockfile, committed |

Plugin and state data stay outside the repo in `%LOCALAPPDATA%\nvim-data`.

## TEMPDOCS

`lua/notes.lua` writes scratch notes to the folder named by the `TEMPDOCS` user env var:

```powershell
[Environment]::SetEnvironmentVariable('TEMPDOCS', '<path to notes folder>', 'User')
```

It is deliberately *not* in this repo — the notes are per-machine working scratch, synced
by Dropbox rather than versioned here. The current value points into
`PRIMER-e Dropbox\...\workspace\temp`.

If the var is unset, notes fall back to `%LOCALAPPDATA%\nvim-data\tempdocs`, so nothing
breaks on a fresh machine — notes just land somewhere unsynced until it's set. Nothing
else in this repo reads the variable.

A trailing `\` on the value is tolerated (paths become `...temp\/note.md`, which Windows
accepts) but better left off.

Env vars are only visible to processes started afterwards, so restart terminals and editors
after setting it.

### What it gives you

| | |
|---|---|
| `:Tmp [name]` | Open/create a file in the notes folder, defaults to `scratch.md`. Capitalised because Neovim rejects lowercase user command names. |
| `<leader>nd` | Open today's note, `YYYY-MM-DD.md`. Idempotent — same file all day. |
| `<leader>ns` | `saveas` the current buffer to a timestamped `note-YYYYMMDD-HHMMSS.md`. Note this *renames the current buffer*. |

`<leader>nd` and `<leader>ns` use different filename shapes, so `nd` never reopens an `ns`
note; those are reachable via `:Tmp` completion.
