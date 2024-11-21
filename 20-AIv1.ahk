#Requires AutoHotkey v2.0
;
;This Script will open a set of AS3 stacked files in AstraImage and batch sharpen
; 2024.08.29 v2
; rewrite some file opening and mixed in MQTT and tray tip options
; 20230826 v1.7 
;  moving variables to ini file
; 20220222 - ver 1.1
;   Added Logging and file moves
;
; Some key assumptions
;   open file dialog should be set to all or tiff or whatever you get from AS3
;    output in batch should be tiff as well, possibly 16-bit grayscale for downstream automations
;
Logging := 1
;
;Variables
;
q := chr(34) ; https://www.autohotkey.com/board/topic/33688-storing-quotation-marks-in-a-variable/#:~:text=Use%20the%20accent%20symbol%20before%20each%20quote%20mark.,a%20variable%20to%20another%20variable%20and%20need%20quotes.
FCRoot := IniRead("00-setup.ini", "Autostakkert", "FCRoot")
AstraImage := IniRead("00-setup.ini", "Programs", "AstraImage")
Blur := IniRead("00-setup.ini", "AI Settings", "Blur")
Iter := IniRead("00-setup.ini", "AI Settings", "Iter")
PreferredStackDepth := IniRead("00-setup.ini", "Autostakkert", "PreferredStackDepth")
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
FileAppend "`n`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AstraImage Setup.`n", "Log.txt"
;
;
;
if Enabled = 1
	{
	Run TARGET '"AstraImage"'
	Run STATUS '"Starting AstraImage setup..."'
	Run FILTER '"Not yet started"'
	}
;
;
; ================================================================================
; This secion sets up input video files via prompt or arg passing
; ================================================================================
;
;
if A_Args.Length < 1
	{
    UserPathIn := InputBox("This script requires at least 1 parameters but it only received " A_Args.Length ".  Please paste the path to your FireCapture RAW Root, stack depth is read from setup file").value
	UserPathIn := UserPathIn "\" PreferredStackDepth
	if Enabled = 1
		{
		Run STATUS UserPathIn
		}
	}
else
	{
	UserPathIn := A_Args[1]
	if Enabled = 1
		{
		Run STATUS UserPathIn
		}
	}
