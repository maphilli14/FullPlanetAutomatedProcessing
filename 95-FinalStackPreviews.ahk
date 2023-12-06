#Requires AutoHotkey v2.0
;
Logging := 1
;
; Variables
;
Destination1 := IniRead("00-setup.ini", "ExportFolders", "Destination1")
Destination2 := IniRead("00-setup.ini", "ExportFolders", "Destination2")
PreferredStackDepth := IniRead("00-setup.ini", "Autostakkert", "PreferredStackDepth")
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
FCInput := StrSplit(UserPathIn,"//")
}
;
; Logging
FileAppend "`n`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting Final Image loading`n", "Log.txt"

; Setup Archive Folders to open files from:
sFCInput := ""
For Index, Value in FCInput
	sFCInput .= Value . "|"
sFCInput := RTrim(sFCInput, " | ") ; removes the last pipe - via https://www.autohotkey.com/boards/viewtopic.php?t=52034
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " the split array is " sFCInput, "Log.txt"
TrayTip "the split array is " sFCInput
Planet := FCInput[3]
DateSet := FCInput[4]
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
ROOT := Destination1 "\" Planet "\" DateSet
CurrentSet := Destination1 "\" Planet "\" DateSet "\" PreferredStackDepth
SharpSet := Destination1 "\" Planet "\" DateSet "\" PreferredStackDepth "\LrD-" Blur "-" Iter 
Dst1 := Destination1 "\" Planet "\" DateSet
;
;
sleep 5500
;
try
	{
	Run SharpSet "\RGB+labels-bests\"
	}
sleep 5500
Send "{Right}"
sleep 500
Send "{Left}"
sleep 500
Send "{End}"
sleep 500
Send "{Enter}"
sleep 5500
Send "#{Left}"
sleep 500
;Send "{Esc}"
try
	{
	Run SharpSet "\Anims\"
	}
sleep 500
Send "{Right}"
sleep 500
Send "{Left}"
sleep 500
Send "{End}"
sleep 500
Send "{Enter}"
sleep 5500
Send "#{Right}"
sleep 500
;Send "{Esc}"
;
; Copy to file server for display on homeassistant or published locations on Internet etc...
try
	{
	FileCopy SharpSet "\Anims\RGB+labels-bestsfastanimrock.gif", Destination2 "\latest.gif", 1
	FileAppend FormatTime("`n`n" A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting Final Image copy to " Destination2 "\latest.gif`n", "Log.txt"
	sleep 2000
	FileCopy SharpSet "\Anims\RGB+labels-bestsfastanimrock.gif", Destination2 "\latest.gif", 1
	FileAppend FormatTime("`n`n" A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting Final Image copy to " Destination2 "\latest.gif`n", "Log.txt"
	}
catch as e  ; Handles the first error thrown by the block above.
{
	FileAppend FormatTime("`n`n" A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Failed to copy to " Destination2 "\latest.gif`n" " An error was thrown!`nSpecifically: " e.Message, "Log.txt"
	
}
MsgBox "Your files are ready", "Script Complete"