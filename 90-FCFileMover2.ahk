#Requires AutoHotkey v2.0
;
;This Script will open WSL in Win10 and run various Imagemagik functions
; 20240807 v2 includes MQTT and lots of cleanup
; 20220222 - ver 1.1
; Added Logging and file moves
; 20230831 - ver 1.2
;  changed to native AHK
; FinalStackPath=os.path.join(Dst2,Planet,P[3],P[4],P[5])
; FinalStackPath="\""+FinalStackPath+"\""
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
ASOutputFileType := IniRead("00-setup.ini", "Autostakkert", "ASOutputFileType")
FCRoot := IniRead("00-setup.ini", "Autostakkert", "FCRoot")
PreferredStackDepth := IniRead("00-setup.ini", "Autostakkert", "PreferredStackDepth")
AI := IniRead("00-setup.ini", "Programs", "Autostakkert")
Destination1 := IniRead("00-setup.ini", "ExportFolders", "Destination1")
Destination2 := IniRead("00-setup.ini", "ExportFolders", "Destination2")
Blur := IniRead("00-setup.ini", "AI Settings", "Blur")
Iter := IniRead("00-setup.ini", "AI Settings", "Iter")
Enabled := IniRead("00-setup.ini", "MQTT", "Enabled")
STATUS := IniRead("00-setup.ini", "MQTT", "STATUS")
MQTTERROR := IniRead("00-setup.ini", "MQTT", "MQTTERROR")
FILTER := IniRead("00-setup.ini", "MQTT", "FILTER")
Target := IniRead("00-setup.ini", "MQTT", "Target")
;
;
;
;
; ================================================================================
; Starting Logging
; ================================================================================
;
;
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting FCFileMover.`n", "Log.txt"
;
if Enabled = 1
	{
	Run STATUS '"Starting FCFileMover"'
	}
;
;
;
; ================================================================================
; This secion sets up input video files via prompt or arg passing
; ================================================================================
;
;
;
if A_Args.Length < 1
{
    UserPathIn := InputBox("This script requires at least 1 parameters but it only received " A_Args.Length ".  Please paste the path to your AstraImage SHARPENED images.  (IE PATH...\LrD-X-Y").value
	; neeeded for command prompt pathing when pasted ... 	UserPathIn := StrReplace(UserPathIn, "\", "\\")
	FCInput := StrSplit(UserPathIn,"\")
}
else
{
;UserPathIn := StrReplace(A_Args[1], "\\", "\")
UserPathIn := A_Args[1]
;FCInput := StrSplit(UserPathIn,"//")  ; WORKING - borked 20240819
FCInput := StrSplit(UserPathIn,"\")  ; BROKED RUnning from RGB ; trial 20240819
}
;
;
;
; This section splits input FC captures to obtain planet and current capture date
;
TrayTip UserPathIn
;
FileAppend "`n`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting AI Archive process.`n", "Log.txt"
sFCInput := ""
For Index, Value in FCInput
	sFCInput .= Value . " | "
sFCInput := RTrim(sFCInput, "|") ; removes the last pipe - via https://www.autohotkey.com/boards/viewtopic.php?t=52034
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Input Path is: " UserPathIn ".`n", "Log.txt"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found path extraction as: " sFCInput ".`n", "Log.txt"
TrayTip "the split array is " sFCInput
Planet := FCInput[3]
DateSet := FCInput[4]
ROOT := FCRoot "\" Planet "\" DateSet
CurrentSet := FCRoot "\" Planet "\" DateSet "\" PreferredStackDepth
SharpSet := FCRoot "\" Planet "\" DateSet "\" PreferredStackDepth "\LrD-" Blur "-" Iter 
;
;
;This Section calculates the expiry
;
TimeString := FormatTime(, "yyyyMMdd")
;MsgBox "The current ISO date is " TimeString
Expiration := DateAdd(A_Now, DaysFromNow, "days")
Expiration := FormatTime(Expiration, "yyyyMMdd")
;MsgBox "The expiration ISO date is " Expiration
;
;
; This Section Creates the expiry folder
;
try
{
	ExpPath := ArchiveDrive "\" ArchiveFolder "\" "FC-Expiring--" Expiration "\" Planet "\" DateSet
	Dst1 := Destination1 "\" Planet "\" DateSet
	DirCreate ExpPath
	DirCreate Dst1
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Archived Folder is: " ExpPath " named " ArchiveDriveName "`n", "Log.txt"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Source Folder is: " ROOT "`n", "Log.txt"
}
;
;
; This section compares input and output files types to evaulate if AstraImage was successful before archiving files
;
CountRAW := 0
Loop Files, CurrentSet "\" PreferredStackDepth "\" ASOutputFileType
	CountRAW++
