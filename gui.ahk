; Create a GUI window
Gui, Add, Text, x20 y20 w100 h20, Hello, World!
Gui, Add, Button, x20 y50 w100 h30 gButtonClicked, Click Me
Gui, Show, w200 h100, My First GUI Window
return

ButtonClicked:
    MsgBox, Button clicked!
return

GuiClose:
    ExitApp