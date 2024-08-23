#Requires AutoHotkey v2.0
;
;This Script will open onpen an image and align to snap
;20240819 - ver 1.0
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




MyPATH := A_Args[1]
TrayTip MyPATH
MyFILE := A_Args[2]
TrayTip MyFILE
DIRECTION := A_Args[3]
MyFILE := MyPATH "\\" MyFILE

;FileAppend "`n`n" FormatTime(A_Now, "dddd MMMM d, yyyy hh:mm:ss tt") " Opening image: " MyFILE "`n", "Log.txt"


Run "explorer " MyFILE
sleep 1500
Send "{Enter}"
sleep 1500
Send "#Right"
sleep 1500
Send "{Esc}"