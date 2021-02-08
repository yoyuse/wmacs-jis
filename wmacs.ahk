; --------------------------------------------------------------------
WmacsVersion = 4.3.0
; --------------------------------------------------------------------
; - 2021-02-08 4.3.0 new menu item: version info, opening URL
; - 2021-02-08 4.2.0 remove option: SandC, CSSpaceToEnter
; - 2021-02-07 4.1.2 additional one shot check (not perfect)
; - 2021-02-07 4.1.1 icon file existence check
; - 2021-02-07 4.1.0 無変換/変換 or LAlt/RAlt as one shot modifier
; - 2021-02-06 4.0.0 renamed to wmacs.ahk
; - 2021-02-05 4.0β  wmacs-mh.ahk from wmacs3.ahk, wmacs-jis.ahk
; --------------------------------------------------------------------

; --------------------------------------------------------------------
; Config
; --------------------------------------------------------------------

#Persistent
#SingleInstance force
#NoEnv
#Warn
#InstallKeybdHook
#UseHook
; XXX: SendMode Input だと vk1D::LCtrl のリマップが効かない
; SendMode Input
SendMode Event
SetWorkingDir %A_ScriptDir%

; --------------------------------------------------------------------
; C-q
; --------------------------------------------------------------------

C_q = 0

quoted_insert() {
    global C_q
    C_q_x := A_CaretX + 8
    C_q_y := A_CaretY + 16
    ToolTip, C-q, C_q_x, C_q_y
    C_q = 1
    Return
}

SendBlind(key) {
    global RemapRAltToRCtrl
    mod := ""
    ; If GetKeyState("RCtrl", "P")
    If GetKeyState("RCtrl")
        mod = %mod%^
    If GetKeyState("Shift", "P")
        mod = %mod%+
    If GetKeyState(RemapRAltToRCtrl ? "LAlt" : "Alt", "P")
        mod = %mod%!
    If (GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))
        mod = %mod%#
    hkey = %mod%%key%
    Send, %hkey%
    Return
}

; --------------------------------------------------------------------
; Group NoWmacs
; --------------------------------------------------------------------

GroupAdd, NoWmacs, ahk_class Emacs                 ; Emacs (Spacemacs)
GroupAdd, NoWmacs, ahk_class gdkWindowToplevel     ; GIMPPortable and Inkscpae
GroupAdd, NoWmacs, ahk_class PuTTY                 ; PuTTY
GroupAdd, NoWmacs, ahk_class QWidget               ; VirtualBox
GroupAdd, NoWmacs, ahk_class Vim                   ; GVim
GroupAdd, NoWmacs, ahk_class VirtualConsoleClass   ; ConEmu
GroupAdd, NoWmacs, ahk_class VTWin32               ; TeraTerm
GroupAdd, NoWmacs, ahk_class 　                    ; xyzzy
GroupAdd, NoWmacs, ahk_class VNCMDI_Window         ; UltraVNC

; --------------------------------------------------------------------
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

; --------------------------------------------------------------------
; Group Explorer
; --------------------------------------------------------------------

GroupAdd,Explorer,ahk_class CabinetWClass   ; Explorer
GroupAdd,Explorer,ahk_class ExploreWClass   ; ???
GroupAdd,Explorer,ahk_class Progman         ; Desktop (Program Manager)

; --------------------------------------------------------------------
; Target
; --------------------------------------------------------------------

isWmacsTarget() {
    IfWinActive, ahk_group NoWmacs
        Return 0
    Return 1
}

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

; --------------------------------------------------------------------
; OnClipboardChange
; --------------------------------------------------------------------

OnClipboardChange("ClipChanged")

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

; --------------------------------------------------------------------
; Tray Icon / Menu
; --------------------------------------------------------------------

; wmacs.ini
IniFile := % A_LineFile . "\..\wmacs.ini"
Section := "wmacs"

