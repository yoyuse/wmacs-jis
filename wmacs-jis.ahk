; --------------------------------------------------------------------
; - 2021-02-05 new feature: HenkanToCtrl; new option: SandM
; - 2021-02-05 ~vk1D & Tab::Return
; - 2021-02-03 OnClipboardChange("ClipChanged")
; - 2021-02-02 <!Tab::AltTab
; - 2021-02-02 SendCase(), SendQuote(), SendUnquote()
; - 2021-02-02 無変換-q → QuotedInsert()
; - 2021-02-02 無変換-Arrow → C-Arrow
; - 2021-02-01 無変換-BS → C-BS ; 無変換-Del → C-Del
; - 2021-02-01 カタカナ ひらがな → 半角/全角
; - 2021-01-31 S-無変換-c, S-無変換-x for Explorer
; - 2021-01-30 無変換-click → C-Click
; - 2021-01-30 %A_LineFile%\..\wmacs-jis-ttt.ini
; - 2021-01-30 diable S-無変換
; - 2021-01-29 半角/全角 → `~ ; \_ → \_
; - 2021-01-29 rename to wmacs-jis
; - 2021-01-28 no key repeat, long press of 変換, 無変換
; - 2021-01-28 半角/全角 → Esc ; \_ → `~
; - 2021-01-28 WmacsJIS
; --------------------------------------------------------------------

; config
; --------------------------------------------------------------------

#NoEnv
#Warn
#InstallKeybdHook
#UseHook
SendMode Input
SetWorkingDir %A_ScriptDir%

; icon
; --------------------------------------------------------------------

; XXX: wmacs-jis.ico
icon = %A_LineFile%\..\wmacs-jis.ico
If FileExist(icon) {
    Menu, Tray, Icon, %icon%
}

; global variable
; --------------------------------------------------------------------

Global C_q = 0

QuotedInsert() {
    Global C_q
    C_q_x := A_CaretX + 8
    C_q_y := A_CaretY + 16
    ToolTip, C-q, C_q_x, C_q_y
    C_q = 1
    Return
}

; Group NoTTT
; --------------------------------------------------------------------

GroupAdd, NoTTT, ahk_class Hidemaru32Class       ; 秀丸
GroupAdd, NoTTT, ahk_class Emacs                 ; Emacs (Spacemacs)
GroupAdd, NoTTT, ahk_class PuTTY                 ; PuTTY
GroupAdd, NoTTT, ahk_class Vim                   ; GVim
GroupAdd, NoTTT, ahk_class VTWin32               ; TeraTerm
GroupAdd, NoTTT, ahk_class 　                    ; xyzzy
GroupAdd, NoTTT, ahk_exe atom.exe                ; Atom
GroupAdd, NoTTT, ahk_exe Code.exe                ; VS Code

; Group Explorer
; --------------------------------------------------------------------

GroupAdd,Explorer,ahk_class CabinetWClass   ; Explorer
GroupAdd,Explorer,ahk_class ExploreWClass   ; ???
GroupAdd,Explorer,ahk_class Progman         ; Desktop (Program Manager)

; Target
; --------------------------------------------------------------------

isTargetTTT() {
    IfWinActive, ahk_group NoTTT
        Return 0
    Return 1
}

isTargetExplorer() {
    IfWinActive,ahk_group Explorer
        Return 1
    Return 0
}

isTargetTTTExplorer() {
    ; address bar of Explorer window
    If WinActive("ahk_class CabinetWClass") and ActiveControlIsOfClass("Edit") and ParentControlIsOfClass("ComboBox")
        Return 0
    If !ActiveControlIsOfClass("Edit")
        Return 0
    ; address bar of Explorer window
    IfWinActive,ahk_group Explorer
        Return 1
    Return 0
}

ActiveControlIsOfClass(Class) {
    ControlGetFocus, FocusedControl, A
    ControlGet, FocusedControlHwnd, Hwnd,, %FocusedControl%, A
    WinGetClass, FocusedControlClass, ahk_id %FocusedControlHwnd%
    Return (FocusedControlClass=Class)
}

