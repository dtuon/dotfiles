# TODO

Ideas not built yet. Kept out of [SETUP.md](SETUP.md) so that stays trustworthy
as a checklist — if it's listed there, it works.

## Repo hygiene

- [ ] The Copilot `auth.db*` files were committed to this **public** repo before
      being gitignored. They hold an `oauth_tokens` table with a
      `token_ciphertext` column — encrypted, not plaintext, but still present in
      git history. Decide whether to revoke the Copilot OAuth grant and scrub
      history (`git filter-repo`), or make the repo private.

## Shell

- [ ] Port the `Admin`, `DynamicParams`, `Fonts` and `NerdFonts` PowerShell
      modules into the repo, or record them in `2-packages.ps1` as
      `Install-Module` calls. They currently live only in the Dropbox
      `Documents\PowerShell\Modules` folder and would be lost on a new machine.
- [ ] Prompt customisation (oh-my-posh / starship) — currently none.

## Config not yet versioned

- [ ] Windows Terminal `settings.json`
- [ ] git config (`.gitconfig` / `gh` aliases beyond `co`)
- [ ] `~\.ssh\config` — the `github-dtuon` host alias is a manual step in
      `SETUP.md`; a template (minus keys) could live here.
- [ ] Visual Studio settings export, to replace part of `MANUAL.md`

## Bootstrap

- [ ] `4-windows.ps1` could also pin taskbar items and set the dark wallpaper
      (`dark_desktop.jpg` is in the Dropbox docs folder).
- [ ] Install the pre-commit hook from `bootstrap/README.md` automatically.
