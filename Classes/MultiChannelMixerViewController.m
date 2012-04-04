//
//  MultiChannelMixerViewController.m
//  MultiChannelMixer
//
//  Created by Alexander Attar on 12/7/11.
//

#import "MultiChannelMixerViewController.h"
#import "MultiChannelMixer.h"

NSString *MultiChannelMixerObjectPlaybackStateDidChangeNotification = @"MultiChannelMixerObjectPlaybackStateDidChangeNotification";

@implementation MultiChannelMixerViewController


/* Create Setters and Getters For Properties with Synthesize */
@synthesize playButton;

@synthesize mixerBus0LevelFader;
@synthesize mixerBus1LevelFader;
@synthesize mixerBus2LevelFader;
@synthesize mixerBus3LevelFader;
@synthesize mixerBus4LevelFader;
@synthesize mixerBus5LevelFader;


@synthesize panPot1;
@synthesize panPot2;
@synthesize panPot3;
@synthesize panPot4;
@synthesize panPot5;
@synthesize panPot6;

@synthesize mixerOutputLevelFader;

@synthesize mixerButton0;
@synthesize mixerButton1;
@synthesize mixerButton2;
@synthesize mixerButton3;
@synthesize mixerButton4;
@synthesize mixerButton5;

@synthesize audioObject;

/* USER INTERFACE METHODS */
# pragma mark -
# pragma mark User interface methods
- (void) initializeMixerSettingsToUI {
	
	buttonBool0 = YES;
	buttonBool1 = YES;
	buttonBool2 = YES;
	buttonBool3 = YES;
	buttonBool4 = YES;
	buttonBool5 = YES;
	
	[playButton setImage: [UIImage imageNamed:@"p.png"]]; //set playButton image to play icon
	
	[mixerButton0 setTitle:@"Stop" forState:UIControlStateNormal];
	[mixerButton1 setTitle:@"Stop" forState:UIControlStateNormal];
	[mixerButton2 setTitle:@"Stop" forState:UIControlStateNormal];
	[mixerButton3 setTitle:@"Stop" forState:UIControlStateNormal];
	[mixerButton4 setTitle:@"Stop" forState:UIControlStateNormal];
	[mixerButton5 setTitle:@"Stop" forState:UIControlStateNormal];
	
	
	//Initialize Mixer Settings To UI 
	
	[audioObject setMixerPan:	   0  pan: panPot1.value];
	[audioObject setMixerPan:	   1  pan: panPot2.value];
	[audioObject setMixerPan:	   2  pan: panPot3.value];
	[audioObject setMixerPan:	   3  pan: panPot4.value];
	[audioObject setMixerPan:	   4  pan: panPot5.value];
	[audioObject setMixerPan:	   5  pan: panPot6.value];
	
	
	[audioObject setMixerOutputGain: mixerOutputLevelFader.value];
	
	[audioObject setMixerInput: 0 gain: mixerBus0LevelFader.value];
	[audioObject setMixerInput: 1 gain: mixerBus1LevelFader.value];
	[audioObject setMixerInput: 2 gain: mixerBus2LevelFader.value];
	[audioObject setMixerInput: 3 gain: mixerBus2LevelFader.value];
	[audioObject setMixerInput: 4 gain: mixerBus2LevelFader.value];
	[audioObject setMixerInput: 5 gain: mixerBus2LevelFader.value];

}

//Deal with changes in mixer output gain slider.
- (IBAction) mixerOutputGainChanged: (UISlider *)sender {
	
	[audioObject setMixerOutputGain: (AudioUnitParameterValue) sender.value];
}

//Deal with changes in mixer input gain sliders. Tag value of the slider allows
//the method to distinguish between channels.
- (IBAction) mixerInputGainChanged: (UISlider *) sender {
	
	/* ENABLE CROSS FADER ON BUS 0 and 1 */
	if (sender.tag == 0) {
		
		[audioObject setMixerInput: 1 gain: (AudioUnitParameterValue) sender.value];
		[audioObject setMixerInput: 0 gain: (AudioUnitParameterValue) sender.value - 1];
		
    } else {
	
	UInt32 inputBus = sender.tag;
    [audioObject setMixerInput: (UInt32) inputBus gain: (AudioUnitParameterValue) sender.value];
	}
}

