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
WinWait "ahk_exe WindowsTerminal.exe"
TrayTip "Python RGB Script launched successfully!"
Send "#{Right}"
FileAppend FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " CMD= " WTCLI " " UserPathIn "`n", "Log.txt"
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
Run "explorer " UserPathIn "\Anims\RGB+labels-bestsfastanimrock.gif"
Send "#{Left}"