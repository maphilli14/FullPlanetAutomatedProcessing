Introduction
I use automation where ever possible.  These scripts will show you how I automate my routine of Astrophotography for making planetary photos.  I use this set of software and settings - https://astromaphilli14.blogspot.com/p/how-mike-images-planets.html

Why do you care?  I leverage existing applications and cut out the mundane steps of clicking, loading and watching paint dry!  Typically I find myself stacking in AS3 and then grabbing the results as they process and sharpening in AstraImage.  This set of scripts automates all of that!

Notes
For ease of use I will maintain tiny scripts that I can use to rerun sub portions of my routine.  Such as being able to run a script that ONLY executes commands within AstraImage or ONLY moves files from one phase or set of directories to another.
Note logging into the script running host via VNC can cause issues with the watcher scripts so it's likely better to spy on the computer with the homeassistant agent or a dropbox or onedrive log sync.

Goals
The goal of the whole project was to have a single button to press at the end of the night and a loosely processed final product would shoot out the other side.

Background
For a long time I used Sikuli, which is a great script language to work in as python/jython, but it's strength in Computer Vision (CV) was ultimately the hardest part to work with, lack of ability to change and adapt to new version, resolutions and theme or color changes. Example as seen 12 years ago - Automating Registax with Sikuli


Then I tried to work with other, python native things such as PYWinAuto but had little success.
I gave up and tried AutoHotKey, which as an outsider I always believed to be more a macro tool than a true programming language.  I still have lots of learning to do and still prefer to write specific elements of my workflow in python.

Dependencies
	1) AutoStakkert folder
	2) AstraImage for sharpening
	3) Color pattern and pixel offsets for end detection needs AHK spying
	4) WSL - Windows Subsystem for Linux


Instruction manual and loose steps
	1) Lots of variables are written to a 'setup.ini' file and should be adjusted 
	2) Pathing is static and you should find replace your script path manually until further notice

Each script can be run as a starting point and will drive to the end.  The end is currently a script that loads a single final RGB with labels as well as the whole night's animation.

The full scripted process begins with an automated 'end of night' starting with -> AS!3

 and then running into AstraImage for sharpening


 -> RGB assembly and animation building in ImageMagik within WSL

 -> archiving files and loading finals to webshare and local display!


Deep dive of steps

Manually run start of end of night autohotkey to start the following:
Automated AutoStakkert
	1) Asks for source avi/ser folder based upon 00-setup.ini and will open root in exploere for copy paste
	2) Selects all files and opens for stacking
	3) Stacks with fixed parameters based upon 00-setup.ini allows 20sec to override defaults
	4) Determine when done?
		a. Watch pixel values - https://www.autohotkey.com/docs/v1/lib/PixelGetColor.htm via discord
		b. Use relative window grap pixel color for top / total progress bar, all F's is not started or not complete, all 0's is black and done within v3.0.x AS3.  Color change is absolute regardless of Win version or color scheme.
		c. Count input files and compare to output over loop via AHK, status kicked into AHK TrayTip before and after loading new files.
		d. If incoming AVI/SER count = stacked count, the main loop is broken and then the pixel watcher starts to validate AS3 is complete
		e. If saved sharps equals stacks then the AstraImage Script is skipped
		f. Else AstraImage batch sharpening script is ran to resharp
		g. Either way next step is to archive all AVI/SER as to denote that the AS3 step is done and avoid confusion as to completeness
1. Automated AS!3 -> AI
	1) If resharpening is needed….
	2) After 'finalizing' AutoStakkert the AstraImage Script should be made to run
	3) Automatically set's parameters and sharpens
		a. Add means to set variables for folder name and actual set PSF / Iter
	4) Determine when done?
		a. Color change is RELATIVE based upon Win version or color scheme, and will need AHK Spy and setting variables
		b. Count input files and compare to output over loop
2. Automated AI -> Imagemagik
	1) After 'finalizing' AstraImage, the RGB Script that runs in WSL python using imagemaik should be made to run
	2) AHK is used to launch a windows terminal defaulting to WSL (all manually installed and setup)
	3) Arguments passed from AHK to Python are in the following order:
		a. PATH - passed via AHK from start of automation
		b. PENDING: Animation Speed - read from setup.ini
		c. Image watermark / logo to place in lower right corner - read from setup.ini
	4) PENDING: Add croping
	5) PENDING: Add resizing
	6) Add offsets for text and watermarks to accommodate diff sizing
3. Automated post to web
	1) Can copy to a mounted network share for use within apache/w3/homeassistant services  - read from setup.ini
	2) Investigate google photo or imgur api (like greenshot)
![image](https://github.com/maphilli14/FullPlanetAutomatedProcessing/assets/6034105/4d2a695e-72a4-437b-a70f-b8661f7a1fef)