/* Handle the gain changes of the primary channels separately from the Cross Fader */ 
- (IBAction) primaryBusGain: (UISlider *) sender {

	if (sender.tag == 0 || sender.tag == 1) {
	
		UInt32 inputBus = sender.tag;
		[audioObject setMixerInput: (UInt32) inputBus gain: (AudioUnitParameterValue) sender.value];
	}
}


/*- (IBAction) crossFaderChanged: (UISlider *) sender {
	
	UInt32 inputBus = sender.tag;
    [audioObject setMixerInput: (UInt32) inputBus gain: (AudioUnitParameterValue) sender.value];
}*/


/* ACTION TO CHANGE PAN POSITION */ 
- (IBAction) panningPosChanged: (UISlider *) sender {
	
	UInt32 inputBus = sender.tag;
	[audioObject setMixerPan:(UInt32) inputBus pan: (AudioUnitParameterValue) sender.value];
}
	 

/* Audio Processing Graph Control */

//Handle a play/stop button gesture
- (IBAction) playOrStop: (id) sender {
	
	    if (audioObject.playing) {
			[audioObject stopAUGraph];
			[playButton setImage: [UIImage imageNamed:@"p.png"]]; //set play icon
			
        
    } else {
        [audioObject startAUGraph];
		[playButton setImage: [UIImage imageNamed:@"s.png"]]; //set stop icon
	} 
}

/* Notification flag if the playback state has changed */
- (void) handlePlaybackStateChanged:(id) notification {
	
	[self playOrStop: nil];
}

/* Handle Mixer Unit Input On/Off Switch Actions */
- (IBAction) enableMixerInput: (UISwitch *) sender {
	
	UInt32 inputBus = sender.tag;
    AudioUnitParameterValue isOn = (AudioUnitParameterValue) sender.isOn;
    
    [audioObject enableMixerInput: inputBus isOn: isOn];
}

/* Method to allow playing and pausing tracks with the UIButtons */
- (IBAction) buttonPressed:(id)sender {
	
	UIButton *button = (UIButton*)sender;
	AudioUnitParameterValue isOn;

	/* Using Bools to keep track of the state of the buttons in the interface */
	
	if ( button.tag == 0 ) {
		if ( buttonBool0 ) {
			
			[mixerButton0 setTitle:@"Play" forState:UIControlStateNormal];
		}
		else {
			[mixerButton0 setTitle:@"Stop" forState:UIControlStateNormal];

		}
		buttonBool0 = !buttonBool0;
		isOn = (AudioUnitParameterValue) buttonBool0;
		
	}
	
	if ( button.tag == 1 ) {
		if ( buttonBool1 ) {
			[mixerButton1 setTitle:@"Play" forState:UIControlStateNormal];
		}
		else {
			[mixerButton1 setTitle:@"Stop" forState:UIControlStateNormal];
			
		}
		buttonBool1 = !buttonBool1;
		isOn = (AudioUnitParameterValue) buttonBool1;
	}
	
	if ( button.tag == 2 ) {
		if ( buttonBool2 ) {
			[mixerButton2 setTitle:@"Play" forState:UIControlStateNormal];
		}
		else {
			[mixerButton2 setTitle:@"Stop" forState:UIControlStateNormal];
		}
		buttonBool2 = !buttonBool2;
		isOn = (AudioUnitParameterValue) buttonBool2;
	}

	if ( button.tag == 3 ) {
		if ( buttonBool3 ) {
			[mixerButton3 setTitle:@"Play" forState:UIControlStateNormal];
		}
		else {
			[mixerButton3 setTitle:@"Stop" forState:UIControlStateNormal];
		}
		buttonBool3 = !buttonBool3;
		isOn = (AudioUnitParameterValue) buttonBool3;
	}

	if ( button.tag == 4 ) {
		if ( buttonBool4 ) {
			[mixerButton4 setTitle:@"Play" forState:UIControlStateNormal];
		}
		else {
			[mixerButton4 setTitle:@"Stop" forState:UIControlStateNormal];
		}
		buttonBool4 = !buttonBool4;
		isOn = (AudioUnitParameterValue) buttonBool4;
	}
	
	if ( button.tag == 5 ) {
		if ( buttonBool5 ) {
			[mixerButton5 setTitle:@"Play" forState:UIControlStateNormal];
		}
		else {
			[mixerButton5 setTitle:@"Stop" forState:UIControlStateNormal];
		}
		buttonBool5 = !buttonBool5;
		isOn = (AudioUnitParameterValue) buttonBool5;
	}
	
	UInt32 inputBus = button.tag;
    [audioObject enableMixerInput: inputBus isOn: isOn];

}


