#Requires AutoHotkey v2.0
;
;This Script will open WSL in Win10 and run various Imagemagik functions
;20220222 - ver 1.1
; Added Logging and file moves
;
; set variable froma args passed
;
;
if A_Args.Length < 1
{
    PATH := InputBox("This script requires at least 1 parameters but it only received " A_Args.Length ".  Please paste the path to your AstraImage sharped images for animation redo (IE - full path to LrD-X-Y.").value
	PATH := StrReplace(PATH, "\", "\\")
}
else
{
PATH := A_Args[1]
UserPathIn := StrReplace(UserPathIn, "\", "\\")
}
;
;
FileAppend A_Now " Starting Imagemagik ANIM redo processing.`n", "Log.txt"
;
; Start WSL Terminal
Run "wt.exe"
;
; wait until open then pass RBG script with path
;
WinWait "maphilli14@"
WinActivate "maphilli14@"
sleep 500
Send "/mnt/c/Users/Mike/OneDrive/D-Permanent/Scripts/Astronomy/AutoHotKey/WithLoggingandMoves-maphilli14-work2/RED-Imagemagik.py " PATH "`r"