GetParent(hwnd) {
    Return DllCall("GetParent", "UInt", hwnd, "UInt")
}

ParentControlIsOfClass(Class) {
    ControlGetFocus, FocusedControl, A
    ControlGet, FocusedControlHwnd, Hwnd,, %FocusedControl%, A
    FocusedControlHwnd := GetParent(FocusedControlHwnd)
    WinGetClass, FocusedControlClass, ahk_id %FocusedControlHwnd%
    Return (FocusedControlClass=Class)
}

; OnClipboardChange
; --------------------------------------------------------------------

OnClipboardChange("ClipChanged")

; menu
; --------------------------------------------------------------------

; use 変換 key as Ctrl
HenkanToCtrl := 1

; use Space and Mod
SandM := 0
strSandM := "SandM (Space and Mod)"

; separator
Menu, Tray, Add

; use SandM (Space and Mod)
Menu, Tray, Add, %strSandM%, menuSandM
If (SandM == 1) {
    Menu, Tray, Check, %strSandM%
}

; end of Auto-execute Section
Return

menuSandM:
    if (SandM == 1) {
        Menu, Tray, Uncheck, %strSandM%
        SandM := 0
    } else {
        Menu, Tray, Check, %strSandM%
        SandM := 1
    }
    Return

; Date String
; --------------------------------------------------------------------

SendDateStampLong() {
    FormatTime,TimeString,,yyyy-MM-dd
    Send,%TimeString%
}

SendDateStampShort() {
    FormatTime,TimeString,,yyMMdd
    Send,%TimeString%
}

; Muhenkan/Henkan modifier
; --------------------------------------------------------------------

#If

; disable S-無変換
+vk1D::Return

; disable W-無変換
#vk1D::Return

; 変換を修飾キーとして扱うための準備
; 変換を押し続けている限りリピートせず待機
$vk1C::
    startTime := A_TickCount
    KeyWait, vk1C
    keyPressDuration := A_TickCount - startTime
    ; 変換を押している間に他のホットキーが発動した場合は入力しない
    ; 変換を長押ししていた場合も入力しない
    If (A_ThisHotkey == "$vk1C" and keyPressDuration < 200) {
        Send,{vk1C}
    }
    Return

; 無変換を修飾キーとして扱うための準備
; 無変換を押し続けている限りリピートせず待機
$vk1D::
    startTime := A_TickCount
    KeyWait, vk1D
    keyPressDuration := A_TickCount - startTime
    ; 無変換を押している間に他のホットキーが発動した場合は入力しない
    ; 無変換を長押ししていた場合も入力しない
    If (A_ThisHotkey == "$vk1D" and keyPressDuration < 200) {
        Send,{vk1D}
    }
    Return

; SandM (Space and Mod)
; --------------------------------------------------------------------

#If (SandM == 1)

; Space を修飾キーとして扱うための準備
; Space を押し続けている限りリピートせず待機
$Space::
    startTime := A_TickCount
    KeyWait, Space
    keyPressDuration := A_TickCount - startTime
    ; Space を押している間に他のホットキーが発動した場合は入力しない
    ; Space を長押ししていた場合も入力しない
    If (A_ThisHotkey == "$Space" and keyPressDuration < 200) {
        Send,{Space}
    }
    Return

SendBlindSandM(key) {
    mod := ""
    If GetKeyState("Ctrl", "P")
        mod = %mod%^
    If GetKeyState("LShift", "P")
        mod = %mod%+
    If GetKeyState("Alt", "P")
        mod = %mod%!
    If (GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))
        mod = %mod%#
    hkey = %mod%%key%
    Send, %hkey%
    Return
}

; disable LS-Space
*<+Space::Return

; RS-Space → Space (for key repeat)
*>+Space::SendBlindSandM("{Space}")

#If

; OnClipboardChange
; --------------------------------------------------------------------

