#import <Foundation/Foundation.h>

#import "SFMediaLibrary.h"

@class SFTestRootMediaItem;

@interface SFTestMediaLibrary : NSObject <SFMediaLibrary>

- (SFTestRootMediaItem *)addMediaItemWithKey:(id)aKey;
- (void)addMediaItem:(id<SFMediaItem>)mediaItem;
- (void)removeMediaItem:(id<SFMediaItem>)mediaItem;

- (NSUInteger)size;

@end
