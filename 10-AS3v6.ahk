#Requires AutoHotkey v2.0
;
;This Script will open a set of FireCaputre recordings in AutoStakkert3 and stack with defaults
; 20230826 v1.7 
;  moving variables to ini file
; 20220222 - ver 1.1
;  Added Logging and file moves
;
Logging := 1
;
; Variables
;
FCRoot := IniRead("00-setup.ini", "Autostakkert", "FCRoot")
VideoFileType := IniRead("00-setup.ini", "Autostakkert", "VideoFileType")
ASOutputFileType := IniRead("00-setup.ini", "Autostakkert", "ASOutputFileType")
PreferredStackDepth := IniRead("00-setup.ini", "Autostakkert", "PreferredStackDepth")
AI := IniRead("00-setup.ini", "Programs", "Autostakkert")
VideoFileType := IniRead("00-setup.ini", "Autostakkert", "VideoFileType")
;
;
;TrayTip "All windows explorers will close in 5seconds"
;sleep 5000

;WinClose "ahk_exe explorer.exe"
; 
sleep 2000
;
; Open your capture folder to help seed files to process
try
    Run FCRoot
catch
    MsgBox "File does not exist."
;
;
TrayTip "Pick your folder and close windows, else this script will minimize everything for you."

; Starting Logging
;
FileAppend "`n`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AS3 Stacking Setup.`n", "Log.txt"
;
;

if A_Args.Length < 1
{
    PATH := InputBox("This script requires at least 1 parameters but it only received " A_Args.Length ".  Please paste the path to your FireCaputre raw AVIs.").value
}
else
{
PATH := A_Args[1]
}
;
; Count files, and log start times
;
;
; minimize all windows
TrayTip "HANDS OFF, I GOT THIS FOR NOW!!!"
sleep 5000
Send "#m"
sleep 5000
;
;
nDIR := PATH "\" VideoFileType
Counter := 0

Loop Files, nDIR
	Counter++
;	
TrayTip VideoFileType " count is: " Counter
;
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " " nDIR ": Input File count is: " Counter "`n", "Log.txt"
;
;
; Log attempted start time of AS3
;
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt")  " Starting AS3 setup.`n", "Log.txt"
TrayTip "HANDS OFF, I GOT THIS FOR NOW!!!"
sleep 5000
;
try
    Run AI
catch
    MsgBox "File does not exist."
sleep 5000
; Consider set focus and or wait for app
;
; Sends file / open
MenuSelect "AutoStakkert",, "File", "Open AVI/SER"
sleep 2000
Send PATH
sleep 2000
ControlClick "Edit1", "ahk_class #32770" ; clicks into edit path to find all files later
sleep 2000
Send "^a"
sleep 2000
Send "^a"
sleep 2000
Send "!o"
sleep 200
;
;This section gets window postion to click into middle of diaglog box

sleep 200
ControlClick "SysListView321", "ahk_class #32770" ; clicks into edit path to find all files later
sleep 2000
Send "^a"
sleep 200
Send "^a"
sleep 200
Send "!o"
;
; This section sets Mike's favorite Mars stacking parameters
;
WinActivate "ahk_class TFormImage"
sleep 2000
SetControlDelay -1
;ControlClick "TRadioButton3","ahk_class TFormImage" ; AP Size 48
sleep 2000
ControlClick "TButton3","ahk_class TFormImage" ; Places AP Grid
sleep 100
WinActivate "ahk_class TFormMain"
ControlClick "TRadioButton2","ahk_class TFormMain" ; Ref frame autosize?  
;
; This section sets Mike's favorite Mars stacking parameters
;
WinActivate "ahk_class TFormImage"
sleep 2000
SetControlDelay -1
;ControlClick "TRadioButton3","ahk_class TFormImage" ; AP Size 48
sleep 2000
ControlClick "TButton3","ahk_class TFormImage" ; Places AP Grid
sleep 100
WinActivate "ahk_class TFormMain"
ControlClick "TRadioButton2","ahk_class TFormMain" ; Ref frame autosize?  
;
TrayTip "Override any stack settings within 20sec"
sleep 20000
ControlClick "TButton5","ahk_class TFormMain" ; presses STACK button
;
; The main body is complete the following line starts the wait until done script
; End Logging
;
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " AS3 Stacking started.`n", "Log.txt"
;
;
Run "15-AS3-wait-loop-v1.ahk" " " PATH