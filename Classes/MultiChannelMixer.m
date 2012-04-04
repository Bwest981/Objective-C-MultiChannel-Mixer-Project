//
//  MultiChannelMixer.m
//  MultiChannelMixer
//
//  Created by Alexander Attar on 12/7/11.
//

//similar to include, but prevents any issues if the header files are included in more than one of the sources.
#import "MultiChannelMixer.h"  


//    The audio callback is invoked each time a Multichannel Mixer unit input bus requires more audio
//    samples.
//    This callback is written for an inRefCon parameter that can point to two noninterleaved 
//    buffers (for a stereo sound) or to one mono buffer (for a mono sound).
//

/* Code which invokes audio callbacks is taken from Apple's documentation, which
   demonstrates proper usage of the audio callback system within the AudioToolBox and AVFoundation
   Frameworks in Objective-C. I have addapted the code to fit the means of a 6 channel mixer with volume and panning control. 
*/

/* AUDIO CALLBACK */
#pragma mark Mixer input bus render callback
static OSStatus inputRenderCallback (
									 
			 void                        *inRefCon,      // A pointer to a struct containing the complete audio data 
			 //    to play, as well as state information such as the  
			 //    first sample to play on this invocation of the callback.
			 AudioUnitRenderActionFlags  *ioActionFlags, // Unused here. When generating audio, use ioActionFlags to indicate silence 
			 //    between sounds; for silence, also memset the ioData buffers to 0.
			 const AudioTimeStamp        *inTimeStamp,   // Unused here.
			 UInt32                      inBusNumber,    // The mixer unit input bus that is requesting some new
			 //        frames of audio data to play.
			 UInt32                      inNumberFrames, // The number of frames of audio to provide to the buffer(s)
			 //        pointed to by the ioData parameter.
			 AudioBufferList             *ioData         // On output, the audio data to play. The callback's primary 
			 //        responsibility is to fill the buffer(s) in the 
			 //        AudioBufferList.
			 ) {
	
    soundStructPtr    soundStructPointerArray   = (soundStructPtr) inRefCon;
    UInt32            frameTotalForSound        = soundStructPointerArray[inBusNumber].frameCount;
    BOOL              isStereo                  = soundStructPointerArray[inBusNumber].isStereo;
	
    // Declare variables to point to the audio buffers. Their data type must match the buffer data type.
    AudioUnitSampleType *dataInLeft;
    AudioUnitSampleType *dataInRight;
    
    dataInLeft                 = soundStructPointerArray[inBusNumber].audioDataLeft;
    if (isStereo) dataInRight  = soundStructPointerArray[inBusNumber].audioDataRight;
    
    // Establish pointers to the memory into which the audio from the buffers should go. This reflects
    //    the fact that each Multichannel Mixer unit input bus has two channels, as specified by this app's
    //    graphStreamFormat variable.
    AudioUnitSampleType *outSamplesChannelLeft;
    AudioUnitSampleType *outSamplesChannelRight;
    
    outSamplesChannelLeft                 = (AudioUnitSampleType *) ioData->mBuffers[0].mData;
    if (isStereo) outSamplesChannelRight  = (AudioUnitSampleType *) ioData->mBuffers[1].mData;
	
    // Get the sample number, as an index into the sound stored in memory,
    //    to start reading data from.
    UInt32 sampleNumber = soundStructPointerArray[inBusNumber].sampleNumber;
	
    // Fill the buffer or buffers pointed at by *ioData with the requested number of samples 
    //    of audio from the sound stored in memory.
    for (UInt32 frameNumber = 0; frameNumber < inNumberFrames; ++frameNumber) {
		
        outSamplesChannelLeft[frameNumber]                 = dataInLeft[sampleNumber];
        if (isStereo) outSamplesChannelRight[frameNumber]  = dataInRight[sampleNumber];
        
        sampleNumber++;
		
        // After reaching the end of the sound stored in memory,loop back to the 
        //    start of the sound so playback resumes from there.
        if (sampleNumber >= frameTotalForSound) sampleNumber = 0;
    }
    
    // Update the stored sample number so, the next time this callback is invoked, playback resumes 
    //    at the correct spot.
    soundStructPointerArray[inBusNumber].sampleNumber = sampleNumber;
    
    return noErr;
}

