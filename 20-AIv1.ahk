#Requires AutoHotkey v2.0
;
;This Script will open a set of AS3 stacked files in AstraImage and batch sharpen
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
FCRoot := IniRead("00-setup.ini", "Autostakkert", "FCRoot")
AstraImage := IniRead("00-setup.ini", "Programs", "AstraImage")
Blur := IniRead("00-setup.ini", "AI Settings", "Blur")
Iter := IniRead("00-setup.ini", "AI Settings", "Iter")
PreferredStackDepth := IniRead("00-setup.ini", "Autostakkert", "PreferredStackDepth")
;
;
if A_Args.Length < 1
{
    UserPathIn := InputBox("This script requires at least 1 parameters but it only received " A_Args.Length ".  Please paste the path to your AS3 stacked images ONLY, stack depth is read from setup file").value
	UserPathIn := UserPathIn "\" PreferredStackDepth
}
else
{
UserPathIn := A_Args[1]
;TrayTip UserPathIn
UserPathIn := UserPathIn
}
;

TrayTip "All windows explorers will close in 5seconds"
sleep 5000

WinClose "ahk_exe explorer.exe"
WinClose "ahk_exe explorer.exe"
;
;TrayTip UserPathIn
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

;
;
TrayTip "Blur=" Blur " and Iter=" Iter, "Your AstraImage settings"
FileAppend "`n`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AstraImage Script.`n", "Log.txt"
;
LabelPath := UserPathIn "\LrD-" Blur "-" Iter
DirCreate LabelPath
;
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AstraImage.exe`n", "Log.txt"
try
	Run AstraImage
catch
	MsgBox "File does not exist."
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Please check setup for AI.exe location`n", "Log.txt"
sleep 10000
; Set focus and or wait for app
;
WinActivate "ahk_class TfrmMain"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Switching to app.`n", "Log.txt"
sleep 2000
;
; Sends file / open (alt+f,b,s)
MenuSelect "Astra Image",, "File", "Batch Processing", "Simple Deconvolution"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Opened Simple Deconvolution.`n", "Log.txt"
sleep 10000
SetControlDelay -1
; This looks for "Files to process: Add Files"
ControlClick "TButton6","ahk_class TfrmSimpleDeconvolutionBatch"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Opening add files.`n", "Log.txt"
sleep 4000
WinActivate "Batch Processing Files"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Switching to file open.`n", "Log.txt"
; then removes existing path info by pasting in "our" path / need CR?
Send UserPathIn
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Pasting " UserPathIn ".`n", "Log.txt"
sleep 1000
; Opens path to expose files
Send "!o"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Opening " UserPathIn ".`n", "Log.txt"
;
;This section gets window postion to click into middle of diaglog box
; Then click into files, select all and open them for processing
WinGetPos &X, &Y, &W, &H, "ahk_class #32770"
;
nX := Integer((X+(W/2))/1)
ny := Integer((Y+(H/2))/1)

;nX := 250
;ny := 250
;
sleep 1000
MouseClick "left", nX, nY
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Clicking into files.`n", "Log.txt"
sleep 3000
Send "^a"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Selecting ALL.`n", "Log.txt"
sleep 2000
Send "!o"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Pressing OPEN.`n", "Log.txt"
;
; sets output dir created above
sleep 4000
;
ControlClick "TButton4","ahk_class TfrmSimpleDeconvolutionBatch"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Opening OUTPUT Path dialog.`n", "Log.txt"
sleep 4000
Send LabelPath
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Pasting " LabelPath ".`n", "Log.txt"
sleep 2000
;
; This section sets Mike's favorite Mars stacking parameters
;
sleep 4000

ControlClick "Button1","ahk_class #32770"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Pressing Select Folder.`n", "Log.txt"
sleep 2000
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