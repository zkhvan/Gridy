; ====================================================================
;
;   VirtualDesktopAccessor
;   Manage virtual desktops through auto hot key scripts
;
;   https://github.com/Ciantic/VirtualDesktopAccessor
;
; ====================================================================

; --------------------------------------------------------------------
; Setup
; --------------------------------------------------------------------

DetectHiddenWindows, On

; --------------------------------------------------------------------
; Initialize all handlers
; --------------------------------------------------------------------
hCurrentWnd := WinExist("ahk_pid " . DllCall("GetCurrentProcessId", "Uint"))
hCurrentWnd += 0x1000 << 32

DllFile = %A_LineFile%\..\VirtualDesktopAccessor.dll
hVirtualDesktopAccessor := DllCall("LoadLibrary"
                                   , "Str"
                                   , DllFile
                                   , "Ptr")

; Handles for the function pointers
GoToDesktopNumberProc               := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GoToDesktopNumber",               "Ptr")
GetCurrentDesktopNumberProc         := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetCurrentDesktopNumber",         "Ptr")
IsWindowOnCurrentVirtualDesktopProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsWindowOnCurrentVirtualDesktop", "Ptr")
MoveWindowToDesktopNumberProc       := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "MoveWindowToDesktopNumber",       "Ptr")
IsPinnedWindowProc                  := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsPinnedWindow",                  "Ptr")
RestartVirtualDesktopAccessorProc   := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "RestartVirtualDesktopAccessor",   "Ptr")
GetWindowDesktopNumberProc          := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetWindowDesktopNumber",          "Ptr")

; Handles of hooks that get called when the  current virtual desktop changes.
RegisterPostMessageHookProc         := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "RegisterPostMessageHook",         "Ptr")
UnregisterPostMessageHookProc       := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "UnregisterPostMessageHook",       "Ptr")

RegisterOnDesktopChangeHook()

; --------------------------------------------------------------------
; Get the current desktop number.
; --------------------------------------------------------------------
GetCurrentDesktopNumber() {
    Global GetCurrentDesktopNumberProc

    return DllCall(GetCurrentDesktopNumberProc)
}

GetTotalDesktopNumber() {
    Global GetDesktopCountProc

    return DllCall(GetDesktopCountProc)
}

MoveCurrentWindowToDesktop(DesktopNumber) {
    Global MoveWindowToDesktopNumberProc

    WinGet, ActiveHwnd, Id, A

    DllCall(MoveWindowToDesktopNumberProc, UInt, ActiveHwnd, UInt, DesktopNumber)
}

GoToDesktop(DesktopNumber) {
    Global GoToDesktopNumberProc

    DllCall(GoToDesktopNumberProc, Int, DesktopNumber)
}

; --------------------------------------------------------------------
;
;     Virtual Desktop Accessor Hooks
;
; --------------------------------------------------------------------
; 
RegisterOnDesktopChangeHook() {
    Global RegisterPostMessageHookProc, hCurrentWnd

    Handle := GetOnDesktopChangeHandle()
    DllCall(RegisterPostMessageHookProc, Int, hCurrentWnd, Int, Handle)
}

GetOnDesktopChangeHandle() {
    Return 0x1400 + 30
}

; --------------------------------------------------------------------
;
;     UI Functions
;
; --------------------------------------------------------------------

; --------------------------------------------------------------------
; Show the tooltip.
; --------------------------------------------------------------------
; Shows the tooltip for the given desktop number or the current
; desktop number if no number is passed in.
; --------------------------------------------------------------------
ShowTooltip(DesktopNumber := -1) {
    params := {}

    params.message := GetDesktopName(DesktopNumber)

    ; Centered
    params.position := 1

    Toast(params)
}

; --------------------------------------------------------------------
; Get the formatted desktop name.
; --------------------------------------------------------------------
GetDesktopName(DesktopNumber := -1) {
    if (DesktopNumber == -1) {
        DesktopNumber := GetCurrentDesktopNumber()
    }

    DesktopNumber += 1
    DesktopName = Desktop %DesktopNumber%

    Return DesktopName
}

