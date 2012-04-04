TITLE: Multi-Channel Audio/DJ Mixer
AUTHOR: Alexander Attar
DATE 12/20/2011

REQUIREMENTS:

MAC OSX - 10.6.8 (SNOW LEOPARD) and later.
Xcode 3.2 and later.
iOS 2.0 and later.


INSTALLATION:

Use the OSX Finder and 
Navigate to the MultiChannelMixer project folder.
In the project folder you will find the MultiChannelMixer.xcodeproj

Open this file and Xcode will boot up. Within Xcode there is quick access to the individual source and multimedia files in the Groups & Files browser on the left side of the Xcode window. 

The program can be run by selecting the Build and Run option in Xcode.
You will find it in the top tool bar of Xcode. You can also use the key-command Command-R. 

If any error happens to occur claiming that the SDK cannot be found follow these steps:

* Select the MultiChannelMixer.xcodeproj from the Groups and Files browser.

* Right click the MultiChannelMixer.xcodeproj and click "Get Info". You can also hit Command-I while the file is selected to get the info window. 

* Once the info window is open click the "Build" tab. In this tab you will see the Base SDK listed. Next to Base SDK will be listed a value. Click this to enter a menu of choices, and select the most recent iOS Simulator from the menu. 

* Exit the info window, save the file, and try to Build and Run. It should now work. 


SOURCE FILES AND ORGANIZATION 

The files containing the code that I have worked on can be found within the Classes folder. Here you will find:

MultiChannelMixerViewController.h //the GUI header source
MultiChannelMixerViewController.m //the GUI implementation source

MultiChannelMixer.h //the audio mixer header source
MultiChannelMixer.m //the audio mixer implementation source

Any adjustments to the GUI can be edited in the ViewController sources, and any adjustments to the backend audio code can be done in the MultiChannelMixer sources. 

Within the Other Sources folder you will find 

MultiChannelMixerAppDelegate.h
MultiChannelMixerAppDelegate.m

These contain the overarching source code for including the view within the window.

MultiChannelMixer_Prefix.pch which is Prefix header for all source files of the 'MultiMixer' target
in the 'MultiMixer' project

and Finally, main.m

In the Frameworks folder are the four frameworks this program utilizes:

UIKit.framework  
Foundation.framework
AudioToolBox.framework 
AVFoundation.framework

These frameworks must be included in the project for it to build successfully. 

The Resources folder contains the media files that this program utilizes along with the GUI Nib file, which contains the layout of the UIButtons, Sliders, ect. 

The images included are the Play (p.png) and Stop (s.png) icons for the master bar play button on the interface, and the Default.png, which is the loading screen for the application. 

The sounds included are what the MultiChannelMixer will load into buffers for playback. These include six stereo tracks which are currently used in the program: 

Bass.wav
Drums.wav
hihat.wav
Lead.wav
Piano.wav
Piano2.wav

The sounds can be swapped out by navigating to line 250 of MultiChannelMixer.m and replacing the track URLS with the new ones. I've included a couple small loop files incase one should want to test out this functionality. 

XF.wav
XF2.wav

In the Products folder, you will find the application executable after the project has been built. 


USAGE:

The application is fairly straight forward to use, and the GUI should largely be self explanatory. 

The master play button is located in the button bar. Pressing this will launch all the audio clips simultaneously. 

The audio clips can be individually played or paused using the corresponding UI buttons. The clips can be launched and paused, but will remain synced by sample.

Bus 0 and Bus 1 reside at the top of the interface and are currently the only tracks with the crossfading feature. 

The other four busses are below in a separate row of buttons Bus 2 is on the left of the interface and Bus 3 - 5 are found in sequence moving right. 

Every track has it's own Gain and Panning control. The amount of gain can be reduced by moving the sliders to the left, and increased by moving the sliders to the right. Panning control allows the user to pan an audio clip to the left by moving the slider to the left, and right by moving the slider to the right. 

In addition to individual gain control. The primary tracks located at the top in Bus 0 and Bus 1 have a Crossfader which allows for fading back and forth between two sound files. 

The six different busses allow for flexibility, and it is up to the user to decide what sort of audio files to import into each bus. For this demonstration I have imported some stems from some of the music I have composed myself, to show how a program like this might be used for live performances of prerecorded tracks. 

NOTES:

At this point, the program has only been tested using the iPhone simulator. It would take further development and registration with Apple to get the program onto an actual iPhone. 























