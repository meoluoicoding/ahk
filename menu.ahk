   ;    + = shift      ^ = Ctrl    ! = Alt     # = Win (Windows logo key) 
   ;    F2 rename      F5 refresh 



#SingleInstance,Force

Menu, MyMenu, Add, Open Desktop Folder, MenuHandler
Menu, MyMenu, Add, Open Downloads Folder, MenuHandler
Menu, MyMenu, Add, Run Calculator, MenuHandler
Menu, MyMenu, Add, Run Chrome, MenuHandler
return

+z::
Menu, MyMenu, Show
return

MenuHandler:
If (A_ThisMenuItemPos = 1) {
	Run, %A_Desktop%
} else if (A_ThisMenuItemPos = 2) {
	Run, C:\users\juho2\downloads
} else if (A_ThisMenuItemPos = 3) {
	Run, calc.exe
} else if (A_ThisMenuItemPos = 4) {
	Run, Chrome.exe
}

return

ESC::ExitApp