; from:
; http://www.autohotkey.com/forum/viewtopic.php?p=253705#253705
; Shimanov, Metaxal, maximo3491
; If Shimanov agrees:
; GNU General Public License 3.0 or higher <http://www.gnu.org/licenses/gpl-3.0.txt>

; Version 1.5 - Metaxal 2010/06/05
;   - added multiple display support

#SingleInstance, Force
CoordMode, Mouse, Screen

color_IDs=0x000000,0xC0C0C0,0x808080,0xFFFFFF,0x800000,0xFF0000,0x800080,0xFF00FF,0x008000,0x00FF00,0xFFFF00,0x000080,0x0000FF,0x008080,0x00FFFF
color_names=Black,Silver,Gray,White,Navy,Blue,Purple,Pink,Green,Lime,Aqua,Maroon,Red,Olive,Yellow

Process, Exist
pid_this := ErrorLevel
hdc_screen := DllCall( "GetDC", "uint", 0 )

MonitorNum := 0 ; primary monitor

/* uncomment to show monitor selection GUI
SysGet, MonitorCount, MonitorCount
if (MonitorCount > 1) {
    Gui, Add, Text,, Select the display:
    Gui, Add, UpDown, vMonitorNum Range0-%MonitorCount%, 0
    Gui, Add, Button, default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
    Gui, Show
    return  ; End of auto-execute section. The script is idle until the user does something.

}

ButtonOK:
Gui, Submit
Gui, Destroy
Sleep, 100 ; wait for the GUI to hide

*/

SysGet, Screen, Monitor, %MonitorNum% ;creates the 4 variables ScreenLeft, ScreenTop, ScreenRight, ScreenBottom

ScreenWidth := ScreenRight - ScreenLeft
ScreenHeight := ScreenBottom - ScreenTop

/* uncomment to draw on all screens
MonitorTopArray := []
MonitorLeftArray := []
MonitorRightArray := []
MonitorBottomArray := []
SysGet, MonitorCount, MonitorCount
Loop, %MonitorCount%
{
    SysGet, Monitor, Monitor, %A_Index%
    MonitorTopArray.Push(MonitorTop)
    MonitorLeftArray.Push(MonitorLeft)
    MonitorRightArray.Push(MonitorRight)
    MonitorBottomArray.Push(MonitorBottom)
}
X1:= Min(MonitorLeftArray*) ;get min left value
Y1:= Min(MonitorTopArray*) ;get min top value
X2:= Max(MonitorRightArray*) ;get max right value
Y2:= Max(MonitorBottomArray*) ;get max bottom value

ScreenLeft := X1
ScreenTop := Y1
ScreenWidth := X2 - X1
ScreenHeight := Y2 - Y1

*/

hdc_buffer := DllCall( "CreateCompatibleDC", "uint", hdc_screen )
hbm_buffer := DllCall( "CreateCompatibleBitmap", "uint", hdc_screen, "int", ScreenWidth, "int", ScreenHeight )
DllCall( "SelectObject", "uint", hdc_buffer, "uint", hbm_buffer )
DllCall( "BitBlt", "uint", hdc_buffer, "int", 0, "int", 0, "int", ScreenWidth, "int", ScreenHeight, "uint", hdc_screen, "int", ScreenLeft, "int", ScreenTop, "uint", 0x00CC0020 )

; Create a completely transparent GUI with the size of the display
Gui, +AlwaysOnTop -Caption -DPIScale
Gui, Show, x%ScreenLeft% y%ScreenTop% w%ScreenWidth% h%ScreenHeight%

WinGet, hw_canvas, ID, ahk_class AutoHotkeyGUI ahk_pid %pid_this%

; Get the canvas of the created window
hdc_canvas := DllCall( "GetDC", "uint", hw_canvas )

; Begin by drawing the background in the canvas
DllCall( "BitBlt", "uint", hdc_canvas, "int", 0, "int", 0, "int", ScreenWidth, "int", ScreenHeight, "uint", hdc_buffer, "int", 0, "int", 0, "uint", 0x00CC0020 )

; not exactly because colors are reverse in SetPixel...
StringSplit colors, color_IDs, `, ;separates the string into an array of substrings using the specified delimiter
StringSplit colornames, color_names, `,
color_index := 13 ;default (red)
Loop, %colornames0%
   maxIndex++
color := colors%color_index%