/* Respond to interuptions in audio playback */
#pragma mark -
#pragma mark Audio route change listener callback
// Audio session callback function for responding to audio route changes. If playing back audio and
//   the user unplugs a headset or headphones, or removes the device from a dock connector for hardware  
//   that supports audio playback, this callback detects that and stops playback. 
//
// Refer to AudioSessionPropertyListener in Audio Session Services Reference.
void audioRouteChangeListenerCallback (
									   void                      *inUserData,
									   AudioSessionPropertyID    inPropertyID,
									   UInt32                    inPropertyValueSize,
									   const void                *inPropertyValue
									   ) {
    
    // Ensure that this callback was invoked because of an audio route change
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
	
    // This callback, being outside the implementation block, needs a reference to the MultiChannelMixer
    //   object, which it receives in the inUserData parameter. You provide this reference when
    //   registering this callback (see the call to AudioSessionAddPropertyListener).
    MultiChannelMixer *audioObject = (MultiChannelMixer *) inUserData;
    
    // if application sound is not playing, there's nothing to do, so return.
    if (NO == audioObject.playing) {
		
        NSLog (@"Audio route change while application audio is stopped.");
        return;
        
    } else {
		
        // Determine the specific type of audio route change that occurred.
        CFDictionaryRef routeChangeDictionary = inPropertyValue;
        
        CFNumberRef routeChangeReasonRef =
		CFDictionaryGetValue (
							  routeChangeDictionary,
							  CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
							  );
		
        SInt32 routeChangeReason;
        
        CFNumberGetValue (
						  routeChangeReasonRef,
						  kCFNumberSInt32Type,
						  &routeChangeReason
						  );
        
        // "Old device unavailable" indicates that a headset or headphones were unplugged, or that 
        //    the device was removed from a dock connector that supports audio output. In such a case,
        //    pause or stop audio. This is in correspondence to the human interface iOS guidelines. 
        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
			
            NSLog (@"Audio output device was removed; stopping audio playback.");
            NSString *MultiChannelMixerObjectPlaybackStateDidChangeNotification = @"MultiChannelMixerObjectPlaybackStateDidChangeNotification";
            [[NSNotificationCenter defaultCenter] postNotificationName: MultiChannelMixerObjectPlaybackStateDidChangeNotification object: audioObject]; 
			
        } else {
			
            NSLog (@"A route change occurred that does not require stopping application audio.");
        }
    }
}


//...........................................................................................................................
/* IMPLEMENTATION */
#pragma mark -
@implementation MultiChannelMixer

@synthesize stereoStreamFormat;         // stereo format for use in buffer and mixer input for "track 1" sound
@synthesize monoStreamFormat;           // mono format for use in buffer and mixer input for "track 2" sound
@synthesize graphSampleRate;            // sample rate to use throughout audio processing chain
@synthesize mixerUnit;                  // the Multichannel Mixer unit
@synthesize playing;                    // Boolean flag to indicate whether audio is playing or not
@synthesize interruptedDuringPlayback;  // Boolean flag to indicate whether audio was playing when an interruption arrived

@synthesize crossFaderMixer;

#pragma mark -
#pragma mark Initialize

// Get the app ready for playback.
- (id) init {
	
    self = [super init];
    
    if (!self) return nil;
	
    self.interruptedDuringPlayback = NO;
	
    [self setupAudioSession];
    [self obtainSoundFileURLs];
    [self setupStereoStreamFormat];
    [self setupMonoStreamFormat];
    [self readAudioFilesIntoMemory];
    [self configureAndInitializeAudioProcessingGraph];
    
    return self;
}


#pragma mark -
#pragma mark Audio set up

/* SETUP AUDIO */
- (void) setupAudioSession {
	
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
	
    // Specify that this object is the delegate of the audio session, so that
    //    this object's endInterruption method will be invoked when needed.
    [mySession setDelegate: self];
	
    // Assign the Playback category to the audio session.
    NSError *audioSessionError = nil;
    [mySession setCategory: AVAudioSessionCategoryPlayback
                     error: &audioSessionError];
    
    if (audioSessionError != nil) {
		
        NSLog (@"Error setting audio session category.");
        return;
    }
	
    // Request the desired hardware sample rate.
    self.graphSampleRate = 44100.0;    // Hertz
    
    [mySession setPreferredHardwareSampleRate: graphSampleRate
                                        error: &audioSessionError];
    
    if (audioSessionError != nil) {
		
        NSLog (@"Error setting preferred hardware sample rate.");
        return;
    }
	
    // Activate the audio session
    [mySession setActive: YES
                   error: &audioSessionError];
	
    if (audioSessionError != nil) {
		
        NSLog (@"Error activating audio session during initial setup.");
        return;
    }
	
    // Obtain the actual hardware sample rate and store it for later use in the audio processing graph.
    self.graphSampleRate = [mySession currentHardwareSampleRate];
	
    // Register the audio route change listener callback function with the audio session.
    AudioSessionAddPropertyListener (
									 kAudioSessionProperty_AudioRouteChange,
									 audioRouteChangeListenerCallback,
									 self
									 );
}


