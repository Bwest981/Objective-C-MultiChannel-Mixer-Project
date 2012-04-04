//
//  UIScreen.h
//  UIKit
//
//  Copyright 2007-2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKitDefines.h>

@class UIScreenMode, CADisplayLink;

UIKIT_EXTERN NSString *const UIScreenDidConnectNotification;    // object is the UIScreen that represents the new screen. connection notifications are not sent for screens present when the application is first launched
UIKIT_EXTERN NSString *const UIScreenDidDisconnectNotification; // object is the UIScreen that represented the disconnected screen

UIKIT_EXTERN NSString *const UIScreenModeDidChangeNotification; // object is the UIScreen. [object currentMode] is the new UIScreenMode

UIKIT_EXTERN_CLASS @interface UIScreen : NSObject {
  @private
    id _display;
    CGRect _bounds;
    CGFloat _scale;
    CGFloat _horizontalScale;
    struct {
        unsigned int bitsPerComponent:4;
        unsigned int initialized:1;
        unsigned int connected:1;
    } _screenFlags;
}

+ (NSArray *)screens __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_2);          // all screens currently attached to the device
+ (UIScreen *)mainScreen;      // the device's internal screen

@property(nonatomic,readonly) CGRect  bounds;                // Bounds of entire screen in points
@property(nonatomic,readonly) CGRect  applicationFrame;      // Frame of application screen area in points (i.e. entire screen minus status bar if visible)
@property(nonatomic,readonly) CGFloat scale __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

@property(nonatomic,readonly,copy) NSArray *availableModes __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_2); // The list of modes that this screen supports
@property(nonatomic,retain) UIScreenMode *currentMode __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_2);      // Current mode of this screen

- (CADisplayLink *)displayLinkWithTarget:(id)target selector:(SEL)sel __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

@end