ClipChanged(Type) {
    if (Type = 1) {
        ; long text
        maxLength := 100
        StringLen, length, Clipboard
        if (length > maxLength) {
            str := SubStr(Clipboard, 1, maxLength)
            ToolTip テキストをコピーしました`n%str%...`n(%length% 文字)
        } else {
            ; short text
            ToolTip テキストをコピーしました`n%Clipboard%
        }
    } else if (Type = 2) {
        ; non text
        ToolTip テキストでないものをコピーしました
    }
    SetTimer, RemoveToolTip, 1500
}

RemoveToolTip() {
    ; SetTimer, RemoveToolTip, Off
    ToolTip
}

; Explorer
; --------------------------------------------------------------------

#If (isTargetExplorer())

CopyFileName() {
    Clipboard =
    Send,^c
    ClipWait,2
    ;;
    paths := Clipboard
    names :=
    Loop,Parse,paths,`n,`r
    {
        SplitPath,A_LoopField,name
        If names !=
            names .= "`r`n"
        names .= name
    }
    ;;
    Clipboard := names
}

CopyFilePath() {
    Clipboard =
    Send,^c
    ClipWait,2
    ;;
    names := Clipboard
    Clipboard := names
}

+^c::CopyFileName()
+^x::CopyFilePath()

#If (isTargetExplorer() and GetKeyState("Shift"))

~vk1D & c::CopyFileName()
~vk1D & x::CopyFilePath()

#If (isTargetExplorer() and GetKeyState("Shift") and SandM == 1)

~Space & c::CopyFileName()
~Space & x::CopyFilePath()

#If

; ttt
; --------------------------------------------------------------------

Decode(code) {
    StringReplace, code, code, ``, /, All
    IniRead, kanji, %A_LineFile%\..\wmacs-jis-ttt.ini, main, %code%,
    If (kanji == "ERROR") {
        IniRead, kanji, %A_LineFile%\..\wmacs-jis-ttt.ini, user, %code%,
    }
    If (kanji == "ERROR") {
        kanji := ""
    }
    Return kanji
}

DecodeStr(body) {
    res := ""
    While 0 < StrLen(body) {
        code := SubStr(body, 1, 2)
        body := Substr(body, 3)
        len := StrLen(body)
        ; left/right/assoc table
        If (code == "jf" || code == "fj" || code == "43") {
            code := code . SubStr(body, 1, 2)
            body := SubStr(body, 3)
        }
        ; code beginning with ";"
        If (SubStr(code, 1, 1) == ";") {
            code := "\" . code
        }
        kanji := Decode(code)
        res := res . kanji
    }
    Return res
}

DecodeSubstr(src) {
    StringCaseSense, On

    ch := ""
    tail := ""
    body := ""
    head := ""

    If isTargetTTTExplorer() {
        ttt_keys := "1234567890qwertyuiopasdfghjkl;zxcvbnm,.``"
        ttt_delimiter := "~"
    } Else {
        ttt_keys := "1234567890qwertyuiopasdfghjkl;zxcvbnm,./"
        ttt_delimiter := ":"
    }

    i := StrLen(src) - 1
    While 0 <= i
    {
        ch := SubStr(src, i+1, 1)
        If (0 < InStr(ttt_keys, ch, true))
            Break
        tail := ch . tail
        i -= 1
    }
    While 0 <= i
    {
        ch := Substr(src, i+1, 1)
        If (InStr(ttt_keys, ch, true) = 0)
            Break
        body := ch . body
        i -= 1
    }
    If (ch == ttt_delimiter)
        i -= 1
    While 0 <= i
    {
        ch := Substr(src, i+1, 1)
        head := ch . head
        i -= 1
    }
    Return head . DecodeStr(body) . tail
}

DoTTT(backward = "+{Home}") {
    OnClipboardChange("ClipChanged", 0)
    ;;
    clipboard_backup = %ClipboardAll%
    Send, %backward%
    Clipboard :=
    Send ^c
    ClipWait, 1
    src := Clipboard
    Clipboard := clipboard_backup
    clipboard_backup =
    decoded := DecodeSubstr(src)
    ; `r`n to `n
    StringReplace, decoded, decoded, `r`n, `n, All
    SendRaw, %decoded%
    ;;
    OnClipboardChange("ClipChanged", 1)
    Return
}

#If (isTargetTTTExplorer() and not WinExist("漢直窓 TT - ON"))

/::Send, ``
`::Send, /
:::Send,~
~::Send,:

#If (isTargetTTTExplorer())

!j::DoTTT("+^{Home}")
~vk1D & j::DoTTT("+^{Home}")            ; 無変換-j → DoTTT()

#If (isTargetTTT())

!j::DoTTT()
^!j::DoTTT("+^{Home}")

~vk1D & j::                             ; 無変換-j → DoTTT() ; C-無変換-j → DoTTT()
    If GetKeyState("LCtrl","P")
        DoTTT("+^{Home}")
    Else
        DoTTT()
    Return

#If

~vk1D & j::Send,!j                      ; 無変換-j → A-j (ttt)

; 104 on 109
; --------------------------------------------------------------------

; #If (C_q = 0)

; +vk32::Send,{@}
; +vk36::Send,{^}
; +vk37::Send,{&}
; +vk38::Send,{*}
; +vk39::Send,{(}
; +vk30::Send,{)}
; +vkBD::Send,{_}
; vkDE::Send,{=}
; +vkDE::Send,{+}
; ;  vkC0::Send,{[}
; ; +vkC0::Send,{{}
; ;  vkDB::Send,{]}
; ; +vkDB::Send,{}}
; ; ; *vkC0::Send,{Blind}{[}
; ; ; *vkDB::Send,{Blind}{]}
; +vkBB::Send,{:}
; vkBA::Send,{'}
; +vkBA::Send,{"}
; ;  vkDD::Send,{\}
; ; +vkDD::Send,{|}
; ; ; *vkDD::Send,{Blind}{\}

; vkF3::Send,{``}
; vkF4::Send,{``}
; +vkF3::Send,{~}
; +vkF4::Send,{~}

; 無変換
; --------------------------------------------------------------------

#If

SendQuote(key) {
    Global SandM
    mod := ""
    If GetKeyState("Ctrl", "P") || GetKeyState("vk1D", "P") || (SandM == 1 && GetKeyState("Space", "P"))
        mod = %mod%^
    If GetKeyState("Shift", "P")
        mod = %mod%+
    If GetKeyState("Alt", "P")
        mod = %mod%!
    If (GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))
        mod = %mod%#
    hkey = %mod%%key%
    Send,%hkey%
    C_q = 0
    ToolTip
}

SendUnquote(key0, key1, key2) {
    Global HenkanToCtrl
    Global SandM
    mod := ""
    key := key0
    If GetKeyState("Ctrl", "P") || (HenkanToCtrl == 1 && GetKeyState("vk1C", "P"))
        mod = %mod%^
    If GetKeyState("Shift", "P") {
        If (key2 = "")
            mod = %mod%+
        Else
            key := key2
    }
    If GetKeyState("Alt", "P")
        mod = %mod%!
    If (GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))
        mod = %mod%#
    If GetKeyState("vk1D", "P") || (SandM == 1 && GetKeyState("Space", "P"))
        Send,%mod%%key1%
    Else
        Send,%mod%%key%
}

SendCase(key0, key1, key2 = "") {
    If (C_q = 1)
        SendQuote(key0)
    Else
        SendUnquote(key0, key1, key2)
}

#If

*0::SendCase("0", "{F10}", "{)}")
*1::SendCase("1", "{F1}")
*2::SendCase("2", "{F2}", "{@}")
*3::SendCase("3", "{F3}")
*4::SendCase("4", "{F4}")
*5::SendCase("5", "{F5}")
*6::SendCase("6", "{F6}", "{^}")
*7::SendCase("7", "{F7}", "{&}")
*8::SendCase("8", "{F8}", "{*}")
*9::SendCase("9", "{F9}", "{(}")
*a::SendCase("a", "{Home}")
*b::SendCase("b", "{Left}")
*c::SendCase("c", "^c")
*d::SendCase("d", "{Del}")
*e::SendCase("e", "{End}")
*f::SendCase("f", "{Right}")
*g::SendCase("g", "^g")
*h::SendCase("h", "{BS}")
*i::SendCase("i", "^i")
; *j::SendCase("j", "{Enter}")
#If (SandM == 1)
*j::SendCase("j", "{Enter}")
#If
*k::SendCase("k", "^k")
*l::SendCase("l", "^l")
*m::SendCase("m", "{Enter}")
*n::SendCase("n", "{Down}")
*o::SendCase("o", "^o")
*p::SendCase("p", "{Up}")
~vk1D & q::QuotedInsert()
#If (SandM == 1)
~Space & q::QuotedInsert()
#If
*r::SendCase("r", "^r")
*s::SendCase("s", "^s")
*t::SendCase("t", "^t")
*u::SendCase("u", "^u")
*v::SendCase("v", "^v")
*w::SendCase("w", "^w")
*x::SendCase("x", "^x")
*y::SendCase("y", "^y")
*z::SendCase("z", "^z")

~vk1D & vkBA::
    If GetKeyState("Shift", "P")
        SendDateStampShort()
    Else
        Send,{Blind}^{Down}
    Return

~vk1D & vkBB::
    If GetKeyState("Shift", "P")
        SendDateStampLong()
    Else
        Send,{Blind}^{Up}
    Return

#If (SandM == 1)
~Space & vkBA::
    If GetKeyState("Shift", "P")
        SendDateStampShort()
    Else
        Send,{Blind}^{Down}
    Return

~Space & vkBB::
    If GetKeyState("Shift", "P")
        SendDateStampLong()
    Else
        Send,{Blind}^{Up}
    Return

#If

*vkBA::SendCase("{'}", "^{Down}", "{""}")
*vkBB::SendCase("{;}", "^{Up}", "{:}")

*vkBC::SendCase("{,}", "^{Home}")
*vkBD::SendCase("{-}", "{F11}", "{_}")
*vkBE::SendCase("{.}", "^{End}")
*vkBF::SendCase("{/}", "^{/}")
*vkC0::SendCase("{[}", "{PgUp}")
*vkDB::SendCase("{]}", "{PgDn}")
*vkDC::SendCase("{\}", "^{\}")
*vkDD::SendCase("{\}", "^{\}")
*vkDE::SendCase("{=}", "{F12}", "{+}")
*vkE2::SendCase("{vkE2}", "^{vkE2}")
*vkF3::SendCase("{``}", "^{``}", "{~}")
*vkF4::SendCase("{``}", "^{``}", "{~}")

~vk1D & Esc::Reload
#If (SandM == 1)
~Space & Esc::Reload
#If
*Esc::SendCase("{Esc}", "^{Esc}")
*BS::SendCase("{BS}", "^{BS}")
; <!Tab::AltTab
; *Tab::SendCase("{Tab}", "^{Tab}")
~vk1D & Tab::Return
#If (SandM == 1)
~Space & Tab::Return
#If
*Enter::SendCase("{Enter}", "^{Enter}")
*Del::SendCase("{Del}", "^{Del}")
*Left::SendCase("{Left}", "^{Left}")
*Right::SendCase("{Right}", "^{Right}")
*Up::SendCase("{Up}", "^{Up}")
*Down::SendCase("{Down}", "^{Down}")
*Home::SendCase("{Home}", "^{Home}")
*End::SendCase("{End}", "^{End}")
*PgUp::SendCase("{PgUp}", "^{PgUp}")
*PgDn::SendCase("{PgDn}", "^{PgDn}")

; 無変換-click → C-click
~vk1D & LButton::SendCase("{LButton}", "^{LButton}")
; XXX: not implemented for double click, drag etc.
#If (SandM == 1)
~Space & LButton::SendCase("{LButton}", "^{LButton}")
#If

; 英数
; --------------------------------------------------------------------

#If

; disable 英数
vkF0::Return

; カタカナ ひらがな → 半角/全角
vkF2::Send,{vkF3}

#If
