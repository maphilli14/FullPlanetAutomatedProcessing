#Requires AutoHotkey v2.0
;
;This Script will open a set of FireCaputre recordings in AutoStakkert3 and stack with defaults
; 20240807 v2 includes MQTT and lots of cleanup
; 20230826 v1.7 
;  moving variables to ini file
; 20220222 - ver 1.1
;  Added Logging and file moves
;
Logging := 1
;
; Variables
;
q := chr(34) ; https://www.autohotkey.com/board/topic/33688-storing-quotation-marks-in-a-variable/#:~:text=Use%20the%20accent%20symbol%20before%20each%20quote%20mark.,a%20variable%20to%20another%20variable%20and%20need%20quotes.
FCRoot := IniRead("00-setup.ini", "Autostakkert", "FCRoot")
VideoFileType := IniRead("00-setup.ini", "Autostakkert", "VideoFileType")
ASOutputFileType := IniRead("00-setup.ini", "Autostakkert", "ASOutputFileType")
PreferredStackDepth := IniRead("00-setup.ini", "Autostakkert", "PreferredStackDepth")
AS4 := IniRead("00-setup.ini", "Programs", "Autostakkert")
VideoFileType := IniRead("00-setup.ini", "Autostakkert", "VideoFileType")
Enabled := IniRead("00-setup.ini", "MQTT", "Enabled")
STATUS := IniRead("00-setup.ini", "MQTT", "STATUS")
MQTTERROR := IniRead("00-setup.ini", "MQTT", "MQTTERROR")
FILTER := IniRead("00-setup.ini", "MQTT", "FILTER")
Target := IniRead("00-setup.ini", "MQTT", "Target")
;
;
; ================================================================================
; Starting Logging
; ================================================================================
;
;
FileAppend "`n`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AS4 Stacking Setup.`n", "Log.txt"
;
;
;
if Enabled = 1
	{
	Run MQTTERROR '"Starting setup..."' ; clears previous errors to avoid confusion
	Run STATUS '"Starting AS4 setup..."'
	}
;
;
; ================================================================================
; This secion sets up input video files via prompt or arg passing
; ================================================================================
;
;
try
    Run FCRoot
catch
	if Enabled = 1
	{
	Run MQTTERROR '"You are missing the FC ROOT files!"'
	}
	else
	{
    MsgBox "You are missing the FC ROOT files!"
	}
;
;
TrayTip "Pick your folder and close windows, else this script will minimize everything for you."


if A_Args.Length < 1
{
    if Enabled = 1
		{
		Run MQTTERROR '"Needs input"'
		}
	PATH := InputBox("This script requires at least 1 parameters but it only received " A_Args.Length ".  Please paste the path to your FireCaputre raw AVIs.").value
    if Enabled = 1
		{
		Run MQTTERROR '"Running"'
		}
}
else
{
PATH := A_Args[1]
}
;
;
; ================================================================================
; Count files, and log start times
; ================================================================================
;
;
; minimize all windows
TrayTip "HANDS OFF, I GOT THIS FOR NOW!!!"
sleep 5000
Send "#m"
sleep 5000
;MouseMove 100, 100
;
nDIR := PATH "\" VideoFileType
Counter := 0
;
Loop Files, nDIR
	Counter++
;	
TrayTip VideoFileType " count is: " Counter
if Enabled = 1
	{
	Run Filter Counter
	}
;
COUTTXT := nDIR ": Input File count is: " Counter
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " " nDIR ": Input File count is: " Counter "`n", "Log.txt"
;
; Log attempted start time of AS3
;
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt")  " Starting AS4 setup.`n", "Log.txt"
sleep 10000 ; 10seconds
if Enabled = 1
	{
		try
		{
			Run TARGET '"AS4"'
			Run FILTER q COUTTXT q
			Run STATUS '"Starting AS4 setup"'
		}
		catch as e  ; Handles the first error thrown by the block above.
		{
			MsgBox "An error was thrown!`nSpecifically: " e.Message
			Exit
		}
	}
