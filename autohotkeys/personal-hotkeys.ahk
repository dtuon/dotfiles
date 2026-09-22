#Requires AutoHotkey v2.0
#SingleInstance Force

; Remap the capslock key
Capslock::Esc

^!Enter::Run('wt')

^!n::Run('nvim', 'C:\Users\DaleEuinton')

^!b::Run('nvim "C:\Users\DaleEuinton\PRIMER-e Dropbox\Dale Euinton\PE09\Desktop\workspace\temp\boredom_pad.md"', 'C:\Users\DaleEuinton')

^!l::Run('powershell.exe "C:\Users\DaleEuinton\bedrock\repos-dale-primer-e\powershell-utilities\open-current-log\open_current_log.ps1"')
