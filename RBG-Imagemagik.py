#!/usr/bin/python3


import os, shutil, logging, subprocess, time, sys


'''

This script automates RGB combine in GIMP 2.10.
It will ask for where your stacked or sharped source files are,
sort them into RBG sequences, calculate the mid time and make them
into color images.

; 2023114 v2.0
;  Flow is now:
       1) Create subfolders
       2) Extract image dimentions for logo and labeling
       3) Assemble RGB and label / logo at same iter
       4) Label and logo subchannel
       5) Animate RGB
       6) Animate Subchanel
       7) Launch file move AHK
       

; 20230829 v1.7 
;  Change cleanup scripts to launch ahk, to launch separate terminal to run python

'''
STACKROOT='/mnt/d/B-Sorted/Astronomy/20-Stacked/SolarSystem/4-Mars/2020/'
OneDRIVERGB=''
#LOGO='/mnt/c/Users/Mike\ Phillips/OneDrive/D-Permanent/Astronomy/Templates/maptag.png'
LOGO='/mnt/c/maptag.png'
#logo and label delay timers
t=0.1
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
#STACKEDFOLDER = input("Where are you stacked files? ").replace('\\','/')'
print()
print(str(sys.argv[1]))
WINSTACKEDFOLDER = sys.argv[1]
WINSTACKEDFOLDER='\"'+WINSTACKEDFOLDER+'\"'
time.sleep(int(SLEEPT))


#L=os.listdir(os.path.join(STACKROOT,RECENT,AS3,AI))

cmd='wslpath '+WINSTACKEDFOLDER
SP = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
OUT,err=SP.communicate()
RC=SP.wait()

STACKEDFOLDER=OUT.strip()
print()
print("WSL variant of your folder = "+OUT)
print("WSL variant of your folder = "+STACKEDFOLDER)
L=sorted(os.listdir(OUT.strip()))

SUBFolders=['RGB','Anims','RGB+labels', 'RGB+labels-bests']
SUBChannels=['RED','BLUE','GREEN']

for s in SUBChannels:
    try:
        print()
        print('Making folder: '+s)
        os.mkdir(os.path.join(STACKEDFOLDER,s))
    except:
        print()
        print('Folder already created or failed')
        pass

for s in SUBFolders:
    try:
        print()
        print('Making folder: '+s)
        os.mkdir(os.path.join(STACKEDFOLDER,s))
    except:
        print()
        print('Folder already created or failed')
        pass

BLUES=[]
CAPS=[]
for f in L:
    print('Found files: '+f)
    if '-B_' in f:
        BLUES.append(f)
    if '.tif' in f:
        TEST=f
try:
    INFILE=os.path.join(STACKEDFOLDER,TEST)
    print()
    print('Extracting image parameters for logo and labling')
    size=subprocess.check_output(['identify', '-format', '"%w %h"', INFILE]).decode('utf-8').split()
    width=int(size[0].strip("\""))
    Logowidth=str(int(size[0].strip("\""))-500)
    Sigwidth=str(25)
    height=int(size[1].strip("\""))
    Logoheight=str(int(size[1].strip("\""))-100)
    Sigheight=str(int(size[1].strip("\""))-25)
except:
    print()
    print('FAILED to Extract image parameters for logo and labling')

