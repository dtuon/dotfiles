# Setting up a new machine

Ordered by dependency, not by topic. Work top to bottom.

Things that can only be done by clicking are in [MANUAL.md](MANUAL.md).
Ideas not built yet are in [TODO.md](TODO.md).

## 1. Prerequisites, by hand

Chicken-and-egg: you need these before you can clone the repo that automates
the rest.

- [ ] Sign in to Windows, let Dropbox finish its first sync
- [ ] Install git: `winget install --id Git.Git`
- [ ] Install PowerShell 7: `winget install --id Microsoft.PowerShell`
      (everything here targets `pwsh`, not Windows PowerShell 5.1)
- [ ] Create `~\.ssh\` and a `config`, generate a key, add it to GitHub.
      The remote for this repo uses a host alias (`git@github-dtuon:...`), so
      `~\.ssh\config` needs the matching `Host github-dtuon` block. Example:

```
# in %HOME%\.ssh\config
Host github-dtuon
    HostName github.com
    User git
    IdentityFile ~/.ssh/github-dale-personal
    IdentitiesOnly yes
```

## 2. Clone and configure

In this most recent setup, I chose `bedrock` for things that are not cloud synced and `ether` a directory in Dropbox or MEGA.

- [ ] Create the code root and clone:
      ```powershell
      mkdir ~\bedrock\repos-dtuon
      git clone git@github-dtuon:dtuon/dotfiles.git ~\bedrock\repos-dtuon\dotfiles
      cd ~\bedrock\repos-dtuon\dotfiles
      ```
- [ ] Copy the per-machine config and edit the paths in it:
      ```powershell
      Copy-Item bootstrap\local.example.ps1 bootstrap\local.ps1
      notepad bootstrap\local.ps1
      ```
      This is the only file you edit. Everything else derives from it.

## 3. Wire up the paths

- [ ] Dry run, then apply:
      ```powershell
      .\bootstrap\1-env.ps1 -WhatIf
      .\bootstrap\1-env.ps1
      ```
- [ ] **Open a new terminal.** Env vars are only visible to processes started
      afterwards. Nothing below works until you do this.
- [ ] `.\bootstrap\check.ps1` — should pass the ENV section.

## 4. Install software

- [ ] Review what's about to be installed, and why:
      `.\bootstrap\2-packages.ps1 -List`
- [ ] Install: `.\bootstrap\2-packages.ps1`
      (add `-Group core,dev` to skip the work toolchain on a personal machine)
- [ ] Re-run it if anything failed; already-installed packages are skipped.

## 5. Shell

- [ ] `.\bootstrap\3-profile.ps1`
- [ ] Open a new shell, check an alias works: `cddf` should land you in this repo.

## 6. Windows settings

- [ ] `.\bootstrap\4-windows.ps1 -WhatIf` then without `-WhatIf`
- [ ] Restart Explorer so its settings apply:
      `Stop-Process -Name explorer -Force`

## 7. Per-tool setup

- [ ] **neovim** — first `nvim` launch bootstraps lazy.nvim and installs plugins
      from `nvim/lazy-lock.json`. Then `:checkhealth`.
- [ ] **komorebi** — fetch the app catalogue (generated, deliberately not
      versioned — see `komorebi/README.md`):
      ```powershell
      komorebic fetch-app-specific-configuration
      Move-Item ~\applications.json $env:KOMOREBI_CONFIG_HOME\applications.json -Force
      ```
      Then start it: `komorebic start --whkd`
- [ ] **AutoHotkey** — copy the hotkey scripts into the Startup folder:
      ```powershell
      cd $env:DOTFILES\autohotkeys; .\copy_all_ahk_to_startup_folder.ps1
      ```
- [ ] **gh** — `gh auth login`. Writes `gh/hosts.yml`, which is gitignored.
- [ ] **Copilot / Claude Code** — sign in. Auth state is gitignored.

## 8. Verify

- [ ] `.\bootstrap\check.ps1` — both sections should pass
- [ ] Work through [MANUAL.md](MANUAL.md)
