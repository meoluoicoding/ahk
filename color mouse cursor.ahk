#SingleInstance,Force
SetWinDelay, -1
CoordMode, Mouse, Screen

CircleSize := 75
Gui, -Caption +Hwndhwnd +AlwaysOnTop +ToolWindow +E0x20 ;+E0x20 click thru
Gui, Color, cFFFF00 ;hex code yellow
Gui, Show, x0 y-%CircleSize% w%CircleSize% h%CircleSize% NA, ahk_id %hwnd%
WinSet, Transparent, 60, ahk_id %hwnd%
WinSet, Region, 0-0 w%CircleSize% h%CircleSize% E, ahk_id %hwnd%
SetTimer, Circle, 10
return

Circle:
MouseGetPos, X, Y
X -= CircleSize / 2 - 3
Y -= CircleSize / 2 - 2
WinMove, ahk_id %hwnd%, , %X%, %Y%
WinSet, AlwaysOnTop, On, ahk_id %hwnd%
return