print()
print('Trying to assemble RGB')
for f in L:
    if '.tif' in f:
        try:
            if '-B_' in f:
                print('Found a blue')
                BLUE=f
                MID=f[11:17]
                if '-R_' in L[L.index(f)-1]:
                    print('Found a red')
                    RED = L[L.index(f)-1]
                    RGB=RED[0:11]+MID+'-RGB'+RED[19:]
                else:
                    RED = ''
                if '-G_' in L[L.index(f)+1]:
                    print('Found a green')
                    GREEN = L[L.index(f)+1]
                else:
                    GREEN = ''
                print('\n\nMIDTIME = '+str(MID)+' Processing ('+str(BLUES.index(BLUE)+1)+' of '+str(len(BLUES))+')')
                print('==================')
                print('RED = '+RED)
                print('GREEN = '+GREEN)
                print('BLUE = '+f)
                if not RED=='' and not GREEN=='' and not BLUE=='':
                    print()
                    print('All RGB FOUND!')
                    #
                    #ease of use vars
                    #
                    INFILE=os.path.join(STACKEDFOLDER,'RGB',RGB)
                    OUTFILE=os.path.join(STACKEDFOLDER,'RGB+labels',RGB)
                    OUTFILE2=os.path.join(STACKEDFOLDER,'RGB+labels-bests',RGB)
                    LEVELS=' -level 0%,60% '
                    #LEVELS=' -auto-level '
                    RGBdt=RGB[:17]
                    #
                    #end ease of use vars
                    #
                    CAPS.append(MID)
                    #This command does the RGB composition
                    os.system('convert '+os.path.join(STACKEDFOLDER,RED)+' '+os.path.join(STACKEDFOLDER,GREEN)+' '+os.path.join(STACKEDFOLDER,BLUE)+' -combine -set colorspace sRGB '+os.path.join(STACKEDFOLDER,'RGB',RGB))
                    #time.sleep(2.2)
                    #This command adds labels
                    # Get image's size via - https://stackoverflow.com/questions/4760215/running-shell-command-and-capturing-the-output
                    #
                    try:
                        time.sleep(t)
                        #subprocess.Popen('convert '+INFILE+LEVELS+' -font Times-Bold -pointsize 40 -stroke none -fill white -annotate +5+1275 \'Michael A. Phillips\'  -font Times-Bold -pointsize 20 -stroke none -fill white -annotate +5+25 '+RGBdt+' '+OUTFILE)
                        os.system('convert '+INFILE+LEVELS+' -font Times-Bold -pointsize 40 -stroke none -fill white -annotate +5+'+Sigheight+' \'Michael A. Phillips\'  -font Times-Bold -pointsize 20 -stroke none -fill white -annotate +5+25 '+RGBdt+' '+OUTFILE)
                        os.system('convert '+INFILE+LEVELS+' -font Times-Bold -pointsize 40 -stroke none -fill white -annotate +5+'+Sigheight+' \'Michael A. Phillips\'  -font Times-Bold -pointsize 20 -stroke none -fill white -annotate +5+25 '+RGBdt+' '+OUTFILE2)
                        #This command adds watermark
                        time.sleep(t)
                        #subprocess.Popen('composite -geometry +1255+1190 /mnt/d/D-Permanent/Astronomy/Templates/maptag.png '+OUTFILE+' '+OUTFILE)
                        os.system('composite -geometry +'+Logowidth+'+'+Logoheight+' '+LOGO+' '+OUTFILE+' '+OUTFILE)
                        os.system('composite -geometry +'+Logowidth+'+'+Logoheight+' '+LOGO+' '+OUTFILE2+' '+OUTFILE2)
                        #shutil.copy(os.path.join(STACKEDFOLDER,RGB),os.path.join(STACKEDFOLDER,'RGB'))
                        print('The Labels are applied')
                    except:
                        print()
                        print('Something bad happened wrt labeling the color image')
                else:
                        print()
                        print('Not all RGB found, manually assemble')
                print('')
        except:
            print()
            print('Trying to assemble RGB but something went wrong, exiting!')
        try:
            if '-R_' in f:
                INFILE=os.path.join(STACKEDFOLDER,f)
                OUTFILE=os.path.join(STACKEDFOLDER,'RED',f)
                LEVELS=' -level 0%,60% '
                #LEVELS=' -auto-level '
                RGBdt=f[:17]
                os.system('convert -quiet '+INFILE+LEVELS+' -font Times-Bold -pointsize 40 -stroke none -fill white -annotate +5+'+Sigheight+' \'Michael A. Phillips\'  -font Times-Bold -pointsize 20 -stroke none -fill white -annotate +5+25 '+RGBdt+' '+OUTFILE)
                time.sleep(t)
                os.system('composite -geometry +'+Logowidth+'+'+Logoheight+' '+LOGO+' '+OUTFILE+' '+OUTFILE)
        except:
            print()
            print('Trying to label RED channels but something went wrong, exiting!')
        try:
            if '-G_' in f:
                INFILE=os.path.join(STACKEDFOLDER,f)
                OUTFILE=os.path.join(STACKEDFOLDER,'GREEN',f)
                #LEVELS=' -level 0%,60% '
                LEVELS=' -auto-level '
                RGBdt=f[:17]
                os.system('convert '+INFILE+LEVELS+' -font Times-Bold -pointsize 40 -stroke none -fill white -annotate +5+'+Sigheight+' \'Michael A. Phillips\'  -font Times-Bold -pointsize 20 -stroke none -fill white -annotate +5+25 '+RGBdt+' '+OUTFILE)
                time.sleep(t)
                os.system('composite -geometry +'+Logowidth+'+'+Logoheight+' '+LOGO+' '+OUTFILE+' '+OUTFILE)
        except:
            print()
            print('Trying to label GREEN channels but something went wrong, exiting!')
        try:
            if '-B_' in f:
                INFILE=os.path.join(STACKEDFOLDER,f)
                OUTFILE=os.path.join(STACKEDFOLDER,'BLUE',f)
                #LEVELS=' -level 0%,60% '
                LEVELS=' -auto-level '
                RGBdt=f[:17]
                os.system('convert '+INFILE+LEVELS+' -font Times-Bold -pointsize 40 -stroke none -fill white -annotate +5+'+Sigheight+' \'Michael A. Phillips\'  -font Times-Bold -pointsize 20 -stroke none -fill white -annotate +5+25 '+RGBdt+' '+OUTFILE)
                #time.sleep(t)
                os.system('composite -geometry +'+Logowidth+'+'+Logoheight+' '+LOGO+' '+OUTFILE+' '+OUTFILE)
        except:
            print()
            print('Trying to label BLUE channels but something went wrong, exiting!')

