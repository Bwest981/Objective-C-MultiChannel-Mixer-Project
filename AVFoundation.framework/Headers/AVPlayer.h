/*
    File:  AVPlayer.h

	Framework:  AVFoundation
 
	Copyright 2010 Apple Inc. All rights reserved.

*/

/*!
	@class			AVPlayer
 
	@abstract		AVPlayer offers a playback interface for single- or multiple-item playback that's 
    				sufficient for the implementation of playback controllers and playback user interfaces.
    				The multiple item-case has support for automatically advancing from the playback of one item to the next
    				and also for advancing under the control of the client.
 
	@discussion		AVPlayer works equally well with local and remote media files, providing clients with appropriate
					information about readiness to play or about the need to await additional data before continuing.

					AVPlayer can be configured to display visual media to CoreAnimation layers or to vend images
					to clients for processing via AVImageProvider, or both simultaneously.

*/

#import <AVFoundation/AVBase.h>
#import <CoreMedia/CMTime.h>
#import <CoreMedia/CMTimeRange.h>
#import <Foundation/Foundation.h>

@class AVPlayerItem;
@class AVPlayerInternal;

/*!
 @enum AVPlayerStatus
 @abstract
	These constants are returned by the AVPlayer status property to indicate whether it can successfully play items.
 
 @constant	 AVPlayerStatusUnknown
	Indicates that the status of the player is not yet known because it has not tried to load new media resources for
	playback.
 @constant	 AVPlayerStatusReadyToPlay
	Indicates that the player is ready to play AVPlayerItem instances.
 @constant	 AVPlayerStatusFailed
	Indicates that the player can no longer play AVPlayerItem instances because of an error. The error is described by
	the value of the player's error property.
 */
enum {
	AVPlayerStatusUnknown,
	AVPlayerStatusReadyToPlay,
	AVPlayerStatusFailed
};
typedef NSInteger AVPlayerStatus;

enum
{
	AVPlayerActionAtItemEndPause = 1,
	AVPlayerActionAtItemEndNone
};
typedef NSInteger AVPlayerActionAtItemEnd;

@interface AVPlayer : NSObject 
{
@private
	AVPlayerInternal     *_player;
}

/*!
	@method			playerWithURL:
	@abstract		Returns an instance of AVPlayer that plays a single audiovisual resource referenced by URL.
	@param			URL
	@result			An instance of AVPlayer
	@discussion		Implicitly creates an AVPlayerItem. Clients can obtain the AVPlayerItem as it becomes the player's currentItem.
*/
+ (AVPlayer *)playerWithURL:(NSURL *)URL;

/*!
	@method			playerWithPlayerItem:
	@abstract		Create an AVPlayer that plays a single audiovisual item.
	@param			AVPlayerItem
	@result			An instance of AVPlayer
	@discussion		Useful in order to play items for which an AVAsset has previously been created. See -[AVPlayerItem initWithAsset:].
*/
+ (AVPlayer *)playerWithPlayerItem:(AVPlayerItem *)item;

/*!
	@method			initWithURL:
	@abstract		Initializes an AVPlayer that plays a single audiovisual resource referenced by URL.
	@param			URL
	@result			An instance of AVPlayer
	@discussion		Implicitly creates an AVPlayerItem. Clients can obtain the AVPlayerItem as it becomes the player's currentItem.
*/
- (id)initWithURL:(NSURL *)URL;

/*!
	@method			initWithPlayerItem:
	@abstract		Create an AVPlayer that plays a single audiovisual item.
	@param			item
	@result			An instance of AVPlayer
	@discussion		Useful in order to play items for which an AVAsset has previously been created. See -[AVPlayerItem initWithAsset:].
*/
- (id)initWithPlayerItem:(AVPlayerItem *)item;

/*!
 @property status
 @abstract
	The ability of the receiver to be used for playback.
 
 @discussion
	The value of this property is an AVPlayerStatus that indicates whether the receiver can be used for playback. When
	the value of this property is AVPlayerStatusFailed, the receiver can no longer be used for playback and a new
	instance needs to be created in its place. When this happens, clients can check the value of the error property to
	determine the nature of the failure. This property is key value observable.
 */
@property (nonatomic, readonly) AVPlayerStatus status;

/*!
 @property error
 @abstract
	If the receiver's status is AVPlayerStatusFailed, this describes the error that caused the failure.
 
 @discussion
	The value of this property is an NSError that describes what caused the receiver to no longer be able to play items.
	If the receiver's status is not AVPlayerItemStatusFailed, the value of this property is nil.
 */
@property (nonatomic, readonly) NSError *error;

/*!
 @method			currentTime
 @abstract			Returns the current time of the current item.
 @result			A CMTime
 @discussion		Returns the current time of the current item. Not key-value observable; use -addPeriodicTimeObserverForInterval:usingBlock: instead.
 */
- (CMTime)currentTime;

/*!
 @method			seekToTime:
 @abstract			Moves the playback cursor.
 @param				time
 @discussion		Use this method to seek to a specified time for the current player item.
					The time seeked to may differ from the specified time for efficiency. For sample accurate seeking see seekToTime:toleranceBefore:toleranceAfter:.
 */
- (void)seekToTime:(CMTime)time;

