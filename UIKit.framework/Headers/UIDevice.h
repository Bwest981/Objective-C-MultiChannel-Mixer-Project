//
//  UIDevice.h
//  UIKit
//
//  Copyright 2007-2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

typedef enum {
    UIDeviceOrientationUnknown,
    UIDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
    UIDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
    UIDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
    UIDeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
    UIDeviceOrientationFaceUp,              // Device oriented flat, face up
    UIDeviceOrientationFaceDown             // Device oriented flat, face down
} UIDeviceOrientation;

typedef enum {
    UIDeviceBatteryStateUnknown,
    UIDeviceBatteryStateUnplugged,   // on battery, discharging
    UIDeviceBatteryStateCharging,    // plugged in, less than 100%
    UIDeviceBatteryStateFull,        // plugged in, at 100%
} UIDeviceBatteryState;              // available in iPhone 3.0

typedef enum {
#if __IPHONE_3_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    UIUserInterfaceIdiomPhone,           // iPhone and iPod touch style UI
    UIUserInterfaceIdiomPad,             // iPad style UI
#endif
} UIUserInterfaceIdiom;

#define UI_USER_INTERFACE_IDIOM() ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ? [[UIDevice currentDevice] userInterfaceIdiom] : UIUserInterfaceIdiomPhone)

#define UIDeviceOrientationIsPortrait(orientation)  ((orientation) == UIDeviceOrientationPortrait || (orientation) == UIDeviceOrientationPortraitUpsideDown)
#define UIDeviceOrientationIsLandscape(orientation) ((orientation) == UIDeviceOrientationLandscapeLeft || (orientation) == UIDeviceOrientationLandscapeRight)

UIKIT_EXTERN_CLASS @interface UIDevice : NSObject {
 @private
    NSInteger _numDeviceOrientationObservers;
    float     _batteryLevel;
    struct {
	unsigned int batteryMonitoringEnabled:1;
	unsigned int proximityMonitoringEnabled:1;
        unsigned int orientation:3;
        unsigned int batteryState:2;
        unsigned int proximityState:1;
    } _deviceFlags;
}

+ (UIDevice *)currentDevice;

@property(nonatomic,readonly,retain) NSString    *name;              // e.g. "My iPhone"
@property(nonatomic,readonly,retain) NSString    *model;             // e.g. @"iPhone", @"iPod Touch"
@property(nonatomic,readonly,retain) NSString    *localizedModel;    // localized version of model
@property(nonatomic,readonly,retain) NSString    *systemName;        // e.g. @"iPhone OS"
@property(nonatomic,readonly,retain) NSString    *systemVersion;     // e.g. @"2.0"
@property(nonatomic,readonly) UIDeviceOrientation orientation;       // return current device orientation
@property(nonatomic,readonly,retain) NSString    *uniqueIdentifier;  // a string unique to each device based on various hardware info.

@property(nonatomic,readonly,getter=isGeneratingDeviceOrientationNotifications) BOOL generatesDeviceOrientationNotifications;
- (void)beginGeneratingDeviceOrientationNotifications;      // nestable
- (void)endGeneratingDeviceOrientationNotifications;

@property(nonatomic,getter=isBatteryMonitoringEnabled) BOOL batteryMonitoringEnabled __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);  // default is NO
@property(nonatomic,readonly) UIDeviceBatteryState          batteryState __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);  // UIDeviceBatteryStateUnknown if monitoring disabled
@property(nonatomic,readonly) float                         batteryLevel __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);  // 0 .. 1.0. -1.0 if UIDeviceBatteryStateUnknown

@property(nonatomic,getter=isProximityMonitoringEnabled) BOOL proximityMonitoringEnabled __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0); // default is NO
@property(nonatomic,readonly)                            BOOL proximityState __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);  // always returns NO if no proximity detector

@property(nonatomic,readonly,getter=isMultitaskingSupported) BOOL multitaskingSupported __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

@property(nonatomic,readonly) UIUserInterfaceIdiom userInterfaceIdiom __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_2);

@end

UIKIT_EXTERN NSString *const UIDeviceOrientationDidChangeNotification;
UIKIT_EXTERN NSString *const UIDeviceBatteryStateDidChangeNotification   __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
UIKIT_EXTERN NSString *const UIDeviceBatteryLevelDidChangeNotification   __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
UIKIT_EXTERN NSString *const UIDeviceProximityStateDidChangeNotification __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);