for i in SUBFolders:
    if not 'Anims' in i:
        try:
            print()
            print('Making an animation out of the '+i+' channel.')
            os.system('convert -delay 10 '+os.path.join(STACKEDFOLDER,i)+'/*.tif '+os.path.join(STACKEDFOLDER,'Anims')+'/'+i+'anim.gif')
            #reverses the labeled gif
            time.sleep(t)
            os.system('convert '+os.path.join(STACKEDFOLDER,'Anims')+'/'+i+'anim.gif -coalesce -reverse -quiet -layers OptimizePlus -loop 0 '+os.path.join(STACKEDFOLDER,'Anims')+'/'+i+'fastanimback.gif')
            #This creates a looping/rocking animation
            time.sleep(t)
            os.system('convert '+os.path.join(STACKEDFOLDER,'Anims')+'/'+i+'anim.gif '+os.path.join(STACKEDFOLDER,'Anims')+'/'+i+'fastanimback.gif '+os.path.join(STACKEDFOLDER,'Anims')+'/'+i+'fastanimrock.gif')
            #time.sleep(2.2)
            #shutil.copy(os.path.join(STACKEDFOLDER,RGB),os.path.join(STACKEDFOLDER,'RGB'))
            #shutil.copy(os.path.join(STACKEDFOLDER,RGB),os.path.join(STACKEDFOLDER,'RGB'))
        except:
                pass
for i in SUBChannels:
    try:
        print()
        print('Making an animation out of the '+i+' channel.')
        os.system('convert -delay 10 '+os.path.join(STACKEDFOLDER,i)+'/*.tif '+os.path.join(STACKEDFOLDER,i)+'/'+i+'anim.gif')
        #reverses the labeled gif
        time.sleep(t)
        os.system('convert '+os.path.join(STACKEDFOLDER,i)+'/'+i+'anim.gif -coalesce -reverse -quiet -layers OptimizePlus -loop 0 '+os.path.join(STACKEDFOLDER,i)+'/'+i+'fastanimback.gif')
        #This creates a looping/rocking animation
        time.sleep(t)
        os.system('convert '+os.path.join(STACKEDFOLDER,i)+'/'+i+'anim.gif '+os.path.join(STACKEDFOLDER,i)+'/'+i+'fastanimback.gif '+os.path.join(STACKEDFOLDER,'Anims')+'/'+i+'fastanimrock.gif')
        #time.sleep(2.2)
        #shutil.copy(os.path.join(STACKEDFOLDER,RGB),os.path.join(STACKEDFOLDER,'RGB'))
        #shutil.copy(os.path.join(STACKEDFOLDER,RGB),os.path.join(STACKEDFOLDER,'RGB'))
    except:
            pass



for c in CAPS:
    print()
    print(c)

try:
    print()
    print('Opening final gif')
    os.system('cmd.exe /c \"'+sys.argv[1]+'\\Anims\\RGB+labels-bestsfastanimrock.gif\"')
except:
    print()
    print('bad')


print()
print("\nThis script has completed successfully!\n")

AHK="/mnt/c/Program\\ Files/AutoHotKey/v2/AutoHotkey.exe"
Script=r'"C:\Users\Mike Phillips\OneDrive\D-Permanent\Scripts\Astronomy\AutoHotKey\FullPlanetAutomatedProcessing\90-FCFileMover2.ahk"'

try:
    print()
    print('Running File Compare and move')
    os.system(AHK+" "+Script+" "+sys.argv[1].replace("\\","/"))
except:
    print()
    print('Failed to start next AHK script')

print()
print("CLOSING")
