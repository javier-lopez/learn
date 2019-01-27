;https://www.autohotkey.com/

;& "$ENV:Programfiles\AutoHotkey\Compiler\Ahk2Exe.exe" /in "volume-down.ahk"
;cp volume-down.exe "$ENV:AppData\Microsoft\Windows\Start Menu\Programs\Startup\"

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

<^>!,::Send {Volume_Down 1} ; AltGr + ,
