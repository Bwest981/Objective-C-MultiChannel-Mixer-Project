//
//  MultiChannelMixer.h
//  MultiChannelMixer
//
//  Created by Alexander Attar on 12/7/11.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#include <AudioUnit/AudioUnit.h>

#define NUM_FILES 6

//Data structure for mono or stereo sound, to pass to the application's render callback function, 
//which gets invoked by a Mixer unit input bus when it needs more audio to play.
typedef struct {
	
    BOOL                 isStereo;           // set to true if there is data in the audioDataRight member
    UInt32               frameCount;         // the total number of frames in the audio data
    UInt32               sampleNumber;       // the next audio sample to play
    AudioUnitSampleType  *audioDataLeft;     // the complete left (or mono) channel of audio data read from an audio file
    AudioUnitSampleType  *audioDataRight;    // the complete right channel of audio data read from an audio file
    
} soundStruct, *soundStructPtr;

@interface MultiChannelMixer : NSObject <AVAudioSessionDelegate> {
	
    Float64                         graphSampleRate;
    CFURLRef                        sourceURLArray[NUM_FILES];
    soundStruct                     soundStructArray[NUM_FILES];
	
    //Audio Stream Basic Description Structure must be Initialized to 0. Because these ASBDs
	// are declared in external storage, they are automatically initialized to 0.
    AudioStreamBasicDescription     stereoStreamFormat;
    AudioStreamBasicDescription     monoStreamFormat;
    AUGraph                         processingGraph;
    BOOL                            playing;
    BOOL                            interruptedDuringPlayback;
    AudioUnit                       mixerUnit;
	
	
	AudioUnit						crossFaderMixer;
	
	
}

@property (readwrite)           AudioStreamBasicDescription stereoStreamFormat;
@property (readwrite)           AudioStreamBasicDescription monoStreamFormat;
@property (readwrite)           Float64                     graphSampleRate;
@property (getter = isPlaying)  BOOL                        playing;
@property                       BOOL                        interruptedDuringPlayback;
@property                       AudioUnit                   mixerUnit;


@property (nonatomic)			AudioUnit					crossFaderMixer;


/* Method Prototypes */ 
- (void) obtainSoundFileURLs;
- (void) setupAudioSession;
- (void) setupStereoStreamFormat;
- (void) setupMonoStreamFormat;

- (void) readAudioFilesIntoMemory;

- (void) configureAndInitializeAudioProcessingGraph;
- (void) startAUGraph;
- (void) stopAUGraph;

- (void) enableMixerInput: (UInt32) inputBus isOn: (AudioUnitParameterValue) isONValue;
- (void) setMixerInput: (UInt32) inputBus gain: (AudioUnitParameterValue) inputGain;
- (void) setMixerPan: (Float32) inputBus pan: (AudioUnitParameterValue) panningPos;

- (void) setMixerOutputGain: (AudioUnitParameterValue) outputGain;

- (void) printASBD: (AudioStreamBasicDescription) asbd;
- (void) printErrorMessage: (NSString *) errorString withStatus: (OSStatus) result;


@end

