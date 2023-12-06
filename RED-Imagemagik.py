#!/usr/bin/python3


import os, shutil, logging, subprocess, time, sys


'''

This script automates RGB combine in GIMP 2.10.
It will ask for where your stacked or sharped source files are,
sort them into RBG sequences, calculate the mid time and make them
into color images.

; 20230829 v1.7 
;  Change cleanup scripts to launch ahk, to launch separate terminal to run python

'''
STACKROOT='/mnt/d/B-Sorted/Astronomy/20-Stacked/SolarSystem/4-Mars/2020/'
OneDRIVERGB=''

'''

# dicey automatic finding based upon static and rudemntaary root

STACKEDFOLDER = os.listdir(os.path.join(STACKROOT,RECENT))
for F in STACKEDFOLDER:
    if 'AS' in F:
        AS3=F
STACKEDFOLDER = os.path.join(STACKROOT,RECENT,AS3)
AIFiles=os.listdir(os.path.join(STACKROOT,RECENT,AS3))
for F in AIFiles:
    if 'LrD' in F:
        AI=F

STACKEDFOLDER = os.path.join(STACKROOT,RECENT,AS3,AI)
'''
# totally static down to final folder, this is where they are sharped
#SLEEPT = input("How long to wait before starting script? ")
SLEEPT = 0
#STACKEDFOLDER = input("Where are you stacked files? ").replace('\\','/')
print(str(sys.argv[1]))
WINSTACKEDFOLDER = sys.argv[1].replace('\\','/')
STACKEDFOLDER = sys.argv[1].replace('\\','/')
#STACKEDFOLDER='D:\D-Permanent\OneDrive\B-Sorted\Astronomy\\20-Stacked\SolarSystem\\5-Jupiter\\2021\Jupiter_20210618\AS_P50\LrD-1.5-12'
#STACKEDFOLDER=STACKEDFOLDER.replace('\\','/')
time.sleep(int(SLEEPT))


#L=os.listdir(os.path.join(STACKROOT,RECENT,AS3,AI))

cmd='wslpath '+STACKEDFOLDER
SP = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
OUT,err=SP.communicate()
RC=SP.wait()

STACKEDFOLDER=OUT.strip()

print("WSL variant of your folder = "+OUT)
print("WSL variant of your folder = "+STACKEDFOLDER)
L=os.listdir(OUT.strip())

SUBFolders=['RED']

for i in SUBFolders:
    try:
            os.mkdir(os.path.join(STACKEDFOLDER,i))
    except:
            print('Folders already made?')
            pass
for f in L:
    try:
        if '-R_' in L[L.index(f)]:
            RED = L[L.index(f)]
            MID=f[11:17]
            RGB=RED[0:11]+MID+RED[19:]
            #
            #ease of use vars
            #
            INFILE=os.path.join(STACKEDFOLDER,RED)
            OUTFILE=os.path.join(STACKEDFOLDER,'RED',RED)
            #OUTFILE2=os.path.join(STACKEDFOLDER,'RGB+labels-bests',RED)
            #LEVELS=' -level 0%,60% '
            LEVELS=' -auto-level '
            RGBdt=RGB[:17]
            #
            #end ease of use vars
            #
            #This command does the RGB composition
            #os.popen('convert '+os.path.join(STACKEDFOLDER,RED)+' '+os.path.join(STACKEDFOLDER,GREEN)+' '+os.path.join(STACKEDFOLDER,BLUE)+' -combine -set colorspace sRGB '+os.path.join(STACKEDFOLDER,'RGB',RGB))
            time.sleep(2.2)
            #This command adds labels
            # Get image's size via - https://stackoverflow.com/questions/4760215/running-shell-command-and-capturing-the-output
            #
            size=subprocess.check_output(['identify', '-format', '"%w %h"', INFILE]).decode('utf-8').split()
            width=int(size[0].strip("\""))
            Logowidth=str(int(size[0].strip("\""))-500)
            Sigwidth=str(25)
            height=int(size[1].strip("\""))
            Logoheight=str(int(size[1].strip("\""))-100)
            Sigheight=str(int(size[1].strip("\""))-25)
            #os.popen('convert '+INFILE+LEVELS+' -font Times-Bold -pointsize 40 -stroke none -fill white -annotate +5+1275 \'Michael A. Phillips\'  -font Times-Bold -pointsize 20 -stroke none -fill white -annotate +5+25 '+RGBdt+' '+OUTFILE)
            os.popen('convert '+INFILE+LEVELS+' -font Times-Bold -pointsize 40 -stroke none -fill white -annotate +5+'+Sigheight+' \'Michael A. Phillips\'  -font Times-Bold -pointsize 20 -stroke none -fill white -annotate +5+25 '+RGBdt+' '+OUTFILE)
            #os.popen('convert '+INFILE+LEVELS+' -font Times-Bold -pointsize 40 -stroke none -fill white -annotate +5+'+Sigheight+' \'Michael A. Phillips\'  -font Times-Bold -pointsize 20 -stroke none -fill white -annotate +5+25 '+RGBdt+' '+OUTFILE2)
            #This command adds watermark
            time.sleep(2.2)
            #os.popen('composite -geometry +1255+1190 /mnt/d/D-Permanent/Astronomy/Templates/maptag.png '+OUTFILE+' '+OUTFILE)
            os.popen('composite -geometry +'+Logowidth+'+'+Logoheight+' /mnt/c/Users/Mike/OneDrive/D-Permanent/Astronomy/Templates/maptag.png '+OUTFILE+' '+OUTFILE)
            #os.popen('composite -geometry +'+Logowidth+'+'+Logoheight+' /mnt/c/Users/Mike/OneDrive/D-Permanent/Astronomy/Templates/maptag.png '+OUTFILE2+' '+OUTFILE2)
            #shutil.copy(os.path.join(STACKEDFOLDER,RGB),os.path.join(STACKEDFOLDER,'RGB'))
            print("Finished "+INFILE)
    except:
        print("Nothing done to RED File: "+INFILE)
        pass