strWmacsVersion := "Wmacs Version " . WmacsVersion
WmacsURL := "https://github.com/yoyuse/wmacs-jis"

RemapRAltToRCtrl := 0
strRemapRAltToRCtrl := "Remap RAlt to RCtrl"
IniRead, RemapRAltToRCtrl, %IniFile%, %Section%, RemapRAltToRCtrl, %RemapRAltToRCtrl%

Use104On109 := 1
strUse104On109 := "Use 104 Layout on 109 Keyboard Driver"
IniRead, Use104On109, %IniFile%, %Section%, Use104On109, %Use104On109%

icoWmacsOn := % A_LineFile . "\..\wmacs-on.ico"
icoWmacsOff := % A_LineFile . "\..\wmacs-off.ico"
WmacsIconCheckInterval := 1000

Menu, Tray, Icon, *, 1, 1

; 区切り線
Menu, Tray, Add

; バージョン情報
Menu, Tray, Add, %strWmacsVersion%, menuWmacsVersion

; RAlt を RCtrl にリマップするか
Menu, Tray, Add, %strRemapRAltToRCtrl%, menuRemapRAltToRCtrl
If (RemapRAltToRCtrl == 1) {
    Menu, Tray, Check, %strRemapRAltToRCtrl%
}

; JIS キーボードドライバで US 配列を使うか
Menu, Tray, Add, %strUse104On109%, menuUse104On109
if (Use104On109 == 1) {
    Menu, Tray, Check, %strUse104On109%
}

SetTimer, WmacsStatusCheckTimer, %WmacsIconCheckInterval%

; Auto-execute Section の終わり
Return

WmacsStatusCheckTimer:
    if !(FileExist(icoWmacsOn) && FileExist(icoWmacsOff)) {
        Return
    }
    if (isWmacsTarget() && !A_IsSuspended) {
        Menu, Tray, Icon, %icoWmacsOn%, 1
    } else {
        Menu, Tray, Icon, %icoWmacsOff%, 1
    }
    Return

menuWmacsVersion:
    Run, %WmacsURL%
    Return

menuRemapRAltToRCtrl:
    if (RemapRAltToRCtrl == 1) {
        Menu, Tray, Uncheck, %strRemapRAltToRCtrl%
        RemapRAltToRCtrl := 0
    } else {
        Menu, Tray, Check, %strRemapRAltToRCtrl%
        RemapRAltToRCtrl := 1
    }
    IniWrite, %RemapRAltToRCtrl%, %IniFile%, %Section%, RemapRAltToRCtrl
    Return

menuUse104On109:
    if (Use104On109 == 1) {
        Menu, Tray, Uncheck, %strUse104On109%
        Use104On109 := 0
    } else {
        Menu, Tray, Check, %strUse104On109%
        Use104On109 := 1
    }
    IniWrite, %Use104On109%, %IniFile%, %Section%, Use104On109
    Return

; --------------------------------------------------------------------
; Reload Script
; --------------------------------------------------------------------

#If (C_q = 0)

+<^Esc::Reload

; XXX
~vk1D & Esc::Reload

#If

; --------------------------------------------------------------------
; Muhenkan/Henkan Modifier
; --------------------------------------------------------------------

#If (Use104On109 == 1)

; 無変換 / 変換 → LCtrl / RCtrl
vk1D::LCtrl
vk1C::RCtrl

; 単独押しで 無変換 / 変換
; vk1D Up::Send, % "{LCtrl Up}" (A_TimeSincePriorHotkey < 300 ? "{vk1D}" : "")
; vk1C Up::Send, % "{RCtrl Up}" (A_TimeSincePriorHotkey < 300 ? "{vk1C}" : "")
vk1D Up::Send, % "{LCtrl Up}" (A_PriorKey == "" && A_TimeSincePriorHotkey < 300 ? "{vk1D}" : "")
vk1C Up::Send, % "{RCtrl Up}" (A_PriorKey == "" && A_TimeSincePriorHotkey < 300 ? "{vk1C}" : "")

