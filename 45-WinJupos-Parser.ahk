#Requires AutoHotkey v2.0
;
FileAppend "`n`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Logging Planet Ephem`n`n", "WinJupos.txt"
;
;
PLANET := InputBox("Input Planet's position number:`n EG: 5= Jupiter").value

;
;System
;
WinActivate "ahk_class TDialogHauptfenster"
sleep 1000
MouseClick "r",22, 275
sleep 1000
MouseClick ,32, 285
sleep 1000
System := A_Clipboard
DATE := SubStr(System, 1 , 10)
TIME := StrReplace(SubStr(System, 26 , 7), ":", "-")
SYS := SubStr(System, 38 , )
;
;
;Alt
;
sleep 1000
MouseClick ,654, 275 
sleep 1000
MouseClickDrag ,654, 275 ,1031, 317
sleep 1000
Send "^c"
sleep 1000
Alt := A_Clipboard
Loop Parse Alt, "`n", "`r"
{
	if InStr(A_LoopField, "Alt")
		ALT := SubStr(A_LoopField, -3)
		
}
;
;
;rest box
;
sleep 1000
MouseClick "r", 851, 544
sleep 2000
MouseClick "l", 861, 554
sleep 1000
Rest := A_Clipboard
;
A_Clipboard := System Alt Rest
;
;
if (PLANET = "5")
{
	Loop Parse Rest, "`n", "`r"
	{
		if InStr(A_LoopField, "Elongation")
			ELONG := SubStr(A_LoopField, 21, )
		if InStr(A_LoopField, "phase corrected")
			DIA := SubStr(A_LoopField, 22, 5 )
		if InStr(A_LoopField, "magnitude")
			MAG := SubStr(A_LoopField, 22, 4 )
		if InStr(A_LoopField, "Longitude of Sun")
			LS := SubStr(A_LoopField, 22,)
	}
	FileAppend "j" DATE "_" TIME "`n`n", "WinJupos.txt"
	FileAppend DATE " - " TIME "UTC`n`n", "WinJupos.txt"
	FileAppend SYS "`n`n", "WinJupos.txt"
	PlanetStats := "Dia:" DIA ",mag:" MAG "`n" "Alt:" ALT ", Ls:" LS "`nElong:" ELONG "`n`n"
	FileAppend  PlanetStats, "WinJupos.txt"
}
if (PLANET = "2")
{
	Loop Parse Rest, "`n", "`r"
	{
		if InStr(A_LoopField, "Elongation")
			ELONG := SubStr(A_LoopField, 21, )
		if InStr(A_LoopField, "Diameter")
			DIA := SubStr(A_LoopField, 22, 5 )
		if InStr(A_LoopField, "magnitude")
			MAG := SubStr(A_LoopField, 22, 4 )
		if InStr(A_LoopField, "Illumin. fraction")
			PHASE := Round(SubStr(A_LoopField, 23, 5) * 100, 1)
			;PHASE := Round(rPHASE * 100, 1)
	}
	FileAppend "v" DATE "_" TIME "`n`n", "WinJupos.txt"
	FileAppend DATE " - " TIME "UTC`n`n", "WinJupos.txt"
	FileAppend " System I             II (Atm. UV)`n" SYS "`n`n", "WinJupos.txt"
	PlanetStats := "Dia:" DIA ",mag:" MAG "`n" "Alt:" ALT ", Phase:" PHASE "%`nElong:" ELONG "`n`n"
	FileAppend  PlanetStats, "WinJupos.txt"
}
if (PLANET = "6")
{
	Loop Parse Rest, "`n", "`r"
	{
		if InStr(A_LoopField, "Elongation")
			ELONG := SubStr(A_LoopField, 21, )
		if InStr(A_LoopField, "phase corrected")
			DIA := SubStr(A_LoopField, 22, 5 )
		if InStr(A_LoopField, "magnitude")
			MAG := SubStr(A_LoopField, 22, 4 )
		if InStr(A_LoopField, "Earth")
			RINGS := SubStr(A_LoopField, 33, 5)
		if InStr(A_LoopField, "Longitude of Sun")
			LS := SubStr(A_LoopField, 21,)
	}
	FileAppend "s" DATE "_" TIME "`n`n", "WinJupos.txt"
	FileAppend DATE " - " TIME "UTC`n`n", "WinJupos.txt"
	FileAppend SYS "`nLoS=" LS "`n`n", "WinJupos.txt"
	PlanetStats := "Dia:" DIA ",mag:" MAG "`n" "Alt:" ALT ", Rings:" RINGS "`nElong:" ELONG "`n`n"
	FileAppend  PlanetStats, "WinJupos.txt"
}

;
WinActivate "ahk_class Notepad++"
TrayTip "Script is done"