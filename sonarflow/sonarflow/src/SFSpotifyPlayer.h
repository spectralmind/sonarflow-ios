#import "SFAbstractMediaPlayer.h"

@protocol SFSpotifyMediaItem;
@class SPSession;
@class SFSpotifyFactory;

@interface SFSpotifyPlayer : SFAbstractMediaPlayer

- (id)initWithSession:(SPSession *)theSession factory:(SFSpotifyFactory *)theFactory;

- (void)play:(id<SFSpotifyMediaItem>)mediaItem;
- (void)play:(id<SFSpotifyMediaItem>)mediaItem startingAtIndex:(NSUInteger)index;
- (void)stop;

@end
