;https://www.autohotkey.com/

;& "$ENV:Programfiles\AutoHotkey\Compiler\Ahk2Exe.exe" /in "youtube-next-previous.ahk"
;cp youtube-next-previous.exe "$ENV:AppData\Microsoft\Windows\Start Menu\Programs\Startup\"

;bug: requires the youtube tab to be focused in the chrome window

;============================== Start Auto-Execution Section ==============================

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn   ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Keeps script permanently running
#Persistent
#SingleInstance, Force
DetectHiddenWindows, On
SetTitleMatchMode, 2
controlID 		:= 0
return

#IfWinNotActive, ahk_exe chrome.exe

; Next video in playlist, Alt-gr + n
<^>!n::
	ControlGet, controlID, Hwnd,,Chrome_RenderWidgetHostHWND1, Google Chrome

	ControlFocus,,ahk_id %controlID%

	IfWinExist, YouTube
	{
		ControlSend, Chrome_RenderWidgetHostHWND1, +n , Google Chrome
		return
	}
	Loop {
		IfWinExist, YouTube
			break

		ControlSend, , ^{PgDown} , Google Chrome
		sleep 150
	}
	ControlSend, , +n , Google Chrome
return

; Previous video in playlist, Alt-gr + p
<^>!p::
	ControlGet, controlID, Hwnd,,Chrome_RenderWidgetHostHWND1, Google Chrome

	ControlFocus,,ahk_id %controlID%

	IfWinExist, YouTube
	{
		ControlSend, Chrome_RenderWidgetHostHWND1, +p , Google Chrome
		return
	}
	Loop {
		IfWinExist, YouTube
			break

		ControlSend, , ^{PgDown} , Google Chrome
		sleep 150
	}
	ControlSend, , +p , Google Chrome
return

#IfWinNotActive
