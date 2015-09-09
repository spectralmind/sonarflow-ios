#import <Foundation/Foundation.h>

#import "SFTestMediaItem.h"
#import "SFRootItem.h"

@class SFTestMediaLibrary;

@interface SFTestRootMediaItem : SFTestMediaItem <SFRootItem>

@property (nonatomic, weak) SFTestMediaLibrary *library;
@property (nonatomic, readwrite, assign) CGPoint origin;


@end
