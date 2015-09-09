#import "SFNativeMediaItem.h"
#import "SFAudioTrack.h"

@class MPMediaItem;

@protocol SFNativeTrack <SFNativeMediaItem, SFAudioTrack>

- (NSNumber *)mediaItemId;
- (MPMediaItem *)mediaItem;

@end
