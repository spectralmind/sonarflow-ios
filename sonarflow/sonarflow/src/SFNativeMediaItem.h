#import "SFMediaItem.h"

@protocol SFNativeMediaItem <SFMediaItem>

- (NSComparisonResult)compareKeys:(id<SFMediaItem>)other;
- (NSUInteger)numTracks;
- (NSArray *)tracks; //Returns array of NSObject<SFTrack>

@end