;
;
; This section sets up a planet specific Sharpening per the setup file
;
FCInput := StrSplit(UserPathIn,"\")
Planet := FCInput[3]
;TrayTip Planet
DateSet := FCInput[4]
CurrentSet := FCRoot "\" Planet "\" DateSet "\"
if (Planet = "Jupiter")
{
	Blur := IniRead("00-setup.ini", "AI Settings", "JupiterBlur")
	Iter := IniRead("00-setup.ini", "AI Settings", "JupiterIter")
	TrayTip "Planet = " Planet
	if Enabled = 1
		{
		Run STATUS Planet
		}
}
else if (Planet = "Saturn")
{
	Blur := IniRead("00-setup.ini", "AI Settings", "SaturnBlur")
	Iter := IniRead("00-setup.ini", "AI Settings", "SaturnIter")
	TrayTip "Planet = " Planet
	if Enabled = 1
		{
		Run STATUS Planet
		}
}
else if (Planet = "Mars")
{
	Blur := IniRead("00-setup.ini", "AI Settings", "MarsBlur")
	Iter := IniRead("00-setup.ini", "AI Settings", "MarsIter")
	TrayTip "Planet = " Planet
	if Enabled = 1
		{
		Run STATUS Planet
		}
}
else if (Planet = "Star")
{
	Blur := IniRead("00-setup.ini", "AI Settings", "StarBlur")
	Iter := IniRead("00-setup.ini", "AI Settings", "StarIter")
	TrayTip "Planet = " Planet
	if Enabled = 1
		{
		Run STATUS Planet
		}
}
else
{
	Blur := IniRead("00-setup.ini", "AI Settings", "Blur")
	Iter := IniRead("00-setup.ini", "AI Settings", "Iter")
	TrayTip "Planet = " Planet
	if Enabled = 1
		{
		Run STATUS Planet
		}
}

;
;
LrD := "Blur=" Blur " and Iter=" Iter, "Your AstraImage settings"
TrayTip LrD
	if Enabled = 1
		{
		Run STATUS q LrD q
		}
FileAppend "`n`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AstraImage Script.`n", "Log.txt"
;
LabelPath := UserPathIn "\LrD-" Blur "-" Iter
DirCreate LabelPath
;
; Open app
;
try
	{
	Run AstraImage
	WinWait "Astra Image" , , 30000
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AstraImage.exe`n", "Log.txt"
	if Enabled = 1
		{
		Run STATUS '"Starting AstraImage"'
		}
	}
catch Error
	{
	MsgBox "AstraImage did not start"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " AstraImage did not start`n", "Log.txt"
	if Enabled = 1
		{
		Run MQTTERROR Error.message
		}
	ExitApp()
	}
;
; Set focus and start batch process
;
try
	{
	WinActivate "Astra Image"
	sleep 200
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Switching to app to start workflow.`n", "Log.txt"
	if Enabled = 1
		{
		Run STATUS '"Starting AstraImage batch process"'
		}
	}
catch
	{
	MsgBox "AstraImage did not start"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " AstraImage did not start`n", "Log.txt"
	if Enabled = 1
		{
		Run MQTTERROR Error.message
		}
	ExitApp()
	}
;	
; Sends file / open (alt+f,b,s)
;
try
	{
	MenuSelect "Astra Image",, "File", "Batch Processing", "Simple Deconvolution"
	sleep 200
	WinWait "ahk_class TfrmSimpleDeconvolutionBatch" , , 3000
	sleep 200
	WinActivate "ahk_class TfrmSimpleDeconvolutionBatch" , , 3000
	sleep 200
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Opened Simple Deconvolution.`n", "Log.txt"
	if Enabled = 1
		{
		Run STATUS '"Starting batch setup params"'
		}
	sleep 200
	WinActivate "ahk_class TfrmSimpleDeconvolutionBatch" , , 3000
	}
catch Error
	{
    MsgBox("Error: " Error.message "`nExiting script.")
    FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " AstraImage batch dialogue not start`n", "Log.txt"
	if Enabled = 1
		{
		Run MQTTERROR Error.message
		}
	ExitApp()
	}
;
; Adds source files
;
; ref
; SetControlDelay -1
; ControlClick "Toolbar321", WinTitle,,,, "NA"
; via  https://www.autohotkey.com/docs/v2/lib/ControlClick.htm
;
try
	{
	SetControlDelay -1
	ControlClick "TButton6", "ahk_class TfrmSimpleDeconvolutionBatch",,,, "NA"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Clicked add files.`n", "Log.txt"
	sleep 3000
	WinWait "ahk_class #32770" , , 30000
	sleep 3000
	WinActivate "ahk_class #32770" , , 30000
	sleep 3000
	WinActivate "ahk_class #32770" , , 30000
	sleep 3000
	WinActivate "ahk_class #32770" , , 30000
	sleep 3000
	SetControlDelay -1
	ControlClick "Edit1", "ahk_class #32770" ,,,, "NA" ; clicks into edit path to refocus window
	Send UserPathIn "`n"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Pasting " UserPathIn "`n", "Log.txt"
	sleep 2000
	WinActivate "ahk_class #32770" , , 30000
	SetControlDelay -1
	ControlClick "Edit1", "ahk_class #32770" ,,,, "NA" ; clicks into edit path to refocus window
	Send "+{Tab 1}"
	sleep 1000
	Send "^a"
	sleep 200
	Send "^a"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Selecting ALL.`n", "Log.txt"
	sleep 200
	Send "!o"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Pressing OPEN.`n", "Log.txt"
	WinWaitClose "ahk_class #32770" , , 2000
	if Enabled = 1
		{
		Run STATUS '"Clicked add files successfully"'
		}
	sleep 200
	WinActivate "ahk_class TfrmSimpleDeconvolutionBatch" , , 3000
	}
catch Error
	{
    MsgBox("Error: " Error.message "`nExiting script.")
    FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Add files failed`n", "Log.txt"
	if Enabled = 1
		{
		Run MQTTERROR Error.message
		}
	ExitApp()
	}
;
; Output folder
;
;
;
;
try
	{
	WinActivate "ahk_class TfrmSimpleDeconvolutionBatch" , , 3000
	sleep 200
	SetControlDelay -1
	ControlClick "TButton4", "ahk_class TfrmSimpleDeconvolutionBatch",,,, "NA"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Opening OUTPUT Path dialog.`n", "Log.txt"
	WinWait "ahk_class #32770" , , 10000
	sleep 200
	Send LabelPath "`n"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Pasting " LabelPath ".`n", "Log.txt"
	sleep 1000
	SetControlDelay -1
	ControlClick "Button1","ahk_class #32770"
	WinWaitClose "ahk_class #32770" , , 10000
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Pressing Select Folder.`n", "Log.txt"
	if Enabled = 1
		{
		Run STATUS '"Set output folder successfully"'
		}
	sleep 200
	WinActivate "ahk_class TfrmSimpleDeconvolutionBatch" , , 3000
	}
catch Error
	{
    MsgBox("Error: " Error.message "`nExiting script.")
    FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Output folder failed`n", "Log.txt"
	if Enabled = 1
		{
		Run MQTTERROR Error.message
		}
	ExitApp()
	}
;
; This section sets Mike's favorite Mars stacking parameters
;
sleep 200
WinActivate "ahk_class TfrmSimpleDeconvolutionBatch" , , 3000
sleep 400
ControlClick "TNumEdit3","ahk_class TfrmSimpleDeconvolutionBatch"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Clicking Blur field.`n", "Log.txt"
sleep 1000
Send "`b`b`b`b"
sleep 1000
Send Blur
sleep 1000
ControlClick "TNumEdit2","ahk_class TfrmSimpleDeconvolutionBatch"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Clicking Iter field.`n", "Log.txt"
sleep 1000
Send "`b`b`b`b"
sleep 1000
Send Iter
sleep 1000
ControlClick "TButton3","ahk_class TfrmSimpleDeconvolutionBatch"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Pressing Start.`n", "Log.txt"
	if Enabled = 1
		{
		Run STATUS '"Set parameters and started processing successfully"'
		}

;
;
; Finish Log
;
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Finished AstraImage Setup.`n", "Log.txt"
;
;
; The following script will check AI status and wait until complete
;
;LabelPath := StrReplace(LabelPath, "\", "\\")
Run "25-AI-wait-loop-v1.ahk" " " LabelPath