;MsgBox "Found " CountRAW " Raw Files"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found " CountRAW " raw stacked files`n", "Log.txt"
;
;
; This Section compares outputs vs inputs
;
CountSHARP := 0
Loop Files, SharpSet "\" ASOutputFileType
	CountSHARP++
;MsgBox "Found " CountSHARP " SHARPENED Files"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found " CountSHARP " sharpened files`n", "Log.txt"

if CountSHARP >= CountRAW {
	;MsgBox "Found same or more stacked files vs FC Video"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found same or more AstraImage SHARPENED files vs stacked files.`n", "Log.txt"
	;
	;
	; This section opens explerers and moves files via drag drop
	;
	;MsgBox ExpPath
	Run "explorer.exe " ROOT
	sleep 5500
	;Send "^l"
	;sleep 2000
	;Send ROOT
	ControlClick "DirectUIHWND2","ahk_class CabinetWClass" ; Clicks into object view to select all and COPY
	sleep 2000
	;ControlClick "DirectUIHWND2","ahk_class CabinetWClass" ; Clicks into object view to select all and COPY
	;sleep 1000
	Send "^a"
	sleep 1000
	Send "^c"
	sleep 2000
	; Now we close the active window to keep clean
	Send "^w"
	;
	Run "explorer.exe " Dst1
	sleep 5500
	;Send "^l"
	;sleep 2000
	;Send Dst1
	;sleep 500
	Send "^v"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting file copy to " Dst1 "`n", "Log.txt"
	sleep 10000
	WinWait "ahk_class OperationStatusWindow", , 10
	if WinExist("Replace or Skip Files")
		sleep 10000
		;Send "`n"
		TrayTip "Found Replace File ERR"
		sleep 2000
	WinWait "ahk_class OperationStatusWindow", , 10
	WinWaitClose "ahk_class OperationStatusWindow"
	; Now we close the active window to keep clean
	sleep 2000
	Send "^w"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " File transfers Complete`n", "Log.txt"
	TrayTip "File moves complete and confirmed!`n Script complete!"
	; This section closes the logging
	;
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Completed File copy Process`n", "Log.txt"
	;
	;
	;Now we will Archive to archive disc
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting File Moving of sharps to archive.`n", "Log.txt"
	Run "explorer.exe " ROOT
	sleep 5500
	sleep 1000
	Send "^a"
	sleep 1000
	Send "^x"
	sleep 2000
	; Now we close the active window to keep clean
	WinClose DateSet
	;
	;
	Run "explorer.exe " ExpPath
	sleep 5500
	sleep 1000
	Send "^v"
	WinWait "ahk_class OperationStatusWindow", , 10
	WinWaitClose "ahk_class OperationStatusWindow"
	;
	; if src directory empty, prune it if conditions are met
	SrcFileCount := 0
	Loop Files, ROOT
		SrcFileCount++
		if SrcFileCount = 0
			TrayTip "Found 0 Files in " ROOT " will remove empty folder"
			FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Removing empty folder " ROOT ".`n", "Log.txt"
			try
			{
			DirDelete ROOT
			}
	; Now we close the active window to keep clean
	sleep 2000
	Send "^w"
	;
	;
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Completed File Moving of sharps to archive.`n", "Log.txt"
	;
	;
	Run "95-FinalStackPreviews.ahk" " " UserPathIn
}
else {
	MsgBox "Found discrepancy with AstraImage output files, rerun?"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found discrepancy with AstraImage output files, rerun?`n", "Log.txt"

}
;
;
