#import "SFSpotifyBridge.h"

@class SFSpotifyChildrenFactory;
@class SFSpotifyPlayer;
@class SPPlaylist;

@interface SFSpotifyPlaylistBridge : SFSpotifyBridge
- (id)initWithName:(NSString *)theName key:(id)theKey color:(UIColor *)theColor player:(SFSpotifyPlayer *)thePlayer playlist:(SPPlaylist *)thePlaylist origin:(CGPoint)theOrigin factory:(SFSpotifyChildrenFactory *)theChildrenFactory;

@end