else
{
   TrayTip "MQTT NOT Enabled"
}
;
; 
; This secion runs Autostakkert and opens your inputed files
;
;
try
	{
    Run AS4
    if Enabled = 1
		{
		Run STATUS '"Opening AS4"'
		}
	WinWait "AutoStakkert"
	WinActivate "AutoStakkert"
    if Enabled = 1
		{
		Run STATUS '"AS4 Confirmed open"'
		}
	}
catch
	{
    MsgBox "File does not exist."
    if Enabled = 1
		{
		Run MQTTERROR '"AS4 needs input"'
		}
	}
; Sends file / open
try
	{
	MenuSelect "AutoStakkert",, "File", "Open AVI/SER"
    if Enabled = 1
		{
		Run STATUS '"AS4 file menu OK"'
		sleep 2000 ; 2seconds ; long waits due to bg win popups and traytips
		ControlClick "Edit1", "ahk_class #32770" ; clicks into edit path to find all files later
		}
	}
catch
	{
	if Enabled = 1
		{
		Run STATUS '"AS4 file menu failed"'
		Run MQTTERROR '"Starting setup..."' ; clears previous errors to avoid confusion
		Exit
		}
	}
try
	{
	WinWait "ahk_class #32770"
	sleep 5000 ; MQTT Pub opens window and AHK needs time to refoucs active window
	WinActivate "ahk_class #32770"
	sleep 5000 ; MQTT Pub opens window and AHK needs time to refoucs active window
	WinActivate "ahk_class #32770" ; clicks into edit path to refocus window
	ControlClick "Edit1", "ahk_class #32770" ; clicks into edit path to refocus window
	Send "!a" ; unneded alt+a
	sleep 200
	Send "!n" ; ensures it's inside path
	Send PATH  "`n" ; pastes path
	sleep 200
	ControlClick "Edit1", "ahk_class #32770" ; clicks into edit path to find all files later
	sleep 5000 ; MQTT Pub opens window and AHK needs time to refoucs active window
	sleep 200
	Send "{Shift down}" ; Shift+TAB into files area
	Send "{Tab}"        ; Shift+TAB into files area
	Send "{Shift up}"   ; Shift+TAB into files area
	sleep 200
	Send "{Home}"  ; change file selection
	Send "Right"   ; change file selection
	sleep 200
	Send "^a"   ; SELECT ALL
	sleep 200
	Send "^a"   ; SELECT ALL
	sleep 200
	Send "!o" ; Loads all files
	WinWaitClose "ahk_class #32770" , , 30000 ; validate this section by making sure file dialgoue closes
    if Enabled = 1
		{
		Run STATUS '"AS4 files opened OK"'
		}
	}
catch
	{
	if Enabled = 1
		{
		Run STATUS '"AS4 opening files failed"'
		}
	}
;
;
; This section sets various AP size parameters
;
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
ControlClick "TRadioButton1","ahk_class TFormImage" ; AP Size 104
sleep 2000
ControlClick "TButton3","ahk_class TFormImage" ; Places AP Grid
sleep 100
WinActivate "ahk_class TFormMain"
ControlClick "TRadioButton2","ahk_class TFormMain" ; Ref frame autosize
ControlClick "TRadioButton4","ahk_class TFormMain" ; 1.5x Drizzle
;
TrayTip "Override any stack settings within 20sec"
ToolTip "Override any stack settings within 20sec"
if Enabled = 1
	{
	Run STATUS '"AS4: Override any stack settings within 20sec"'
	}
sleep 20000
ControlClick "TButton3","ahk_class TFormMain" ; presses STACK button
if Enabled = 1
	{
	Run STATUS '"AS4 pressed STACK button"'
	}
;
; The main body is complete the following line starts the wait until done script
; End Logging
;
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " AS4 Stacking started.`n", "Log.txt"
;
;
Run "15-AS3-wait-loop-v1.ahk" " " PATH