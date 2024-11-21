#Requires AutoHotkey v2.0
;
;
Logging := 1
;
; Variables
;
FCRoot := IniRead("00-setup.ini", "Autostakkert", "FCRoot")
VideoFileType := IniRead("00-setup.ini", "Autostakkert", "VideoFileType")
ASOutputFileType := IniRead("00-setup.ini", "Autostakkert", "ASOutputFileType")
PreferredStackDepth := IniRead("00-setup.ini", "Autostakkert", "PreferredStackDepth")
AI := IniRead("00-setup.ini", "Programs", "Autostakkert")
VideoFileType := IniRead("00-setup.ini", "Autostakkert", "VideoFileType")
;
;
;
if A_Args.Length < 1
{
    PATH := InputBox("This script requires at least 1 parameters but it only received " A_Args.Length ".  Please paste the path to your FireCaputre raw AVIs.").value
}
else
{
PATH := A_Args[1]
}
;
Loop Files, PATH "\*R.txt"
{
	RedFile := A_LoopFilePath
}
Loop Files, PATH "\*G.txt"
{
	GreenFile := A_LoopFilePath
}
Loop Files, PATH "\*B.txt"
{
	BlueFile := A_LoopFilePath
}



;Loop read,  "C:\Personal\B-Sorted\Astronomy\20-Stacked\SolarSystem\Jupiter\Jupiter_2023_09_04\2023-09-04-0818_1-R.txt"
;Loop read, "P:\Personal\E-Delete\FC-Expiring--20240309\Saturn\Saturn_2023_09_01\2023-09-01-0338_8-R.txt"
Loop read, RedFile
{
	if InStr(A_LoopReadLine, "Shutter")
		RedShutter := A_LoopReadLine	
	if InStr(A_LoopReadLine, "Gain")
		RedGain := A_LoopReadLine	
}
RedShutter := SubStr(RedShutter, 9 , 4)
RedShutter := Round(RedShutter,0)
RedGain := SubStr(RedGain, 6 , 4)
RedGain := RedGain
;
;Loop read,  "C:\Personal\B-Sorted\Astronomy\20-Stacked\SolarSystem\Jupiter\Jupiter_2023_09_04\2023-09-04-0819_1-G.txt"
;Loop read, "P:\Personal\E-Delete\FC-Expiring--20240309\Saturn\Saturn_2023_09_01\2023-09-01-0342_9-G.txt"
;
Loop read, GreenFile
{
	if InStr(A_LoopReadLine, "Shutter")
		GreenShutter := A_LoopReadLine	
	if InStr(A_LoopReadLine, "Gain")
		GreenGain := A_LoopReadLine	
}
GreenShutter := SubStr(GreenShutter, 9 , 4)
GreenShutter := Round(GreenShutter,0)
GreenGain := SubStr(GreenGain, 6 , 4)
GreenGain := GreenGain
;
;Loop read,  "C:\Personal\B-Sorted\Astronomy\20-Stacked\SolarSystem\Jupiter\Jupiter_2023_09_04\2023-09-04-0818_6-B.txt"
;Loop read, "P:\Personal\E-Delete\FC-Expiring--20240309\Saturn\Saturn_2023_09_01\2023-09-01-0340_9-B.txt"
Loop read, BlueFile
{
	if InStr(A_LoopReadLine, "Shutter")
		BlueShutter := A_LoopReadLine	
	if InStr(A_LoopReadLine, "Gain")
		BlueGain := A_LoopReadLine	
}
BlueShutter := SubStr(BlueShutter, 9 , 4)
BlueShutter := Round(BlueShutter,0)
BlueGain := SubStr(BlueGain, 6 , 4)
BlueGain := BlueGain


;
;
TrayTip "RBG: " RedShutter  ", " BlueShutter  ", " GreenShutter  " ms`nGain: " RedGain  ", " BlueGain  ", " GreenGain
A_Clipboard := "RBG: " RedShutter  ", " BlueShutter  ", " GreenShutter  " ms`nGain: " RedGain  ", " BlueGain  ", " GreenGain
;
FileAppend "`n`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") "`nRedFile= " RedFile "`nBlueFile= " BlueFile "`nGreenFile= " GreenFile, "FCSettings.txt"
FileAppend "`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Logging Firecapture Exposure Settings`n`n" A_Clipboard, "FCSettings.txt"
;
TrayTip "Script is done"