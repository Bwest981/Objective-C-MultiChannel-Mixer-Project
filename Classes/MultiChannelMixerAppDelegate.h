//
//  MultiChannelMixerAppDelegate.h
//  MultiChannelMixer
//
//  Created by Alexander Attar on 12/7/11.
//

#import <UIKit/UIKit.h>

@class MultiChannelMixerViewController;

@interface MultiChannelMixerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MultiChannelMixerViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MultiChannelMixerViewController *viewController;

@end