/*!
 @method			seekToTime:toleranceBefore:toleranceAfter:
 @abstract			Moves the playback cursor within a specified time bound.
 @param				time
 @param				toleranceBefore
 @param				toleranceAfter
 @discussion		Use this method to seek to a specified time for the current player item.
					The time seeked to will be within the range [time-beforeTolerance, time+afterTolerance] and may differ from the specified time for efficiency.
					Pass kCMTimeZero for both toleranceBefore and toleranceAfter to request sample accurate seeking which may incur additional decoding delay. 
					Messaging this method with beforeTolerance:kCMTimePositiveInfinity and afterTolerance:kCMTimePositiveInfinity is the same as messaging seekToTime: directly.
 */
- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter;


@property (nonatomic, readonly) AVPlayerItem *currentItem;

/* indicates the current rate of playback; 0.0 means "stopped", 1.0 means "play at the natural rate of the current item" */
@property (nonatomic) float rate;

@property (nonatomic) AVPlayerActionAtItemEnd actionAtItemEnd;

@property (nonatomic, getter=isClosedCaptionDisplayEnabled) BOOL closedCaptionDisplayEnabled;

@end

@interface AVPlayer (AVPlayerPlaybackControl)

// convenience methods for controlling playback; results are also achievable by setting properties

/*!
	@method			play
	@abstract		Begins playback of the current item.
	@discussion		Same as setting rate to 1.0.
*/
- (void)play;

/*!
	@method			pause
	@abstract		Pauses playback.
	@discussion		Same as setting rate to 0.0.
*/
- (void)pause;

/*!
	@method			replaceCurrentItemWithPlayerItem:
	@abstract		Replaces the player's current item with the specified player item.
	@discussion		For best results ensure that the tracks property of an AVPlayerItem's AVAsset, if there is one,
					has reached the status AVKeyValueStatusLoaded before attempting to replace the current item with it.
					See -[AVAsset loadValuesAsynchronouslyForKeys:completionHandler:].
*/
- (void)replaceCurrentItemWithPlayerItem:(AVPlayerItem *)item;

@end

@interface AVPlayer (AVPlayerTimeObservation)

/*!
	@method			addPeriodicTimeObserverForInterval:queue:usingBlock:
	@abstract		Requests invocation of a block during playback to report changing time.
	@param			interval
	  The interval of invocation of the block during normal playback, according to progress of the current time of the player.
	@param			queue
	  The serial queue onto which block should be enqueued.  If you pass NULL, the main queue (obtained using dispatch_get_main_queue()) will be used.  Passing a
	  concurrent queue to this method will result in undefined behavior.
	@param			block
	  The block to be invoked periodically.
	@result
	  An object conforming to the NSObject protocol.  You must retain this returned value as long as you want the time observer to be invoked by the player.
	  Pass this object to -removeTimeObserver: to cancel time observation.
	@discussion		The block is invoked periodically at the interval specified, interpreted according to the timeline of the current item.
					The block is also invoked whenever time jumps and whenever playback starts or stops.
					If the interval corresponds to a very short interval in real time, the player may invoke the block less frequently
					than requested. Even so, the player will invoke the block sufficiently often for the client to update indications
					of the current time appropriately in its end-user interface.
					Each call to -addPeriodicTimeObserverForInterval:queue:usingBlock: should be paired with a corresponding call to -removeTimeObserver:.
					Releasing the observer object without a call to -removeTimeObserver will result in undefined behavior.
*/
- (id)addPeriodicTimeObserverForInterval:(CMTime)interval queue:(dispatch_queue_t)queue usingBlock:(void (^)(CMTime time))block;

/*!
	@method			addBoundaryTimeObserverForTimes:queue:usingBlock:
	@abstract		Requests invocation of a block when specified times are traversed during normal playback.
	@param			times
	  The times for which the observer requests notification, supplied as an array of NSValues carrying CMTimes.
	@param			queue
	  The serial queue onto which block should be enqueued.  If you pass NULL, the main queue (obtained using dispatch_get_main_queue()) will be used.  Passing a
	  concurrent queue to this method will result in undefined behavior.
	@param			block
	  The block to be invoked when any of the specified times is crossed during normal playback.
	@result
	  An object conforming to the NSObject protocol.  You must retain this returned value as long as you want the time observer to be invoked by the player.
	  Pass this object to -removeTimeObserver: to cancel time observation.
	@discussion		Each call to -addPeriodicTimeObserverForInterval:queue:usingBlock: should be paired with a corresponding call to -removeTimeObserver:.
					Releasing the observer object without a call to -removeTimeObserver will result in undefined behavior.
*/
- (id)addBoundaryTimeObserverForTimes:(NSArray *)times queue:(dispatch_queue_t)queue usingBlock:(void (^)(void))block;

/*!
	@method			removeTimeObserver:
	@abstract		Cancels a previously registered time observer.
	@param			observer
	  An object returned by a previous call to -addPeriodicTimeObserverForInterval:queue:usingBlock: or -addBoundaryTimeObserverForTimes:queue:usingBlock:.
	@discussion		Upon return, the caller is guaranteed that no new time observer blocks will begin executing.  Depending on the calling thread and the queue
					used to add the time observer, an in-flight block may continue to execute after this method returns.  You can guarantee synchronous time 
					observer removal by enqueuing the call to -removeTimeObserver on that queue.  Alternatively, call dispatch_sync(queue, ^{}) after 
					-removeTimeObserver to wait for any in-flight blocks to finish executing.
					-removeTimeObserver should be used to explicitly cancel each time observer added using -addPeriodicTimeObserverForInterval:queue:usingBlock:
					and -addBoundaryTimeObserverForTimes:queue:usingBlock:.
*/
- (void)removeTimeObserver:(id)observer;

@end