- (void) obtainSoundFileURLs { 
	
	/******TRACKS CAN BE CHANGED FROM HERE*******/
	
    // Create the URLs for the source audio files. 
    NSURL *track1Loop   = [[NSBundle mainBundle] URLForResource: @"Piano"
                                                  withExtension: @"wav"];
	
    NSURL *track2Loop    = [[NSBundle mainBundle] URLForResource: @"Piano2"
                                                  withExtension: @"wav"];
	
	NSURL *track3Loop    = [[NSBundle mainBundle] URLForResource: @"Drums"
												   withExtension: @"wav"];
	
	NSURL *track4Loop    = [[NSBundle mainBundle] URLForResource: @"hihat"
												   withExtension: @"wav"];
	
	NSURL *track5Loop    = [[NSBundle mainBundle] URLForResource: @"Bass"
												   withExtension: @"wav"];
	
	NSURL *track6Loop    = [[NSBundle mainBundle] URLForResource: @"Lead"
												   withExtension: @"wav"];
	
	
    // ExtAudioFileRef objects expect CFURLRef URLs (cast to CRURLRef here)
	//a method where you see an NSURL * parameter, you can pass in a CFURLRef, 
	//and in a function where you see a CFURLRef parameter, you can pass in an NSURL instance.
    sourceURLArray[0]   = (CFURLRef) [track1Loop retain];
    sourceURLArray[1]   = (CFURLRef) [track2Loop retain];
	sourceURLArray[2]   = (CFURLRef) [track3Loop retain];
	sourceURLArray[3]   = (CFURLRef) [track4Loop retain];
	sourceURLArray[4]   = (CFURLRef) [track5Loop retain];
	sourceURLArray[5]   = (CFURLRef) [track6Loop retain];

}

/* If a stereo file is loaded, use stereo stream format */
- (void) setupStereoStreamFormat {
	
    // The AudioUnitSampleType data type is the recommended type for sample data in audio
    //    units. This obtains the byte size of the type for use in filling in the ASBD.
    size_t bytesPerSample = sizeof (AudioUnitSampleType);
	
    // Fill the application audio format struct's fields to define a linear PCM, 
    //        stereo, noninterleaved stream at the hardware sample rate.
    stereoStreamFormat.mFormatID          = kAudioFormatLinearPCM;
    stereoStreamFormat.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    stereoStreamFormat.mBytesPerPacket    = bytesPerSample;
    stereoStreamFormat.mFramesPerPacket   = 1;
    stereoStreamFormat.mBytesPerFrame     = bytesPerSample;
    stereoStreamFormat.mChannelsPerFrame  = 2;                    // 2 indicates stereo
    stereoStreamFormat.mBitsPerChannel    = 8 * bytesPerSample;
    stereoStreamFormat.mSampleRate        = graphSampleRate;
	
	
    NSLog (@"The stereo stream format for the mixer input bus:");
    [self printASBD: stereoStreamFormat]; //print the audio data 
}

/* If mono file is loaded, use mono stream format */
- (void) setupMonoStreamFormat {
	
    // The AudioUnitSampleType data type is the recommended type for sample data in audio
    //    units. This obtains the byte size of the type for use in filling in the ASBD.
    size_t bytesPerSample = sizeof (AudioUnitSampleType);
	
    // Fill the application audio format struct's fields to define a linear PCM, 
    //        stereo, noninterleaved stream at the hardware sample rate.
    monoStreamFormat.mFormatID          = kAudioFormatLinearPCM;
    monoStreamFormat.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    monoStreamFormat.mBytesPerPacket    = bytesPerSample;
    monoStreamFormat.mFramesPerPacket   = 1;
    monoStreamFormat.mBytesPerFrame     = bytesPerSample;
    monoStreamFormat.mChannelsPerFrame  = 1;                  // 1 indicates mono
    monoStreamFormat.mBitsPerChannel    = 8 * bytesPerSample;
    monoStreamFormat.mSampleRate        = graphSampleRate;
	
    NSLog (@"The mono stream format for the mixer input bus:");
    [self printASBD: monoStreamFormat];
	
}

