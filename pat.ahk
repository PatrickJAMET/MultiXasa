#include %A_ScriptDir%\JSON.ahk


Loop, read, %A_ScriptDir%\dataPat.ini
    data_json := data_json . A_LoopReadLine  ; When loop finishes, this will hold the last line.

;FileDelete, %A_ScriptDir%\test.ini

saveData(data){
	print := JSON.Dump(data,,1)
	FileDelete, %A_ScriptDir%\dataPat.ini
	FileAppend, %print%, %A_ScriptDir%\dataPat.ini
}

ModultiScriptType = %A_ScriptName%
StringRight, ModultiScriptType, ModultiScriptType, 3

CurrentSelect := 1
charSelected := 1
nbChar := 0
finder := false

data := JSON.load(data_json)

OnMessage(0x204, "WM_RBUTTONDOWN")

unselected := Object()

Gui, Add, Button, gresizeAll vFinder x5, OFF
Gui,Add,Picture, y12 gresizeAll viconFinder,%A_ScriptDir%\look\CheckerOff.png


key = a

if(data.name[5] <> "")
;MsgBox, % " - " data.name[5] " - "

;data.name[5] := "test2"
saveData(data)

gosub,setup
return




setup:
key :=data.next_key
Hotkey, $%key% , nextChar, On

loop, 8{
	name := data.name[A_Index]
	if(name <> ""){
		unselected[A_Index] = false
		nbChar := nbChar + 1
	}
	else break
}



gui, font, s15, Verdana 

Gui, Add, ListView, r%nbChar% w200 -Hdr  gMyListView AltSubmit  X5 Y30,name | deactivate

loop, 8{
	name := data.name[A_Index]
	if(name <> ""){
		LV_Add("", "   "+name, "")
		LV_ModifyCol() 
		;Gui, Add, Text, v%A_Index% gSelectChar, %name%
		if(A_Index = charSelected){
			GuiControl, +cBlue +Redraw, %A_Index%
		}
		;nbChar := nbChar + 1
	}
	else break
}

name := data.name[1]
LV_Modify(1, "Col1", "> "+ name )

Gui, Show,AutoSize, Pat Multi
return


MyListView:
if A_GuiEvent = DoubleClick
{
	LV_Modify(A_EventInfo, "-Select")

    LV_GetText(RowText, A_EventInfo) 
    ;ToolTip You double-clicked row number %A_EventInfo%. Text: "%RowText%"
}
if A_GuiEvent = RightClick
{
	LV_Modify(A_EventInfo, "-Select")
    n = data.name[A_EventInfo]

    unselected[A_EventInfo] := unselected[A_EventInfo] ? false : true
    t := unselected[A_EventInfo] ? "-": "" 
	LV_Modify(A_EventInfo, "Col2", t )

	LV_GetText(RowText, A_EventInfo) 
    ;ToolTip You Right-clicked row number %A_EventInfo%. Text: "%RowText%"
}
if A_GuiEvent = Normal
{
	CurrentSelect := A_EventInfo
	LV_Modify(A_EventInfo, "-Select")
	gosub, SelectCharNormal

	;LV_GetText(RowText, A_EventInfo) 
    ;ToolTip You clicked row number %A_EventInfo%. Text: "%RowText%"
}
return


nextChar:
;MsgBox , ok
gosub, SelectNext
key :=data.next_key
Send, {%key%}
return

GuiClose:		;close Gui to Exit
GuiEscape:		;press Esc to Exit
if (finder){
	if (ModultiScriptType = "ahk")
	CloseScript("PatMultiFinder.ahk")
	else if (ModultiScriptType = "exe")
	CloseScript("PatMultiFinder.exe")
}
ExitApp

SelectChar:

	CurrentSelect := A_GuiControl

	gosub, SelectCharNormal
	
	;MsgBox, %n% - %charSelected%
return

SelectCharNormal:
	n := data.name[charSelected]
	LV_Modify(charSelected, "Col1", "   "+ n )
	GuiControl, +cBlack +Redraw, %charSelected%
	gui,Show 
	gui, font, norm
	n := data.name[CurrentSelect]
	charSelected := CurrentSelect
	LV_Modify(CurrentSelect, "Col1", "> "+ n )
	LV_ModifyCol() 
	GuiControl, +cBlue +Redraw, %charSelected%

	c := data.window
    WinActivate, %n%%c%

return

SelectNext:
next :=  charSelected + 1
if (next = nbChar+1 ){ 
	    next := 1
    }
while(unselected[next]){
	
	next :=  next + 1

	if (next = nbChar+1 ){ 
	    next := 1
    }
}


CurrentSelect := next
gosub, SelectCharNormal
;MsgBox, current %charSelected% next %next%

return

WM_RBUTTONDOWN()
{
	;MouseGetPos,,,,ControlName
	;MsgBox, %ControlName%
}

resizeAll:

data_json_ := ""
Loop, read, %A_ScriptDir%\dataPat.ini 
    data_json_ := data_json_ . A_LoopReadLine  ; When loop finishes, this will hold the last line.

data_size := JSON.load(data_json_)
x:=  data_size.resize.x
y:=  data_size.resize.y
width:=  data_size.resize.width
height:=  data_size.resize.height
loop, %nbChar%{

	name := data.name[A_Index]
    WinMove, %name%,, %x%, %y% , %width%, %height%
}
;ToolTip  ok %nbChar% %x%


if(finder = false){
	GuiControl ,, Finder, ON
	finder := true
	Guicontrol,, iconFinder, %A_ScriptDir%\look\CheckerOn.png

	if (ModultiScriptType = "ahk")
	Run, PatMultiFinder.ahk
	else if (ModultiScriptType = "exe")
	Run, PatMultiFinder.exe

}
else {
	GuiControl ,, Finder, OFF
	finder := false
	Guicontrol,, iconFinder, %A_ScriptDir%\look\CheckerOff.png
	if (ModultiScriptType = "ahk")
	CloseScript("PatMultiFinder.ahk")
	else if (ModultiScriptType = "exe")
	CloseScript("PatMultiFinder.exe")

}
return

CloseScript(Name)
{
	DetectHiddenWindows On
	SetTitleMatchMode RegEx
	IfWinExist, i)%Name%.* ahk_class AutoHotkey
	{
		WinClose
		WinWaitClose, i)%Name%.* ahk_class AutoHotkey, , 2
		If ErrorLevel
			return "Unable to close " . Name
		else
			return "Closed " . Name
	}
	else
		return Name . " not found"
}


F17::
CurrentSelect := 1
gosub, SelectCharNormal
return

F18::
CurrentSelect := 2
gosub, SelectCharNormal
return

F19::
CurrentSelect := 3
gosub, SelectCharNormal
return

F20::
CurrentSelect := 4
gosub, SelectCharNormal
return

F21::
CurrentSelect := 5
gosub, SelectCharNormal
return

F22::
CurrentSelect := 6
gosub, SelectCharNormal
return

F23::
CurrentSelect := 7
gosub, SelectCharNormal
return

F24::
CurrentSelect := 8
gosub, SelectCharNormal
return