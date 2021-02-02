﻿; --------------------------------------------------------------------
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
if FileExist(icon) {
    Menu, Tray, Icon, %icon%
}

; global variable
; --------------------------------------------------------------------

Global no_copy_ToolTip := 1

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

; Date String
; --------------------------------------------------------------------

SendDateStampLong() {
    FormatTime,TimeString,,yyyy-MM-dd
    Send,%TimeString%
    Return
}

SendDateStampShort() {
    FormatTime,TimeString,,yyMMdd
    Send,%TimeString%
    Return
}

Return

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
    If (C_q = 1) {
        Send,{CtrlDown}
    }
    KeyWait, vk1D
    If (C_q = 1) {
        Send,{CtrlUp}
    }
    keyPressDuration := A_TickCount - startTime
    ; 無変換を押している間に他のホットキーが発動した場合は入力しない
    ; 無変換を長押ししていた場合も入力しない
    If (A_ThisHotkey == "$vk1D" and keyPressDuration < 200) {
        Send,{vk1D}
    }
    Return

; copy ToolTip
; --------------------------------------------------------------------

; show tooltip on copy
OnClipboardChange:
    global no_copy_ToolTip
    If (no_copy_ToolTip = 1) {
    ToolTip
    SetTimer, RemoveToolTip, 1000
    Return
    }
    if (A_EventInfo = 1) {
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
    } else if (A_EventInfo = 2) {
    ; non text
        ToolTip テキストでないものをコピーしました
    }
    SetTimer, RemoveToolTip, 1500
    return

RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
    global no_copy_ToolTip
    no_copy_ToolTip = 0
    return

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
    Return
}

CopyFilePath() {
    Clipboard =
    Send,^c
    ClipWait,2
    ;;
    names := Clipboard
    Clipboard := names
    ;;
    Return
}

+^c::CopyFileName()
+^x::CopyFilePath()

#If (isTargetExplorer() and GetKeyState("Shift"))

~vk1D & c::CopyFileName()
~vk1D & x::CopyFilePath()

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
    global no_copy_ToolTip
    no_copy_ToolTip = 1
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

#If (C_q = 0)

+vk32::Send,{@}
+vk36::Send,{^}
+vk37::Send,{&}
+vk38::Send,{*}
+vk39::Send,{(}
+vk30::Send,{)}
+vkBD::Send,{_}
 vkDE::Send,{=}
