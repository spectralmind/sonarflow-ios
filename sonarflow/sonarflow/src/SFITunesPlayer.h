#import "SFAbstractMediaPlayer.h"

@protocol SFITunesMediaItem;

@interface SFITunesPlayer : SFAbstractMediaPlayer

- (void)play:(id<SFITunesMediaItem>)mediaItem;
- (void)play:(id<SFITunesMediaItem>)mediaItem startingAtIndex:(NSUInteger)index;

@end
