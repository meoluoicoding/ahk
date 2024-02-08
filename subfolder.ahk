
   ;    + = shift      ^ = Ctrl    ! = Alt     # = Win (Windows logo key) 
   ;    F2 rename      F5 refresh 


#SingleInstance,Force

Menu, MyMainMenu, Add, Open Folder, MenuHandler
Menu, MySubMenu1, Add, Desktop Folder, SubMenu1Label
Menu, MySubMenu1, Add, Downloads Folder, SubMenu1Label
Menu, MyMainMenu, Add, Open Folder, :MySubMenu1

Menu, MyMainMenu, Add, Run Program, MenuHandler
Menu, MySubMenu2, Add, SublimeText, SubMenu2Label
Menu, MySubMenu2, Add, Floorp, SubMenu2Label
Menu, MyMainMenu, Add, Run Program, :MySubMenu2

Menu, MyMainMenu, Add, Turn Monitor Off, MainMenuLabel
Menu, MyMainMenu, Add, Mute/Unmute Volume, MainMenuLabel

return

+RButton Up::
Menu, MyMainMenu, Show
return

MenuHandler:
return

SubMenu1Label:
If (A_ThisMenuItemPos = 1) {
	Run, %A_desktop%
} else if (A_ThisMenuItemPos = 2) {
	Run, "C:\Users\Administrator\Desktop"
}
return

SubMenu2Label:
If (A_ThisMenuItemPos = 1) {
	Run, "F:\portable\sublime text\sublime_text.exe"
} else if (A_ThisMenuItemPos = 2) {
	Run, "C:\Program Files\Ablaze Floorp\floorp.exe"
}
return

MainMenuLabel:
If (A_ThisMenuItemPos = 3) {
	SendMessage, 0x112, 0xF170, 2,, Program Manager
} else if (A_ThisMenuItemPos = 4) {
	Send, {Volume_Mute}
}
return

ESC::ExitApp