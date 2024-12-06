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
Target := IniRead("00-setup.ini", "MQTT", "Target")
STATUS := IniRead("00-setup.ini", "MQTT", "STATUS")
FILTER := IniRead("00-setup.ini", "MQTT", "FILTER")
MQTTERROR := IniRead("00-setup.ini", "MQTT", "MQTTERROR")
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
; ================================================================================
; INTRO!
; ================================================================================
;	
result := MsgBox("Ready for FullPlanetAutomatedProcessing?  `n Pick your folder to process from the open FC root  `n This MsgBox will time out in 10 seconds.  Continue?",, "Y/N T10")
if (result = "Timeout")
	{
	TrayTip "You didn't press YES or NO within the 10-second period."
    Exit ; Terminate this function as well as the calling function.
	}
else if (result = "No")
	{
	MsgBox "You pressed NO?!?!"
    Exit ; Terminate this function as well as the calling function.
    MsgBox "This MsgBox will never happen because of the Exit."
	}
else (result = "Yes")
	{
    TrayTip "You Said YES :) `n Do NOT touch, I got this...."
	}
;
; ================================================================================
; This secion runs Autostakkert
; ================================================================================
;
; minimize all windows
TrayTip "HANDS OFF, I GOT THIS FOR NOW!!!"
Send "#m"
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
; Copy of 41-FC-Settings-Parser for ease of use
; ================================================================================
;
;
;
try
{
	Loop Files, PATH "\*R.txt"
	{
		RedFile := A_LoopFilePath
	}
	Loop Files, PATH "\*G.txt"
	{
		GreenFile := A_LoopFilePath
	}
	Loop Files, PATH "\*B.txt"
	{
		BlueFile := A_LoopFilePath
	}
	;
	Loop read, RedFile
	;
	{
		if InStr(A_LoopReadLine, "Shutter")
			RedShutter := A_LoopReadLine	
		if InStr(A_LoopReadLine, "Gain")
			RedGain := A_LoopReadLine	
	}
	RedShutter := SubStr(RedShutter, 9 , 4)
	RedShutter := Round(RedShutter,0)
	RedGain := SubStr(RedGain, 6 , 4)
	RedGain := RedGain
	;
	;Loop read,  "C:\Personal\B-Sorted\Astronomy\20-Stacked\SolarSystem\Jupiter\Jupiter_2023_09_04\2023-09-04-0819_1-G.txt"
	;Loop read, "P:\Personal\E-Delete\FC-Expiring--20240309\Saturn\Saturn_2023_09_01\2023-09-01-0342_9-G.txt"
	;
	Loop read, GreenFile
	{
		if InStr(A_LoopReadLine, "Shutter")
			GreenShutter := A_LoopReadLine	
		if InStr(A_LoopReadLine, "Gain")
			GreenGain := A_LoopReadLine	
	}
	GreenShutter := SubStr(GreenShutter, 9 , 4)
	GreenShutter := Round(GreenShutter,0)
	GreenGain := SubStr(GreenGain, 6 , 4)
	GreenGain := GreenGain
	;
	;Loop read,  "C:\Personal\B-Sorted\Astronomy\20-Stacked\SolarSystem\Jupiter\Jupiter_2023_09_04\2023-09-04-0818_6-B.txt"
	;Loop read, "P:\Personal\E-Delete\FC-Expiring--20240309\Saturn\Saturn_2023_09_01\2023-09-01-0340_9-B.txt"
	Loop read, BlueFile
	{
		if InStr(A_LoopReadLine, "Shutter")
			BlueShutter := A_LoopReadLine	
		if InStr(A_LoopReadLine, "Gain")
			BlueGain := A_LoopReadLine	
	}
	BlueShutter := SubStr(BlueShutter, 9 , 4)
	BlueShutter := Round(BlueShutter,0)
	BlueGain := SubStr(BlueGain, 6 , 4)
	BlueGain := BlueGain
	;
	;
	TrayTip "RBG: " RedShutter  ", " BlueShutter  ", " GreenShutter  " ms`nGain: " RedGain  ", " BlueGain  ", " GreenGain
	A_Clipboard := "RBG: " RedShutter  ", " BlueShutter  ", " GreenShutter  " ms`nGain: " RedGain  ", " BlueGain  ", " GreenGain
	;
	FileAppend "`n`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") "`nRedFile= " RedFile "`nBlueFile= " BlueFile "`nGreenFile= " GreenFile, "FCSettings.txt"
	FileAppend "`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Logging Firecapture Exposure Settings`n`n" A_Clipboard, "FCSettings.txt"
}
;
;
; ================================================================================
; END of 41-FC-Settings-Parser for ease of use
; ================================================================================
;
;
;
;
;
; ================================================================================
; Count files, and log start times
; ================================================================================
;
;
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
			Run TARGET '"Autostakkert4"'
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
; ================================================================================
; This secion opens your inputed files
; ================================================================================
;
;
; Sends file / open
try
	{
	WinActivate "AutoStakkert"
	MenuSelect "AutoStakkert",, "File", "Open AVI/SER"
    if Enabled = 1
		{
		Run STATUS '"AS4 file menu OK"'
		sleep 2000 ; 2seconds ; long waits due to bg win popups and traytips
		WinWait "ahk_class #32770"
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
Run "15-AS3-wait-loop-v2.ahk" " " PATH