/* READ AUDIO FILES INTO MEMORY */
#pragma mark -
#pragma mark Read audio files into memory
- (void) readAudioFilesIntoMemory {
	
    for (int audioFile = 0; audioFile < NUM_FILES; ++audioFile)  {
		
        NSLog (@"readAudioFilesIntoMemory - file %i", audioFile);
        
        // Instantiate an extended audio file object.
        ExtAudioFileRef audioFileObject = 0;
        
        // Open an audio file and associate it with the extended audio file object.
        OSStatus result = ExtAudioFileOpenURL (sourceURLArray[audioFile], &audioFileObject);
        
        if (noErr != result || NULL == audioFileObject) {[self printErrorMessage: @"ExtAudioFileOpenURL" withStatus: result]; return;}
		
        // Get the audio file's length in frames.
        UInt64 totalFramesInFile = 0;
        UInt32 frameLengthPropertySize = sizeof (totalFramesInFile);
        
        result =    ExtAudioFileGetProperty (
											 audioFileObject,
											 kExtAudioFileProperty_FileLengthFrames,
											 &frameLengthPropertySize,
											 &totalFramesInFile
											 );
		
        if (noErr != result) {[self printErrorMessage: @"ExtAudioFileGetProperty (audio file length in frames)" withStatus: result]; return;}
        
        // Assign the frame count to the soundStructArray instance variable
        soundStructArray[audioFile].frameCount = totalFramesInFile;
		
        // Get the audio file's number of channels.
        AudioStreamBasicDescription fileAudioFormat = {0};
        UInt32 formatPropertySize = sizeof (fileAudioFormat);
        
        result =    ExtAudioFileGetProperty (
											 audioFileObject,
											 kExtAudioFileProperty_FileDataFormat,
											 &formatPropertySize,
											 &fileAudioFormat
											 );
		
        if (noErr != result) {[self printErrorMessage: @"ExtAudioFileGetProperty (file audio format)" withStatus: result]; return;}
		
        UInt32 channelCount = fileAudioFormat.mChannelsPerFrame;
        
        // Allocate memory in the soundStructArray instance variable to hold the left channel, 
        //    or mono, audio data
        soundStructArray[audioFile].audioDataLeft =
		(AudioUnitSampleType *) calloc (totalFramesInFile, sizeof (AudioUnitSampleType));
		
        AudioStreamBasicDescription importFormat = {0};
        if (2 == channelCount) {
			
            soundStructArray[audioFile].isStereo = YES;
            // Sound is stereo, so allocate memory in the soundStructArray instance variable to  
            //    hold the right channel audio data
            soundStructArray[audioFile].audioDataRight =
			(AudioUnitSampleType *) calloc (totalFramesInFile, sizeof (AudioUnitSampleType));
            importFormat = stereoStreamFormat;
            
        } else if (1 == channelCount) {
			
            soundStructArray[audioFile].isStereo = NO;
            importFormat = monoStreamFormat;
            
        } else {
			
            NSLog (@"*** WARNING: File format not supported - wrong number of channels");
            ExtAudioFileDispose (audioFileObject);
            return;
        }
		
        // Assign the appropriate mixer input bus stream data format to the extended audio 
        //        file object. This is the format used for the audio data placed into the audio 
        //        buffer in the SoundStruct data structure, which is in turn used in the 
        //        inputRenderCallback callback function.
        
        result =    ExtAudioFileSetProperty (
											 audioFileObject,
											 kExtAudioFileProperty_ClientDataFormat,
											 sizeof (importFormat),
											 &importFormat
											 );
		
        if (noErr != result) {[self printErrorMessage: @"ExtAudioFileSetProperty (client data format)" withStatus: result]; return;}
        
        // Set up an AudioBufferList struct, which has two roles:
        //
        //        1. It gives the ExtAudioFileRead function the configuration it 
        //            needs to correctly provide the data to the buffer.
        //
        //        2. It points to the soundStructArray[audioFile].audioDataLeft buffer, so 
        //            that audio data obtained from disk using the ExtAudioFileRead function
        //            goes to that buffer
		
        // Allocate memory for the buffer list struct according to the number of 
        //    channels it represents.
        AudioBufferList *bufferList;
		
        bufferList = (AudioBufferList *) malloc (
												 sizeof (AudioBufferList) + sizeof (AudioBuffer) * (channelCount - 1)
												 );
		
        if (NULL == bufferList) {NSLog (@"*** malloc failure for allocating bufferList memory"); return;}
        
        // initialize the mNumberBuffers member
        bufferList->mNumberBuffers = channelCount;
        
        // initialize the mBuffers member to 0
        AudioBuffer emptyBuffer = {0};
        size_t arrayIndex;
        for (arrayIndex = 0; arrayIndex < channelCount; arrayIndex++) {
            bufferList->mBuffers[arrayIndex] = emptyBuffer;
        }
        
        // set up the AudioBuffer structs in the buffer list
        bufferList->mBuffers[0].mNumberChannels  = 1;
        bufferList->mBuffers[0].mDataByteSize    = totalFramesInFile * sizeof (AudioUnitSampleType);
        bufferList->mBuffers[0].mData            = soundStructArray[audioFile].audioDataLeft;
		
        if (2 == channelCount) {
            bufferList->mBuffers[1].mNumberChannels  = 1;
            bufferList->mBuffers[1].mDataByteSize    = totalFramesInFile * sizeof (AudioUnitSampleType);
            bufferList->mBuffers[1].mData            = soundStructArray[audioFile].audioDataRight;
        }
		
        // Perform a synchronous, sequential read of the audio data out of the file and
        //    into the soundStructArray[audioFile].audioDataLeft and (if stereo) .audioDataRight members.
        UInt32 numberOfPacketsToRead = (UInt32) totalFramesInFile;
        
        result = ExtAudioFileRead (
								   audioFileObject,
								   &numberOfPacketsToRead,
								   bufferList
								   );
		
        free (bufferList);
        
        if (noErr != result) {
			
            [self printErrorMessage: @"ExtAudioFileRead failure - " withStatus: result];
            
            // If reading from the file failed, then free the memory for the sound buffer.
            free (soundStructArray[audioFile].audioDataLeft);
            soundStructArray[audioFile].audioDataLeft = 0;
            
            if (2 == channelCount) {
                free (soundStructArray[audioFile].audioDataRight);
                soundStructArray[audioFile].audioDataRight = 0;
            }
            
            ExtAudioFileDispose (audioFileObject);            
            return;
        }
        
        NSLog (@"Finished reading file %i into memory", audioFile);
		
        // Set the sample index to zero, so that playback starts at the 
        //    beginning of the sound.
        soundStructArray[audioFile].sampleNumber = 0;
		
        // Dispose of the extended audio file object, which also
        //    closes the associated file.
        ExtAudioFileDispose (audioFileObject);
    }
}