#If

; --------------------------------------------------------------------
; RAlt to RCtrl
; --------------------------------------------------------------------

#If (C_q = 0) && (RemapRAltToRCtrl == 1)

RAlt::RCtrl
; 単独押しで変換
; RAlt Up::Send, % "{RCtrl Up}" (A_TimeSincePriorHotkey < 300 ? "{vk1C}" : "")
RAlt Up::Send, % "{RCtrl Up}" (A_PriorKey == "RAlt" && A_TimeSincePriorHotkey < 300 ? "{vk1C}" : "")

#If (C_q = 0) && (RemapRAltToRCtrl != 1)

RAlt::RAlt
; 単独押しで変換
; RAlt Up::Send, % "{RAlt Up}" (A_TimeSincePriorHotkey < 300 ? "{vk1C}" : "")
RAlt Up::Send, % "{RAlt Up}" (A_PriorKey == "RAlt" && A_TimeSincePriorHotkey < 300 ? "{vk1C}" : "")

#If

LAlt::LAlt
; 単独押しで無変換
; LAlt Up::Send, % "{LAlt up}" (A_TimeSincePriorHotkey < 300 ? "{vk1D}" : "")
LAlt Up::Send, % "{LAlt up}" (A_PriorKey == "LAlt" && A_TimeSincePriorHotkey < 300 ? "{vk1D}" : "")

; --------------------------------------------------------------------
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

#If

; --------------------------------------------------------------------
; ttt
; --------------------------------------------------------------------

