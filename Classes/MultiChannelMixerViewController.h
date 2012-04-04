//
//  MultiChannelMixerViewController.h
//  MultiChannelMixer
//
//  Created by Alexander Attar on 12/7/11.
//

#import <UIKit/UIKit.h>
#import "MultiChannelMixer.h"

@class MultiChannelMixer;

@interface MultiChannelMixerViewController : UIViewController {

	//master play button
	UIBarButtonItem		*playButton;	
	
	//UIButtons and Bool flags for the track launch buttons. 
	UIButton			*mixerButton0;	
	BOOL				buttonBool0;
	UIButton			*mixerButton1;
	BOOL				buttonBool1;
	UIButton			*mixerButton2;
	BOOL				buttonBool2;
	UIButton			*mixerButton3;
	BOOL				buttonBool3;
	UIButton			*mixerButton4;
	BOOL				buttonBool4;
	UIButton			*mixerButton5;
	BOOL				buttonBool5;
	
	//UISliders for panning control. One per track. 
	UISlider			*panPot1;
	UISlider			*panPot2;
	UISlider			*panPot3;
	UISlider			*panPot4;
	UISlider			*panPot5;
	UISlider			*panPot6;
	
	//UISliders for gain control. One per track. 
	//mixerBus0LevelFader is special in that bus0 and bus 1 share it for crossfader control
	UISlider			*mixerBus0LevelFader; 
	UISlider			*mixerBus1LevelFader;
	UISlider			*mixerBus2LevelFader;
	UISlider			*mixerBus3LevelFader;
	UISlider			*mixerBus4LevelFader;
	UISlider			*mixerBus5LevelFader;
	
	//UISlider for master gain control 
	UISlider			*mixerOutputLevelFader;
	
	
	//MultiChannelMixer object to store audio information
	MultiChannelMixer	*audioObject;
	
	



}

/* declare the buttons and faders */
@property (nonatomic, retain)    IBOutlet UIBarButtonItem	*playButton; 

@property (nonatomic, retain)    IBOutlet UIButton			*mixerButton0;
@property (nonatomic, retain)    IBOutlet UIButton			*mixerButton1;
@property (nonatomic, retain)    IBOutlet UIButton			*mixerButton2;
@property (nonatomic, retain)    IBOutlet UIButton			*mixerButton3;
@property (nonatomic, retain)    IBOutlet UIButton			*mixerButton4;
@property (nonatomic, retain)    IBOutlet UIButton			*mixerButton5;

@property (nonatomic, retain)	 IBOutlet UISlider			*panPot1;
@property (nonatomic, retain)	 IBOutlet UISlider			*panPot2;
@property (nonatomic, retain)	 IBOutlet UISlider			*panPot3;
@property (nonatomic, retain)	 IBOutlet UISlider			*panPot4;
@property (nonatomic, retain)	 IBOutlet UISlider			*panPot5;
@property (nonatomic, retain)	 IBOutlet UISlider			*panPot6;

@property (nonatomic, retain)    IBOutlet UISlider			*mixerBus0LevelFader;
@property (nonatomic, retain)    IBOutlet UISlider			*mixerBus1LevelFader;
@property (nonatomic, retain)    IBOutlet UISlider			*mixerBus2LevelFader;
@property (nonatomic, retain)    IBOutlet UISlider			*mixerBus3LevelFader;
@property (nonatomic, retain)    IBOutlet UISlider			*mixerBus4LevelFader;
@property (nonatomic, retain)    IBOutlet UISlider			*mixerBus5LevelFader;

@property (nonatomic, retain)    IBOutlet UISlider          *mixerOutputLevelFader;
@property (nonatomic, retain)	 MultiChannelMixer			*audioObject;


/* Declare method prototypes */ 
- (IBAction) primaryBusGain: (UISlider *) sender;

- (IBAction) enableMixerInput:          (UISwitch *) sender;
- (IBAction) mixerInputGainChanged:		(UISlider *) sender;
- (IBAction) panningPosChanged:			(UISlider *) sender;
- (IBAction) buttonPressed:(id)sender;

- (IBAction) mixerOutputGainChanged:	(UISlider *) sender;
- (IBAction) playOrStop:				(id) sender;


- (void) handlePlaybackStateChanged:	(id) sender;
- (void) initializeMixerSettingsToUI;
- (void) registerForAudioObjectNotifications;





@end

