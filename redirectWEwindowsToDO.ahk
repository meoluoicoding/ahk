



;*************************************************************
;;***************   HERE STARTS THE CODE   *******************
;*************************************************************

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
#Persistent
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

global vSuspendedAndShellMessageDeactivated := 0
global vPathNameCustomFileIcon := A_ScriptDir . "\redirectWEwindowsToDO.ico"


#Include, %A_ScriptDir%\redirectWEwindowsToDO_v4.2.config

; Checks the specified files below for the correct file encoding "UTF-8" with BOM, if not compiled.
if !A_IsCompiled
{
	vFullPathFilesToBeCheckedForEncoding := A_ScriptFullPath . "|" . A_ScriptDir . "\redirectWEwindowsToDO_v4.2.config"
	Loop, Parse, vFullPathFilesToBeCheckedForEncoding, |
	{
		voFile := FileOpen(A_LoopField, "r")
		if (not voFile)
		{
			MsgBox, 262144, %A_ScriptName%, The attempt to check the file "%A_LoopField%" for the right encoding failed, because it could not be opened for reading, which is weird, because the AutoHokey exe itself had no problem reading it.`n`nPlease debug and then start the script again.`n`nThe script will terminate as soon as this dialog is closed.
			ExitApp
		}
		else if (not (voFile.Encoding == "UTF-8" and voFile.Position > 0))
		{
			if voFile.Position = 0
				vtextCurrentFileFormat := "However, it is saved without BOM. Die actual file format could thus not be determined."
			else
				vtextCurrentFileFormat := "However, it is saved as """ . voFile.Encoding . """."
			MsgBox, 262144, %A_ScriptName%, The file "%A_LoopField%" is saved in the wrong file format. It must be "UTF-8" *with* BOM. %vtextCurrentFileFormat%`n`nPlease save the file "%A_LoopField%" in "UTF-8" *with* BOM and then start the script again.`n`nThe script will terminate as soon as this dialog is closed.
			voFile.Close()
			ExitApp
		}
		voFile.Close()
	}
}


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;~~~~   INITIALIZATION of TRAY MENU - START   ~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*Close
if !A_IsCompiled
{
	Menu, Tray, UseErrorLevel
	Menu, Tray, Icon, %vPathNameCustomFileIcon%
}

Menu, Tray, NoStandard
Menu, Tray, Add, Use [Ctrl] to manually keep a WE window, _ToggleUseControlToKeepWE ;_ToggleUseControlToKeepWE()
Menu, Tray, Check, Use [Ctrl] to manually keep a WE window

if (vHotkeyInWEwindowsToTriggerRedirectionToXY)
{
	vDisplayFormatOfHKIWETTRTXY := StrReplace(StrReplace(StrReplace(StrReplace(vHotkeyInWEwindowsToTriggerRedirectionToXY, "+", "Shift+"), "#", "Win+"), "!", "Alt+"), "^", "Ctrl+")
	Menu, Tray, Add, Use [%vDisplayFormatOfHKIWETTRTXY%] to manually redirect WE to DO, _ToggleHotkeyIWETTRTXY ;_ToggleHotkeyIWETTRTXY()
	Menu, Tray, Check, Use [%vDisplayFormatOfHKIWETTRTXY%] to manually redirect WE to DO
}
else
{
	Menu, Tray, Add, [Hotkey to trigger WE -> XY not defined], _TrayMenuDummy
}

if (vHotkeyInXYtabsToTriggerRedirectionToWE)
{
	vDisplayFormatOfHKIXYTTRTWE := StrReplace(StrReplace(StrReplace(StrReplace(vHotkeyInXYtabsToTriggerRedirectionToWE, "+", "Shift+"), "#", "Win+"), "!", "Alt+"), "^", "Ctrl+")
	Menu, Tray, Add, Use [%vDisplayFormatOfHKIXYTTRTWE%] to manually redirect DO to WE, _ToggleHotkeyIXYTTRTWE ;_ToggleHotkeyIXYTTRTWE()
	Menu, Tray, Check, Use [%vDisplayFormatOfHKIXYTTRTWE%] to manually redirect XY to WE
}
else
{
	Menu, Tray, Add, [Hotkey to trigger XY -> WE not defined], _TrayMenuDummy
}

if (vHotkeyGlobalToSuspendUnsuspendTheWholeScript)
{
	vDisplayFormatOfHKGTSUSTWS := StrReplace(StrReplace(StrReplace(StrReplace(vHotkeyGlobalToSuspendUnsuspendTheWholeScript, "+", "Shift+"), "#", "Win+"), "!", "Alt+"), "^", "Ctrl+")
	Menu, Tray, Add, Suspend Script ([%vDisplayFormatOfHKGTSUSTWS%]), _TogglePauseAndSuspendScript, +Radio ;_TogglePauseAndSuspendScript()
}
else
{
	Menu, Tray, Add, [Hotkey to suspend script not defined], _TrayMenuDummy
}
Menu, Tray, Add, Exit Script, _ExitApp ;_ExitApp()

_TrayMenuDummy()
{
	return
}

OnMessage(0x404, "AHK_NOTIFYICON") ; According to the TrayIcon library, messages with ID 0x404 (1028) are sent from the tray icon to the AHK main window (A_ScriptHwnd). https://www.autohotkey.com/boards/search.php?author_id=74796&sr=posts
AHK_NOTIFYICON(wParam, lParam, uMsg, hWnd)
{
	; if (lParam = 0x201) ;WM_LBUTTONDOWN := 0x201 (seemed to work as WM_LBUTTONUP := 0x0202)
	if (lParam = 0x202) ;WM_LBUTTONUP := 0x0202
	; if (lParam = 0x203) ;WM_LBUTTONDBLCLK := 0x203
	{
		Menu, Tray, Show
	}
}
*/
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;~~~~   INITIALIZATION of TRAY MENU - END   ~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


if (vHotkeyInWEwindowsToTriggerRedirectionToXY)
{
	Hotkey, IfWinActive, ahk_class CabinetWClass
	Hotkey, %vHotkeyInWEwindowsToTriggerRedirectionToXY%, _TriggerWEwindowRedirectionToXY ;_TriggerWEwindowRedirectionToXY()
	Hotkey, If
}

if (vHotkeyInXYtabsToTriggerRedirectionToWE)
{
	SetTitleMatchMode, 2
	Hotkey, IfWinActive, dopus ahk_class dopus.lister
	Hotkey, %vHotkeyInXYtabsToTriggerRedirectionToWE%, _TriggerXYtabRedirectionToWE ;_TriggerXYtabRedirectionToWE()
	Hotkey, If
}

if (vHotkeyGlobalToSuspendUnsuspendTheWholeScript)
{
	Hotkey, %vHotkeyGlobalToSuspendUnsuspendTheWholeScript%, _TogglePauseAndSuspendScript ;_TogglePauseAndSuspendScript()
}


; checks if vKeepOrRedirect_matchingWEPaths has an allowed value and, if not, pops a message box
if (not (vKeepOrRedirect_matchingWEPaths = "Keep" or vKeepOrRedirect_matchingWEPaths = "Redirect"))
{
	MsgBox, 262144, %A_ScriptName%, The variable vKeepOrRedirect_matchingWEPaths must be either "Keep" or "Redirect", however it is "%vKeepOrRedirect_matchingWEPaths%".`n`nPlease, correct it in the user customize section of the code.`n`nThe script will terminate as soon as this dialog is closed.
	ExitApp
}

vKeepIfCtrlHeldDown := 1

; Before adding the command line parameters, ensure that the first and last char of vWindowsExplorerPaths is a pipe "|". (Necessary for the "identical" compare method.)
; However, the end must be checked first as to whether it already is a pipe, because if two consecutive pipes end up in the middle of the string (after command line parameters are added) then this would lead to unwanted results in case of the RegEx compare method. (compare below)
if (not SubStr(vWindowsExplorerPaths, 0) = "|")
	vWindowsExplorerPaths := "|" . vWindowsExplorerPaths . "|"
else
	vWindowsExplorerPaths := "|" . vWindowsExplorerPaths

/*	About incorrectly passed command line parameters:
	The help file says:
	Any parameter that contains spaces should be enclosed in quotation marks. A literal quotation mark may be passed in by preceding it with a backslash (\"). Consequently, any trailing slash in a quoted parameter (such as "C:\My Documents\") is treated as a literal quotation mark (that is, the script would receive the string C:\My Documents"). To remove such quotes, use StringReplace, 1, 1, ",, All.
	-> In my opinion that is a two edged sword. The core problem is that literal quotation marks are escaped with a backslash. Thus, two consecutive parameters of which the first ends on \" (backslash quote) are treated as one, no matter what. So, I comment the "correction" out in the next line for now.
	StringReplace, vWindowsExplorerPaths, vWindowsExplorerPaths, ",, All
	If wanted/needed, the whole raw command line can be correctly read using full_command_line := DllCall("GetCommandLine", "Str")
	Then it could be custom-parsed.
	For now, I go with instructing the user to NOT pass paths with a trailing backslash.
*/

For n, param in A_Args
{
    vWindowsExplorerPaths .= param . "|"
}

; if RegEx is used as comparision method, then the pipes "|" at the beginning and end must be removed again, because otherwise the ends would be interpreted as empty patterns which would always match
if vUseRegExForPathCompare
	vWindowsExplorerPaths := Trim(vWindowsExplorerPaths, "|")


; Make the GUI window the last found window for use by the line below.
Gui +LastFound
vHWnd := WinExist()
DllCall( "RegisterShellHookWindow", UInt, vHWnd )
vMsgNum := DllCall( "RegisterWindowMessage", Str, "SHELLHOOK" )
OnMessage( vMsgNum, "ShellMessage" )
; MsgBox, %vMsgNum%


if (vApplyRulesToExistingWEwindowsAtScriptStart)
{
	WinGet, vExistingCabinetWClassWindows, List, ahk_class CabinetWClass
	Loop %vExistingCabinetWClassWindows%
	{
		ShellMessage(1, vExistingCabinetWClassWindows%A_Index%)
	}
}

return

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;~~~~   END of AUTOEXECUTE SECTION   ~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


^#e::
;; ^#e::
; Using this construct so that the user in this particular case does not *have* to keep pressing the Ctrl key down until the WE window appears.
OnMessage( vMsgNum, "ShellMessage", 0 )
OnMessage( vMsgNum, "ShellMessage_keepTheNextWEwindow" )
Send, #e
return


ShellMessage_keepTheNextWEwindow( wParam, lParam )
{
	Critical
	global vMsgNum
	; When the function is triggered (by a new window message), do nothing, thus also a new WE window is kept.
	; Then (after doing nothing) set OnMessage back to the normal function.
	if (wParam = 1 and _WinGetClass("ahk_id " lParam) = "CabinetWClass")
	{
		OnMessage( vMsgNum, "ShellMessage_keepTheNextWEwindow", 0 )
		OnMessage( vMsgNum, "ShellMessage" )
	}
}

ShellMessage( wParam, lParam )
{
	global
	Critical

/*wParam =
HSHELL_ACCESSIBILITYSTATE
11
The accessibility state has changed.

HSHELL_ACTIVATESHELLWINDOW
3
The shell should activate its main window.

HSHELL_APPCOMMAND
12
The user completed an input event (for example, pressed an application command button on the mouse or an application command key on the keyboard), and the application did not handle the WM_APPCOMMAND message generated by that input.
If the Shell procedure handles the WM_COMMAND message, it should not call CallNextHookEx. See the Return Value section for more information.

HSHELL_GETMINRECT
5
A window is being minimized or maximized. The system needs the coordinates of the minimized rectangle for the window.

HSHELL_LANGUAGE
8
Keyboard language was changed or a new keyboard layout was loaded.

HSHELL_REDRAW
6
The title of a window in the task bar has been redrawn.

HSHELL_TASKMAN
7
The user has selected the task list. A shell application that provides a task list should return TRUE to prevent Windows from starting its task list.

HSHELL_WINDOWACTIVATED
4
The activation has changed to a different top-level, unowned window.

HSHELL_WINDOWCREATED
1
A top-level, unowned window has been created. The window exists when the system calls this hook.

HSHELL_WINDOWDESTROYED
2
A top-level, unowned window is about to be destroyed. The window still exists when the system calls this hook.

HSHELL_WINDOWREPLACED
13
A top-level window is being replaced. The window exists when the system calls this hook. 

lParam differs in type according to the value of wParam received. For most of the wParam values, the lParam is a handle to a window that can be used as ahk_id %lParam% in AHK's Window commands.
*/

	; static vHWndsToIgnore := "|"

	; if ( (wParam = 1 or wParam = 6) and WinActive("ahk_class CabinetWClass"))
	if (wParam = 1 and _WinGetClass("ahk_id " lParam) = "CabinetWClass")
	{
		; if (InStr(vHWndsToIgnore, "|" lParam "|"))
		; 	return
		if (vKeepIfCtrlHeldDown and GetKeyState("Control", "P"))
		{
			; vHWndsToIgnore .= lParam "|"
			return
		}

		vPath := Explorer_GetPath(lParam)
		while ( vPath = "ERROR" and A_Index < 10)
		{
			 Sleep 100
			 vPath := Explorer_GetPath(lParam)
		}
		if ( vPath = "ERROR" )
		{
			 MsgBox Could not retrieve the path of the explorer window.
			 return
		}


		; If RegEx is *not* used as compare method, then keep WE in case of the content of a zip file
		if (not vUseRegExForPathCompare)
		{
			if (StrLen(vPath) > 3 and StrLen(vPath) - InStr(vPath, ".zip", 0, 0) = 3)
				return
		}

		
		if (vUseRegExForPathCompare)
		{
			; MsgBox, % vPath ", " vWindowsExplorerPaths ", " vKeepOrRedirect_matchingWEPaths
			if (RegExMatch(vPath, vWindowsExplorerPaths))
			{
				if (vKeepOrRedirect_matchingWEPaths = "Keep" and (not vExceptionPathsInCaseOfRegEx or not RegExMatch(vPath, vExceptionPathsInCaseOfRegEx)))
				{
					; MsgBox, 1
					return
				}
				else if (vKeepOrRedirect_matchingWEPaths = "Redirect" and vExceptionPathsInCaseOfRegEx and RegExMatch(vPath, vExceptionPathsInCaseOfRegEx))
				{
					; MsgBox, 2
					return
				}
				; MsgBox, 3
			}
			else if (vKeepOrRedirect_matchingWEPaths = "Redirect")
					return
		}
		else if (InStr(vWindowsExplorerPaths, "|" . vPath . "|"))
		{
			if (vKeepOrRedirect_matchingWEPaths = "Keep")
				return
		}
		else if (vKeepOrRedirect_matchingWEPaths = "Redirect")
			return


		vSelected := Explorer_GetSelected(lParam)
		StringReplace, vSelected, vSelected, % Chr(10), |, 1

		; if vPath is found in a normal way in the file system and is *not* a Directory = vPath is a file (e.g. a zip file)
		vFileAttrib := FileExist(vPath)
		if (vFileAttrib and not InStr(vFileAttrib, "D"))
		{
			SplitPath, vPath, , vOutDir
			vSelected := vPath
			vPath := vOutDir
		}


;Opens in a new window in DOpus
        If (vSelected = "")   ;If vSelected is empty, set vSelected equal to vPath
		{
		vSelected = %vPath%
		}
		
        IfExist, C:\Program Files\GPSoftware\Directory Opus\dopusrt.exe                      ;If the file exists then run the following command
        {
        Run, C:\Program Files\GPSoftware\Directory Opus\dopusrt.exe /cmd Go "%vSelected%" new
        }
         else IfExist, C:\Program Files\Directory Opus\dopusrt.exe                           ;Otherwise, if the file exists then run the following command
         {
         Run, C:\Program Files\Directory Opus\dopusrt.exe /cmd Go "%vSelected%" new
         }
		 else IfExist, C:\Program Files\GPSoftware\Directory Opus\dopusrt.exe                ;Otherwise, if the file exists then run the following command
         {
         Run, C:\Program Files\GPSoftware\Directory Opus\dopusrt.exe /cmd Go "%vSelected%" new
         }
		 else IfExist, C:\Program Files\Directory Opus\dopusrt.exe                           ;Otherwise, if the file exists then run the following command
         {
         Run, C:\Program Files\Directory Opus\dopusrt.exe /cmd Go "%vSelected%" new
         }
		 else IfExist, C:\Tools\GPSoftware\Directory Opus\dopusrt.exe                        ;Otherwise, if the file exists then run the following command
         {
         Run, C:\Tools\GPSoftware\Directory Opus\dopusrt.exe /cmd Go "%vSelected%" new
         }
		 else IfExist, C:\Tools\Directory Opus\dopusrt.exe                                   ;Otherwise, if the file exists then run the following command
         {
         Run, C:\Tools\Directory Opus\dopusrt.exe /cmd Go "%vSelected%" new
         }
		 else IfExist, C:\Program Files\GPSoftware\Directory Opus\dopusrt.exe                ;Otherwise, if the file exists then run the following command
         {
         Run, C:\Program Files\GPSoftware\Directory Opus\dopusrt.exe /cmd Go "%vSelected%" new
         }
		 else IfExist, C:\directory opus\DirectoryOpus.Portable.12.23.0.0_x64\App\DirectoryOpus64\dopusrt.exe               ;Otherwise, if the file exists then run the following command
         {
         Run, C:\directory opus\DirectoryOpus.Portable.12.23.0.0_x64\App\DirectoryOpus64\dopusrt.exe /cmd Go "%vSelected%" new
         }
		 else
		 {
		 MsgBox, Not found dopusrt.exe.`n`nChange the path of dopusrt.exe in the ahk file.
		 return
		 }

		vXYDidNotAutostart := 0
		; SetTitleMatchMode, 2
		; vXYhWnd := WinExist("XYplorer ahk_class ThunderRT6FormDC")
		vXYhWnd := ahk_class dopus.lister
		;[Close it, change it to the following]if (not vXYhWnd or vOpenRedirectedPathsInSeparateReadOnlyXYInstances)
		if (vOpenRedirectedPathsInSeparateReadOnlyXYInstances)
		{
			SplitPath, vPathToXYplorerForAutostart, , vOutDir
			; MsgBox %vOpenRedirectedPathsInSeparateReadOnlyXYInstances%
			if vOpenRedirectedPathsInSeparateReadOnlyXYInstances
			{
				; MsgBox test
				;[Close]Run, "%vPathToXYplorerForAutostart%" /readonly /ini="%vSeparateIniFileInCaseOfReadOnlyXYInstance%" "%vPath%", vOutDir, UseErrorLevel, vOutputVarPID
				; Run, "%vPathToXYplorerForAutostart%" /readonly /script="::focus 'P1';if(get('#800')){#800;}goto '%vPath%';tab('closeothers');", OutDir, UseErrorLevel
				; Run, "%vPathToXYplorerForAutostart%" /readonly /script="::focus 'P1';tab('closeothers');if(get('#800')){#800;}" "%vPath%||%vPath%", OutDir, UseErrorLevel
				; Run, "%vPathToXYplorerForAutostart%" /readonly /fresh /script="::focus 'P1';" "%vPath%||%vPath%", OutDir, UseErrorLevel
				; Run, "%vPathToXYplorerForAutostart%" /readonly, OutDir, UseErrorLevel
			}
			else
			{
				;[Close]Run, "%vPathToXYplorerForAutostart%", vOutDir, UseErrorLevel
			}

			if (ErrorLevel = "ERROR")
			{
				vXYDidNotAutostart := 1
				vXYhWnd := ahk_class dopus.lister
				if (vXYhWnd and vOpenRedirectedPathsInSeparateReadOnlyXYInstances)
				{
					MsgBox, 262145, %A_ScriptName%, A read-only instance of XYplorer could not be started automatically. However, it was determined that a instance of XYplorer is already running.`n`nIf you click "OK", then the existing instance of XYplorer will be used for redirecting the WE path.`n`nIf you click "Cancel", then the WE window will not be redirected to XYplorer this time.
					IfMsgBox, Cancel
						return
				}
				; while not WinExist("XYplorer ahk_class ThunderRT6FormDC")
				while not vXYhWnd
				{
					MsgBox, 262145, %A_ScriptName%, XYplorer could not be started automatically. Please, start it manually.`n`nOnce XYplorer is started you can close this dialog in order to redirect the Windows Explorer window to XYplorer.`n`nPress Cancel in order to *not* redirect the Windows Explorer window to XYplorer this time.
					IfMsgBox, Cancel
						return
					vXYhWnd := ahk_class dopus.lister
				}
			}
			else
			{
				; WinWait, XYplorer ahk_class ThunderRT6FormDC
				; while not WinExist("XYplorer ahk_class ThunderRT6FormDC")
				SetTitleMatchMode, RegEx
				while not ((vOpenRedirectedPathsInSeparateReadOnlyXYInstances and (vXYhWnd := WinExist(".*XYplorer.* ahk_class ^dopus.lister$ ahk_exe \\dopus\.exe$ ahk_pid " vOutputVarPID))) or (not vOpenRedirectedPathsInSeparateReadOnlyXYInstances and (vXYhWnd := ahk_class dopus.lister)))
				{
					ToolTip, %A_ScriptName%:`n`nXYplorer is being started...
					Sleep, 20
				}
				ToolTip
			}

			; WinWait, XYplorer ahk_class ThunderRT6FormDC
			; vXYhWnd := WinExist()

			; in case that meanwhile the WE window does not exist anymore, then return
			IfWinNotExist, ahk_id %lParam%
				return
		}

		;[Close]WinActivate, ahk_id %vXYhWnd%
		
		; WinWaitActive, ahk_id %vXYhWnd%
		; WinGetTitle, vtitle, %vXYhWnd%
		; WinGetClass, vclass, %vXYhWnd%
		; MsgBox, "%vXYhWnd%", "%vtitle%", "%vclass%", "%vOutputVarPID%"
		
		; close the WE window
		WinClose, ahk_id %lParam%

		if (not vOpenRedirectedPathsInSeparateReadOnlyXYInstances or vXYDidNotAutostart)
		{
			;[Close]_XYmessenger_command("if(strpos('|' . get('tabs') . '|', ""|" . vPath . "|"") == -1) {tab('new', """ . vPath . """);} else {goto """ . vPath . """, 1;}", vXYhWnd, 0)
		}

		if (vSelected)
		{
			; MsgBox "%vSelected%"
			vArrSelected := StrSplit(vSelected, "|")
			;[Close]_XYmessenger_command("selfilter row(""" . vArrSelected[1] . """) . ',' . get('CountItems'), , '#', 0, 1;selectitems """ . vSelected . """;", vXYhWnd, 0)
			; _XYmessenger_command("selectitems """ . vSelected . """;", vXYhWnd, 0)
		}

		if (vAutofocusListInXYAfterRedirection)
		{
			;[Close]_XYmessenger_command("focus ""L"";", vXYhWnd, 0)
		}
	}
}
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;~~~~   END of ShellMessage( wParam, lParam )  ~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; #IfWinActive ahk_class ThunderRT6FormDC
; ^t::
; 	; MsgBox test45
; 	_XYmessenger_command("tabset('saveas', 'test24')", , 0)
; return



_TriggerWEwindowRedirectionToXY() {
	global
	Critical
	if (not vHWndWE := WinActive("ahk_class CabinetWClass"))
		return
	vWindowsExplorerPaths_org := vWindowsExplorerPaths
	vWindowsExplorerPaths := ""
	vKeepOrRedirect_matchingWEPaths_org := vKeepOrRedirect_matchingWEPaths
	vKeepOrRedirect_matchingWEPaths := "Redirect"
	vUseRegExForPathCompare_org := vUseRegExForPathCompare
	vUseRegExForPathCompare := 1
	vExceptionPathsInCaseOfRegEx_org := vExceptionPathsInCaseOfRegEx
	vExceptionPathsInCaseOfRegEx := ""
	vKeepIfCtrlHeldDown_org := vKeepIfCtrlHeldDown
	vKeepIfCtrlHeldDown := 0
	ShellMessage( 1, vHWndWE )
	vWindowsExplorerPaths := vWindowsExplorerPaths_org
	vKeepOrRedirect_matchingWEPaths := vKeepOrRedirect_matchingWEPaths_org
	vUseRegExForPathCompare := vUseRegExForPathCompare_org
	vExceptionPathsInCaseOfRegEx := vExceptionPathsInCaseOfRegEx_org
	vKeepIfCtrlHeldDown := vKeepIfCtrlHeldDown_org
}



_TriggerXYtabRedirectionToWE() {
	global
	Critical
	vXYhWnd := _XYmessenger_getXYhWnd(0)
	vCurPath := _XYmessenger_get("resolvepath(""<curpath>"")", vXYhWnd, 0)
	; vCurPath := XY_eval_and_returnvalue("resolvepath(""<curpath>"")")
	; MsgBox, % vCurPath
	if (not FileExist(vCurPath))
	{ ; If the path does not exist open explorer.exe with path "", which should always open the "My Computer" view.
		vCurPath := ""
	}
	OnMessage( vMsgNum, "ShellMessage", 0 )
	OnMessage( vMsgNum, "ShellMessage_keepTheNextWEwindow" )
	WinGet, vOutList, List, ahk_class CabinetWClass
	vActivehWnd := WinExist("A")
	Run, explorer.exe "%vCurPath%"
	; close the XY tab *after* visually opening WE (for psychological support for the user) and only if the path does actually exist (and of course if that setting is turned on)
	if (vCurPath and vCloseXYtabIfRedirectedToWE)
	{
		while 1
		{
			WinWaitNotActive, ahk_id %vActivehWnd%
			vActivehWnd := WinExist("A")
			WinGetClass, vOutClass, ahk_id %vActivehWnd%
			if (vOutClass = "CabinetWClass")
			{
				loop, %vOutList%
				{
					if (vOutList%A_Index% = vActivehWnd)
						continue, 2
				}
				break
			}
		}
		_XYmessenger_command("#351", vXYhWnd, 0) ; close tab
	}
}


_ToggleUseControlToKeepWE() {
	global
	vKeepIfCtrlHeldDown := vKeepIfCtrlHeldDown ? 0 : 1
	Hotkey, ^#e, Toggle
	Menu, Tray, ToggleCheck, Use [Ctrl] to manually keep a WE window
}


_ToggleHotkeyIWETTRTXY() {
	global
	Menu, Tray, ToggleCheck, Use [%vDisplayFormatOfHKIWETTRTXY%] to manually redirect WE to XY
	Hotkey, IfWinActive, ahk_class CabinetWClass
	Hotkey, %vHotkeyInWEwindowsToTriggerRedirectionToXY%, Toggle
	Hotkey, If
}


_ToggleHotkeyIXYTTRTWE() {
	global
	Menu, Tray, ToggleCheck, Use [%vDisplayFormatOfHKIXYTTRTWE%] to manually redirect XY to WE
	SetTitleMatchMode, 2
	Hotkey, IfWinActive, dopus ahk_class dopus.lister
	Hotkey, %vHotkeyInXYtabsToTriggerRedirectionToWE%, Toggle
	Hotkey, If
}


_TogglePauseAndSuspendScript() {
	global
	Suspend, Toggle
	; if A_IsPaused
	if vSuspendedAndShellMessageDeactivated
	{
		OnMessage( vMsgNum, "ShellMessage")
		if A_IsCompiled
		{
			Menu, Tray, Icon, %A_ScriptFullPath%, 1, 1
		}
		else
		{
			Menu, Tray, Icon, %vPathNameCustomFileIcon%, 1, 1
		}
		vSuspendedAndShellMessageDeactivated := 0
	}
	else
	{
		OnMessage( vMsgNum, "ShellMessage", 0 )
		if A_IsCompiled
		{
			Menu, Tray, Icon, %A_ScriptFullPath%, 5, 1
		}
		else
		{
			Menu, Tray, Icon, %A_AhkPath%, 5, 1
		}
		vSuspendedAndShellMessageDeactivated := 1
	}
	; MsgBox test2
	; Pause, Toggle, 1 ; The Pause only is used for the tray icon to show a red S instead of a green S. Otherwise, it is not necessary to use the Pause command. And for checking A_IsPaused in the if clause above. Putting "Suspend, Toggle" after the if clause, does not prevent the hotkey from being suspended. But if I wanted to check in the if clause for A_IsSuspended, then I would have to reverse the if-logic, checking for if *not* A_IsSuspended, since it is already after the Suspend command in the code, which is stupid from the logical part of what this function should do. Thus, since Pause also helps with the tray icon, I might as well use it in the if clause.
	Menu, Tray, ToggleCheck, Suspend Script ([%vDisplayFormatOfHKGTSUSTWS%])
}


_ExitApp() {
	ExitApp
}


_WinGetClass(WinTitle := "", WinText := "", ExcludeTitle := "", ExcludeText := "")
{
	WinGetClass, class, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	return class
}



;*****************************************************************************************************************
;~ Code from others  (or based on):
;*****************************************************************************************************************
/*
	Library for getting info from a specific explorer window (if window handle not specified, the currently active
	window will be used).  Requires AHK_L or similar.  Works with the desktop.  Does not currently work with save
	dialogs and such.
	
	
	Explorer_GetSelected(hwnd="")   - paths of target window's selected items
	Explorer_GetAll(hwnd="")        - paths of all items in the target window's folder
	Explorer_GetPath(hwnd="")       - path of target window's folder
	
	example:
		F1::
			path := Explorer_GetPath()
			all := Explorer_GetAll()
			sel := Explorer_GetSelected()
			MsgBox % path
			MsgBox % all
			MsgBox % sel
		return
	
	Joshua A. Kinnison
	2011-04-27, 16:12
*/

Explorer_GetPath(hwnd="")
{
	if !(window := Explorer_GetWindow(hwnd))
		return ErrorLevel := "ERROR"
	if (window="desktop")
		return A_Desktop
	path := window.LocationURL
	if (path="")
	path := window.LocationName
	path := RegExReplace(path, "ftp://.*@","ftp://")
	StringReplace, path, path, file:///
	StringReplace, path, path, /, \, All 
	; next line added by me on 20200806; suggested by gb007 (https://www.xyplorer.com/xyfc/viewtopic.php?f=7&t=10671&start=75#p179211)
	StringReplace, path, path, file://, //
	
	; thanks to polyethene
	Loop
		if RegExMatch(path, "i)(?<=%)[\da-f]{1,2}", hex)
			StringReplace, path, path, `%%hex%, % Chr("0x" . hex), All
		Else Break
	return path
}

Explorer_GetAll(hwnd="")
{
	return Explorer_Get(hwnd)
}

Explorer_GetSelected(hwnd="")
{
	return Explorer_Get(hwnd,true)
}

Explorer_GetWindow(hwnd="")
{
	; thanks to jethrow for some pointers here
    WinGet, process, processName, % "ahk_id " hwnd := hwnd? hwnd:WinExist("A")
    WinGetClass class, ahk_id %hwnd%


	; MsgBox, %hwnd%, %process%, %class%
	; ; if not process
	; 	MsgBox, % WinExist("ahk_id " hwnd)
	; ; return
	
	if (process!="explorer.exe")
		return
	if (class ~= "(Cabinet|Explore)WClass")
	{
		for window in ComObjCreate("Shell.Application").Windows
			try if (window.hwnd==hwnd)
				return window
	}
	else if (class ~= "Progman|WorkerW") 
		return "desktop" ; desktop found
}

Explorer_Get(hwnd="",selection=false)
{
	if !(window := Explorer_GetWindow(hwnd))
		return ErrorLevel := "ERROR"
	if (window="desktop")
	{
		ControlGet, hwWindow, HWND,, SysListView321, ahk_class Progman
		if !hwWindow ; #D mode
			ControlGet, hwWindow, HWND,, SysListView321, A
		ControlGet, files, List, % ( selection ? "Selected":"") "Col1",,ahk_id %hwWindow%
		base := SubStr(A_Desktop,0,1)=="\" ? SubStr(A_Desktop,1,-1) : A_Desktop
		Loop, Parse, files, `n, `r
		{
			path := base "\" A_LoopField
			IfExist %path% ; ignore special icons like Computer (at least for now)
				ret .= path "`n"
		}
	}
	else
	{
		if selection
			collection := window.document.SelectedItems
		else
			collection := window.document.Folder.Items
		for item in collection
			ret .= item.path "`n"
	}
	return Trim(ret,"`n")
}

;*****************************************************************************************************************

;heavily based on binocular222s work:
;https://www.xyplorer.com/xyfc/viewtopic.php?f=7&t=9233

_XYmessenger_command(p_xys_commandString, p_XY_hWnd := 0, p_allowScanForInactiveXY := 0, p_waitHowLongForXYToProcessMessage_ms := 600000) ; 600000 ms are 10 minutes
{
  if !p_XY_hWnd
    if (not (p_XY_hWnd := _XYmessenger_getXYhWnd(p_allowScanForInactiveXY)))
    {
      ErrorLevel := 1
      return 0
    }
  return _XYmessenger(p_xys_commandString, p_XY_hWnd, 0, p_waitHowLongForXYToProcessMessage_ms)
}


_XYmessenger_get(p_xys_expressionString, p_XY_hWnd := 0, p_allowScanForInactiveXY := 0, p_waitHowLongForReturn_ms := 600000) ; 600000 ms are 10 minutes
{
  if !p_XY_hWnd
    if (not (p_XY_hWnd := _XYmessenger_getXYhWnd(p_allowScanForInactiveXY)))
    {
      ErrorLevel := 1
      return 0
    }
  return _XYmessenger(p_xys_expressionString, p_XY_hWnd, 1, p_waitHowLongForReturn_ms)
}



;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;~~~~   INTERNAL FUNCTIONS   ~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; The ahk help for WinGet, , List says: "Windows are retrieved in order from topmost to bottommost (according to how they are stacked on the desktop)."
; Also, the Window Titles chapter says (e.g. for WinExist): "If multiple windows match the WinTitle and any other criteria, the topmost matching window is used. If the active window matches the criteria, it usually takes precedence since it is usually above all other windows. However, if an always-on-top window also matches (and the active window is not always-on-top), it may be used instead."
; Therefore, it is better to specifically test the currently active window first.
_XYmessenger_getXYhWnd(p_allowScanForInactiveXY := 1)
{
	v_org_titleMatchMode := A_TitleMatchMode
  SetTitleMatchMode, RegEx
  v_XY_hWnd := WinActive("ahk_class ^ThunderRT6FormDC$ ahk_exe \\XYplorer\.exe$")
  if !v_XY_hWnd and p_allowScanForInactiveXY
    v_XY_hWnd := WinExist("ahk_class ^ThunderRT6FormDC$ ahk_exe \\XYplorer\.exe$")
	SetTitleMatchMode, % v_org_titleMatchMode
  return v_XY_hWnd
}


_XYmessenger_cleanUp(p_arr_cleanUp) {
  SetWinDelay, % Array.Pop()
}


_XYmessenger(p_xys_commandOrExpressionString, p_XY_hWnd, p_returnResult, p_waitHowLongForReturn_ms)
{
  v_arr_cleanUp := Array(A_WinDelay)
  SetWinDelay, -1
  
  if (!WinExist("ahk_id " p_XY_hWnd))
  {
    _XYmessenger_cleanUp(v_arr_cleanUp)
    ErrorLevel := 1
    return 0
  }
  
  v_ahk_hWnd := A_ScriptHwnd + 0  ;Return this script's hidden hwdn id.  +0 to convert from Hex to Dec
  
  if p_returnResult
  {
    MessagetoXYplorer := "::CopyData " v_ahk_hWnd ", " p_xys_commandOrExpressionString ", 0"    ;resolves to sth like this:   ::CopyData 7409230, <curitem>, 0   _OR like this:  ::CopyData 7409230, tab('get','count'), 0
  }
  else
  {
    MessagetoXYplorer := "::" p_xys_commandOrExpressionString    ;resolves to sth like this:   ::loadtree get('tree').'|'.listfolder(,,2)
  }
  
  Size := StrLen(MessagetoXYplorer)
  if !(A_IsUnicode)
  {
    VarSetCapacity(Data, Size * 2, 0)
    StrPut(MessagetoXYplorer, &Data, Size, "UTF-16")
  }
  Else
    Data := MessagetoXYplorer

  VarSetCapacity(COPYDATA, A_PtrSize * 3, 0)
  NumPut(4194305, COPYDATA, 0, "Ptr")
  NumPut(Size * 2, COPYDATA, A_PtrSize, "UInt")
  NumPut(&Data, COPYDATA, A_PtrSize * 2, "Ptr")
  if p_returnResult
  {
    global v_XYmessenger_returnMessageProcessed := 0
		global v_XYmessenger_XYreturnValue := ""
    v_waitForReturnInterval := 10 ;ms
    
		OnMessage(0x4a, "_XYmessenger_receive_WM_COPYDATA")  ; 0x4a is WM_COPYDATA. This onhold and wait for the WM_Copydata from XYplorer then execute Function_Receive_WM_COPYDATA(wParam, lParam) below
    v_startTimeWaiting := A_TickCount
		SendMessage, 0x4a, 0, &COPYDATA, , ahk_id %p_XY_hWnd%, , , , %p_waitHowLongForReturn_ms% ;SendMessage waits for the target window to process the message, up until the timeout period expires. Timeout: The maximum number of milliseconds to wait for the target window to process the message. If omitted, it defaults to >> 5000 << (milliseconds), which is also the default behaviour in older versions of AutoHotkey which did not support this parameter. If the message is not processed within this time, the command finishes and sets ErrorLevel to the word FAIL. This parameter can be an expression.
    while !v_XYmessenger_returnMessageProcessed
    {
      if (A_TickCount - v_startTimeWaiting >= p_waitHowLongForReturn_ms)
      {
        OnMessage(0x4a, "")
        _XYmessenger_cleanUp(v_arr_cleanUp)
        ErrorLevel := 1
        return 0
      }
      Sleep, % v_waitForReturnInterval
    }
    OnMessage(0x4a, "")
    _XYmessenger_cleanUp(v_arr_cleanUp)
		ErrorLevel := 0
    return v_XYmessenger_XYreturnValue
  }
  else
  {
	;~ PostMessage, 0x4a, 0, &COPYDATA, , ahk_id %p_XY_hWnd% ;PostMessage places the message in the message queue associated with the target window. It does not wait for acknowledgement or reply.
    SendMessage, 0x4a, 0, &COPYDATA, , ahk_id %p_XY_hWnd%, , , , %p_waitHowLongForReturn_ms% ;By contrast, SendMessage waits for the target window to process the message, up until the timeout period expires. Timeout in ms.
    _XYmessenger_cleanUp(v_arr_cleanUp)
    ErrorLevel := 0
	return 1
  }
}

_XYmessenger_receive_WM_COPYDATA(wParam, lParam)
{
  Critical
  global v_XYmessenger_returnMessageProcessed
  global v_XYmessenger_XYreturnValue
  StringAddress := NumGet(lParam + 2*A_PtrSize) ;lParam+8 is the address of CopyDataStruct's lpData member.
  CopyOfData := StrGet(StringAddress)    ;May also specify CP0 (default) or UTF-8 or UTF-16:   StrGet(StringAddress, NumGet(lParam+A_PtrSize), "UTF-16")
  cbData := NumGet(lParam+A_PtrSize)/2  ;cbData/2 = String length
  StringLeft, Datareceived, CopyOfData, cbData
  v_XYmessenger_XYreturnValue := Datareceived
  v_XYmessenger_returnMessageProcessed := 1
}

/*
From the XYplorer help file:

COPYDATA

Sends data to another window.

Syntax: copydata hwnd, data, mode 

hwnd: Handle of the target window. 
data: Text data to send. 
mode:
 0: Nothing special, simply send the text data.
 1: Text data is an XYplorer script to be executed by the receiving window (which in this case, of course, has to be XYplorer.exe).
 2: Resolve variables in data and return to sender immediately. Variables are XYplorer native and environment variables.
 3: Pass the value of the data argument as location to another XYplorer instance. Whatever XYplorer accepts in the Address Bar is acceptable here.

Examples:

Run a small script in another XYplorer (197078):
copydata 197078, "::echo 'hi';", 1;

Return the contents of variable <curitem> from another XYplorer (197078) to this window (1573124), using copydata first in this XYplorer process and then again in the other XYplorer process for the return:
copydata 197078, '::copydata 1573124, <curitem>;', 1;

Determine <curitem> in another XYplorer instance (hWnd 197078). Note that the single quotes in the example are essential else <curitem> would be resolved in *this* instance of XYplorer before being sent to the other instance:
copydata 197078, '<curitem>', 2; echo <get copieddata 3>;

Go to "C:\" in the XYplorer instance with hWnd 525048:
copydata 525048, "C:\", 3;

Go to the current path of this instance:
copydata 525048, <curpath>, 3;

Run a script (note that the command only returns when the script is completed in the other instance!):
copydata 525048, 'echo "hi!";', 3;

Notes
· The command only returns when the receiving window has fully processed the data. For example if you send a script the command will return only after the script has terminated. 
· The mode parameter in SC CopyData simply selects different dwData:
If called with mode 0 then cds.dwData == 4194304 (0x00400000)
If called with mode 1 then cds.dwData == 4194305 (0x00400001)
If called with mode 2 then cds.dwData == 4194306 (0x00400002)
If called with mode 3 then cds.dwData == 4194307 (0x00400003)
So any application can use these dwData values to trigger a specific reaction in XYplorer when it receives data via WM_COPYDATA. 


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REMOTE CONTROL *** For software developers only ***

You can run an XYplorer script from an external program using the WM_COPYDATA command with XYplorer's hWnd. This means if you are a programmer you can fully remote control XYplorer.
· cds.dwData: 4194305 (0x00400001) 
· cds.lpData: The syntax is identical to the one of the command line switch /script=<script resource>, so you can either pass the path to a script file (commonly called *.xys), or pass the script directly (must be preceded by ::).


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
COMMAND LINE SWITCH /script

You can run a script on startup directly from the command line. The switch is /script=[script resource], where [script resource] can be:

1) The path to a script file (commonly called *.xys). The file spec is resolved as in the script command load, so you can skip the XYS extension. You can also skip the path if the XYS file is located in the default scripts folder. For example
 XYplorer.exe /script=test
would run the file <xyscripts>\test.xys on startup. If the path contains spaces it must be quoted:
 XYplorer.exe /script="C:\Zen\test one.xys"

2) A script. It must be preceded by ::, and it must not contain double quotes or other characters that might lead to problems when parsing the command line. For example
 XYplorer.exe /script="::msg 'Welcome to XY!';"
Note the double quotes surrounding the whole argument which are needed because of the spaces in the script line.

If your script needs double quotes you should use the quote() function or runq with single quotes:
 XYplorer.exe /script="::run quote('E:\Test\Has Space.txt');"
 XYplorer.exe /script="::runq 'E:\Test\Has Space.txt';"

Tip: You can "pipe" a value instead of quoting it. This can be useful when unpredictable quotes (that might be returned from variables) make predictable parsing impossible, or simply to make a string more readable. For example, this is the same Command Line Switch, first quoted then piped:
 /script="::text '"R:\a b c"';"        (this would not work; parser cannot handle the ambiguous quotes)
 /script=|::text '"R:\a b c"';|        (this does work)
Of course, you must be sure that no pipes can come up inside the value.
*/

;*****************************************************************************************************************