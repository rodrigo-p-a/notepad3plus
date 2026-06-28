; =============================================================================
; Regression Tests Notepad3 Gui
; Needs files in a Test Directory:
; Notepad3.exe and Notepad3.ini (from distrib)
; Execute: AutoHotkey64.exe "TestAhkNotepad3.ahk"
; =============================================================================
#Requires AutoHotkey v2.0
SendMode("Input")
SetWorkingDir(A_ScriptDir)
CoordMode("Pixel", "Screen")
SetTitleMatchMode(2)   ; substring match (a window's title may contain WinTitle anywhere)
; =============================================================================

; All globals declared and initialised up front so functions always find them set.
global v_NP3Name      := "Notepad3"
global v_NP3TestDir   := A_WorkingDir . "\_TESTDIR"
global v_NP3IniFile   := v_NP3Name . ".ini"
global v_ExitCode     := 0
global v_Notepad3_PID := 0
global stdout         := ""

try {
    stdout := FileOpen("*", "w")
} catch OSError {
    ; stdout not available - script must be run from CMD with output redirection:
    ;   "%AHK_EXE%" /ErrorStdOut TestAhkNotepad3.ahk >> test.log 2>&1
    MsgBox("stdout not available.`nRun via: TestAhkNotepad3.cmd", "TestAhkNotepad3", "Iconx")
    ExitApp(1)
}

; Safety net: an uncaught exception (e.g. a WinActivate/PostMessage TargetError on
; a window that briefly does not match) would otherwise pop a MODAL error dialog
; and HANG the headless CI runner forever. Turn any uncaught error into a clean,
; logged, non-zero exit instead.
OnError(_OnUncaughtError)
_OnUncaughtError(err, mode) {
    global stdout, v_ExitCode
    try stdout.WriteLine("*** ERROR (uncaught): " . err.Message)
    v_ExitCode := 90
    try Cleanup()
    ExitApp(v_ExitCode)
    return true   ; suppress the default (blocking) error dialog
}

; =============================================================================

stdout.WriteLine("Run " . v_NP3Name . ": " . v_NP3TestDir . "\" . v_NP3Name . ".exe '" . v_NP3TestDir . "\" . v_NP3IniFile . ".")

try {
    Run(v_NP3TestDir . "\" . v_NP3Name . ".exe `"" . v_NP3TestDir . "\" . v_NP3IniFile . "`"", , , &v_Notepad3_PID)
} catch Error {
    v_Notepad3_PID := 0   ; Run() unsets &OutputVarPID on throw — restore it
    stdout.WriteLine("*** ERROR: " . v_NP3Name . " could not be launched.")
    v_ExitCode := 1
    Cleanup()
    ExitApp(v_ExitCode)
}
; -----------------------------------------------------------------------------

CHECK_NP3_STARTS()
Sleep(1000)
CHECK_WIN_TITLE()
Sleep(1000)
CHECK_ABOUT_BOX()

Cleanup()
ExitApp(0)
; =============================================================================

; =============================================================================
CHECK_NP3_STARTS() {
    global v_Notepad3_PID, v_NP3Name, stdout, v_ExitCode
    ; check that NP3 starts up
    if !WinWait("ahk_pid " . v_Notepad3_PID, , 10) {
        stdout.WriteLine("*** ERROR: " . v_NP3Name . "'s seems not to start in time ???")
        v_ExitCode := 2
        Cleanup()
        ExitApp(v_ExitCode)
    }
}
; =============================================================================

; =============================================================================
CHECK_WIN_TITLE() {
    global v_Notepad3_PID, v_NP3Name, v_NP3IniFile, v_NP3TestDir, stdout, v_ExitCode
    ; check Main Window Title
    local v_NP3Title := WinGetTitle("ahk_pid " . v_Notepad3_PID)
    stdout.WriteLine(v_NP3Name . "'s Title is: " . v_NP3Title)

    if !InStr(v_NP3Title, v_NP3Name) {
        v_ExitCode := 3
        stdout.WriteLine("*** ERROR: " . v_NP3Name . " missing in Title: ")
    }
    if !InStr(v_NP3Title, v_NP3IniFile) {
        v_ExitCode := 3
        stdout.WriteLine("*** ERROR: " . v_NP3IniFile . " missing in Title: ")
    }
    if !InStr(v_NP3Title, v_NP3TestDir) {
        v_ExitCode := 3
        stdout.WriteLine("*** ERROR: " . v_NP3TestDir . " missing in Title: ")
    }
    if (v_ExitCode != 0) {
        Cleanup()
        ExitApp(v_ExitCode)
    }
}
; =============================================================================

; =============================================================================
CHECK_ABOUT_BOX() {
    global v_Notepad3_PID, v_NP3Name, stdout, v_ExitCode
    local mainWin  := "ahk_class Notepad3 ahk_pid " . v_Notepad3_PID
    ; Match the About box by its dialog class (#32770) owned by this process, NOT
    ; by caption text: the caption is now branded and localized ("About notepad3plus"
    ; / "Sobre o notepad3plus"), so a fixed "About Notepad3" string never matches.
    local aboutWin := "ahk_class #32770 ahk_pid " . v_Notepad3_PID

    ; Open Help -> About deterministically via WM_COMMAND (IDM_HELP_ABOUT = 43000)
    ; rather than the Shift+F1 hotkey: posting the command does not depend on input
    ; focus, which is unreliable on headless CI runners. Hotkey is the fallback.
    ; Every call that can raise a TargetError is wrapped in try, so a transient
    ; window mismatch fails the check cleanly instead of hanging the runner.
    try {
        if WinExist(mainWin) {
            WinActivate(mainWin)
            PostMessage(0x0111, 43000, 0, , mainWin)   ; WM_COMMAND, IDM_HELP_ABOUT
        }
    }
    if !WinWait(aboutWin, , 5) {
        try {
            WinActivate("ahk_pid " . v_Notepad3_PID)
            Send("+{F1}")                              ; fallback: Shift+F1 accelerator
        }
        if !WinWait(aboutWin, , 5) {
            stdout.WriteLine("*** ERROR: " . v_NP3Name . "'s About Box is not displayed!")
            v_ExitCode := 4
            Cleanup()
            ExitApp(v_ExitCode)
        }
    }
    try stdout.WriteLine("About Box Title is: " . WinGetTitle(aboutWin))

    ; Close it via WM_COMMAND IDOK (1); WinClose / Enter as fallbacks.
    try PostMessage(0x0111, 1, 0, , aboutWin)          ; WM_COMMAND, IDOK
    if !WinWaitClose(aboutWin, , 2) {
        try WinClose(aboutWin)
        if !WinWaitClose(aboutWin, , 2) {
            try {
                WinActivate(aboutWin)
                Send("{Enter}")
            }
            if !WinWaitClose(aboutWin, , 2) {
                stdout.WriteLine("*** ERROR: " . v_NP3Name . "'s About Box can not be closed!")
                v_ExitCode := 5
                Cleanup()
                ExitApp(v_ExitCode)
            }
        }
    }
}
; =============================================================================

; =============================================================================
Cleanup() {
    global v_Notepad3_PID, v_NP3Name, stdout, v_ExitCode
    if (v_Notepad3_PID > 0) {
        WinClose("ahk_pid " . v_Notepad3_PID, , 2)
        if WinExist("ahk_pid " . v_Notepad3_PID)
            WinWaitClose("ahk_pid " . v_Notepad3_PID, , 10)
    }
    if (v_ExitCode != 0)
        stdout.WriteLine("*** ERROR: Testing " . v_NP3Name . " exit with: " . v_ExitCode)
    else
        stdout.WriteLine("Testing " . v_NP3Name . ": All tests PASSED.")
}
; =============================================================================
