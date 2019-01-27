'https://gallery.technet.microsoft.com/scriptcenter/Stop-locking-computer-by-3d6e2ac2

'cp prevent-screensaver.vbs "$ENV:AppData\Microsoft\Windows\Start Menu\Programs\Startup\"

Set ws = CreateObject("WScript.Shell")
Do
    Wscript.Sleep 50000
    ws.SendKeys "{F15}"
Loop
