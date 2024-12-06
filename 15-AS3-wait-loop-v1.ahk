#Requires AutoHotkey v2.0
;
;This Script will open a set of FireCaputre recordings in AutoStakkert3 and stack with defaults
; 20240807 v2 includes MQTT and lots of cleanup
;20220222 - ver 1.1
; Added Logging and file moves
;
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
nX := IniRead("00-setup.ini", "Autostakkert", "ProgressX")
nY := IniRead("00-setup.ini", "Autostakkert", "ProgressY")
VideoFileType := IniRead("00-setup.ini", "Autostakkert", "VideoFileType")
ASOutputFileType := IniRead("00-setup.ini", "Autostakkert", "ASOutputFileType")
ExplorerFileField := IniRead("00-setup.ini", "Programs", "ExplorerFileField")
Enabled := IniRead("00-setup.ini", "MQTT", "Enabled")
; These are moved below the args passing
;UserPathIn := PATH
;FCInput := StrSplit(UserPathIn,"\")
;Planet := FCInput[3]
;DateSet := FCInput[4]
;CurrentSet := FCRoot "\" Planet "\" DateSet "\"
;StackPath := CurrentSet PreferredStackDepth
STATUS := IniRead("00-setup.ini", "MQTT", "STATUS")
MQTTERROR := IniRead("00-setup.ini", "MQTT", "MQTTERROR")
FILTER := IniRead("00-setup.ini", "MQTT", "FILTER")
Target := IniRead("00-setup.ini", "MQTT", "Target")
BLACK := "0x000000"
WHITE := "0xFFFFFF"
;
;This section sets window postion to find total progress bar end
;nX := Integer(901)
;ny := Integer(890)
;
;
;
; ================================================================================
; Initial sleep to delay progress checking
; ================================================================================
;
;
Sleep(10000) ; 10seconds
;
;
;
; ================================================================================
; Starting Logging
; ================================================================================
;
;
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AS4 Stacking watcher.`n", "Log.txt"
;
if Enabled = 1
	{
	Run STATUS '"Starting Autostakkert monitoring..."'
	}
;
;
;
; ================================================================================
; This secion sets up input video files via prompt or arg passing
; ================================================================================
;
;
if A_Args.Length < 1
	{
    PATH := InputBox("This script requires at least 1 parameters but it only received " A_Args.Length ".  Please paste the path to your AS3 stacked images.").value
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
	}
else
	{
	PATH := A_Args[1]
	}
;
UserPathIn := PATH
FCInput := StrSplit(UserPathIn,"\")
Planet := FCInput[3]
DateSet := FCInput[4]
CurrentSet := FCRoot "\" Planet "\" DateSet "\"
StackPath := CurrentSet PreferredStackDepth
;
;
; ================================================================================
; This section sets up a planet specific Sharpening per the setup file
; ================================================================================
;
;
;
if (Planet = "Jupiter")
{
	Blur := IniRead("00-setup.ini", "AI Settings", "AvgJupiterBlur")
	Iter := IniRead("00-setup.ini", "AI Settings", "AvgJupiterIter")
	TrayTip "Planet = " Planet
}
else if (Planet = "Saturn")
{
	Blur := IniRead("00-setup.ini", "AI Settings", "SaturnBlur")
	Iter := IniRead("00-setup.ini", "AI Settings", "SaturnIter")
	TrayTip "Planet = " Planet
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
}
else
{
	Blur := IniRead("00-setup.ini", "AI Settings", "Blur")
	Iter := IniRead("00-setup.ini", "AI Settings", "Iter")
	TrayTip "Planet = " Planet
}
try
	{
	LabelPath := StackPath "\LrD-" Blur "-" Iter "Preview"
	DirCreate LabelPath
	if Enabled = 1
		{
		Run STATUS '"Creating AI Folders"'
		}
	}
catch
	{
	if Enabled = 1
		{
		Run MQTTERROR '"You are missing the FC ROOT files!"'
		}
	else
		{
		MsgBox "You are missing the FC ROOT files!"
		}
	}
;
;
;
; ================================================================================
; This secion sets up progress counting
; ================================================================================
;
;
; Quantity of RAW FC videos
CountVID := 0
; Quantity of STACKED files output from AS4
CountOUT := 0
Loop Files, CurrentSet PreferredStackDepth "\" ASOutputFileType
	CountOUT++
SetTimer () => ToolTip(), -20000
Loop Files, CurrentSet VideoFileType
	CountVID++
;

TrayTip "Stacking should be started.  Found " CountOUT " stacked Files in " CurrentSet PreferredStackDepth "\" ASOutputFileType
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Stacking should be started.  Found " CountOUT " stacked Files in " CurrentSet "\" PreferredStackDepth "\" ASOutputFileType "`n", "Log.txt"

TrayTip "Found " CountVID " Video Files in " CurrentSet "\" VideoFileType
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found " CountVID " Video Files in " CurrentSet "\" VideoFileType "`n", "Log.txt"
;
;
TrayTip "Blur=" Blur " and Iter=" Iter, "Your AstraImage settings"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AstraImage Script.  Using Blur=" Blur " and Iter=" Iter " AstraImage settings`n", "Log.txt"
;
;
; This loop waits for the first file to get processed before loading previews in AstraImage
if CountOUT = 0
	{
	; This section send MQTT if enabled
	if Enabled = 1
		{
		Run Filter CountOUT
		}
	; Loop 60x 10s = 10min then error out as no AS4 got stacked
	Loop 60
		{
		TrayTip "Waiting for 1st file"
		Loop Files, CurrentSet PreferredStackDepth "\" ASOutputFileType
			CountOUT++
		FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AstraImage.exe`n", "Log.txt"	 
		if CountOUT >= 1
			{
			TrayTip "Found 1st file, moving to next step"
			break
			}
		else
			{
			Sleep 10000
			}
		}
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " NO FILE EVER STACKED`n", "Log.txt"
	if Enabled = 1
		{
		Run MQTTERROR '"NO AS4 files written in 10min!"'
		}
	}
;
; Start AI 
; This loop previews in AstraImage until tif count matches avi count
; if the tif count never matches due to processing AVI's faster than preview, the script will periodically evaluate the AS4 progress meter
;
; begins only when a stacked file is spit out!
; while running, each stacked file gets process in AI and saved until either all files are done or the AS4 progress finishes
if CountOUT > 0
	{
	CountVID := 0
	CountOUT := 0
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AstraImage.exe`n", "Log.txt"
	try
		WinClose "ahk_exe AstraImageWindows.exe"
	try
	{
		Run AstraImage
		if Enabled = 1
			{
			Run TARGET '"AstraImage Preview"'
			Run STATUS '"Previewing in AstraImage"'
			}	
	}
	catch
		{
		MsgBox "File does not exist."
		if Enabled = 1
			{
			Run MQTTERROR '"Please check setup for AI.exe location"'
			}
		FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Please check setup for AI.exe location`n", "Log.txt"
		; exit of script is desired, but break only works for loops not catches?
		;break
		}
	WinWait "Astra Image"
	;
	; This section compares input and output files types to evaulate if AS4 was successfule before checking proress bar.
	Loop Files, CurrentSet VideoFileType
		CountVID++
	;
	Loop Files, CurrentSet PreferredStackDepth "\" ASOutputFileType
		CountOUT++
	TrayTip "Found stacked file for AI Preview"
	COUTTXT := "Progress =" Ceil((CountOUT/CountVID)*100) "%"
	TrayTip "Stacked files=" CountOUT " and Video Files=" CountVID
	TrayTip COUTTXT
	if Enabled = 1
		{
		Run FILTER q COUTTXT q
		}			
	ToolTip "Checking AS3 output file status, please wait"
	SetTimer () => ToolTip(), -20000
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found stacked file for AI Preview`n", "Log.txt"
	; Set focus and or wait for app
	; opens AI, sharps and saves, no error handling
	try
		{
		WinActivate "ahk_exe AstraImageWindows.exe"
		MenuSelect "Astra Image",, "File", "Open"
		WinWait "Astra Image - Open File"
		WinWait "ahk_class #32770"
		sleep 1000 ; MQTT Pub opens window and AHK needs time to refoucs active window
		WinActivate "ahk_class #32770"
		sleep 1000 ; MQTT Pub opens window and AHK needs time to refoucs active window
		WinActivate "ahk_class #32770" ; clicks into edit path to refocus window
		sleep 1000 ; MQTT Pub opens window and AHK needs time to refoucs active window
		WinActivate "ahk_class #32770"
		sleep 1000 ; MQTT Pub opens window and AHK needs time to refoucs active window
		WinActivate "ahk_class #32770" ; clicks into edit path to refocus window
		ControlClick "Edit1", "ahk_class #32770" ; clicks into edit path to refocus window
		Send "!a" ; unneded alt+a
		sleep 200
		Send "!n" ; ensures it's inside path
		Send StackPath "`n" ; pastes path
		sleep 200
		Send "+{Tab 1}"
		sleep 1000
		Send "{End 1}" "`n"
		sleep 2000
		Send "!n" "m"
		WinWait "ahk_class TfrmSDDeconvolution"
		ControlClick "TNumEdit1","ahk_class TfrmSDDeconvolution"
		sleep 100
		Send "`b`b`b`b"
		sleep 100
		Send Blur
		sleep 100
		ControlClick "TNumEdit3","ahk_class TfrmSDDeconvolution"
		sleep 100
		Send "`b`b`b`b"
		sleep 100
		Send Iter
		sleep 100
		ControlClick "TButton3","ahk_class TfrmSDDeconvolution"
		Send "`n"
		;
		Sleep 200
		WinWaitClose "ahk_class TfrmSDDeconvolution"
		;
		; Saves file to skep next steps
		;
		WinActivate "ahk_exe AstraImageWindows.exe"
		MenuSelect "Astra Image",, "File", "Save As"
		sleep 2000
		Send "{Home 1}"
		Send LabelPath "\"
		WinWait "ahk_class #32770"
		ControlClick "Button2","ahk_class #32770"
		Send "`n"
		WinWait "ahk_class TfrmSave"
		ControlClick "TButton2","ahk_class TfrmSave"
		Send "`n"
		}
	if CountOUT >= CountVID
		{
		TrayTip "Found same in and out file counts"
		TrayTip "New file found, wrap up your work, will close AI in 10sec"
		sleep 10000
		WinClose "ahk_exe AstraImageWindows.exe"
		WinActivate "ahk_exe AutoStakkert.exe"
		FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Switching to AS3 for wrap up watching.`n", "Log.txt"
		sleep 2000
		; exit of script is desired, but break only works for loops not catches?
		;break
		}
	else
		{
		; This sections from Discord AHK Help
		;
		thatFile := WaitFolder(StackPath)
		TrayTip thatFile
		WaitFolder(folder, timeout := 900000) {
			newFile := false
			Callback(folder, changes) {
				for change in changes
					if change.Action == 1 ; FILE_ACTION_ADDED
						newFile := change.Name
		}
		WatchFolder(folder, callback)
		start := A_TickCount
		while !newFile && (start - A_TickCount) < timeout
			sleep 50
		WatchFolder(folder, "**DEL")
		return newFile
	;
	#Include "100-FileWatchLib.ahk"
	;
	}
	else
	{
	}
}
else
{
}
;
; OLD METHOD ...This secion defines the AS4 watch for end progress
;Loop 5760
;{
;	ToolTip "Checking AS3 status, please wait"
;	SetTimer () => ToolTip(), -20000
;	WinActivate "ahk_exe AutoStakkert.exe"
;	sleep 100
;	WinActivate "ahk_exe AutoStakkert.exe"
;	Progress := PixelGetColor(nX, nY, "Alt")
;	sleep 30000
;	;if WinExist "ahk_class TFormImage"
;	;	ControlClick "Button1","ahk_class #32770"
;	if WinExist("ahk_class #32770")
;		ControlClick "Button1", "ahk_class #32770" ; clicks into edit path to find all files later
;		FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Recovered from error.`n", "Log.txt"
;	if (Progress = BLACK )
;		TrayTip "Found 100% Progress, moving to next step"
;		FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Finished AS3 Stacking watcher.`n", "Log.txt"
;		break
;}
;
; NEW METHOD ...Compare stacks to vids and break when equal!
;
;
Loop 5760
{
	ToolTip "Checking AS3 status, please wait"
	SetTimer () => ToolTip(), -20000
	WinActivate "ahk_exe AutoStakkert.exe"
	sleep 100
	WinActivate "ahk_exe AutoStakkert.exe"
	Progress := PixelGetColor(nX, nY, "Alt")
	sleep 30000
	;if WinExist "ahk_class TFormImage"
	;	ControlClick "Button1","ahk_class #32770"
	if WinExist("ahk_class #32770")
		ControlClick "Button1", "ahk_class #32770" ; clicks into edit path to find all files later
		FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Recovered from error.`n", "Log.txt"
	if (Progress = BLACK )
		TrayTip "Found 100% Progress, moving to next step"
		FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Finished AS3 Stacking watcher.`n", "Log.txt"
		break
}
ToolTip "AS4 COMPLETE"
SetTimer () => ToolTip(), -8000
;MsgBox Progress " means AS3 COMPLETE "
;
;
;
; Logging AS3 complete
;
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " COMPLETED AS4 processing.`n", "Log.txt"
;
;
; Close AS3 to begin file move mode -> 17-FCFileMover1.py
;
WinActivate "ahk_class TFormImage"
sleep 2000
MenuSelect "AutoStakkert",, "File", "Exit"
sleep 5000
Run "17-FCFileMover1.ahk" " " PATH
