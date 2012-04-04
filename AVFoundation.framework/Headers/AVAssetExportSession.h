/*
	File:  AVAssetExportSession.h

	Framework:  AVFoundation
 
	Copyright 2010 Apple Inc. All rights reserved.

*/


#import <AVFoundation/AVBase.h>
#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>
#import <CoreMedia/CMTimeRange.h>

// for CGSize
#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#else // ! TARGET_OS_IPHONE
#import <ApplicationServices/../Frameworks/CoreGraphics.framework/Headers/CoreGraphics.h>
#endif // ! TARGET_OS_IPHONE

/*!
    @class AVAssetExportSession

    @abstract An AVAssetExportSession object transcodes the contents of an AVAsset source to create an output in the form described by a specified export preset.
*/

// -- Export Preset Names --


#if TARGET_OS_IPHONE
/* These export options can be used to produce QuickTime .mov files with video size appropriate to the device.
	The export will not scale the video up from a smaller size. The video will be compressed using
	H.264 and the audio will be compressed using AAC.  */
extern NSString *const AVAssetExportPresetLowQuality        __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);
extern NSString *const AVAssetExportPresetMediumQuality     __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);
extern NSString *const AVAssetExportPresetHighestQuality    __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);
#endif // TARGET_OS_IPHONE

/* These export options can be used to produce QuickTime .mov files with the specified video size.
	The export will not scale the video up from a smaller size. The video will be compressed using
	H.264 and the audio will be compressed using AAC.  Some devices cannot support some sizes. */
extern NSString *const AVAssetExportPreset640x480   __OSX_AVAILABLE_STARTING(__MAC_10_7,__IPHONE_4_0);
extern NSString *const AVAssetExportPreset960x540   __OSX_AVAILABLE_STARTING(__MAC_10_7,__IPHONE_4_0);
extern NSString *const AVAssetExportPreset1280x720  __OSX_AVAILABLE_STARTING(__MAC_10_7,__IPHONE_4_0);

/*  This export option will produce an audio-only .m4a file with appropriate iTunes gapless playback data */
extern NSString *const AVAssetExportPresetAppleM4A	__OSX_AVAILABLE_STARTING(__MAC_10_7,__IPHONE_4_0);

/* This export option will let all tracks passed through unless it is not possible. This option
	will not show up in the -allExportPresets and -exportPresetsCompatibleWithAsset methods. */
extern NSString *const AVAssetExportPresetPassthrough __OSX_AVAILABLE_STARTING(__MAC_10_7,__IPHONE_4_0);


@class AVAsset;
@class AVAssetExportSessionInternal;
@class AVAudioMix;
@class AVVideoComposition;

enum {
	AVAssetExportSessionStatusUnknown,
    AVAssetExportSessionStatusWaiting,
    AVAssetExportSessionStatusExporting,
    AVAssetExportSessionStatusCompleted,
    AVAssetExportSessionStatusFailed,
    AVAssetExportSessionStatusCancelled
};
typedef NSInteger AVAssetExportSessionStatus;

@interface AVAssetExportSession : NSObject
{
@private
	AVAssetExportSessionInternal  *_exportSession;
}

/*!
	@method						allExportPresets
	@abstract					Returns all available export preset names.
	@discussion					Returns an array of NSStrings with the names of all available presets. Note that not all presets are 
								compatible with all AVAssets.
	@result						An NSArray containing an NSString for each of the available preset names.
*/
+ (NSArray *)allExportPresets;

/*!
	@method						exportPresetsCompatibleWithAsset:
	@abstract					Returns only the identifiers compatible with the given AVAsset object.
	@discussion					Not all export presets are compatible with all AVAssets. For example an video only asset is not compatible with an audio only preset.
								This method returns only the identifiers for presets that will be compatible with the given asset. 
								A client should pass in an AVAsset that is ready to be exported.
								In order to ensure that the setup and running of an export operation will succeed using a given preset no significant changes 
								(such as adding or deleting tracks) should be made to the asset between retrieving compatible identifiers and performing the export operation.
	@param asset				An AVAsset object that is intended to be exported.
	@result						An NSArray containing NSString values for the identifiers of compatible export types.  
								The array is a complete list of the valid identifiers that can be used as arguments to 
								initWithAsset:presetName:outputURL: with the specified asset.
*/
+ (NSArray *)exportPresetsCompatibleWithAsset:(AVAsset *)asset;


