SetWinDelay, -1
CoordMode, Mouse, Screen

Alt & LButton::
MouseGetPos, Mouse_Start_X, Mouse_Start_Y, Selected_Window
WinGet, Window_State, MinMax, ahk_id %Selected_Window%
if Window_State = 0
    SetTimer, MyLabel, 1
return

MyLabel:
MouseGetPos, Mouse_Current_X, Mouse_Current_Y
WinGetPos, Selected_Window_X, Selected_Window_Y, , , ahk_id %Selected_Window%
WinMove, ahk_id %Selected_Window%, , Selected_Window_X + Mouse_Current_X - Mouse_Start_X, Selected_Window_Y + Mouse_Current_Y - Mouse_Start_Y

Mouse_Start_X := Mouse_Current_X
Mouse_Start_Y := Mouse_Current_Y

GetKeyState, LButton_State, LButton, P
if LButton_State = U
{
    SetTimer, MyLabel, off
    return
}