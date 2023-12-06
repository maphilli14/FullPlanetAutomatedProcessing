# FullPlanetAutomatedProcessing
These scripts will show you how I automate my routine of Astrophotography for making planetary photos

Introduction
I use automation where ever possible.  These scripts will show you how I automate my routine of Astrophotography for making planetary photos.  I use this set of software and settings - https://astromaphilli14.blogspot.com/p/how-mike-images-planets.html

Notes
For ease of use I will maintain tiny scripts that I can use to rerun sub portions of my routine.  Such as being able to run a script that ONLY executes commands within AstraImage or ONLY moves files from one phase or set of directories to another.
Note logging into the script running host via VNC can cause issues with the watcher scripts so it's likely better to spy on the computer with the homeassistant agent or a dropbox or onedrive log sync.

Goals
The goal of the whole project was to have a single button to press at the end of the night and a loosely processed final product would shoot out the other side.

Background
For along time I used Sikuli, which is a great script language to work in as python/jython, but it's strength in Computer Vision (CV) was ultimately the hardest part to work with, lack of ability to change and adapt to new version, resolutions and theme or color changes. Example as seen 12 years ago - Automating Registax with Sikuli


Then I tried to work with other, python native things such as PYWinAuto but had little success.
I gave up and tried AutoHotKey, which as an outsider I always believed to be more a macro tool than a true programming language.  I still have lots of learning to do and still prefer to write specific elements of my workflow in python.

Loose Steps
Automated capture - fix guiding
	Find yucky night to play with and record settings!
Automated 'end of night' -> AS!3
	Revisit pywinauto
	
Absolute timers should be used AFTER launching program

Manually run start of end of night autohotkey to start the following:
Automated AutoStakkert
	Parses last folder(s) - fixed in variable, pythonic [-1]
	Stacks with fixed parameters
	Determine when done?
		Watch pixel values - https://www.autohotkey.com/docs/v1/lib/PixelGetColor.htm via discord
		Use relative window grap pixel color for top / total progress bar, all F's is not started or not complete, all 0's is black and done within v3.0.x AS3.  Color change is absolute regardless of Win version or color scheme.
		Watch CPU
		Count input files and compare to output over loop via python, status kicked into AHK tool tip before and after moves
			Consider 'empty' dir status return
			When not all stacks found need to stop move of stacks
Automated AS!3 -> AI
	After 'finalizing' AutoStakkert the AstraImage Script should be made to run
	Automatically set's parameters and sharpens
		Add means to set variables for folder name and actual set PSF / Iter
	Determine when done?
		Color change is RELATIVE based upon Win version or color scheme, and will need AHK Spy and setting variables
		Watch CPU
		Count input files and compare to output over loop
Automated AI -> Imagemagik
	AHK is used to launch a windows terminal defaulting to WSL (all manually installed and setup)
	Arguments passed from AHK to Python are in the following order:
		1) PATH - passed via AHK from start of automation
		2) Animation Speed - read from setup.ini
		3) Image watermark / logo to place in lower right corner - read from setup.ini
	After 'finalizing' AstraImage, the RGB Script that runs in WSL python using imagemaik should be made to run
	Add croping
	Add resizing
	Add offsets for text and watermarks to accommodate diff sizing
Automated post to web
	Can copy to a mounted network share for use within apache/w3/homeassistant services  - read from setup.ini
	Investigate google photo or imgur api (like greenshot)

![image](https://github.com/maphilli14/FullPlanetAutomatedProcessing/assets/6034105/244719cb-528a-4099-8e5d-9a3bdee46248)