Decode(code) {
    StringReplace, code, code, ``, /, All
    IniRead, kanji, %A_LineFile%\..\wmacs-ttt.ini, main, %code%,
    If (kanji == "ERROR") {
        IniRead, kanji, %A_LineFile%\..\wmacs-ttt.ini, user, %code%,
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
; 無変換-j → DoTTT()
~vk1D & j::DoTTT("+^{Home}")

#If (isTargetTTT())

!j::DoTTT()
^!j::DoTTT("+^{Home}")

; 無変換-j → DoTTT()
; C-無変換-j → DoTTT()
~vk1D & j::
    If GetKeyState("LCtrl","P")
        DoTTT("+^{Home}")
    Else
        DoTTT()
    Return

#If

; 無変換-j → A-j (vsc-ttt etc.)
~vk1D & j::Send,!j

; --------------------------------------------------------------------
; C-q
; --------------------------------------------------------------------

#If (C_q = 1)

~*1::
~*2::
~*3::
~*4::
~*5::
~*6::
~*7::
~*8::
~*9::
~*0::
~*a::
~*b::
~*c::
~*d::
~*e::
~*f::
~*g::
~*h::
~*i::
~*j::
~*k::
~*l::
~*m::
~*n::
~*o::
~*p::
~*q::
~*r::
~*s::
~*t::
~*u::
~*v::
~*w::
~*x::
~*y::
~*z::
~*vkBA::
~*vkBB::
~*vkBC::
~*vkBD::
~*vkBE::
~*vkBF::
~*VKC0::
~*vkDB::
~*vkDC::
~*vkDD::
~*vkDE::
~*vkE2::
~*Space::
~*Tab::
~*Enter::
~*BS::
~*Del::
~*Ins::
~*Left::
~*Right::
~*Up::
~*Down::
~*Home::
~*End::
~*PgUp::
~*PgDn::
~*vkF3::
~*vkF4::
~*vk1C::
~*vk1D::
~*vkF2::
~*vkF0::
~*F1::
~*F2::
~*F3::
~*F4::
~*F5::
~*F6::
~*F7::
~*F8::
~*F9::
~*F10::
~*F11::
~*F12::
~*F13::
~*F14::
~*F15::
~*F16::
~*F17::
~*F18::
~*F19::
~*F20::
~*F21::
~*F22::
~*F23::
~*F24::
~*Esc::
~*AppsKey::
~*PrintScreen::
~*Pause::
~*Break::
~*Sleep::
~*Help::
~*CapsLock::
~*ScrollLock::
~*NumLock::
~*Numpad0::
~*Numpad1::
~*Numpad2::
~*Numpad3::
~*Numpad4::
~*Numpad5::
~*Numpad6::
~*Numpad7::
~*Numpad8::
~*Numpad9::
~*NumpadDot::
~*NumpadDel::
~*NumpadIns::
~*NumpadClear::
~*NumpadUp::
~*NumpadDown::
~*NumpadLeft::
~*NumpadRight::
~*NumpadHome::
~*NumpadEnd::
~*NumpadPgUp::
~*NumpadPgDn::
~*NumpadDiv::
~*NumpadMult::
~*NumpadAdd::
~*NumpadSub::
~*NumpadEnter::
    C_q = 0
    ToolTip
    Return

#If

; --------------------------------------------------------------------
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

; --------------------------------------------------------------------
; wmacs
; --------------------------------------------------------------------

#If (C_q = 0 && isWmacsTarget() && Use104On109 == 1)

 +2::Send,@
 +6::Send,{^}
*+7::&
*+8::*
*+9::(
*+0::)
*+vkBD::_
*<^vkDE::SendBlind("{F12}")
*+vkDE::Send,{+}
*vkDE::=
*+vkF3::~
*+vkF4::~
*vkF3::Send,{``}
*vkF4::Send,{``}
*<^vkC0::SendBlind("{PgUp}")
*+vkC0::Send,{{}
*vkC0::[
*<^vkDB::SendBlind("{PgDn}")
*+vkDB::Send,{}}
*vkDB::]
 +<^vkBB::SendDateStampLong()
 <^vkBB::Send,{Blind}^{Up}
 +vkBB::Send,{:}
 +<^vkBA::SendDateStampShort()
 <^vkBA::Send,{Blind}^{Down}
*+vkBA::"
*vkBA::'
*<^vkDD::Send,{Blind}^\
*+vkDD::|
*vkDD::\

#If (C_q = 0 && isWmacsTarget())

*<^1::SendBlind("{F1}")
*<^2::SendBlind("{F2}")
*<^3::SendBlind("{F3}")
*<^4::SendBlind("{F4}")
*<^5::SendBlind("{F5}")
*<^6::SendBlind("{F6}")
*<^7::SendBlind("{F7}")
*<^8::SendBlind("{F8}")
*<^9::SendBlind("{F9}")
*<^0::SendBlind("{F10}")
*<^-::SendBlind("{F11}")
*<^=::SendBlind("{F12}")
*<^`::SendBlind("^{Del}")
*<^vkF3::SendBlind("^{Del}")
*<^vkF4::SendBlind("^{Del}")
 <^q::quoted_insert()
*<^e::SendBlind("{End}")
*<^p::SendBlind("{Up}")
*<^vkDB::SendBlind("{PgUp}")
*<^vkDD::SendBlind("{PgDn}")
*<^a::SendBlind("{Home}")
*<^d::SendBlind("{Del}")
*<^f::SendBlind("{Right}")
*<^h::SendBlind("{BS}")
*<^j::SendBlind("{Enter}") ; XXX
+<^vkBA::SendDateStampLong()
 <^vkBA::Send,{Blind}^{Up}
+<^vkDE::SendDateStampShort()
 <^vkDE::Send,{Blind}^{Down}
*<^b::SendBlind("{Left}")
*<^n::SendBlind("{Down}")
*<^m::SendBlind("{Enter}")
*<^,::SendBlind("^{Home}")
*<^.::SendBlind("^{End}")

#If (Use104On109 == 1)

; disable 英数
vkF0::Return
; カタカナ ひらがな → 半角/全角
vkF2::Send,{vkF3}

#If