/* AUDIO PROCESSING GRAPH SETUP */
#pragma mark -
#pragma mark Audio processing graph setup
//First, instantiate and open an audio processing graph
//Second, obtain the audio unit nodes for the graph
//Configure the Multichannel Mixer unit
//     * specify the number of input buses
//     * specify the output sample rate
//     * specify the maximum frames-per-slice
//Finally, initialize the audio processing graph

- (void) configureAndInitializeAudioProcessingGraph {
	
    NSLog (@"Configuring and then initializing audio processing graph");
    OSStatus result = noErr;
	
	
	// Create a new audio processing graph to hold the audio data.
    result = NewAUGraph (&processingGraph);
	
    if (noErr != result) {[self printErrorMessage: @"NewAUGraph" withStatus: result]; return;}
    
    
	// Specify the audio unit component descriptions for the audio units to be
	//    added to the graph.
	
    // I/O unit
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType          = kAudioUnitType_Output;
    iOUnitDescription.componentSubType       = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags         = 0;
    iOUnitDescription.componentFlagsMask     = 0;
    
    // Multichannel mixer unit
    AudioComponentDescription MixerUnitDescription;
    MixerUnitDescription.componentType          = kAudioUnitType_Mixer;
    MixerUnitDescription.componentSubType       = kAudioUnitSubType_MultiChannelMixer;
    MixerUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    MixerUnitDescription.componentFlags         = 0;
    MixerUnitDescription.componentFlagsMask     = 0;
	
	
	// Add nodes to the audio processing graph.
    NSLog (@"Adding nodes to audio processing graph");
	
    AUNode   iONode;         // node for I/O unit
    AUNode   mixerNode;      // node for Multichannel Mixer unit
    
    // Add the nodes to the audio processing graph
    result =    AUGraphAddNode (
								processingGraph,
								&iOUnitDescription,
								&iONode);
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphNewNode failed for I/O unit" withStatus: result]; return;}
    
	
    result =    AUGraphAddNode (
								processingGraph,
								&MixerUnitDescription,
								&mixerNode
								);
	
    if (noErr != result) {[self printErrorMessage: @"AUGraphNewNode failed for Mixer unit" withStatus: result]; return;}
    
	
	// Open the audio processing graph
	
    // Following this call, the audio units are instantiated but not initialized
    //    (no resource allocation occurs and the audio units are not in a state to
    //    process audio).
    result = AUGraphOpen (processingGraph);
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphOpen" withStatus: result]; return;}
    
    
	//............................................................................
	// Obtain the mixer unit instance from its corresponding node.
	
    result =    AUGraphNodeInfo (
								 processingGraph,
								 mixerNode,
								 NULL,
								 &mixerUnit
								 );
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphNodeInfo" withStatus: result]; return;}
    
	
	//............................................................................
	// Multichannel Mixer unit Setup
	
    UInt32 busCount   = 6;    // bus count for mixer unit input
	
    UInt32 track1Bus  = 0;    // will take the track 1 sound
    UInt32 track2Bus  = 1;    // will take the track 2 sound
    UInt32 track3Bus  = 2;    // will take the track 3 sound
	UInt32 track4Bus  = 3;    // will take the track 4 sound
	UInt32 track5Bus  = 4;    // will take the track 5 sound
	UInt32 track6Bus  = 5;    // will take the track 6 sound
	
    NSLog (@"Setting mixer unit input bus count to: %u", busCount);
    result = AudioUnitSetProperty (
								   mixerUnit,
								   kAudioUnitProperty_ElementCount,
								   kAudioUnitScope_Input,
								   0,
								   &busCount,
								   sizeof (busCount)
								   );
	
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit bus count)" withStatus: result]; return;}
	
	
    NSLog (@"Setting kAudioUnitProperty_MaximumFramesPerSlice for mixer unit global scope");
    // Increase the maximum frames per slice allows the mixer unit to accommodate the
    //    larger slice size used when the screen is locked.
    UInt32 maximumFramesPerSlice = 4096;
    
    result = AudioUnitSetProperty (
								   mixerUnit,
								   kAudioUnitProperty_MaximumFramesPerSlice,
								   kAudioUnitScope_Global,
								   0,
								   &maximumFramesPerSlice,
								   sizeof (maximumFramesPerSlice)
								   );
	
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit input stream format)" withStatus: result]; return;}
	
	
    // Attach the input render callback and context to each input bus
    for (UInt16 busNumber = 0; busNumber < busCount; ++busNumber) {
		
        // Setup the struture that contains the input render callback 
        AURenderCallbackStruct inputCallbackStruct;
        inputCallbackStruct.inputProc        = &inputRenderCallback;
        inputCallbackStruct.inputProcRefCon  = soundStructArray;
        
        NSLog (@"Registering the render callback with mixer unit input bus %u", busNumber);
        // Set a callback for the specified node's specified input
        result = AUGraphSetNodeInputCallback (
											  processingGraph,
											  mixerNode,
											  busNumber,
											  &inputCallbackStruct
											  );
		
        if (noErr != result) {[self printErrorMessage: @"AUGraphSetNodeInputCallback" withStatus: result]; return;}
    }
	
	/* Since I am importing all stereo tracks I set them up here for stereo stream format 
	 These I've included mono functionality in the program if a user would like to import
	 mono audio files, the only adjustment that would have to be made is to change the track
	 audio unit set property to &monoStreamFormat rather than &stereoStreamFormat. */
	
	//Track 1
    NSLog (@"Setting stereo stream format for mixer unit \"Track 1\" input bus");
    result = AudioUnitSetProperty (
								   mixerUnit,
								   kAudioUnitProperty_StreamFormat,
								   kAudioUnitScope_Input,
								   track1Bus,
								   &stereoStreamFormat,
								   sizeof (stereoStreamFormat)
								   );
	
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit track 1 input bus stream format)" withStatus: result];return;}
    
	//Track 2
    NSLog (@"Setting stereo stream format for mixer unit \"track 2\" input bus");
    result = AudioUnitSetProperty (
								   mixerUnit,
								   kAudioUnitProperty_StreamFormat,
								   kAudioUnitScope_Input,
								   track2Bus,
								   &stereoStreamFormat,
								   sizeof (stereoStreamFormat)
								   );
	
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit track 2 input bus stream format)" withStatus: result];return;}
	
	//Track 3
	NSLog (@"Setting stereo stream format for mixer unit \"track 3\" input bus");
    result = AudioUnitSetProperty (
								   mixerUnit,
								   kAudioUnitProperty_StreamFormat,
								   kAudioUnitScope_Input,
								   track3Bus,
								   &stereoStreamFormat,
								   sizeof (stereoStreamFormat)
								   );
	
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit track 3 input bus stream format)" withStatus: result];return;} 
	
	//Track 4
	NSLog (@"Setting stereo stream format for mixer unit \"track 4\" input bus");
    result = AudioUnitSetProperty (
								   mixerUnit,
								   kAudioUnitProperty_StreamFormat,
								   kAudioUnitScope_Input,
								   track4Bus,
								   &stereoStreamFormat,
								   sizeof (stereoStreamFormat)
								   );
	
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit track 4 input bus stream format)" withStatus: result];return;} 

	//Track 5
	NSLog (@"Setting stereo stream format for mixer unit \"track 5\" input bus");
    result = AudioUnitSetProperty (
								   mixerUnit,
								   kAudioUnitProperty_StreamFormat,
								   kAudioUnitScope_Input,
								   track5Bus,
								   &stereoStreamFormat,
								   sizeof (stereoStreamFormat)
								   );
	
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit track 5 input bus stream format)" withStatus: result];return;} 

	//Track 6 
	NSLog (@"Setting stereo stream format for mixer unit \"track 6\" input bus");
    result = AudioUnitSetProperty (
								   mixerUnit,
								   kAudioUnitProperty_StreamFormat,
								   kAudioUnitScope_Input,
								   track6Bus,
								   &stereoStreamFormat,
								   sizeof (stereoStreamFormat)
								   );
	
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit track 6 input bus stream format)" withStatus: result];return;} 

	
	//...............................................................................
    NSLog (@"Setting sample rate for mixer unit output scope");
    // Set the mixer unit's output sample rate format. This is the only aspect of the output stream
    //    format that must be explicitly set.
    result = AudioUnitSetProperty (
								   mixerUnit,
								   kAudioUnitProperty_SampleRate,
								   kAudioUnitScope_Output,
								   0,
								   &graphSampleRate,
								   sizeof (graphSampleRate)
								   );
	
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit output stream format)" withStatus: result]; return;}
	
	
	//............................................................................
	// Connect the nodes of the audio processing graph
    NSLog (@"Connecting the mixer output to the input of the I/O unit output element");
	
    result = AUGraphConnectNodeInput (
									  processingGraph,
									  mixerNode,         // source node
									  0,                 // source node output bus number
									  iONode,            // destination node
									  0                  // desintation node input bus number
									  );
	
    if (noErr != result) {[self printErrorMessage: @"AUGraphConnectNodeInput" withStatus: result]; return;}
    
    
	//............................................................................
	// Initialize audio processing graph
	
    // Diagnostic code
    // Call CAShow if you want to look at the state of the audio processing 
    //    graph.
    NSLog (@"Audio processing graph state immediately before initializing it:");
    CAShow (processingGraph);
	
    NSLog (@"Initializing the audio processing graph");
    // Initialize the audio processing graph, configure audio data stream formats for
    //    each input and output, and validate the connections between audio units.
    result = AUGraphInitialize (processingGraph);
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphInitialize" withStatus: result]; return;}
}

