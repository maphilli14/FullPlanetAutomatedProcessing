#Requires AutoHotkey v2.0
;
;This Script will open a set of FireCaputre recordings in AutoStakkert3 and stack with defaults
;20220222 - ver 1.1
; Added Logging and file moves
;
;
Logging := 1
;
;Variables
;
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
;
if A_Args.Length < 1
{
    PATH := InputBox("This script requires at least 1 parameters but it only received " A_Args.Length ".  Please paste the path to your AS3 stacked images.").value
}
else
{
PATH := A_Args[1]
}
; Starting Logging
;
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AS3 Stacking watcher.`n", "Log.txt"
;
;
;
BLACK := "0x000000"
WHITE := "0xFFFFFF"
;
;This section sets window postion to find total progress bar end
;nX := Integer(901)
;ny := Integer(890)
;
;
; Initial sleep to delay progress checking
Sleep(10000)
;
; This section waits until stacking progress is at 100%
; to prevent an infinte loop use timer * count in loop per https://www.autohotkey.com/board/topic/31617-count-1-on-every-loop/
; 48hrs = 172,800sec/30sec = 5760counts 
;
; This section sets up a planet specific Sharpening per the setup file
;
UserPathIn := PATH
FCInput := StrSplit(UserPathIn,"\")
Planet := FCInput[3]
DateSet := FCInput[4]
CurrentSet := FCRoot "\" Planet "\" DateSet "\"
StackPath := CurrentSet PreferredStackDepth

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
LabelPath := StackPath "\LrD-" Blur "-" Iter
DirCreate LabelPath
;
CountVID := 0
CountOUT := 0
Loop Files, CurrentSet PreferredStackDepth "\" ASOutputFileType
	CountOUT++
SetTimer () => ToolTip(), -20000
Loop Files, CurrentSet VideoFileType
	CountVID++
;
TrayTip "Stacking should be started.  Found " CountOUT " stacked Files in " CurrentSet PreferredStackDepth "\" ASOutputFileType
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Stacking should be started.  Found " CountOUT " stacked Files in " CurrentSet "\" PreferredStackDepth "\" ASOutputFileType "`n", "Log.txt"

TrayTip "Found " CountVID " Video Files in " CurrentSet VideoFileType
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found " CountVID " Video Files in " CurrentSet "\" VideoFileType "`n", "Log.txt"
;
;
TrayTip "Blur=" Blur " and Iter=" Iter, "Your AstraImage settings"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AstraImage Script.  Using Blur=" Blur " and Iter=" Iter " AstraImage settings`n", "Log.txt"
;


;

;
;
; This loop waits for the first file to get processed before loading previews in AstraImage
if CountOUT = 0
{
	Loop 5760
	 {
		TrayTip "Waiting for 1st file"
		CountOUT := 0
		Loop Files, CurrentSet PreferredStackDepth "\" ASOutputFileType
			CountOUT++
		Sleep 4000
		FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AstraImage.exe`n", "Log.txt"	 
		if CountOUT >= 1
		{
			TrayTip "Found 1st file, moving to next step"
			break
		}
		else
		{
		}
	}
}
;
;
;
; This loop previews in AstraImage until tif count matches avi count
if CountOUT > 0
{
	Loop 5760
	 {
		CountVID := 0
		CountOUT := 0
		FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AstraImage.exe`n", "Log.txt"
		try
			WinClose "ahk_exe AstraImageWindows.exe"
		try
			Run AstraImage
		catch
			MsgBox "File does not exist."
			FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Please check setup for AI.exe location`n", "Log.txt"
		sleep 10000
		;
		; This section compares input and output files types to evaulate if AS3 was successfule before checking proress bar.
		Loop Files, CurrentSet VideoFileType
			CountVID++
		;
		Loop Files, CurrentSet PreferredStackDepth "\" ASOutputFileType
			CountOUT++
		TrayTip "Found stacked file for AI Preview"
		TrayTip "Stacked files=" CountOUT " and Video Files=" CountVID
		TrayTip "Progress =" Ceil((CountOUT/CountVID)*100) "%"
		ToolTip "Checking AS3 output file status, please wait"
		SetTimer () => ToolTip(), -20000
		FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found stacked file for AI Preview`n", "Log.txt"
		; Set focus and or wait for app
		;
		try
		{
			WinActivate "ahk_exe AstraImageWindows.exe"
			MenuSelect "Astra Image",, "File", "Open"
			WinWait "Astra Image - Open File"
			sleep 500
			Send StackPath "`n"
			sleep 2000
			;WinWaitClose "Astra Image - Open File"
			;Open latest file, Tab, end, Enter then wait close
			Send "+{Tab 1}"
			sleep 1000
			Send "{End 1}" "`n"
			sleep 2000
			Send "!n" "m"
			;MenuSelect "Enhance",, "Simple Deconvolution"
			sleep 2000
			ControlClick "TNumEdit1","ahk_class TfrmSDDeconvolution"
			sleep 1000
			Send "`b`b`b`b"
			sleep 1000
			Send Blur
			sleep 1000
			ControlClick "TNumEdit3","ahk_class TfrmSDDeconvolution"
			sleep 1000
			Send "`b`b`b`b"
			sleep 1000
			Send Iter
			sleep 1000
			ControlClick "TButton3","ahk_class TfrmSDDeconvolution"
			Send "`n"
			;
			Sleep 2000
			WinWaitClose "ahk_class TfrmSDDeconvolution"
			;
			; Saves file to skep next steps
			;
			WinActivate "ahk_exe AstraImageWindows.exe"
			MenuSelect "Astra Image",, "File", "Save As"
			sleep 2000
			LabelPath := StackPath "\LrD-" Blur "-" Iter
			Send "{Home 1}"
			Send LabelPath "\"
			sleep 1000
			ControlClick "Button2","ahk_class #32770"
			Send "`n"
			sleep 10000
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
			break
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
	}
		else
		{
		}
}
else
{
}
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
ToolTip "AS3 COMPLETE"
SetTimer () => ToolTip(), -8000
;MsgBox Progress " means AS3 COMPLETE "
;
;
;
; Logging AS3 complete
;
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " COMPLETED AS3 processing.`n", "Log.txt"
;
;
; Close AS3 to begin file move mode -> 17-FCFileMover1.py
;
WinActivate "ahk_class TFormImage"
sleep 2000
MenuSelect "AutoStakkert",, "File", "Exit"
sleep 5000
Run "17-FCFileMover1.ahk" " " PATH
