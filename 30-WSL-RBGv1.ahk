#Requires AutoHotkey v2.0
;
;This Script will open WSL in Win10 and run various Imagemagik functions
;20220222 - ver 1.1
; Added Logging and file moves
;
; set variable froma args passed
;

;Variables
q := chr(34) ; https://www.autohotkey.com/board/topic/33688-storing-quotation-marks-in-a-variable/#:~:text=Use%20the%20accent%20symbol%20before%20each%20quote%20mark.,a%20variable%20to%20another%20variable%20and%20need%20quotes.
DaysFromNow := IniRead("00-setup.ini", "Expiration", "DaysFromNow")
MonthsFromNow := IniRead("00-setup.ini", "Expiration", "MonthsFromNow")
ArchiveDrive := IniRead("00-setup.ini", "Expiration", "ArchiveDrive")
ArchiveDriveName := IniRead("00-setup.ini", "Expiration", "ArchiveDriveName")
ArchiveFolder := IniRead("00-setup.ini", "Expiration", "ArchiveFolder")
ExplorerSleep := IniRead("00-setup.ini", "Expiration", "ExplorerSleep")
VideoFileType := IniRead("00-setup.ini", "Autostakkert", "VideoFileType")
ASOutputFileType := IniRead("00-setup.ini", "Autostakkert", "ASOutputFileType")
ExplorerFileField := IniRead("00-setup.ini", "Programs", "ExplorerFileField")
CMD := IniRead("00-setup.ini", "ImageMagick", "CMD")
CMD := Chr(34) . CMD . Chr(34)
PreferredStackDepth := IniRead("00-setup.ini", "Autostakkert", "PreferredStackDepth")
FCRoot := IniRead("00-setup.ini", "Autostakkert", "FCRoot")
WSLuserid := IniRead("00-setup.ini", "ImageMagick", "WSLuserid")
WSLProfile := IniRead("00-setup.ini", "ImageMagick", "WSLProfile")
Enabled := IniRead("00-setup.ini", "MQTT", "Enabled")
STATUS := IniRead("00-setup.ini", "MQTT", "STATUS")
MQTTERROR := IniRead("00-setup.ini", "MQTT", "MQTTERROR")
FILTER := IniRead("00-setup.ini", "MQTT", "FILTER")
Target := IniRead("00-setup.ini", "MQTT", "Target")
LocalDST := IniRead("00-setup.ini", "ExportFolders", "LocalDST")
LocalDST2 := IniRead("00-setup.ini", "ExportFolders", "LocalDST2")
LocalDST3 := IniRead("00-setup.ini", "ExportFolders", "LocalDST3")