/* PLAYBACK CONTROL */
#pragma mark -
#pragma mark Playback control
- (void) startAUGraph  {
	
    NSLog (@"Starting audio processing graph");
    OSStatus result = AUGraphStart (processingGraph);
    if (noErr != result) {[self printErrorMessage: @"AUGraphStart" withStatus: result]; return;}
	
    self.playing = YES;
}

/* STOP PLAYBACK */
- (void) stopAUGraph {
	
    NSLog (@"Stopping audio processing graph");
    Boolean isRunning = false;
    OSStatus result = AUGraphIsRunning (processingGraph, &isRunning);
    if (noErr != result) {[self printErrorMessage: @"AUGraphIsRunning" withStatus: result]; return;}
    
    if (isRunning) {
		
        result = AUGraphStop (processingGraph);
        if (noErr != result) {[self printErrorMessage: @"AUGraphStop" withStatus: result]; return;}
        self.playing = NO;
    }
}


#pragma mark -
#pragma mark Mixer unit control
// Enable or disable a specified bus
- (void) enableMixerInput: (UInt32) inputBus isOn: (AudioUnitParameterValue) isOnValue {
	
    NSLog (@"Bus %d now %@", (int) inputBus, isOnValue ? @"on" : @"off");
	
    OSStatus result = AudioUnitSetParameter (
											 mixerUnit,
											 kMultiChannelMixerParam_Enable,
											 kAudioUnitScope_Input,
											 inputBus,
											 isOnValue,
											 0
											 );
	
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetParameter (enable the mixer unit)" withStatus: result]; return;}
    
	
    /* LOOP SYNCING */
    if (0 == inputBus && 1 == isOnValue) {
        soundStructArray[0].sampleNumber = soundStructArray[1].sampleNumber; //Sync the Primary tracks (Bus 0 and 1)
    }
    
    if (1 == inputBus && 1 == isOnValue) {
        soundStructArray[1].sampleNumber = soundStructArray[0].sampleNumber; //Sync the Primary tracks 
    }
	
	if (2 == inputBus && 1 == isOnValue) {
        soundStructArray[2].sampleNumber = soundStructArray[0].sampleNumber; //Sync to Bus 0 (The Primary Tracks)
    }
	
	if (3 == inputBus && 1 == isOnValue) {
        soundStructArray[3].sampleNumber = soundStructArray[2].sampleNumber; //Sync to the Bus 2 (The Drum Channel)
    }

	if (4 == inputBus && 1 == isOnValue) {
        soundStructArray[4].sampleNumber = soundStructArray[2].sampleNumber; //Sync ot the Drums
    }

	if (5 == inputBus && 1 == isOnValue) {
        soundStructArray[5].sampleNumber = soundStructArray[2].sampleNumber; //Sync to the Drums
    }

	
}  


