# Manual steps

Things that can't reasonably be scripted, or aren't worth scripting. Referenced
from step 8 of [SETUP.md](SETUP.md).

## Visual Studio

- Use the **C# settings profile** on first launch — it has the keyboard
  shortcuts that I'm used to. Changing it later is more annoying than picking it
  up front.
- Install VsVim, then change its `C-d` / `C-u` handling so they scroll rather
  than being passed through to Visual Studio.
- Disable CodeLens: **Tools > Options > Text Editor > All Languages > CodeLens**.

## Not available via winget

- **Accessibility Insights for Windows** —
  <https://accessibilityinsights.io/downloads/>

## Explorer

Both of these are set by `bootstrap\4-windows.ps1`; listed here in case it's
easier to click, or the registry keys move in a future Windows build.

- Show file extensions: **View > Show > File name extensions**
- Hide hidden files: **View > Show > Hidden items** (off)

## Checks that need a human

- Twingate connects and internal resources resolve
- Dropbox has finished its initial sync before relying on `DOCS` / `TEMPDOCS`
- Printers / scanners
- Outlook and Teams signed in (both are floated in `komorebi.json`)
