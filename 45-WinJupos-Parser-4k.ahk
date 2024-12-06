 #Requires AutoHotkey v2.0
;
FileAppend "`n`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Logging Planet Ephem`n`n", "WinJupos.txt"
;
; updated to put comments on how to find the right boxes when working at 1080p / HD res with included wjs font and color scheme
; use spy to update all 'the following' comments
;
PLANET := InputBox("Input Planet's position number:`n EG: 5= Jupiter").value

;
;System right click and copy; you'll need an offset to select menu +10-20 , +10-20
;
WinActivate "ahk_class TDialogHauptfenster"
sleep 100
; the following line is the System box, top left under ephem tab
MouseClick "r",48, 484
sleep 100
MouseClick ,68, 500
sleep 100
System := A_Clipboard
DATE := SubStr(System, 1 , 10)
TIME := StrReplace(SubStr(System, 26 , 7), ":", "-")
SYS := SubStr(System, 38 , )
;
;
;Alt is a drag drop within the alt/az field, Top right x/y and bottom left x/y
; USE CLIENT value in spy
;
sleep 100
MouseClick ,1000, 430
sleep 100
MouseClickDrag ,1000, 430 ,1645, 600
sleep 100
Send "^c"
sleep 100
Alt := A_Clipboard
Loop Parse Alt, "`n", "`r"
{
	if InStr(A_LoopField, "Alt")
		ALT := SubStr(A_LoopField, -3)
		
}
;
;
;rest of vars are-- right click and copy; you'll need an offset to select menu +10-20 , +10-20
;
sleep 100
MouseClick "r", 1400, 800
sleep 200
MouseClick "l", 1421, 820
sleep 100
Rest := A_Clipboard
;
A_Clipboard := System Alt Rest
;
;
if (PLANET = "4")
{
	Loop Parse Rest, "`n", "`r"
	{
		if InStr(A_LoopField, "Elongation")
			ELONG := SubStr(A_LoopField, 21, )
		if InStr(A_LoopField, "Diameter")
			DIA := SubStr(A_LoopField, 22, 5 )
		if InStr(A_LoopField, "magnitude")
			MAG := SubStr(A_LoopField, 22, 4 )
		if InStr(A_LoopField, "Longitude of Sun")
			LS := SubStr(A_LoopField, 22,)
	}
	FileAppend Rest "`n", "WinJupos.txt"
	FileAppend "=============================`n", "WinJupos.txt"
	FileAppend "Mars`n", "WinJupos.txt"
	FileAppend "m" DATE "_" TIME "`n`n", "WinJupos.txt"
	FileAppend DATE " - " TIME "UTC`n`n", "WinJupos.txt"
	FileAppend SYS "`n`n", "WinJupos.txt"
	PlanetStats := "Dia:" DIA ", mag:" MAG "`n" "Alt:" ALT ", Ls:" LS "`nElong:" ELONG "`n`n"
	FileAppend  PlanetStats, "WinJupos.txt"
}
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