width := 2
x_last := 0
y_last := 0

SetBatchLines, -1

left_down := false
right_down := false

/*
http://msdn.microsoft.com/en-us/library/ms645616(VS.85).aspx
wParam:
*/
WM_MOUSEMOVE = 0x0200
/*
; numbers
MK_CONTROL  := 0x0008
MK_LBUTTON  := 0x0001
MK_MBUTTON  := 0x0010
MK_RBUTTON  := 0x0002
MK_SHIFT    := 0x0004
MK_XBUTTON1 := 0x0020
MK_XBUTTON2 := 0x0040
*/

OnMessage( WM_MOUSEMOVE, "HandleMessage" )
return

HandleMessage( p_w, p_l )
{
   global hdc_canvas, hdc_buffer, x_last, y_last, width, color, left_down, right_down, log, log_movement, ScreenLeft, ScreenTop
   
   oldWidth:=width

   x := (p_l & 0xFFFF)
   y := (p_l >> 16)

   lbutton := p_w & 0x0001 ; MK_LBUTTON
   rbutton := p_w & 0x0002 ; MK_RBUTTON

   if (lbutton) {
      tooltip
      if not left_down {
         left_down := true
      } else
         drawLine(x_last, y_last, x, y, color, width)
   } else if (rbutton) {
      if not right_down {
         right_down := true
      } else
         width := 30 ;enlarge brush for eraser
         drawLine(x_last, y_last, x, y, "ERASE", width)
         width:= oldWidth
   } else {
      if (left_down) {
         left_down := false
      }
      if (right_down) {
         right_down := false
      }
   }
     
   x_last := x
   y_last := y
}


drawLine(x0, y0, x1, y1, color_ini=0, width=1)
{
   dx := x1 - x0
   dy := y1 - y0
   
   dxy := (Abs(dx) > Abs(dy) ? Abs(dx) : Abs(dy) )
   
   dx := dx / dxy
   dy := dy / dxy
   
   Loop %dxy%
   {
      x0 += dx
      y0 += dy
   
     drawCircle(Round(x0),round(y0), color_ini)
   }
}

drawCircle(x,y, color_ini) {
    global hdc_buffer, hdc_canvas, width, ScreenLeft, ScreenTop, ScreenWidth, ScreenHeight

    cRegion := DllCall( "gdi32.dll\CreateRoundRectRgn", "int", x-width , "int", y-width , "int", x+width , "int", y+width, "int", width*2, "int", width*2 )
    cBrush := DllCall("gdi32.dll\CreateSolidBrush", "uint", color_ini )


    if color_ini=ERASE
    {
        ; from http://msdn.microsoft.com/en-us/library/dd183437%28VS.85%29.aspx
        ; Select clipping region
        DllCall( "SelectClipRgn", "uint", hdc_canvas, "uint", cRegion )
     
        ; Transfer (draw) the bitmap into the clipped rectangle. 
        DllCall( "BitBlt", "uint", hdc_canvas, "int", 0, "int", 0, "int", ScreenWidth, "int", ScreenHeight, "uint", hdc_buffer, "int", 0, "int", 0, "uint", 0x00CC0020 )
       
        ; Select the full region back
        DllCall( "SelectClipRgn", "uint", hdc_canvas, "uint", 0 )
    }
    else
        DllCall( "gdi32.dll\FillRgn" , "uint", hdc_canvas , "uint", cRegion , "uint", cBrush )

    DllCall("gdi32.dll\DeleteObject", "uint", cRegion)
    DllCall("gdi32.dll\DeleteObject", "uint", cBrush)
}


#IfWinActive ahk_class AutoHotkeyGUI
c:: ;clear
   DllCall( "BitBlt", "uint", hdc_canvas, "int", 0, "int", 0, "int", ScreenWidth, "int", ScreenHeight, "uint", hdc_buffer, "int", 0, "int", 0, "uint", 0x00CC0020 )
return

WheelUp::
color_index++
If (color_index > maxIndex)
   color_index := maxIndex
color := colors%color_index%
tooltip % colornames%color_index%
return

WheelDown::
color_index--
If (color_index < 1)
   color_index := 1
color := colors%color_index%
tooltip % colornames%color_index%
return

XButton2::
width++
tooltip % width
return

XButton1::
width--
If (width < 1)
   width := 1
tooltip % width
return

ESC::ExitApp