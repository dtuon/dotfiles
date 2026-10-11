#Requires AutoHotkey v2.0
#SingleInstance Force

; Paths come from env vars set by bootstrap\1-env.ps1, so this file is
; machine-independent. Each lookup falls back to something sane, so an unset
; var degrades a single hotkey rather than breaking the script.
;
; Env vars are read at script start, so reload AHK after changing them.

Home() {
    h := EnvGet("USERPROFILE")
    return h != "" ? h : A_MyDocuments
}

TempDocs() {
    t := EnvGet("TEMPDOCS")
    return t != "" ? RTrim(t, "\/") : Home()
}

; Remap the capslock key
Capslock::Esc

^!Enter::Run('wt')

^!n::Run('nvim', Home())

^!b::Run('nvim "' TempDocs() '\boredom_pad.md"', Home())

; Opens the current day's log. The script lives in the *work* repo, not this
; one, so guard it: on a machine without that repo cloned this hotkey should
; say so rather than fail silently.
^!l::OpenCurrentLog()

OpenCurrentLog() {
    repos := EnvGet("REPOS_WORK")
    if (repos = "") {
        MsgBox("REPOS_WORK is not set.`n`nRun bootstrap\1-env.ps1 and reload this script.",
               "open-current-log", "Icon!")
        return
    }

    script := RTrim(repos, "\/") "\powershell-utilities\open-current-log\open_current_log.ps1"
    if !FileExist(script) {
        MsgBox("Script not found:`n`n" script "`n`nIs repos-dale-primer-e cloned on this machine?",
               "open-current-log", "Icon!")
        return
    }

    Run('powershell.exe -NoProfile -File "' script '"')
}
