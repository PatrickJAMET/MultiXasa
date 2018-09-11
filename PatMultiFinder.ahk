#include %A_ScriptDir%\JSON.ahk

Loop, read, %A_ScriptDir%\dataPat.ini
    data_json := data_json . A_LoopReadLine  ; When loop finishes, this will hold the last line.

data := JSON.load(data_json)


if(Timeout < 0){
	Timeout = 200
}

Timeout := data.timeout

Xarea1 := data.finder.x
Yarea1 := data.finder.y
Xarea2 := Xarea1 +  data.finder.width
Yarea2 := Yarea1 +  data.finder.height

ConsoleSend("find  " . Xarea1 . " - " . Xarea2 . "- " . Yarea1 . "- " . Yarea2, "ahk_class ConsoleWindowClass")

nbChar := 0
loop, 8{
    name := data.name[A_Index]
    ConsoleSend("find  " . name, "ahk_class ConsoleWindowClass")
    if(name <> ""){
        unselected[A_Index] = false
        nbChar := nbChar + 1
    }
    else break
}


regocheck:
Sleep, 200


;ConsoleSend("Hooray, it works! - - " . Xarea1 . "," . Yarea1 . " -- " .  Xarea2 . "," . Yarea2 . " ? " , "ahk_class ConsoleWindowClass")

loop, %nbChar%{
    name_ := data.name[A_Index]
     ;ConsoleSend("check  " . A_Index . " - " . name_ , "ahk_class ConsoleWindowClass")

    ImageSearch, FindOutX, FindOutY,%Xarea1%,%Yarea1%,%Xarea2%,%Yarea2%, *20 %A_ScriptDir%\finder\%name_%.png
    if (FindOutX > 0 OR FindOutY >0)
    {
        ConsoleSend("detect- - " . name_)
    FindOutX := 0
    c := data.window
    WinActivate, %name_%%c%
    F_ := A_Index + 16
    Send, {F%F_%}
    ;Send, {F17}
    ;sendDataFromPos(A_Index,NumCurrentComposition,name_)
    Sleep, 750
    }
}

goto, regocheck
return

sendDataFromPos(posname, mainpos, name){

    loop,8
    {
        IniRead, pos, %A_ScriptDir%\data.ini, OrderCompo%mainpos%, %A_Index%posuseby
       
        if(pos = posname){
            ConsoleSend("----- name " . name . "posname = " . posname . ", pos = " . pos , "ahk_class ConsoleWindowClass")
            F_ := A_Index + 16
            Send, {F%F_%}
            break
        }
    }
}

ConsoleSend(text, WinTitle="", WinText="", ExcludeTitle="", ExcludeText="")
{
    WinGet, pid, PID, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    if !pid
        return false, ErrorLevel:="window"
    ; Attach to the console belonging to %WinTitle%'s process.
    if !DllCall("AttachConsole", "uint", pid)
        return false, ErrorLevel:="AttachConsole"
    hConIn := DllCall("CreateFile", "str", "CONIN$", "uint", 0xC0000000
                , "uint", 0x3, "uint", 0, "uint", 0x3, "uint", 0, "uint", 0)
    if hConIn = -1
        return false, ErrorLevel:="CreateFile"
    
    VarSetCapacity(ir, 24, 0)       ; ir := new INPUT_RECORD
    NumPut(1, ir, 0, "UShort")      ; ir.EventType := KEY_EVENT
    NumPut(1, ir, 8, "UShort")      ; ir.KeyEvent.wRepeatCount := 1
    ; wVirtualKeyCode, wVirtualScanCode and dwControlKeyState are not needed,
    ; so are left at the default value of zero.
    
    Loop, Parse, text ; for each character in text
    {
        NumPut(Asc(A_LoopField), ir, 14, "UShort")
        
        NumPut(true, ir, 4, "Int")  ; ir.KeyEvent.bKeyDown := true
        gosub ConsoleSendWrite
        
        NumPut(false, ir, 4, "Int") ; ir.KeyEvent.bKeyDown := false
        gosub ConsoleSendWrite
    }
    gosub ConsoleSendCleanup
    return true
    
    ConsoleSendWrite:
        if ! DllCall("WriteConsoleInput", "uint", hconin, "uint", &ir, "uint", 1, "uint*", 0)
        {
            gosub ConsoleSendCleanup
            return false, ErrorLevel:="WriteConsoleInput"
        }
    return
    
    ConsoleSendCleanup:
        if (hConIn!="" && hConIn!=-1)
            DllCall("CloseHandle", "uint", hConIn)
        ; Detach from %WinTitle%'s console.
        DllCall("FreeConsole")
    return
}