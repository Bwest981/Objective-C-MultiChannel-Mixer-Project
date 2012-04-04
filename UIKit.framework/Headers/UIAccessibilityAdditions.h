//
//  UIAccessibilityAdditions.h
//  UIKit
//
//  Copyright 2009-2010 Apple Inc. All rights reserved.
//

#if __IPHONE_4_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIPickerView.h>

/* 
  Optionally implement the following methods in a UIPickerView delegate
  in order to provide accessibility information per component. 
  See UIAccessibility.h for more information about hints and labels.
*/
@protocol UIPickerViewAccessibilityDelegate <UIPickerViewDelegate>

@optional
- (NSString *)pickerView:(UIPickerView *)pickerView accessibilityLabelForComponent:(NSInteger)component;
- (NSString *)pickerView:(UIPickerView *)pickerView accessibilityHintForComponent:(NSInteger)component;

@end

#endif

