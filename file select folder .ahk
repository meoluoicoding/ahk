;source: https://www.autohotkey.com/boards/viewtopic.php?f=76&t=53136&p=231879#p231879

#SingleInstance,Force

ESC::ExitApp

F1::
Result := ChooseFile( [0, "Dialog title - ChooseFile.."]
                     , A_Desktop "\Select File"
                     , {All: "`n*.*", Music: "*.mp3", Images: "*.jpg;*.png", Videos: "*.avi;*.mp4;*.mkv;*.wmp", Documents: "*.txt"}
                     , [A_WinDir,A_Desktop,A_Temp,A_Startup,A_ProgramFiles]
                     , 0x10000000 | 0x02000000 | 0x00000200 | 0x00001000 )
If ((List := "") == "" && Result != FALSE)
    For Each, File in Result
        List .= File . "`n"
If List
    MsgBox % List
return


F2::
Result := ChooseFolder( [0, "Dialog title - ChooseFolder.."]
                       , A_Desktop
                       , [A_WinDir,A_Desktop,A_Temp,A_Startup,A_ProgramFiles,"C:\Users\juho2\Desktop\Temporary Scripts"]
                       , 0x10000000 | 0x02000000 | 0x00000200 )
List := ""
For Each, Directory in Result
    List .= Directory . "`n"
If List
    MsgBox % List
return


F3::
path := SaveFile( [0, "Dialog title - SaveFile.."]
                  , A_Desktop "\Select File"
                  , {Music: "*.mp3", Images: "`n*.jpg;*.png", Videos: "*.avi;*.mp4;*.mkv;*.wmp", Documents: "*.txt"}
                  , [A_WinDir,A_Desktop,A_Temp,A_Startup,A_ProgramFiles]
                  , 0x00000002 | 0x00000004 | 0x10000000 | 0x02000000 )
If path
    MsgBox % path
return




;------------------------------------------------------------------------------------------

