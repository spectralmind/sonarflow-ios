#import <Foundation/Foundation.h>

#import "SFSpotifyMediaItem.h"
#import "SFAudioTrack.h"

@class SPTrack;
@class SFSpotifyPlayer;

@interface SFSpotifyTrack : SFSpotifyMediaItem <SFAudioTrack>

@property (nonatomic, readonly) SPTrack *spTrack;
@property (nonatomic, assign) BOOL starred;

- (id)initWithTrack:(SPTrack *)theTrack player:(SFSpotifyPlayer *)thePlayer;

@end