/*!
	@method						initWithAsset:presetName:outputURL:
	@abstract					Initialize an AVAssetExportSession with the specified preset and set the source to the contents of the asset.
	@param		asset			An AVAsset object that is intended to be exported.
	@param		presetName		An NSString specifying the name of the preset template for the export.
	@result						Returns the initialized AVAssetExportSession.
*/
- (id)initWithAsset:(AVAsset *)asset presetName:(NSString *)presetName;


/* These properties are key-value observable unless documented otherwise */

/* Indicates the name of the preset with which the AVExportSession was initialized */
@property (nonatomic, readonly) NSString *presetName;

/* Indicates the types of files the target can write, using the AVAsset and export preset with which it was initialized */
@property (nonatomic, readonly) NSArray *supportedFileTypes;

/* Indicates the type of file to be written by the session; it must be set */
@property (nonatomic, copy) NSString *outputFileType;

/* Indicates the URL of the export session's output */
@property (nonatomic, copy) NSURL *outputURL;

/* indicates the status of the export session */
@property (nonatomic, readonly) AVAssetExportSessionStatus status;

/* describes the error that occured if the export status is AVAssetExportSessionStatusFailed */
@property (nonatomic, readonly) NSError *error;

/* Specifies the progress of the export on a scale from 0 to 1.0.  A value of 0 means the export has not yet begun, A value of 1.0 means the export is complete. This property is not key-value observable. */
@property (nonatomic, readonly) float progress;

/* indicates the maximum duration that is allowed for export */
@property (nonatomic, readonly) CMTime maxDuration;

/* specifies a time range to be exported from the source; the default timeRange of an export session is kCMTimeZero..kCMTimePositiveInfinity, meaning that, pending a possible limit on file length, the full duration of the asset will be exported */
@property (nonatomic) CMTimeRange timeRange;

/* Specifies an NSArray of AVMetadataItems that are to be written to the output file by the export session.
   If the value of this key is nil, any existing metadata in the exported asset will be translated as accurately as possible into
   the appropriate metadata keyspace for the output file and written to the output. */
@property (nonatomic, copy) NSArray *metadata; 

/* Indicates the maximum number of bytes that the session is allowed to write to the output URL. The export will stop when the output reaches this size regardless of the duration of the source or the value of the timeRange property. */
@property (nonatomic) long long fileLengthLimit; 

/* indicates whether non-default audio mixing is enabled for export and supplies the parameters for audio mixing */
@property (nonatomic, copy) AVAudioMix *audioMix;

/* indicates whether video composition is enabled for export and supplies the instructions for video composition */
@property (nonatomic, copy) AVVideoComposition *videoComposition;

/* indicates the movie should be optimized for network use */
@property (nonatomic) BOOL shouldOptimizeForNetworkUse;

/*!
	@method						exportAsynchronouslyWithCompletionHandler:
	@abstract					Starts the asynchronous execution of an export session.
	@param						handler
								If internal preparation for export fails, the handler will be invoked synchronously.
								The handler may also be called asynchronously after -exportAsynchronouslyWithCompletionHandler: returns,
								in the following cases: 
								1) if a failure occurs during the export, including failures of loading, re-encoding, or writing media data to the output,
								2) if -cancelExport is invoked, 
								3) if export session succeeds, having completely written its output to the outputURL. 
								In each case, AVAssetExportSession.status will signal the terminal state of the asset reader, and if a failure occurs, the NSError 
								that describes the failure can be obtained from the error property.
	@discussion					Initiates an asynchronous export operation and returns immediately.
*/
- (void)exportAsynchronouslyWithCompletionHandler:(void (^)(void))handler;

/*!
	@method						cancelExport
	@abstract					Cancels the execution of an export session.
	@discussion					Cancel can be invoked when the export is running.
*/
- (void)cancelExport;

@end
