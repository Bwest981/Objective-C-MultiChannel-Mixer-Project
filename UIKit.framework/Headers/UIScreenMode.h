//
//  UIScreenMode.h
//  UIKit
//
//  Copyright 2009-2010 Apple Inc. All rights reserved.
//

#if __IPHONE_3_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>
#import <CoreGraphics/CoreGraphics.h>

UIKIT_EXTERN_CLASS @interface UIScreenMode : NSObject {
  @private
    id _mode;
}

@property(readonly,nonatomic) CGSize  size;             // The width and height in pixels
@property(readonly,nonatomic) CGFloat pixelAspectRatio; // The aspect ratio of a single pixel. The ratio is defined as X/Y.

@end

#endif
