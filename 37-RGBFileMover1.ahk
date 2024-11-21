#Requires AutoHotkey v2.0
;
;This Script will perform date math and move files in Windows Explorer
; 20241027 - ver 1.0 ; copies files to local drives, moving pathing to indicate workflow progress
;
; Logic is: Create date in future to archive video files into.
; Compare number of AVI/SER to Stacked AS3 files
; Move files in win explorer if Stack files is = or greater than videos
;
; Unless you care to rewrite these scripts, use the same path depth as I use....
; My capture path in example is E:\A-Inbox\Saturn\Saturn_2024_08_01
; this path depth is important as the planet specific settings are read from path and setup.
; 
;
;   https://www.autohotkey.com/docs/v2/lib/DateAdd.htm
;   https://www.autohotkey.com/docs/v2/lib/DirCreate.htm
;   https://www.autohotkey.com/docs/v2/lib/LoopFiles.htm
;
Logging := 1
;
; Variables
;
DaysFromNow := IniRead("00-setup.ini", "Expiration", "DaysFromNow")
MonthsFromNow := IniRead("00-setup.ini", "Expiration", "MonthsFromNow")
ArchiveDrive := IniRead("00-setup.ini", "Expiration", "ArchiveDrive")
ArchiveDriveName := IniRead("00-setup.ini", "Expiration", "ArchiveDriveName")
ArchiveFolder := IniRead("00-setup.ini", "Expiration", "ArchiveFolder")
ExplorerSleep := IniRead("00-setup.ini", "Expiration", "ExplorerSleep")
FCRoot := IniRead("00-setup.ini", "Autostakkert", "FCRoot")
VideoFileType := IniRead("00-setup.ini", "Autostakkert", "VideoFileType")
ASOutputFileType := IniRead("00-setup.ini", "Autostakkert", "ASOutputFileType")
PreferredStackDepth := IniRead("00-setup.ini", "Autostakkert", "PreferredStackDepth")
ExplorerFileField := IniRead("00-setup.ini", "Programs", "ExplorerFileField")
LocalDST := IniRead("00-setup.ini", "ExportFolders", "LocalDST")
;
;
; This section takes user input
;
if A_Args.Length < 1
{
    UserPathIn := InputBox("This script requires at least 1 parameters but it only received " A_Args.Length ".  Please paste the path to your FireCapture RAW Root.").value
}
else
{
UserPathIn := A_Args[1]
}
;
;
;
; This section splits input FC captures to obtain planet and current capture date
;
PATH := UserPathIn "\" PreferredStackDepth
FCInput := StrSplit(UserPathIn,"\")
Planet := FCInput[3]
DateSet := FCInput[4]
CurrentSet := UserPathIn
;
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
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Blur=" Blur " and Iter=" Iter "are your AstraImage settings`n", "Log.txt"
;
DeCon :=  "\LrD-" Blur "-" Iter

;
;This Section calculates the expiry
;
TimeString := FormatTime(, "yyyyMMdd")
;MsgBox "The current ISO date is " TimeString
Expiration := DateAdd(A_Now, DaysFromNow, "days")
Expiration := FormatTime(Expiration, "yyyyMMdd")
;MsgBox "The expiration ISO date is " Expiration
FileAppend "`n`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting Video Archive process.`n", "Log.txt"
;
;
; This Section Creates the expiry folder
;
ExpPath := ArchiveDrive "\" ArchiveFolder "\" "FC-Expiring--" Expiration "\" Planet "\" DateSet
DirCreate ExpPath
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Archived Folder is: " ExpPath " named " ArchiveDrive "`n", "Log.txt"
;
;
; This Section compares RGBs vs sharps
;
CountRGB := 0
SRCRGBFILES := CurrentSet PreferredStackDepth "\LrD-" Blur "-" Iter "\RGB+labels\"
Loop Files, SRCRGBFILES "*.tif"
	CountRGB++
TrayTip "Found " CountRGB " stacked Files in " SRCRGBFILES
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found " CountRGB " stacked Files in " SRCRGBFILES  "`n", "Log.txt"
;
result := MsgBox("Count video and stacks?  `n This MsgBox will time out in 5 seconds.  Continue?",, "Y/N T5")
if (result = "Timeout")
	{
	TrayTip "You didn't press YES or NO within the 5-second period."
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
    TrayTip "You Said YES :)"
	}
;
;
; This section compares input and output files types to evaulate if AS3 was successfule before archiving files
;
CountVID := 0
Loop Files, CurrentSet "\" VideoFileType
	CountVID++
TrayTip "Found " CountVID " Video Files in " CurrentSet "\" VideoFileType
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found " CountVID " Video Files in " CurrentSet "\" VideoFileType "`n", "Log.txt"
;
;
; This section actually moves the files
;
if CountRGB = 0
	{
	; MsgBox "Files already moved or stacked incorrectly?" ; confirmed 20241027
	if CountRGB > 0
		{
		;Run "20-AIv1.ahk" " " PATH
		}
	Exit
	}
else if CountOUT >= CountVID
	{
	TrayTip "Found same or more stacked files vs FC Video"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found same or more stacked files vs FC Video`n", "Log.txt"
	;
	;
	; This section opens explerers and moves files via cut paste
	;

	try
		{
		FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting file transfers`n", "Log.txt"
		FileCopy CurrentSet "\" VideoFileType, LocalDST
		FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Completed File Moving Process`n", "Log.txt"
		}
	catch
		{
		ErrorCount += 1
		; Report each problem folder by name.
		MsgBox "Could not move " CurrentSet "\" VideoFileType " into " ExpPath
		FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " FAILED File Moving Process`n", "Log.txt"
		}
	TrayTip "File moves complete and confirmed!`n Script complete!"
	;MsgBox "Check your files" ; successful 20241027
	}
else
	{
	TrayTip "Found discrepancy with AS3 output files, rerun?"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found discrepancy with AS3 output files, rerun?`n", "Log.txt"
	;Run "20-AIv1.ahk" " " PATH
	}

;

CountSHARP := 0
Loop Files, CurrentSet "\" PreferredStackDepth "\"  DeCon "\" ASOutputFileType
	CountSHARP++
TrayTip "Found " CountSHARP " AI sharp files in " CurrentSet PreferredStackDepth DeCon "\" ASOutputFileType
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found " CountSHARP " AI sharp files in " CurrentSet PreferredStackDepth DeCon "\" ASOutputFileType "`n", "Log.txt"
;

; This Section compares outputs vs inputs
;
CountOUT := 0
Loop Files, CurrentSet "\" PreferredStackDepth "\" ASOutputFileType
	CountOUT++
TrayTip "Found " CountOUT " stacked Files in " CurrentSet "\" PreferredStackDepth "\" ASOutputFileType
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found " CountOUT " stacked Files in " CurrentSet "\" PreferredStackDepth "\" ASOutputFileType "`n", "Log.txt"

if CountSHARP >= CountOUT
{
	TrayTip "Found same or more Sharped files vs Stacked files"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found same or more Sharp vs stacked, skipping AI scripts and will jump to RGB.`n", "Log.txt"
	;
	;Via ChatGPT Openai
	;PATH := Chr(34) . PATH . Chr(34)
	Run "30-WSL-RBGv1.ahk" " " PATH
}

else
{
	TrayTip "Found LESS Sharped files vs Stacked files"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found LESS Sharp vs stacked files, rerunning AI scripts.`n", "Log.txt"
	Run "20-AIv1.ahk" " " PATH
}