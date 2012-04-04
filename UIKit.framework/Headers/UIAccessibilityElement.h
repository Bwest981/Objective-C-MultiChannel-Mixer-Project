//
//  UIAccessibilityElement.h
//  UIAccessibility
//
//  Copyright 2008-2010 Apple Inc. All rights reserved.
//

#if __IPHONE_3_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIAccessibilityConstants.h>

/*
 UIAccessibilityElement
 
 Instances of this class can be used as "fake" accessibility elements.
 An accessibility container (see UIAccessibility.h) can create and vend instances
 of UIAccessibilityElement to cover for user interface items that are not
 backed by a UIView (for example: painted text or icon).
 */
UIKIT_EXTERN_CLASS @interface UIAccessibilityElement : NSObject
{
@private
    id _storage;
}

// initialize with the accessibility container that contains this element
- (id)initWithAccessibilityContainer:(id)container;

@property (nonatomic, assign) id accessibilityContainer;
@property (nonatomic, assign) BOOL isAccessibilityElement;
@property (nonatomic, retain) NSString *accessibilityLabel;
@property (nonatomic, retain) NSString *accessibilityHint;
@property (nonatomic, retain) NSString *accessibilityValue;
@property (nonatomic, assign) CGRect accessibilityFrame;
@property (nonatomic, assign) UIAccessibilityTraits accessibilityTraits;

@end

#endif
