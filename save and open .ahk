;https://gist.github.com/akaleeroy/f23bd4dd2ddae63ece2582ede842b028#file-currently-opened-folders-md
; a fork from above script, which works for Windows Explorer, author: Leeroy
; further, above script was inspired by author: Savage
; the script works with Directory Opus, but with below prerequisites:
;  1. Your DOpus setting has set the title bar starts with "DOpus"
;  2. Your DOpus seeting has set the title bar "Display full path"
; in my case, I set the title bar "DOpus | C:\xxxxxx", hence my script will cut off 8 chacters from the title string
; please adapt the script on your own to fit your settings
#SingleInstance, Force
#KeyHistory, 0
SetBatchLines, -1
ListLines, Off
SendMode Input ; Forces Send and SendRaw to use SendInput buffering for speed.
SetTitleMatchMode, 2 ; 
#MaxThreadsPerHotkey, 1 ; no re-entrant hotkey handling

;   two sets of keys, both active
; Middle-MouseButton, CTRL+G, like Listary
f_Hotkey = ~MButton
f_HotkeyCombo = ~^g


; Auto-execute section.
Hotkey, %f_Hotkey%, f_Jump2ActivePath
Hotkey, %f_HotkeyCombo%, f_Jump2ActivePath
return 

f_Jump2ActivePath:
;validate the correct dialogue type
WinGet, f_window_id, ID, a
WinGetClass, f_class, a
; Don't display menu unless it's a dialog or console window
if f_class not in #32770,ConsoleWindowClass
return


; get the path from Dopus
WinGet, id, list, ahk_exe dopus.exe			;get IDs for all DOpus windows
    Loop, %id% 							;Loop through IDs of all DOpus windows
    {
        this_ID := id%A_Index%
        WinGetTitle, Title, ahk_id %this_ID%			;get the title of the current window
        StringLeft, Left6, Title, 6
        ; MsgBox, %Left6%
        ; if Left6=="DOpus "
        ; {
            StringLen, TitleLen, Title 
            StringRight, DopusPath, Title, TitleLen-8
            ; MsgBox, %DopusPath%
            break            
        ; }
    }
    ; return


if f_class = #32770 ; It's a dialog.
{
    ; Activate the window so that if the user is middle-clicking
    ; outside the dialog, subsequent clicks will also work:
    WinActivate ahk_id %f_window_id%
    ; Alt+D to convert Address bar from breadcrumbs to editbox
    Send !{d}
    ; Wait for focus
    Sleep 50
    ; The control that's focused after Alt+D is thus the address bar
    ControlGetFocus, addressbar, a
    ; Put in the chosen path
    ControlSetText %addressbar%, % DopusPath, a
    Sleep 50
    ; Go there
    ControlSend %addressbar%, {Enter}, a
    ; Return focus to filename field
    ControlFocus Edit1, a
    return
}
; In a console window, pushd to that directory
else if f_class = ConsoleWindowClass
{
    ; Because sometimes the mclick deactivates it.
    WinActivate, ahk_id %f_window_id%
    ; This will be in effect only for the duration of this thread.
    SetKeyDelay, 0
    ; Clear existing text from prompt and send pushd command
    Send, {Esc}pushd %DopusPath%{Enter}
    return
}
return