#Requires AutoHotkey v2.0
#SingleInstance Force
; Hook hotkeys ignore the script's own keystrokes, so Cmd+[ sending Alt+Left
; doesn't set off Cmd+Left
#UseHook

; Mac-style shortcuts on Windows. With the Kinesis Windows layout, the key
; beside the space bar (where Cmd is on the Mac) sends Alt and the next one out
; (where Option is) sends Win. This script makes Alt act as Cmd and Win as
; Option. Ctrl stays Ctrl, so terminal and Vim keys work as on the Mac.
;
; Option+letter is left as the Windows Win+letter shortcut (Win+V clipboard
; history, Win+E Explorer, Win+R Run); Windows keeps Option+L for locking.
; Cmd+Tab is Windows' own Alt+Tab.

; Stop a released Alt or Win key opening the menu bar or the Start menu
A_MenuMaskKey := "vkE8"

GroupAdd "terminal", "ahk_exe wezterm-gui.exe"
GroupAdd "terminal", "ahk_exe WindowsTerminal.exe"
GroupAdd "browser", "ahk_exe chrome.exe"
GroupAdd "browser", "ahk_exe msedge.exe"
GroupAdd "browser", "ahk_exe firefox.exe"

InTerminal(*) => WinActive("ahk_group terminal")
SendKeys(keys) => (*) => Send(keys)

; Cmd+key sends Ctrl+key. In terminals Ctrl+key belongs to the shell, so it
; sends Ctrl+Shift+key, which WezTerm and Windows Terminal use for copy, paste,
; new tab and the rest. Left out: H, M and Q, handled below.
for key in StrSplit("abcdefgijklnoprstuvwxyz0123456789,./;'=-") {
    HotIf
    Hotkey "!" key, SendKeys("^" key)
    Hotkey "!+" key, SendKeys("^+" key)
    HotIf InTerminal
    Hotkey "!" key, SendKeys("^+" key)
    Hotkey "!+" key, SendKeys("^+" key)
}

; Exceptions to the rule above, set after it so they replace it
Snip := SendKeys("#+s")  ; screenshot: the Snipping Tool
HotIf
Hotkey "!+z", SendKeys("^y")  ; redo, which Office only knows as Ctrl+Y
Hotkey "!+3", Snip
Hotkey "!+4", Snip
HotIf InTerminal
Hotkey "!+3", Snip
Hotkey "!+4", Snip
HotIf

!q::Send "!{F4}"
!h::WinMinimize "A"
!m::WinMinimize "A"
^!q::DllCall("LockWorkStation")
!Space::Send "^{Esc}"  ; Start menu search, in place of Spotlight

; Line and document navigation
!Left::Send "{Home}"
!Right::Send "{End}"
!+Left::Send "+{Home}"
!+Right::Send "+{End}"
!Up::Send "^{Home}"
!Down::Send "^{End}"
!+Up::Send "^+{Home}"
!+Down::Send "^+{End}"

; Option moves and deletes by word
#Left::Send "^{Left}"
#Right::Send "^{Right}"
#+Left::Send "^+{Left}"
#+Right::Send "^+{Right}"
#Backspace::Send "^{Backspace}"
#Delete::Send "^{Delete}"

; Ctrl+Left and Ctrl+Right switch desktops, as they switch Spaces on the Mac
^Left::Send "^#{Left}"
^Right::Send "^#{Right}"

; A tapped Cmd or Option does nothing, instead of opening the menu bar or the
; Start menu
~LAlt::Send "{Blind}{vkE8}"
~LWin::Send "{Blind}{vkE8}"

#HotIf !WinActive("ahk_group terminal")
!Backspace::Send "+{Home}{Delete}"
#HotIf

; Cmd+[ and Cmd+] go back and forward in browsers, and stay Ctrl+[ and Ctrl+]
; elsewhere (outdent and indent in VS Code)
#HotIf WinActive("ahk_group browser")
![::Send "!{Left}"
!]::Send "!{Right}"
#HotIf
![::Send "^["
!]::Send "^]"
