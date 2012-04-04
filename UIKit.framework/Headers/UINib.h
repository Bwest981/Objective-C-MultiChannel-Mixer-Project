//
//  UINib.h
//  UIKit
//
//  Copyright 2008-2010 Apple Inc. All rights reserved.
//

#if __IPHONE_4_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

UIKIT_EXTERN_CLASS @interface UINib : NSObject {
  @private
    id storage;
}

// If the bundle parameter is nil, the main bundle is used.
// Releases resources in response to memory pressure (e.g. memory warning), reloading from the bundle when necessary.
+ (UINib *)nibWithNibName:(NSString *)name bundle:(NSBundle *)bundleOrNil;

// If the bundle parameter is nil, the main bundle is used.
+ (UINib *)nibWithData:(NSData *)data bundle:(NSBundle *)bundleOrNil;

// Returns an array containing the top-level objects from the NIB.
// The owner and options parameters may both be nil.
// If the owner parameter is nil, connections to File's Owner are not permitted.
// Options are identical to the options specified with -[NSBundle loadNibNamed:owner:options:]
- (NSArray *)instantiateWithOwner:(id)ownerOrNil options:(NSDictionary *)optionsOrNil;
@end

#endif
