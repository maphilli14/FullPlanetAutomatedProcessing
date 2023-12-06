#Requires AutoHotkey v2.0
;
;This Script will open WSL in Win10 and run various Imagemagik functions
;20220222 - ver 1.1
; Added Logging and file moves
;
; set variable froma args passed
;

;Variables
CMD := IniRead("00-setup.ini", "ImageMagick", "CMD")
CMD := Chr(34) . CMD . Chr(34)
PreferredStackDepth := IniRead("00-setup.ini", "Autostakkert", "PreferredStackDepth")
FCRoot := IniRead("00-setup.ini", "Autostakkert", "FCRoot")
WSLuserid := IniRead("00-setup.ini", "ImageMagick", "WSLuserid")
WSLProfile := IniRead("00-setup.ini", "ImageMagick", "WSLProfile")
;
FileAppend "`n`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting WSL RGB Assembly.`n", "Log.txt"
;
if A_Args.Length < 1
{
    UserPathIn := InputBox("This script requires at least 1 parameters but it only received " A_Args.Length ".  Please paste the path to your AS3 stacked images ONLY, stack depth is read from setup file").value
	;UserPathIn := StrReplace(UserPathIn, "\", "\\")
}
else
{
	UserPathIn := StrReplace(A_Args[1], "\", "\\")
	;UserPathIn := A_Args[1]
	TrayTip UserPathIn
}
FCInput := StrSplit(UserPathIn,"\\")
sFCInput := ""
For Index, Value in FCInput
	sFCInput .= Value . " | "
sFCInput := RTrim(sFCInput, "|") ; removes the last pipe - via https://www.autohotkey.com/boards/viewtopic.php?t=52034
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Input Path is: " UserPathIn ".`n", "Log.txt"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Found path extraction as: " sFCInput ".`n", "Log.txt"
TrayTip "the split array is " sFCInput
Planet := FCInput[3]
TrayTip Planet
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
; This section fixes a weired path issue I ran into
;
;
if A_Args.Length < 1
{
	UserPathIn := UserPathIn "\" PreferredStackDepth "\LrD-" Blur "-" Iter 
}
else
{
	UserPathIn := UserPathIn "\LrD-" Blur "-" Iter 

}
;
;
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Starting Imagemagik processing.`n", "Log.txt"
;
; Start WSL Terminal
WTCLI := "wsl -e " CMD 
TrayTip WTCLI
Run WTCLI " " UserPathIn
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " CMD= " WTCLI " " UserPathIn "`n", "Log.txt"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Blind launch of script should be complete.`n", "Log.txt"
