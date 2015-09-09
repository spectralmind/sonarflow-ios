#import "SFSpotifyMediaItem.h"

#import "SFPlaylist.h"

@interface SFSpotifyMediaItemTracksProxy : SFSpotifyMediaItem <SFPlaylist>

- (id)initWithMediaItem:(SFSpotifyMediaItem *)theMediaItem;

@end
