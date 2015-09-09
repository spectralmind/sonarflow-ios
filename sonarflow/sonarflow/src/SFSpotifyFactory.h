#import <Foundation/Foundation.h>

@class SFSpotifyChildrenFactory;
@class SFSpotifyPlaylist;
@class SFSpotifyPlayer;
@class SFSpotifyPlaylistBridge;
@class SFSpotifyTrack;
@class SFSpotifyToplistBridge;
@class SPPlaylist;
@class SPTrack;

@interface SFSpotifyFactory : NSObject

@property (nonatomic, readonly) SFSpotifyPlayer *player;
@property (nonatomic, readonly) SFSpotifyChildrenFactory *childrenFactory;

- (SFSpotifyTrack *)trackForSPTrack:(SPTrack *)spTrack;
- (SFSpotifyPlaylistBridge *)playlistBridgeForSPPlaylist:(SPPlaylist *)spPlaylist withName:(NSString *)name origin:(CGPoint)origin color:(UIColor *)theColor;
- (SFSpotifyToplistBridge *)toplistBridge;
- (SFSpotifyToplistBridge *)userToplistBridge;

@end