for i in SUBFolders:
    try:
        print('Making an animation out of the '+i+' channel.')
        os.system('convert -delay 20 '+os.path.join(STACKEDFOLDER,i)+'/*.tif '+os.path.join(STACKEDFOLDER,'Anims')+'/'+i+'anim.gif')
        #reverses the labeled gif
        #time.sleep(2.2)
        #os.popen('convert RGB+labelsanim.gif -coalesce -reverse -quiet -layers OptimizePlus -loop 0 RGB+labelsanimback.gif')
        #shutil.copy(os.path.join(STACKEDFOLDER,RGB),os.path.join(STACKEDFOLDER,'RGB'))
        #
        #This creates a looping/rocking animation
        time.sleep(2.2)
        #os.popen('convert RGB+labelsanim.gif RGB+labelsanimback.gif RGB+labelsanimRock.gif')
        #shutil.copy(os.path.join(STACKEDFOLDER,RGB),os.path.join(STACKEDFOLDER,'RGB'))
        #
        #reverses the labeled gif
        #time.sleep(2.2)
        #os.popen('convert RGB+labelsanim.gif -coalesce -reverse -quiet -layers OptimizePlus -loop 0 RGB+labelsanimback.gif')
        #shutil.copy(os.path.join(STACKEDFOLDER,RGB),os.path.join(STACKEDFOLDER,'RGB'))
        #
        #This creates a looping/rocking animation
        #time.sleep(2.2)
        #os.popen('convert RGB+labelsanim.gif RGB+labelsanimback.gif RGB+labelsanimRock.gif')
        #shutil.copy(os.path.join(STACKEDFOLDER,RGB),os.path.join(STACKEDFOLDER,'RGB'))
    except:
            pass



print("\nThis script has completed successfully!\n")

AHK="/mnt/c/Program\\ Files/AutoHotKey/v2/AutoHotkey.exe"
Script=r'"C:\Users\Mike\OneDrive\D-Permanent\Scripts\Astronomy\AutoHotKey\FullPlanetAutomatedProcessing-maphilli14-work2\90-FCFileMover2.ahk"'
'''
try:
    print('Running File Compare and move')
    os.system(AHK+" "+Script+" "+sys.argv[1].replace("\\","/"))
except:
    print('Failed to start next AHK script')
'''


'''
this is what I want to happen but it is not consistent
os.popen('/mnt/c/Users/Mike\ Phillips/AppData/Local/Programs/Python/Python311/python.exe \"C:\\Users\Mike Phillips\OneDrive\D-Permanent\Scripts\Astronomy\AutoHotKey\FullPlanetAutomatedProcessing\\90-FCFileMover2.py\" '+WINSTACKEDFOLDER)
'''
print("CLOSING")