DirExist(DirName)
{
    loop Files, % DirName, D
        return A_LoopFileAttrib
}
StrPutVar(string, ByRef var, encoding)
{
    ; Ensure capacity.
    VarSetCapacity( var, StrPut(string, encoding)
        ; StrPut returns char count, but VarSetCapacity needs bytes.
        * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
    ; Copy or convert the string.
    return StrPut(string, &var, encoding)
} ; https://www.autohotkey.com/docs/commands/StrPut.htm#Examples

/*
    Displays a standard dialog that allows the user to select folder(s).
    Parameters:
        Owner / Title:
            The identifier of the window that owns this dialog. This value can be zero.
            An Array with the identifier of the owner window and the title. If the title is an empty string, it is set to the default.
        StartingFolder:
            The path to the directory selected by default. If the directory does not exist, it searches in higher directories.
        CustomPlaces:
            Specify an Array with the custom directories that will be displayed in the left pane. Missing directories will be omitted.
            To specify the location in the list, specify an Array with the directory and its location (0 = Lower, 1 = Upper).
        Options:
            Determines the behavior of the dialog. This parameter must be one or more of the following values.
            0x00000200 (FOS_ALLOWMULTISELECT) = Enables the user to select multiple items in the open dialog.
            0x00040000 (FOS_HIDEPINNEDPLACES) = Hide items shown by default in the view's navigation pane.
            0x02000000  (FOS_DONTADDTORECENT) = Do not add the item being opened or saved to the recent documents list (SHAddToRecentDocs).
            0x10000000  (FOS_FORCESHOWHIDDEN) = Include hidden and system items.
            You can check all available values ??at https://msdn.microsoft.com/en-us/library/windows/desktop/dn457282(v=vs.85).aspx.
    Return:
        Returns zero if the user canceled the dialog, otherwise returns the path of the selected directory. The directory never ends with "\".
*/
ChooseFolder(Owner, StartingFolder := "", CustomPlaces := "", Options := 0)
{
    ; IFileOpenDialog interface
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775834(v=vs.85).aspx
    local IFileOpenDialog := ComObjCreate("{DC1C5A9C-E88A-4DDE-A5A1-60F82A20AEF7}", "{D57C7288-D4AD-4768-BE02-9D969532D960}")
        ,           Title := IsObject(Owner) ? Owner[2] . "" : ""
        ,           Flags := 0x20 | Options    ; FILEOPENDIALOGOPTIONS enumeration (https://msdn.microsoft.com/en-us/library/windows/desktop/dn457282(v=vs.85).aspx)
        ,      IShellItem := PIDL := 0         ; PIDL recibe la direcci�n de memoria a la estructura ITEMIDLIST que debe ser liberada con la funci�n CoTaskMemFree
        ,             Obj := {}, foo := bar := ""
    Owner := IsObject(Owner) ? Owner[1] : (WinExist("ahk_id" . Owner) ? Owner : 0)
    CustomPlaces := IsObject(CustomPlaces) || CustomPlaces == "" ? CustomPlaces : [CustomPlaces]


    while (InStr(StartingFolder, "\") && !DirExist(StartingFolder))
        StartingFolder := SubStr(StartingFolder, 1, InStr(StartingFolder, "\",, -1) - 1)
    if ( DirExist(StartingFolder) )
    {
        StrPutVar(StartingFolder, StartingFolderW, "UTF-16")
        DllCall("Shell32.dll\SHParseDisplayName", "UPtr", &StartingFolderW, "Ptr", 0, "UPtrP", PIDL, "UInt", 0, "UInt", 0)
        DllCall("Shell32.dll\SHCreateShellItem", "Ptr", 0, "Ptr", 0, "UPtr", PIDL, "UPtrP", IShellItem)
        ObjRawSet(Obj, IShellItem, PIDL)
        ; IFileDialog::SetFolder method
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761828(v=vs.85).aspx
        DllCall(NumGet(NumGet(IFileOpenDialog+0)+12*A_PtrSize), "Ptr", IFileOpenDialog, "UPtr", IShellItem)
    }


    if ( IsObject(CustomPlaces) )
    {
        local Directory := ""
        For foo, Directory in CustomPlaces    ; foo = index
        {
            foo := IsObject(Directory) ? Directory[2] : 0    ; FDAP enumeration (https://msdn.microsoft.com/en-us/library/windows/desktop/bb762502(v=vs.85).aspx)
            if ( DirExist(Directory := IsObject(Directory) ? Directory[1] : Directory) )
            {
                StrPutVar(Directory, DirectoryW, "UTF-16")
                DllCall("Shell32.dll\SHParseDisplayName", "UPtr", &DirectoryW, "Ptr", 0, "UPtrP", PIDL, "UInt", 0, "UInt", 0)
                DllCall("Shell32.dll\SHCreateShellItem", "Ptr", 0, "Ptr", 0, "UPtr", PIDL, "UPtrP", IShellItem)
                ObjRawSet(Obj, IShellItem, PIDL)
                ; IFileDialog::AddPlace method
                ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775946(v=vs.85).aspx
                DllCall(NumGet(NumGet(IFileOpenDialog+0)+21*A_PtrSize), "UPtr", IFileOpenDialog, "UPtr", IShellItem, "UInt", foo)
            }
        }
    }


    ; IFileDialog::SetTitle method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761834(v=vs.85).aspx
    StrPutVar(Title, TitleW, "UTF-16")
    DllCall(NumGet(NumGet(IFileOpenDialog+0)+17*A_PtrSize), "UPtr", IFileOpenDialog, "UPtr", Title == "" ? 0 : &TitleW)

    ; IFileDialog::SetOptions method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761832(v=vs.85).aspx
    DllCall(NumGet(NumGet(IFileOpenDialog+0)+9*A_PtrSize), "UPtr", IFileOpenDialog, "UInt", Flags)


    ; IModalWindow::Show method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761688(v=vs.85).aspx
    local Result := []
    if ( !DllCall(NumGet(NumGet(IFileOpenDialog+0)+3*A_PtrSize), "UPtr", IFileOpenDialog, "Ptr", Owner, "UInt") )
    {
        ; IFileOpenDialog::GetResults method
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775831(v=vs.85).aspx
        local IShellItemArray := 0    ; IShellItemArray interface (https://msdn.microsoft.com/en-us/library/windows/desktop/bb761106(v=vs.85).aspx)
        DllCall(NumGet(NumGet(IFileOpenDialog+0)+27*A_PtrSize), "UPtr", IFileOpenDialog, "UPtrP", IShellItemArray)

        ; IShellItemArray::GetCount method
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761098(v=vs.85).aspx
        local Count := 0    ; pdwNumItems
        DllCall(NumGet(NumGet(IShellItemArray+0)+7*A_PtrSize), "UPtr", IShellItemArray, "UIntP", Count)

        local Buffer := ""
        VarSetCapacity(Buffer, 32767 * 2)
        loop % Count
        {
            ; IShellItemArray::GetItemAt method
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761100(v=vs.85).aspx
            DllCall(NumGet(NumGet(IShellItemArray+0)+8*A_PtrSize), "UPtr", IShellItemArray, "UInt", A_Index-1, "UPtrP", IShellItem)

            ; IShellItem::GetDisplayName method
            ; https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-ishellitem-getdisplayname
            DllCall(NumGet(NumGet(IShellItem+0)+5*A_PtrSize), "Ptr", IShellItem, "Int", 0x80028000, "PtrP", ptr:=0)
            ObjRawSet(Obj, IShellItem, ptr), ObjPush(Result, RTrim(StrGet(ptr,"UTF-16"), "\"))

            if (Result[A_Index] ~= "^::")  ; handle "::{00000000-0000-0000-0000-000000000000}\Documents.library-ms" (library)
            {
            	; SHLoadLibraryFromParsingName
            	; https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-shloadlibraryfromparsingname
                VarSetCapacity(IID_IShellItem, 16)
                DllCall("Ole32\CLSIDFromString", "Str", "{43826d1e-e718-42ee-bc55-a1e261c37bfe}", "Ptr", &IID_IShellItem)
                DllCall("Shell32\SHCreateItemFromParsingName", "WStr", Result[A_Index], "Ptr", 0, "Ptr", &IID_IShellItem, "PtrP", IShellItem:=0)

                IShellLibrary := ComObjCreate("{d9b3211d-e57f-4426-aaef-30a806add397}", "{11A66EFA-382E-451A-9234-1E0E12EF3085}")
                ; IShellLibrary::LoadLibraryFromItem
                ; https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nn-shobjidl_core-ishelllibrary
                DllCall(NumGet(NumGet(IShellLibrary+0)+3*A_PtrSize), "UPtr", IShellLibrary, "Ptr", IShellItem, "Int", 0)
                IShellLibrary2 := ComObjQuery(IShellLibrary, "{11A66EFA-382E-451A-9234-1E0E12EF3085}")
                ObjRelease(IShellLibrary)
                ObjRelease(IShellItem)

                VarSetCapacity(IID_IShellItemArray, 16)
                DllCall("Ole32\CLSIDFromString", "Str", "{b63ea76d-1f85-456f-a19c-48159efa858b}", "Ptr", &IID_IShellItemArray)
                ; IShellLibrary::GetFolders method
                ; https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-ishelllibrary-getfolders
                DllCall(NumGet(NumGet(IShellLibrary2+0)+7*A_PtrSize), "UPtr", IShellLibrary2, "Int", 1, "Ptr", &IID_IShellItemArray, "PtrP", IShellItemArray:=0)

                DllCall(NumGet(NumGet(IShellItemArray+0)+8*A_PtrSize), "UPtr", IShellItemArray, "Int", 0, "PtrP", IShellItem0:=0)
                DllCall(NumGet(NumGet(IShellItem0+0)+5*A_PtrSize), "Ptr", IShellItem0, "Int", 0x80028000, "PtrP", ptr:=0)
                Result[A_Index] := StrGet(ptr, "UTF-16")
                DllCall("Ole32\CoTaskMemFree", "Ptr", ptr)
                ObjRelease(IShellItem0)
                ObjRelease(IShellItemArray)
                ObjRelease(IShellLibrary2)
            }
        }

        ObjRelease(IShellItemArray)
    }


    for foo, bar in Obj    ; foo = IShellItem interface (ptr)  |  bar = PIDL structure (ptr)
        ObjRelease(foo), DllCall("Ole32.dll\CoTaskMemFree", "Ptr", bar)
    ObjRelease(IFileOpenDialog)

    return ObjLength(Result) ? ( Options & 0x200 ? Result : Result[1] ) : FALSE
}


/*
    Displays a standard dialog that allows the user to open file(s).
    Parameters:
        Owner / Title:
            The identifier of the window that owns this dialog. This value can be zero.
            An Array with the identifier of the owner window and the title. If the title is an empty string, it is set to the default.
        FileName:
            The path to the file or directory selected by default. If you specify a directory, it must end with a backslash.
        Filter:
            Specify a file filter. You must specify an object, each key represents the description and the value the file types.
            To specify the filter selected by default, add the "`n" character to the value.
        CustomPlaces:
            Specify an Array with the custom directories that will be displayed in the left pane. Missing directories will be omitted.
            To specify the location in the list, specify an Array with the directory and its location (0 = Lower, 1 = Upper).
        Options:
            Determines the behavior of the dialog. This parameter must be one or more of the following values.
                0x00000200 (FOS_ALLOWMULTISELECT) = Enables the user to select multiple items in the open dialog.
                0x00001000    (FOS_FILEMUSTEXIST) = The item returned must exist.
                0x00040000 (FOS_HIDEPINNEDPLACES) = Hide items shown by default in the view's navigation pane.
                0x02000000  (FOS_DONTADDTORECENT) = Do not add the item being opened or saved to the recent documents list (SHAddToRecentDocs).
                0x10000000  (FOS_FORCESHOWHIDDEN) = Include hidden and system items.
            You can check all available values ??at https://msdn.microsoft.com/en-us/library/windows/desktop/dn457282(v=vs.85).aspx.
    Return:
        Returns 0 if the user canceled the dialog, otherwise returns the path of the selected file.
        If you specified the FOS_ALLOWMULTISELECT option and the function succeeded, it returns an Array with the path of the selected files.
*/
ChooseFile(Owner, FileName := "", Filter := "", CustomPlaces := "", Options := 0x1000)
{
    ; IFileOpenDialog interface
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775834(v=vs.85).aspx
    local IFileOpenDialog := ComObjCreate("{DC1C5A9C-E88A-4DDE-A5A1-60F82A20AEF7}", "{D57C7288-D4AD-4768-BE02-9D969532D960}")
        ,           Title := IsObject(Owner) ? Owner[2] . "" : ""
        ,           Flags := Options     ; FILEOPENDIALOGOPTIONS enumeration (https://msdn.microsoft.com/en-us/library/windows/desktop/dn457282(v=vs.85).aspx)
        ,      IShellItem := PIDL := 0   ; PIDL recibe la direcci�n de memoria a la estructura ITEMIDLIST que debe ser liberada con la funci�n CoTaskMemFree
        ,             Obj := {COMDLG_FILTERSPEC: ""}, foo := bar := ""
        ,       Directory := FileName
    Owner := IsObject(Owner) ? Owner[1] : (WinExist("ahk_id" . Owner) ? Owner : 0)
    Filter := IsObject(Filter) ? Filter : {"All files": "*.*"}


    if ( FileName != "" )
    {
        if ( InStr(FileName, "\") )
        {
            if !( FileName ~= "\\$" )    ; si �FileName� termina con "\" se trata de una carpeta
            {
                local File := ""
                SplitPath FileName, File, Directory
                ; IFileDialog::SetFileName
                ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775974(v=vs.85).aspx
                StrPutVar(File, FileW, "UTF-16")
                DllCall(NumGet(NumGet(IFileOpenDialog+0)+15*A_PtrSize), "UPtr", IFileOpenDialog, "UPtr", &FileW)
            }
            
            while ( InStr(Directory,"\") && !DirExist(Directory) )                   ; si el directorio no existe buscamos directorios superiores
                Directory := SubStr(Directory, 1, InStr(Directory, "\",, -1) - 1)    ; recupera el directorio superior
            if ( DirExist(Directory) )
            {
                StrPutVar(Directory, DirectoryW, "UTF-16")
                DllCall("Shell32.dll\SHParseDisplayName", "UPtr", &DirectoryW, "Ptr", 0, "UPtrP", PIDL, "UInt", 0, "UInt", 0)
                DllCall("Shell32.dll\SHCreateShellItem", "Ptr", 0, "Ptr", 0, "UPtr", PIDL, "UPtrP", IShellItem)
                ObjRawSet(Obj, IShellItem, PIDL)
                ; IFileDialog::SetFolder method
                ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761828(v=vs.85).aspx
                DllCall(NumGet(NumGet(IFileOpenDialog+0)+12*A_PtrSize), "Ptr", IFileOpenDialog, "UPtr", IShellItem)
            }
        }
        else
        {
            StrPutVar(FileName, FileNameW, "UTF-16")
            DllCall(NumGet(NumGet(IFileOpenDialog+0)+15*A_PtrSize), "UPtr", IFileOpenDialog, "UPtr", &FileNameW)
        }
    }
    

    ; COMDLG_FILTERSPEC structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773221(v=vs.85).aspx
    local Description := "", FileTypes := "", FileTypeIndex := 1
    ObjSetCapacity(Obj, "COMDLG_FILTERSPEC", 2*Filter.Count() * A_PtrSize)
    for Description, FileTypes in Filter
    {
        FileTypeIndex := InStr(FileTypes,"`n") ? A_Index : FileTypeIndex
        StrPutVar(Trim(Description), desc_%A_Index%, "UTF-16")
        StrPutVar(Trim(StrReplace(FileTypes,"`n")), ft_%A_Index%, "UTF-16")
        NumPut(&desc_%A_Index%, ObjGetAddress(Obj,"COMDLG_FILTERSPEC") + A_PtrSize * 2*(A_Index-1))        ; COMDLG_FILTERSPEC.pszName
        NumPut(&ft_%A_Index%, ObjGetAddress(Obj,"COMDLG_FILTERSPEC") + A_PtrSize * (2*(A_Index-1)+1))    ; COMDLG_FILTERSPEC.pszSpec
    }

    ; IFileDialog::SetFileTypes method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775980(v=vs.85).aspx
    DllCall(NumGet(NumGet(IFileOpenDialog+0)+4*A_PtrSize), "UPtr", IFileOpenDialog, "UInt", Filter.Count(), "UPtr", ObjGetAddress(Obj,"COMDLG_FILTERSPEC"))

    ; IFileDialog::SetFileTypeIndex method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775978(v=vs.85).aspx
    DllCall(NumGet(NumGet(IFileOpenDialog+0)+5*A_PtrSize), "UPtr", IFileOpenDialog, "UInt", FileTypeIndex)

    
    if ( IsObject(CustomPlaces := IsObject(CustomPlaces) || CustomPlaces == "" ? CustomPlaces : [CustomPlaces]) )
    {
        for foo, Directory in CustomPlaces    ; foo = index
        {
            foo := IsObject(Directory) ? Directory[2] : 0    ; FDAP enumeration (https://msdn.microsoft.com/en-us/library/windows/desktop/bb762502(v=vs.85).aspx)
            if ( DirExist(Directory := IsObject(Directory) ? Directory[1] : Directory) )
            {
                StrPutVar(Directory, DirectoryW, "UTF-16")
                DllCall("Shell32.dll\SHParseDisplayName", "UPtr", &DirectoryW, "Ptr", 0, "UPtrP", PIDL, "UInt", 0, "UInt", 0)
                DllCall("Shell32.dll\SHCreateShellItem", "Ptr", 0, "Ptr", 0, "UPtr", PIDL, "UPtrP", IShellItem)
                ObjRawSet(Obj, IShellItem, PIDL)
                ; IFileDialog::AddPlace method
                ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775946(v=vs.85).aspx
                DllCall(NumGet(NumGet(IFileOpenDialog+0)+21*A_PtrSize), "UPtr", IFileOpenDialog, "UPtr", IShellItem, "UInt", foo)
            }
        }
    }


    ; IFileDialog::SetTitle method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761834(v=vs.85).aspx
    StrPutVar(Title, TitleW, "UTF-16")
    DllCall(NumGet(NumGet(IFileOpenDialog+0)+17*A_PtrSize), "UPtr", IFileOpenDialog, "UPtr", Title == "" ? 0 : &TitleW)

    ; IFileDialog::SetOptions method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761832(v=vs.85).aspx
    DllCall(NumGet(NumGet(IFileOpenDialog+0)+9*A_PtrSize), "UPtr", IFileOpenDialog, "UInt", Flags)


    ; IModalWindow::Show method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761688(v=vs.85).aspx
    local Result := []
    if ( !DllCall(NumGet(NumGet(IFileOpenDialog+0)+3*A_PtrSize), "UPtr", IFileOpenDialog, "Ptr", Owner, "UInt") )
    {
        ; IFileOpenDialog::GetResults method
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775831(v=vs.85).aspx
        local IShellItemArray := 0    ; IShellItemArray interface (https://msdn.microsoft.com/en-us/library/windows/desktop/bb761106(v=vs.85).aspx)
        DllCall(NumGet(NumGet(IFileOpenDialog+0)+27*A_PtrSize), "UPtr", IFileOpenDialog, "UPtrP", IShellItemArray)

        ; IShellItemArray::GetCount method
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761098(v=vs.85).aspx
        local Count := 0    ; pdwNumItems
        DllCall(NumGet(NumGet(IShellItemArray+0)+7*A_PtrSize), "UPtr", IShellItemArray, "UIntP", Count, "UInt")

        local Buffer := ""
        loop % 0*VarSetCapacity(Buffer,32767 * 2) + Count
        {
            ; IShellItemArray::GetItemAt method
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761100(v=vs.85).aspx
            DllCall(NumGet(NumGet(IShellItemArray+0)+8*A_PtrSize), "UPtr", IShellItemArray, "UInt", A_Index-1, "UPtrP", IShellItem)
            DllCall("Shell32.dll\SHGetIDListFromObject", "UPtr", IShellItem, "UPtrP", PIDL)
            DllCall("Shell32.dll\SHGetPathFromIDListEx", "UPtr", PIDL, "Str", Buffer, "UInt", 32767, "UInt", 0)
            ObjRawSet(Obj, IShellItem, PIDL), ObjPush(Result, StrGet(&Buffer, "UTF-16"))
        }

        ObjRelease(IShellItemArray)
    }


    for foo, bar in Obj    ; foo = IShellItem interface (ptr)  |  bar = PIDL structure (ptr)
        if foo is integer    ; IShellItem?
            ObjRelease(foo), DllCall("Ole32.dll\CoTaskMemFree", "UPtr", bar)
    ObjRelease(IFileOpenDialog)

    return ObjLength(Result) ? (Options & 0x200 ? Result : Result[1]) : FALSE
}




/*
    Displays a standard dialog that allows the user to save a file.
    Parameters:
        Owner / Title:
            The identifier of the window that owns this dialog. This value can be zero.
            An Array with the identifier of the owner window and the title. If the title is an empty string, it is set to the default.
        FileName:
            The path to the file or directory selected by default. If you specify a directory, it must end with a backslash.
        Filter:
            Specify a file filter. You must specify an object, each key represents the description and the value the file types.
            To specify the filter selected by default, add the "`n" character to the value.
        CustomPlaces:
            Specify an Array with the custom directories that will be displayed in the left pane. Missing directories will be omitted.
            To specify the location in the list, specify an Array with the directory and its location (0 = Lower, 1 = Upper).
        Options:
            Determines the behavior of the dialog. This parameter must be one or more of the following values.
                0x00000002  (FOS_OVERWRITEPROMPT) = When saving a file, prompt before overwriting an existing file of the same name.
                0x00000004  (FOS_STRICTFILETYPES) = Only allow the user to choose a file that has one of the file name extensions specified through Filter.
                0x00040000 (FOS_HIDEPINNEDPLACES) = Hide items shown by default in the view's navigation pane.
                0x10000000  (FOS_FORCESHOWHIDDEN) = Include hidden and system items.
                0x02000000  (FOS_DONTADDTORECENT) = Do not add the item being opened or saved to the recent documents list (SHAddToRecentDocs).
            You can check all available values at https://msdn.microsoft.com/en-us/library/windows/desktop/dn457282(v=vs.85).aspx.
    Return:
        Returns 0 if the user canceled the dialog, otherwise returns the path of the selected file.
*/
SaveFile(Owner, FileName := "", Filter := "", CustomPlaces := "", Options := 0x6)
{
    ; IFileSaveDialog interface
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775688(v=vs.85).aspx
    local IFileSaveDialog := ComObjCreate("{C0B4E2F3-BA21-4773-8DBA-335EC946EB8B}", "{84BCCD23-5FDE-4CDB-AEA4-AF64B83D78AB}")
        ,           Title := IsObject(Owner) ? Owner[2] . "" : ""
        ,           Flags := Options     ; FILEOPENDIALOGOPTIONS enumeration (https://msdn.microsoft.com/en-us/library/windows/desktop/dn457282(v=vs.85).aspx)
        ,      IShellItem := PIDL := 0   ; PIDL recibe la direcci�n de memoria a la estructura ITEMIDLIST que debe ser liberada con la funci�n CoTaskMemFree
        ,             Obj := {}, foo := bar := ""
        ,       Directory := FileName
    Owner := IsObject(Owner) ? Owner[1] : (WinExist("ahk_id" . Owner) ? Owner : 0)
    Filter := IsObject(Filter) ? Filter : {"All files": "*.*"}


    if ( FileName != "" )
    {
        if ( InStr(FileName, "\") )
        {
            if !( FileName ~= "\\$" )    ; si �FileName� termina con "\" se trata de una carpeta
            {
                local File := ""
                SplitPath FileName, File, Directory
                ; IFileDialog::SetFileName
                ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775974(v=vs.85).aspx
                StrPutVar(File, FileW, "UTF-16")
                DllCall(NumGet(NumGet(IFileSaveDialog+0)+15*A_PtrSize), "UPtr", IFileSaveDialog, "UPtr", &FileW)
            }
            
            while ( InStr(Directory,"\") && !DirExist(Directory) )                   ; si el directorio no existe buscamos directorios superiores
                Directory := SubStr(Directory, 1, InStr(Directory, "\",, -1) - 1)    ; recupera el directorio superior
            if ( DirExist(Directory) )
            {
                StrPutVar(Directory, DirectoryW, "UTF-16")
                DllCall("Shell32.dll\SHParseDisplayName", "UPtr", &DirectoryW, "Ptr", 0, "UPtrP", PIDL, "UInt", 0, "UInt", 0)
                DllCall("Shell32.dll\SHCreateShellItem", "Ptr", 0, "Ptr", 0, "UPtr", PIDL, "UPtrP", IShellItem)
                ObjRawSet(Obj, IShellItem, PIDL)
                ; IFileDialog::SetFolder method
                ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761828(v=vs.85).aspx
                DllCall(NumGet(NumGet(IFileSaveDialog+0)+12*A_PtrSize), "Ptr", IFileSaveDialog, "UPtr", IShellItem)
            }
        }
        else
        {
            StrPutVar(FileName, FileNameW, "UTF-16")
            DllCall(NumGet(NumGet(IFileSaveDialog+0)+15*A_PtrSize), "UPtr", IFileSaveDialog, "UPtr", &FileNameW)
        }
    }


    ; COMDLG_FILTERSPEC structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773221(v=vs.85).aspx
    local Description := "", FileTypes := "", FileTypeIndex := 1
    ObjSetCapacity(Obj, "COMDLG_FILTERSPEC", 2*Filter.Count() * A_PtrSize)
    for Description, FileTypes in Filter
    {
        FileTypeIndex := InStr(FileTypes,"`n") ? A_Index : FileTypeIndex
        StrPutVar(Trim(Description), desc_%A_Index%, "UTF-16")
        StrPutVar(Trim(StrReplace(FileTypes,"`n")), ft_%A_Index%, "UTF-16")
        NumPut(&desc_%A_Index%, ObjGetAddress(Obj,"COMDLG_FILTERSPEC") + A_PtrSize * 2*(A_Index-1))        ; COMDLG_FILTERSPEC.pszName
        NumPut(&ft_%A_Index%, ObjGetAddress(Obj,"COMDLG_FILTERSPEC") + A_PtrSize * (2*(A_Index-1)+1))    ; COMDLG_FILTERSPEC.pszSpec
    }

    ; IFileDialog::SetFileTypes method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775980(v=vs.85).aspx
    DllCall(NumGet(NumGet(IFileSaveDialog+0)+4*A_PtrSize), "UPtr", IFileSaveDialog, "UInt", Filter.Count(), "UPtr", ObjGetAddress(Obj,"COMDLG_FILTERSPEC"))

    ; IFileDialog::SetFileTypeIndex method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775978(v=vs.85).aspx
    DllCall(NumGet(NumGet(IFileSaveDialog+0)+5*A_PtrSize), "UPtr", IFileSaveDialog, "UInt", FileTypeIndex)


    if ( IsObject(CustomPlaces := IsObject(CustomPlaces) || CustomPlaces == "" ? CustomPlaces : [CustomPlaces]) )
    {
        for foo, Directory in CustomPlaces    ; foo = index
        {
            foo := IsObject(Directory) ? Directory[2] : 0    ; FDAP enumeration (https://msdn.microsoft.com/en-us/library/windows/desktop/bb762502(v=vs.85).aspx)
            if ( DirExist(Directory := IsObject(Directory) ? Directory[1] : Directory) )
            {
                StrPutVar(Directory, DirectoryW, "UTF-16")
                DllCall("Shell32.dll\SHParseDisplayName", "UPtr", &DirectoryW, "Ptr", 0, "UPtrP", PIDL, "UInt", 0, "UInt", 0)
                DllCall("Shell32.dll\SHCreateShellItem", "Ptr", 0, "Ptr", 0, "UPtr", PIDL, "UPtrP", IShellItem)
                ObjRawSet(Obj, IShellItem, PIDL)
                ; IFileDialog::AddPlace method
                ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775946(v=vs.85).aspx
                DllCall(NumGet(NumGet(IFileSaveDialog+0)+21*A_PtrSize), "UPtr", IFileSaveDialog, "UPtr", IShellItem, "UInt", foo)
            }
        }
    }


    ; IFileDialog::SetTitle method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761834(v=vs.85).aspx
    StrPutVar(Title, TitleW, "UTF-16")
    DllCall(NumGet(NumGet(IFileSaveDialog+0)+17*A_PtrSize), "UPtr", IFileSaveDialog, "UPtr", Title == "" ? 0 : &TitleW)

    ; IFileDialog::SetOptions method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761832(v=vs.85).aspx
    DllCall(NumGet(NumGet(IFileSaveDialog+0)+9*A_PtrSize), "UPtr", IFileSaveDialog, "UInt", Flags)


    ; IModalWindow::Show method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761688(v=vs.85).aspx
    local Result := FALSE
    if ( !DllCall(NumGet(NumGet(IFileSaveDialog+0)+3*A_PtrSize), "UPtr", IFileSaveDialog, "Ptr", Owner, "UInt") )
    {
        ; IFileDialog::GetResult method
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775964(v=vs.85).aspx
        if ( !DllCall(NumGet(NumGet(IFileSaveDialog+0)+20*A_PtrSize), "UPtr", IFileSaveDialog, "UPtrP", IShellItem) )
        {
            VarSetCapacity(Result, 32767 * 2, 0)
            DllCall("Shell32.dll\SHGetIDListFromObject", "UPtr", IShellItem, "UPtrP", PIDL)
            DllCall("Shell32.dll\SHGetPathFromIDListEx", "UPtr", PIDL, "Str", Result, "UInt", 2000, "UInt", 0)
            Result := StrGet(&Result, "UTF-16")
            ObjRawSet(Obj, IShellItem, PIDL)
        }
    }


    for foo, bar in Obj      ; foo = IShellItem interface (ptr)  |  bar = PIDL structure (ptr)
        if foo is integer    ; IShellItem?
            ObjRelease(foo), DllCall("Ole32.dll\CoTaskMemFree", "UPtr", bar)
    ObjRelease(IFileSaveDialog)

    return Result
}