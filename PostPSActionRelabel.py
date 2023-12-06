#!/usr/bin/python3


import os, shutil, logging, subprocess, time, sys, traceback


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
#RECENT=os.listdir('/mnt/d/B-Sorted/Astronomy/20-Stacked/SolarSystem/4-Mars/2020/')[-1]

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
ESCPath=sys.argv[1]
WINSTACKEDFOLDER = ESCPath.replace('\\','/')
STACKEDFOLDER = ESCPath.replace('\\','/')
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

try:
        os.mkdir(os.path.join(STACKEDFOLDER,'new'))
except Exception:
        traceback.print_exc()
        print('Could not create new outdir')
        pass

for RGB in L:
    if '.tif' in RGB:
        INFILE=os.path.join(STACKEDFOLDER,RGB)
        OUTFILE=os.path.join(STACKEDFOLDER,'new',RGB)
        #LEVELS=' -level 0%,60% '
        #LEVELS=' -auto-level '
        RGBdt=RGB[:17]
        #This command adds labels
        # Get image's size via - https://stackoverflow.com/questions/4760215/running-shell-command-and-capturing-the-output
        #
        try:
            size=subprocess.check_output(['identify', '-format', '"%w %h"', INFILE]).decode('utf-8').split()
            #size=['1196' , '1024']
            width=int(size[0].strip("\""))
            Logowidth=str(int(size[0].strip("\""))-400)
            Sigwidth=str(25)
            height=int(size[1].strip("\""))
            Logoheight=str(int(size[1].strip("\""))-100)
            Sigheight=str(int(size[1].strip("\""))-25)
            #os.popen('convert '+INFILE+LEVELS+' -font Times-Bold -pointsize 40 -stroke none -fill white -annotate +5+1275 \'Michael A. Phillips\'  -font Times-Bold -pointsize 20 -stroke none -fill white -annotate +5+25 '+RGBdt+' '+OUTFILE)
            os.popen('convert '+INFILE+' -font Times-Bold -pointsize 40 -stroke none -fill white -annotate +5+'+Sigheight+' \'Michael A. Phillips\'  -font Times-Bold -pointsize 20 -stroke none -fill white -annotate +5+25 '+RGBdt+' '+OUTFILE)
            #This command adds watermark
            time.sleep(2.2)
            #os.popen('composite -geometry +1255+1190 /mnt/d/D-Permanent/Astronomy/Templates/maptag.png '+OUTFILE+' '+OUTFILE)
            os.popen('composite -geometry +'+Logowidth+'+'+Logoheight+' /mnt/c/Users/Mike\ Phillips/OneDrive/D-Permanent/Astronomy/Templates/maptag.png '+OUTFILE+' '+OUTFILE)
            #shutil.copy(os.path.join(STACKEDFOLDER,RGB),os.path.join(STACKEDFOLDER,'RGB'))
            print('The Labels are applied')
        except:
            print('Something bad happened wrt labeling the color image')

try:
    print('Making an animation with rock!')
    os.system('convert -delay 25 '+os.path.join(STACKEDFOLDER,'new')+'/*.tif '+os.path.join(STACKEDFOLDER,'new')+'/anim.gif')
    os.system('convert '+os.path.join(STACKEDFOLDER,'new')+'/anim.gif -coalesce -reverse -quiet -layers OptimizePlus -loop 0 '+os.path.join(STACKEDFOLDER,'new')+'/fastanimback.gif')
    os.system('convert '+os.path.join(STACKEDFOLDER,'new')+'/anim.gif '+os.path.join(STACKEDFOLDER,'new')+'/fastanimback.gif '+os.path.join(STACKEDFOLDER,'new')+'/fastanimrock.gif')
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

try:
    print('Opening final gif')
    os.popen('cmd.exe /c \"'+ESCPath+'\\new\\fastanimrock.gif\"')
except:
    print('bad')

print("CLOSING")
