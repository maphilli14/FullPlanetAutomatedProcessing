#Requires AutoHotkey v2.0
;
;This Script will open a set of FireCaputre recordings in AutoStakkert3 and stack with defaults
;20220222 - ver 1.1
; Added Logging and file moves
;
;Variables
PreferredStackDepth := IniRead("00-setup.ini", "Autostakkert", "PreferredStackDepth")
nX := IniRead("00-setup.ini", "AI Settings", "ProgressX")
nY := IniRead("00-setup.ini", "AI Settings", "ProgressY")
NOTDONE := IniRead("00-setup.ini", "AI Settings", "NOTDONE")
Enabled := IniRead("00-setup.ini", "MQTT", "Enabled")
STATUS := IniRead("00-setup.ini", "MQTT", "STATUS")
MQTTERROR := IniRead("00-setup.ini", "MQTT", "MQTTERROR")
FILTER := IniRead("00-setup.ini", "MQTT", "FILTER")
Target := IniRead("00-setup.ini", "MQTT", "Target")


; NOTDONE means the busy color of the Start button in Simple Decon
;
if A_Args.Length < 1
{
    PATH := InputBox("This script requires at least 1 parameters but it only received " A_Args.Length ".  Please paste the path to your SHARPED images!!").value
}
else
{
PATH := A_Args[1]
;PATH := StrReplace(PATH, "\", "\\")
}
;
;
; Progress is finicky based upon screen zoom and you will need to use the ahkspy to find the color of the button for your win scheme
; The button highlights when it is avaiable and color changee instabliity means you must use UNAVAILABLE, double negative logic
; This section sets window postion the color change on the Start button, Unavailable to press (actively working) = NOTDONE, 
; Available to press (COMPLETE) = DONE
;
;
; Log start of watcher
FileAppend "`n`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AstraImage WATCHER`n", "Log.txt"
;

;
;
; Initial sleep to delay progress checking
Sleep(10000)
;
; This section waits until stacking progress is at 100%
; to prevent an infinte loop use timer * count in loop per https://www.autohotkey.com/board/topic/31617-count-1-on-every-loop/
; 30min = 1800sec ; 1800sec/3sec = 600counts 

Loop 600
{
	WinActivate "ahk_class TfrmSimpleDeconvolutionBatch"
	Progress := PixelGetColor(nX, nY)
	if (Progress = NOTDONE )
	{
		;MouseMove nX, nY
		ToolTip "Checking AI status, please wait, found " Progress " color"
		sleep 5000
		;MouseMove 1100, 700
		;sleep 3000
	}
	else
	{
			break
	}
}
ToolTip "AI COMPLETE"
SetTimer () => ToolTip(), -8000
;MsgBox Progress " means AS3 COMPLETE "

;
nDIR := PATH "\*.tif"
Counter := 0

Loop Files, nDIR
	Counter++
;
; Log start of watcher
FileAppend FormatTime("`n`n" A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " ENDED AstraImage WATCHER`n", "Log.txt"
;
;

;Via ChatGPT Openai
;PATH := Chr(34) . PATH . Chr(34)
Run "30-WSL-RBGv1.ahk" " " PATH