// Set the mixer unit input volume for a specified bus
- (void) setMixerInput: (UInt32) inputBus gain: (AudioUnitParameterValue) newGain {
	
	/*
	 
	 The method does not ensure that sound loops will stay in sync if the 
	 user lowers the volume to zero. In order to prevent the input render
	 callback from being stopped, the view controller Nib file sets the 
	 minimum input level is 0.01 rather than zero so that the loops will
	 remain in sync 
	
	 The enableMixerInput:enabled: method in this class, however, does ensure that the 
	 loops stay in sync when a user disables and then reenables an input bus.
	 */
	
    OSStatus result = AudioUnitSetParameter (
											 mixerUnit,
											 kMultiChannelMixerParam_Volume,
											 kAudioUnitScope_Input,
											 inputBus,
											 newGain,
											 0
											 );
	
	
	
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetParameter (set mixer unit input volume)" withStatus: result]; return;}
    
}

//- (void)changeCrossFaderAmount:(float)inputBus volume: (AudioUnitParameterValue) newVolume {

	
	
	
/* Method for Panning Audio */ 
- (void) setMixerPan: (Float32) inputBus pan: (AudioUnitParameterValue) newPanningPosition {
					   
	OSStatus result =	AudioUnitSetParameter (
											   mixerUnit,
											   kMultiChannelMixerParam_Pan,
											   kAudioUnitScope_Input,
											   inputBus,
											   newPanningPosition,
											   0
											   );
	
	if (noErr != result) {[self printErrorMessage: @"AudioUnitSetParameter (set mixer unit panning position)" withStatus: result]; return;}


}



