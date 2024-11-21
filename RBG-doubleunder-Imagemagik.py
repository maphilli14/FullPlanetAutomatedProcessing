#!/usr/bin/python3


import os, shutil, logging, subprocess, time, sys, datetime
import paho.mqtt.client as mqtt

'''

This script automates RGB combine in GIMP 2.10.
It will ask for where your stacked or sharped source files are,
sort them into RBG sequences, calculate the mid time and make them
into color images.

; 20240819 v3.0
; Added MQTT

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
# Logging Section
NOW = datetime.datetime.now().strftime("%A %B %d, %Y %I:%M:%S %p")
logger = logging.getLogger(__name__)
logging.basicConfig(filename='/mnt/c/Users/maphilli14-work2/Documents/GitHub/FullPlanetAutomatedProcessing/Log.txt', encoding='utf-8', level=logging.DEBUG)

NOW = datetime.datetime.now().strftime("%A %B %d, %Y %I:%M:%S %p")
message = "Starting RGB Assembly"
logger.error(" " + NOW + " " + message)

#Path Vars
MyFILE = sys.argv[1]
NOW = datetime.datetime.now().strftime("%A %B %d, %Y %I:%M:%S %p")
logger.info(" " + NOW + " " + MyFILE)

# Mike's Astro vars
STACKROOT='/mnt/d/B-Sorted/Astronomy/20-Stacked/SolarSystem/4-Mars/2020/'
OneDRIVERGB=''
#LOGO='/mnt/c/Users/Mike\ Phillips/OneDrive/D-Permanent/Astronomy/Templates/maptag.png'
LOGO='/mnt/c/maptag.png'
#logo and label delay timers
t=0.1
LEVELS=' -level 1%,50% '
#RECENT=os.listdir('/mnt/d/B-Sorted/Astronomy/20-Stacked/SolarSystem/4-Mars/2020/')[-1]
AHK="/mnt/c/Program\\ Files/AutoHotKey/v2/AutoHotkey.exe"
PreviewScript=r'"C:\Users\maphilli14-work2\Documents\GitHub\FullPlanetAutomatedProcessing\31-animopen.ahk"'

# Define the MQTT broker details
broker = "192.168.45.249"
port = 1883
Target = "homeassistant/sensor/NINA-ACPlus/NINAStatus/Target/"
STATUS = "homeassistant/sensor/NINA-ACPlus/NINAStatus/Status/"
FILTER = "homeassistant/sensor/NINA-ACPlus/NINAStatus/Filter/"
MQTTERROR = "homeassistant/sensor/NINA-ACPlus/NINAStatus/AkuleError/"

username = "maphilli14"
password = "F6aX8TxvAQup"
#
# Callback function when the client receives a CONNACK response from the server
# and additional defs
#
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected successfully")
        client.subscribe(STATUS)
    else:
        print(f"Connect failed with code {rc}")
# Function to start a process and leave it open
def start_process(command):
    # Start the process
    process = subprocess.Popen(command, shell=True)
    # Return the process if needed
    return process


# Callback function when a PUBLISH message is received from the server
def on_message(client, userdata, msg):
    print(f"Received message: {msg.payload.decode()} on STATUS {msg.STATUS}")

# Create an MQTT client instance
client = mqtt.Client()

# Set username and password
client.username_pw_set(username, password)

# Assign the callback functions
client.on_connect = on_connect
client.on_message = on_message

# Connect to the broker
client.connect(broker, port, 6)

message = "RGB Assembly in Imagemagik"
print(message)
client.publish(Target, message)
message = "Error free"
client.publish(MQTTERROR, message)

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
NewSTACKEDFOLDER='\"'+WINSTACKEDFOLDER+'\"'
time.sleep(int(SLEEPT))


#L=os.listdir(os.path.join(STACKROOT,RECENT,AS3,AI))

cmd='wslpath '+NewSTACKEDFOLDER
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

#
# Creates folders
#

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


#
# Extracts image dimensions 
#
BLUES=[]
CAPS=[]
for f in L:
    print('Found files: '+f)
    if '_B_' in f:
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

#
# RGB assembly
#
print()
message = "Trying to assemble RGB"
print(message)
client.publish(STATUS, message)

for f in L:
    if '.tif' in f:
        try:
            if '_B_' in f:
                print('Found a blue')
                BLUE=f
                MID=f[11:17]
                if '_R_' in L[L.index(f)-1]:
                    print('Found a red')
                    RED = L[L.index(f)-1]
                    RGB=RED[0:11]+MID+'-RGB'+RED[19:]
                else:
                    RED = ''
                if '_G_' in L[L.index(f)+1]:
                    print('Found a green')
                    GREEN = L[L.index(f)+1]
                else:
                    GREEN = ''
                print('\n\nMIDTIME = '+str(MID)+' Processing ('+str(BLUES.index(BLUE)+1)+' of '+str(len(BLUES))+')')
                print('==================')
                print('RED = '+RED)
                print('GREEN = '+GREEN)
                print('BLUE = '+f)
                message = 'RBG counter= '+str(BLUES.index(BLUE)+1)+' of '+str(len(BLUES))
                logger.info(NOW + " " + message)
                client.publish(STATUS, message)
                COUNT = str(int(((BLUES.index(BLUE)+1)/(len(BLUES)))*100))+'%'
                client.publish(FILTER, COUNT)
                #
                # Checks for non-blank RGB files, if all are found, assemble into color and open 1st file for preview.
                #
                if not RED=='' and not GREEN=='' and not BLUE=='':
                    print()
                    print('All RGB FOUND!')
                    #
                    #ease of use vars
                    #
                    INFILE=os.path.join(STACKEDFOLDER,'RGB',RGB)
                    OUTFILE=os.path.join(STACKEDFOLDER,'RGB+labels',RGB)
                    OUTFILE2=os.path.join(STACKEDFOLDER,'RGB+labels-bests',RGB)
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
                    #
                    # only open 1st RGB for preview
                    # REF: https://learn.microsoft.com/en-us/windows/wsl/filesystems
                    #
                    if BLUES.index(BLUE)+1 == 1:
                        print('1st RGB found for opening!')
                        #opens file directly
                        command = 'explorer.exe \"'+ WINSTACKEDFOLDER + "\\RGB+labels-bests\\" + RGB  +'\"'
                        process = start_process(command)
                        command = 'explorer.exe \"'+ WINSTACKEDFOLDER + "\\RGB+labels-bests"'\"'
                        process = start_process(command)
                        #opens AHK for cleaner previews
                        #REF os.system(AHK+" "+Script+" "+sys.argv[1].replace("\\","/"))
                        #command = 'cmd.exe /c \"'+ AHK + " " + NewSTACKEDFOLDER + "\\RGB+labels-bests\\" + RGB + '\" /s'
                        #process = start_process(command)                        
                    else:
                        #print('1st RGB missed')
                        pass
                else:
                        print()
                        print('Not all RGB found, manually assemble')
                print('')
        except:
            print()
            print('Trying to assemble RGB but something went wrong, exiting!')
        try:
            if '_R_' in f:
                INFILE=os.path.join(STACKEDFOLDER,f)
                OUTFILE=os.path.join(STACKEDFOLDER,'RED',f)
                RGBdt=f[:17]
                os.system('convert -quiet '+INFILE+LEVELS+' -font Times-Bold -pointsize 40 -stroke none -fill white -annotate +5+'+Sigheight+' \'Michael A. Phillips\'  -font Times-Bold -pointsize 20 -stroke none -fill white -annotate +5+25 '+RGBdt+' '+OUTFILE)
                time.sleep(t)
                os.system('composite -geometry +'+Logowidth+'+'+Logoheight+' '+LOGO+' '+OUTFILE+' '+OUTFILE)
        except:
            print()
            print('Trying to label RED channels but something went wrong, exiting!')
        try:
            if '_G_' in f:
                INFILE=os.path.join(STACKEDFOLDER,f)
                OUTFILE=os.path.join(STACKEDFOLDER,'GREEN',f)
                RGBdt=f[:17]
                os.system('convert '+INFILE+LEVELS+' -font Times-Bold -pointsize 40 -stroke none -fill white -annotate +5+'+Sigheight+' \'Michael A. Phillips\'  -font Times-Bold -pointsize 20 -stroke none -fill white -annotate +5+25 '+RGBdt+' '+OUTFILE)
                time.sleep(t)
                os.system('composite -geometry +'+Logowidth+'+'+Logoheight+' '+LOGO+' '+OUTFILE+' '+OUTFILE)
        except:
            print()
            print('Trying to label GREEN channels but something went wrong, exiting!')
        try:
            if '_B_' in f:
                INFILE=os.path.join(STACKEDFOLDER,f)
                OUTFILE=os.path.join(STACKEDFOLDER,'BLUE',f)
                RGBdt=f[:17]
                os.system('convert '+INFILE+LEVELS+' -font Times-Bold -pointsize 40 -stroke none -fill white -annotate +5+'+Sigheight+' \'Michael A. Phillips\'  -font Times-Bold -pointsize 20 -stroke none -fill white -annotate +5+25 '+RGBdt+' '+OUTFILE)
                #time.sleep(t)
                os.system('composite -geometry +'+Logowidth+'+'+Logoheight+' '+LOGO+' '+OUTFILE+' '+OUTFILE)
        except:
            print()
            print('Trying to label BLUE channels but something went wrong, exiting!')
#
# Make anims
#
print("Sleeping to clean up bests for 2min...")
#time.sleep(120)
print("Ready to resume!")
time.sleep(2)
#
for i in SUBFolders:
    if not 'Anims' in i:
        try:
            print()
            message = "Making an animation out of the " + i + " channel."
            print(message)
            client.publish(STATUS, message)
            logger.info("\n\n" + NOW + " " + message)
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
            message = "SUBFolder Errors"
            client.publish(MQTTERROR, message)
            logger.error("\n\n" + NOW + " " + message)
            
for i in SUBChannels:
    try:
        print()
        message = "Making an animation out of the " + i + " channel."
        print(message)
        client.publish(STATUS, message)
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
        message = "SUBChannels Errors"
        client.publish(MQTTERROR, message)
        logger.error("\n\n" + NOW + " " + message)


for c in CAPS:
    print()
    print(c)


# The command to run the specific part of the script
endPATH = "\Anims\RGB+labels-bestsfastanimrock.gif".replace('\\','\\\\')
FILE = WINSTACKEDFOLDER.strip("\"") + endPATH # raw mode to preserve backslashes
MyFILE = r"FILE"
command = 'cmd.exe /c \"'+ WINSTACKEDFOLDER.strip("\"") +'\\Anims\\RGB+labels-bestsfastanimrock.gif\" /s'
#process = start_process(command)
message = command
client.publish(STATUS, message)
print(message)
NOW = datetime.datetime.now().strftime("%A %B %d, %Y %I:%M:%S %p")
logger.info("\n" + NOW + " " + message)
logger.info("\n" + NOW + " " + FILE)
logger.info("\n" + NOW + " " + MyFILE)


try:
    print()
    # Start the process
    #process = start_process(command)
    message = "RGB Animation READY"
    client.publish(STATUS, message)
    print(message)
    NOW = datetime.datetime.now().strftime("%A %B %d, %Y %I:%M:%S %p")
    logger.info("\n\n" + NOW + " " + message)
    # Continue with the rest of your script
    print("Subprocess started, continuing with the main script...")
except:
    print()
    message = "Failed to open RGB animation"
    client.publish(MQTTERROR, message)
    print(message)
    NOW = datetime.datetime.now().strftime("%A %B %d, %Y %I:%M:%S %p")
    logger.error("\n\n" + NOW + " " + message)