+vkDE::Send,{+}
;  vkC0::Send,{[}
; +vkC0::Send,{{}
;  vkDB::Send,{]}
; +vkDB::Send,{}}
*vkC0::Send,{Blind}{[}
*vkDB::Send,{Blind}{]}
+vkBB::Send,{:}
 vkBA::Send,{'}
+vkBA::Send,{"}
;  vkDD::Send,{\}
; +vkDD::Send,{|}
*vkDD::Send,{Blind}{\}

 vkF3::Send,{``}
 vkF4::Send,{``}
+vkF3::Send,{~}
+vkF4::Send,{~}

; 無変換
; --------------------------------------------------------------------

SendMuhenkan(key) {
    mod := ""
    If GetKeyState("vk1D", "P")
        mod = %mod%^
    If GetKeyState("LShift", "P")
        mod = %mod%+
    If GetKeyState("Alt", "P")
        mod = %mod%!
    If (GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))
        mod = %mod%#
    hkey = %mod%%key%
    Send,{Blind}%hkey%
    C_q = 0
    ToolTip
    Return
}

#If (C_q = 1)

*0::SendMuhenkan("0")
*1::SendMuhenkan("1")
*2::SendMuhenkan("2")
*3::SendMuhenkan("3")
*4::SendMuhenkan("4")
*5::SendMuhenkan("5")
*6::SendMuhenkan("6")
*7::SendMuhenkan("7")
*8::SendMuhenkan("8")
*9::SendMuhenkan("9")
*a::SendMuhenkan("a")
*b::SendMuhenkan("b")
*c::SendMuhenkan("c")
*d::SendMuhenkan("d")
*e::SendMuhenkan("e")
*f::SendMuhenkan("f")
*g::SendMuhenkan("g")
*h::SendMuhenkan("h")
*i::SendMuhenkan("i")
*j::SendMuhenkan("j")
*k::SendMuhenkan("k")
*l::SendMuhenkan("l")
*m::SendMuhenkan("m")
*n::SendMuhenkan("n")
*o::SendMuhenkan("o")
*p::SendMuhenkan("p")
*q::SendMuhenkan("q")
*r::SendMuhenkan("r")
*s::SendMuhenkan("s")
*t::SendMuhenkan("t")
*u::SendMuhenkan("u")
*v::SendMuhenkan("v")
*w::SendMuhenkan("w")
*x::SendMuhenkan("x")
*y::SendMuhenkan("y")
*z::SendMuhenkan("z")

*vkBA::SendMuhenkan("{'}")
*vkBB::SendMuhenkan("{;}")
*vkBC::SendMuhenkan("{vkBC}")
*vkBD::SendMuhenkan("{-}")
*vkBE::SendMuhenkan("{vkBE}")
*vkBF::SendMuhenkan("{vkBF}")
*vkC0::SendMuhenkan("{[}")
*vkDB::SendMuhenkan("{]}")
*vkDC::SendMuhenkan("{\}")
*vkDD::SendMuhenkan("{\}")
*vkDE::SendMuhenkan("{=}")
*vkE2::SendMuhenkan("{\}")
*vkF3::SendMuhenkan("{``}")
*vkF4::SendMuhenkan("{``}")

*Esc::SendMuhenkan("{Esc}")
*BS::SendMuhenkan("{BS}")
*Tab::SendMuhenkan("{Tab}")
*Enter::SendMuhenkan("{Enter}")
*Del::SendMuhenkan("{Del}")
*Left::SendMuhenkan("{Left}")
*Right::SendMuhenkan("{Right}")
*Up::SendMuhenkan("{Up}")
*Down::SendMuhenkan("{Down}")
*Home::SendMuhenkan("{Home}")
*End::SendMuhenkan("{End}")
*PgUp::SendMuhenkan("{PgUp}")
*PgDn::SendMuhenkan("{PgDn}")

#If (C_q = 0)

~vk1D & 0::Send,{Blind}{F10}
~vk1D & 1::Send,{Blind}{F1}
~vk1D & 2::Send,{Blind}{F2}
~vk1D & 3::Send,{Blind}{F3}
~vk1D & 4::Send,{Blind}{F4}
~vk1D & 5::Send,{Blind}{F5}
~vk1D & 6::Send,{Blind}{F6}
~vk1D & 7::Send,{Blind}{F7}
~vk1D & 8::Send,{Blind}{F8}
~vk1D & 9::Send,{Blind}{F9}
~vk1D & a::Send,{Blind}{Home}
~vk1D & b::Send,{Blind}{Left}
~vk1D & c::Send,{Blind}^c
~vk1D & d::Send,{Blind}{Del}
~vk1D & e::Send,{Blind}{End}
~vk1D & f::Send,{Blind}{Right}
~vk1D & g::Send,{Blind}^g
~vk1D & h::Send,{Blind}{BS}
~vk1D & i::Send,{Blind}^i
; ~vk1D & j::Send,{Blind}{Enter}
~vk1D & k::Send,{Blind}^k
~vk1D & l::Send,{Blind}^l
~vk1D & m::Send,{Blind}{Enter}
~vk1D & n::Send,{Blind}{Down}
~vk1D & o::Send,{Blind}^o
~vk1D & p::Send,{Blind}{Up}
~vk1D & q::QuotedInsert()
~vk1D & r::Send,{Blind}^r
~vk1D & s::Send,{Blind}^s
~vk1D & t::Send,{Blind}^t
~vk1D & u::Send,{Blind}^u
~vk1D & v::Send,{Blind}^v
~vk1D & w::Send,{Blind}^w
~vk1D & x::Send,{Blind}^x
~vk1D & y::Send,{Blind}^y
~vk1D & z::Send,{Blind}^z

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

~vk1D & vkBC::Send,{Blind}^{Home}
~vk1D & vkBD::Send,{Blind}{F11}
~vk1D & vkBE::Send,{Blind}^{End}
~vk1D & vkBF::Send,{Blind}^{/}
~vk1D & vkC0::Send,{Blind}{PgUp}
~vk1D & vkDB::Send,{Blind}{PgDn}
~vk1D & vkDC::Send,{Blind}^{\}
~vk1D & vkDD::Send,{Blind}^{\}
~vk1D & vkDE::Send,{Blind}{F12}
~vk1D & vkE2::Send,{Blind}^{\}
~vk1D & vkF3::Send,{Blind}^{``}
~vk1D & vkF4::Send,{Blind}^{``}

~vk1D & Esc::Reload
~vk1D & BS::Send,{Blind}^{BS}
~vk1D & Tab::Send,{Blind}^{Tab}
~vk1D & Enter::Send,{Blind}^{Enter}
~vk1D & Del::Send,{Blind}^{Del}
~vk1D & Left::Send,{Blind}^{Left}
~vk1D & Right::Send,{Blind}^{Right}
~vk1D & Up::Send,{Blind}^{Up}
~vk1D & Down::Send,{Blind}^{Down}
~vk1D & Home::Send,{Blind}^{Home}
~vk1D & End::Send,{Blind}^{End}
~vk1D & PgUp::Send,{Blind}^{PgUp}
~vk1D & PgDn::Send,{Blind}^{PgDn}

; 無変換-click → C-click
~vk1D & LButton::Send,{Blind}^{LButton}
; XXX: not implemented for double click, drag etc.

; 英数
; --------------------------------------------------------------------

#If

; disable 英数
vkF0::Return

; カタカナ ひらがな → 半角/全角
vkF2::Send,{vkF3}

#If