// Set the mxer unit output volume
- (void) setMixerOutputGain: (AudioUnitParameterValue) newGain {
	
    OSStatus result = AudioUnitSetParameter (
											 mixerUnit,
											 kMultiChannelMixerParam_Volume,
											 kAudioUnitScope_Output,
											 0,
											 newGain,
											 0
											 );
	
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetParameter (set mixer unit output volume)" withStatus: result]; return;}
    
}

/* RESPOND TO POTENTIAL PHONE INTERUPTIONS */
#pragma mark -
#pragma mark Audio Session Delegate Methods
// Respond to having been interrupted. This method sends a notification to the 
//    controller object, which in turn invokes the playOrStop: toggle method. The 
//    interruptedDuringPlayback flag lets the  endInterruptionWithFlags: method know 
//    whether playback was in progress at the time of the interruption.
- (void) beginInterruption {
	
    NSLog (@"Audio session was interrupted.");
    
    if (playing) {
		
        self.interruptedDuringPlayback = YES;
        
        NSString *MultiChannelMixerObjectPlaybackStateDidChangeNotification = @"MultiChannelMixerObjectPlaybackStateDidChangeNotification";
        [[NSNotificationCenter defaultCenter] postNotificationName: MultiChannelMixerObjectPlaybackStateDidChangeNotification object: self]; 
    }
}


// Respond to the end of an interruption. This method gets invoked, for example, 
//    after the user dismisses a clock alarm. 
- (void) endInterruptionWithFlags: (NSUInteger) flags {
	
    // Test if the interruption that has just ended was one from which this app 
    //    should resume playback.
    if (flags & AVAudioSessionInterruptionFlags_ShouldResume) {
		
        NSError *endInterruptionError = nil;
        [[AVAudioSession sharedInstance] setActive: YES
                                             error: &endInterruptionError];
        if (endInterruptionError != nil) {
			
            NSLog (@"Unable to reactivate the audio session after the interruption ended.");
            return;
            
        } else {
			
            NSLog (@"Audio session reactivated after interruption.");
            
            if (interruptedDuringPlayback) {
				
                self.interruptedDuringPlayback = NO;
				
                // Resume playback by sending a notification to the controller object, which
                //    in turn invokes the playOrStop: toggle method.
                NSString *MultiChannelMixerObjectPlaybackStateDidChangeNotification = @"MultiChannelMixerObjectPlaybackStateDidChangeNotification";
                [[NSNotificationCenter defaultCenter] postNotificationName: MultiChannelMixerObjectPlaybackStateDidChangeNotification object: self]; 
				
            }
        }
    }
}

/* 
 AUDIO STREAM INFORMATION FOR DEBUGGING 
 
 All of these logs are viewable in the Console window which can be accessed 
 using the keys command-shift-r while in Xcode. It can also be accessed in the 
 Run Menu. If the program crashes we can get clues of what went wrong from here.
*/


#pragma mark -
#pragma mark Utility methods
// You can use this method during development and debugging to look at the
//    fields of an AudioStreamBasicDescription struct.
- (void) printASBD: (AudioStreamBasicDescription) asbd {
	
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10X",    asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10d",    asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10d",    asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10d",    asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10d",    asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10d",    asbd.mBitsPerChannel);
}


- (void) printErrorMessage: (NSString *) errorString withStatus: (OSStatus) result {
	
    char resultString[5];
    UInt32 swappedResult = CFSwapInt32HostToBig (result);
    bcopy (&swappedResult, resultString, 4);
    resultString[4] = '\0';
	
    NSLog (
		   @"*** %@ error: %d %08X %4.4s\n",
		   errorString,
		   (char*) &resultString
		   );
}

/* Deallocate Memory */ 
#pragma mark -
#pragma mark Deallocate
- (void) dealloc {
	
    for (int audioFile = 0; audioFile < NUM_FILES; ++audioFile)  {    
		
        if (sourceURLArray[audioFile] != NULL) CFRelease (sourceURLArray[audioFile]);
		
        if (soundStructArray[audioFile].audioDataLeft != NULL) {
            free (soundStructArray[audioFile].audioDataLeft);
            soundStructArray[audioFile].audioDataLeft = 0;
        }
		
        if (soundStructArray[audioFile].audioDataRight != NULL) {
            free (soundStructArray[audioFile].audioDataRight);
            soundStructArray[audioFile].audioDataRight = 0;
        }
    }
    
    [super dealloc];
}


@end //end of mixer implementation
