   ;    + = shift      ^ = Ctrl    ! = Alt     # = Win (Windows logo key) 
   ;    F2 rename      F5 refresh 
   ;    go chu

;thay phím capslock = delete
Capslock:: Delete           ;Capslock (Delete)
                            ;Ctrl + Capslock (Ctrl + Delete) = xóa cả cụm đằng sau
                            ;shift + Capslock (shift + Delete) = xóa hẳn file

;cách mở capslock
#Capslock:: SetCapsLockState, on       ;Win + Capslock (Capslock ON)
#`:: SetCapsLockState, off             ;Win + ` (Capslock OFF)



;thay phím window =ctrl+esc 
~LWin::Send {Blind}{vkE8}

         

   ;tác vụ 
`:: send, ^w                ;    bấm phím ` = Đóng tab (Ctrl + w)
^`:: send, !{F4}            ;    Ctrl + `  = Đóng app (Alt + F4)Q
+space::WinMinimize, A      ;    Shift + alt
+tab::WinMaximize, A        ;    shift +tab
+z:: reload                 ;    shift + Z = reload autohotkey



 ; bấm phím alt+space minimize mọi app trừ app đang xài 
!space::
WinGet, id, list,,, Program Manager
Loop, %id%
{
    this_ID := id%A_Index%
    WinGetTitle, active_title, A
    WinGetTitle, title, ahk_id %this_ID%
    If title = %active_title%
    Continue
    WinMinimize, %title%
}
return                   



;phần mềm




;tác vụ foobar2000 nghe nhạc
^+z:: run, "F:\portable\foobar2000\foobar2000.exe" ;ctrl+shift+z = chạy foobar 2000;
^+x:: send, {Media_Play_Pause}                     ;ctrl+shift+x =pause nhạc 
^space:: send, {Media_Stop} ;                      ;ctrl+space =dừng nhạc
#z:: send, {Media_Prev}                            ;win+z= tiếp theo
#x:: send, {Media_Next}                            ;win+x=lùi
#a:: send, {Volume_Up}                             ;win+a=tăng âm lượng
#s:: send, {Volume_Down}                           ;win+s= giảm âm lượng 


; Google Search phần văn bản được highlight ,Script sau sẽ tự động tìm kiếm Google khi bạn highlight một phần văn bản và nhấn `Ctrl`+`Shift`+`C`

^+c::
{
Send, ^c
Sleep 50
Run, http://www.google.com/search?q=%clipboard%
Return
}



;chụp màn hình 
F3:: send, {PrintScreen}{RWin up}        ;F3 ( PrintScreen) = Screenshot
F4:: send, {LWin Down}{shift Down}S{LWin Up}{shift Up}    ;F4 (Win + shift + S) = Crop man hinh
F1::send,{ctrlDown}{PrintScreen}  ;F1 (ctrl+print screen}=capture zone 
;quay phim 
#q:: send,{ShiftDown}{PrintScreen}



;làm rỗng thùng rác ;win+del
#del::FileRecycleEmpty 
return 
                           
                      


 ; Nhấn ~ để di chuyển lên một thư mục trong Explorer
#IfWinActive, ahk_class CabinetWClass
`::Send !{Up}
#IfWinActive
return

                       
