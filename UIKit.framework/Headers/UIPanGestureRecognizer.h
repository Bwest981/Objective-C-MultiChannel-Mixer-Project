//
//  UIPanGestureRecognizer.h
//  UIKit
//
//  Copyright 2008-2010 Apple Inc. All rights reserved.
//

#if __IPHONE_3_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIGestureRecognizer.h>

// Begins:  when at least minimumNumberOfTouches have moved enough to be considered a pan
// Changes: when a finger moves while at least minimumNumberOfTouches are down
// Ends:    when all fingers have lifted

UIKIT_EXTERN_CLASS @interface UIPanGestureRecognizer : UIGestureRecognizer {
  @package
    CGPoint           _firstScreenLocation;
    CGPoint           _lastScreenLocation;
    NSTimeInterval    _firstTouchTime;
    NSTimeInterval    _lastTouchTime;
    CGPoint           _velocity;
    CGPoint           _previousVelocity;
    CGAffineTransform _transform;
    NSMutableArray   *_touches;
    NSUInteger        _lastTouchCount;
    NSUInteger        _minTouchCount;
    NSUInteger        _maxTouchCount;
    CGFloat           _hysteresis;
    unsigned int      _directionalLockEnabled:1;
    unsigned int      _lockVertical:1;
    unsigned int      _lockHorizontal:1;
    unsigned int      _wasLockedVertical:1;
    unsigned int      _wasLockedHorizontal:1;
    unsigned int      _scrollViewGesture:1;
    unsigned int      _hasChildScrollView:1;
    unsigned int      _hasParentScrollView:1;
    unsigned int      _failsPastMaxTouches:1;
}

@property (nonatomic)          NSUInteger minimumNumberOfTouches;   // default is 1. the minimum number of touches required to match
@property (nonatomic)          NSUInteger maximumNumberOfTouches;   // default is UINT_MAX. the maximum number of touches that can be down

- (CGPoint)translationInView:(UIView *)view;                        // translation in the coordinate system of the specified view
- (void)setTranslation:(CGPoint)translation inView:(UIView *)view;

- (CGPoint)velocityInView:(UIView *)view;                           // velocity of the pan in pixels/second in the coordinate system of the specified view

@end

#endif