;
FileAppend "`n`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting WSL RGB Assembly.`n", "Log.txt"
;
if A_Args.Length < 1
{
    ;UserPathIn := InputBox("This script requires at least 1 parameters but it only received " A_Args.Length ".  Please paste the path to your AS3 stacked images ONLY, stack depth is read from setup file").value
	UserPathIn := InputBox("This script requires at least 1 parameters but it only received " A_Args.Length ".  Please paste the path to your FireCapture RAW Root.").value
	;UserPathIn := StrReplace(UserPathIn, "\", "\\")
}
else
{
	;UserPathIn := StrReplace(A_Args[1], "\", "/") ; working but annoying trying cleanup 20240819
	UserPathIn := A_Args[1] ; trial for trying cleanup 20240819
	;TrayTip UserPathIn
}
FCInput := StrSplit(UserPathIn,"\")
sFCInput := ""
MyPATH := StrReplace(UserPathIn, "\", "\\\\") ; this allows a doublebackslash to be passed to py and back to ahk
;TrayTip MyPATH
For Index, Value in FCInput
	sFCInput .= Value . " | "
sFCInput := RTrim(sFCInput, "|") ; removes the last pipe - via https://www.autohotkey.com/boards/viewtopic.php?t=52034
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Input Path is: " UserPathIn ".`n", "Log.txt"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found path extraction as: " sFCInput ".`n", "Log.txt"
;TrayTip "the split array is " sFCInput
Planet := FCInput[3]
;TrayTip Planet
DateSet := FCInput[4]
CurrentSet := FCRoot "\" Planet "\" DateSet "\"
Expiration := DateAdd(A_Now, DaysFromNow, "days")
Expiration := FormatTime(Expiration, "yyyyMMdd")
;
; This Section Creates the expiry folder
;
ExpPath := ArchiveDrive "\" ArchiveFolder "\" "FC-Expiring--" Expiration "\" Planet "\" DateSet
DirCreate ExpPath
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Archived Folder is: " ExpPath " named " ArchiveDrive "`n", "Log.txt"
;

;
if (Planet = "Mars")
{
	Blur := IniRead("00-setup.ini", "AI Settings", "MarsBlur")
	Iter := IniRead("00-setup.ini", "AI Settings", "MarsIter")
	TrayTip "Planet = " Planet
}
if (Planet = "Jupiter")
{
	Blur := IniRead("00-setup.ini", "AI Settings", "JupiterBlur")
	Iter := IniRead("00-setup.ini", "AI Settings", "JupiterIter")
	TrayTip "Planet = " Planet
}
else if (Planet = "Saturn")
{
	Blur := IniRead("00-setup.ini", "AI Settings", "SaturnBlur")
	Iter := IniRead("00-setup.ini", "AI Settings", "SaturnIter")
	TrayTip "Planet = " Planet
}
else if (Planet = "SaturnHighFrameRate")
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
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " DeCon settings are for " Planet " are: Blur= " Blur " and Iter= " Iter "`n", "Log.txt"

;
; This section fixes a weired path issue I ran into
;
;
if A_Args.Length < 1
{
	WholeCapFolder := UserPathIn
	UserPathIn := UserPathIn "\" PreferredStackDepth "\LrD-" Blur "-" Iter
	
}
else
{
	WholeCapFolder := CurrentSet
	UserPathIn := UserPathIn

}
;
;
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting Imagemagik processing.`n", "Log.txt"
;
; Start WSL Terminal
WTCLI := "wsl -e " CMD 
;TrayTip WTCLI

Run WTCLI " " UserPathIn " \" MyPATH
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " CMD= " WTCLI " " UserPathIn "`n", "Log.txt"
WinWait "ahk_exe WindowsTerminal.exe"
sleep 2000
Send "#{Right}"
sleep 800
Send "Esc"
sleep 800
Send "Esc"
TrayTip "Python RGB Script launched successfully!"
WinWaitClose "ahk_exe WindowsTerminal.exe"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Blind launch of script should be complete.`n", "Log.txt"
;
;
;
; ================================================================================
; This secion sets up progress counting
; ================================================================================
;
;
;
TrayTip "Python RGB Script complete!"
DateSet := LTrim(DateSet, "Mars_")
DateSet := LTrim(DateSet, "Jupiter_")
DateSet := LTrim(DateSet, "Saturn_")
DateSet := StrReplace(DateSet, "_", "-")
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " explorer " UserPathIn "\Anims\" DateSet "-RGB+labels-bestsfastanimrock.gif`n", "Log.txt"
;
; ================================================================================
; This secion copies anims to LocalDST2 and 3
; ================================================================================
;
try
	{
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") "Starting copies to LocalDST2 and LocalDST3`n", "Log.txt"
	OneDrive := LocalDST2  "\" Planet "\" DateSet  "\Anims"
	DirCreate OneDrive
	FileCopy UserPathIn "\Anims\RGB+labels-bestsfastanimrock.gif" , OneDrive "\" DateSet "-RGB+labels-bestsfastanimrock.gif" , 1
	FileCopy UserPathIn "\Anims\RGB+labels-bestsfastanimrock.gif" , LocalDST3 , 1
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") "Completed copies to LocalDST2 and LocalDST3`n", "Log.txt"
	;Run UserPathIn LocalDST3
	;sleep 800
	;Send "#{Right}"
	;sleep 800
	;Send "Esc"
	;sleep 800
	;Send "Esc"
	}
catch as e  ; Handles the first error thrown by the block above.
	{
	;MsgBox "Could not move " UserPathIn "\Anims\RGB+labels-bestsfastanimrock.gif" " into " LocalDST3 " or " LocalDST2 "because: " e.Message
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") "Could not move " UserPathIn "\Anims\RGB+labels-bestsfastanimrock.gif into " OneDrive "because: " e.Message "`n", "Log.txt"

	if Enabled = 1
		{
		Run STATUS '"Final file copy and opening failed"'
		}
	}

;
;
; ================================================================================
; Open file cleanup
; ================================================================================
;
try
	{
	sleep 20000
	WinClose "RGB"
	WinClose "tif"
	}
;
sleep 2000
;
;
; ================================================================================
; This secion archives via copy to LocalDST
; ================================================================================
;
try
	{
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting file copies to LocalDST`n", "Log.txt"
	TrayTip "Starting file copy"
	CURR := LocalDST "\" Planet "\" DateSet
	RunWait Format('{} /c Robocopy {} {} /ETA /MIR', A_ComSpec, CurrentSet, CURR) ; via lots of copilot
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Completed File COPY Process`n", "Log.txt"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Src= " WholeCapFolder "  Dst= " CURR "`n", "Log.txt"
	TrayTip "Completed File COPY Process"
	}
catch as e  ; Handles the first error thrown by the block above.
	{
	;MsgBox "An error was thrown!`nSpecifically: " e.Message
	; Report each problem folder by name.
	MsgBox "Could not copy " WholeCapFolder " into " CURR "because: " e.Message
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " FAILED File COPY Process, because: " e.Message "`n", "Log.txt"
	TrayTip "FAILED File copy Process"
	Exit
	}
;
;
;
;
; ================================================================================
; This secion archives via move to expiry folders
; ================================================================================
;
try
	{
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting file transfers`n", "Log.txt"
	TrayTip "Starting file MOVES"
	CURR := ExpPath
	RunWait Format('{} /c Robocopy {} {} /MOVE /MIR /ETA', A_ComSpec, WholeCapFolder, CURR) ; via lots of copilot
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Completed File Moving Process`n", "Log.txt"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Src= " WholeCapFolder "  Dst= " CURR "`n", "Log.txt"
	TrayTip "Completed File Moving Process"
	}
catch as e  ; Handles the first error thrown by the block above.
	{
	;MsgBox "An error was thrown!`nSpecifically: " e.Message
	; Report each problem folder by name.
	MsgBox "Could not move " WholeCapFolder " into " CURR "because: " e.Message
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " FAILED File Moving Process, because: " e.Message "`n", "Log.txt"
	TrayTip "FAILED File Moving Process"
	Exit
	}
;
;
; ================================================================================
; reopen anim and stills
; ================================================================================
;
try
	{
	CURR := LocalDST "\" Planet "\" DateSet  "\" PreferredStackDepth "\LrD-" Blur "-" Iter
	Run CURR "\Anims\RGB+labels-bestsfastanimrock.gif"
	sleep 1500
	Run CURR "\RGB+labels-bests"
	sleep 1500
	Send "{Right}"
	sleep 1500
	Send "{Left}"
	sleep 1500
	Send "{End}"
	sleep 1500
	Send "{Enter}"
	;
	sleep 1500
	WinActivate "rock"
	sleep 200
	Send "#{Right}"
	sleep 1800
	Send "Esc"
	WinActivate "tif"
	sleep 200
	Send "#{Left}"
	sleep 1800
	Send "Esc"
	FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Launched " CURR "\Anims\RGB+labels-bestsfastanimrock.gif`n", "Log.txt"
	}