/* Respond To Remote Control Events */ 
- (void) remoteControlReceivedWithEvent:(UIEvent *) receivedEvent {
	
	if (receivedEvent.type == UIEventTypeRemoteControl) {
		
		switch (receivedEvent.subtype) {
			case UIEventSubtypeRemoteControlTogglePlayPause:
				[self playOrStop: nil];
				break;
			default:
				break;
		}
	}
}

/* Notifications Registration */

// If this app's audio session is interrupted when playing audio, it needs to update its user interface 
//    to reflect the fact that audio has stopped. 
- (void) registerForAudioObjectNotifications {
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	[notificationCenter addObserver: self
						   selector: @selector (handlePlaybackStateChanged:)
							   name: MultiChannelMixerObjectPlaybackStateDidChangeNotification
							 object: audioObject];
												
}


/* Application State Management */
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	MultiChannelMixer *newAudioObject = [[MultiChannelMixer alloc] init];
	self.audioObject = newAudioObject;
	[newAudioObject release];
	
	[self registerForAudioObjectNotifications];
	[self initializeMixerSettingsToUI];
}

- (void) viewDidAppear: (BOOL) animated {
	
    [super viewDidAppear: animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (BOOL) canBecomeFirstResponder {
	
    return YES;
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void) viewWillDisppear: (BOOL) animated {
	
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    [super viewWillDisappear: animated];
}

/* Release the view controllers memory that was allocated */
- (void)viewDidUnload {

	self.playButton				= nil;
	
	mixerButton0				= nil;
	mixerButton1				= nil;
	mixerButton2				= nil;
	mixerButton3				= nil;
	mixerButton4				= nil;
	mixerButton5				= nil;
	
	self.panPot1				= nil;
	self.panPot2				= nil;

	self.mixerBus0LevelFader	= nil;
	self.mixerBus1LevelFader	= nil;
	self.mixerBus2LevelFader	= nil;
	self.mixerBus3LevelFader	= nil;
	self.mixerBus4LevelFader	= nil;
	self.mixerBus5LevelFader	= nil;
	
	self.mixerOutputLevelFader  = nil;
	
	self.audioObject			= nil;
	[super viewDidUnload];
	
}

/* Final Deallocation the memory of the UI Elements */
- (void)dealloc {
	
	[playButton				release];
	
	[mixerButton0			release];
	[mixerButton1			release];
	[mixerButton2			release];
	[mixerButton3			release];
	[mixerButton4			release];
	[mixerButton5			release];
	
	[mixerBus0LevelFader	release];
	[mixerBus1LevelFader	release];
	[mixerBus2LevelFader	release];
	[mixerBus3LevelFader	release];
	[mixerBus4LevelFader	release];
	[mixerBus5LevelFader	release];
	
	[panPot1				release];
	[panPot2				release];
	
	[mixerOutputLevelFader	release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name: MultiChannelMixerObjectPlaybackStateDidChangeNotification
												  object: audioObject];
	
	[audioObject		release];
	[[UIApplication		sharedApplication] endReceivingRemoteControlEvents];
	
    [super dealloc];
}

@end //end of view implementation 
