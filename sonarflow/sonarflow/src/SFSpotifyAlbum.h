#import "SFSpotifyMediaGroup.h"

@class SPAlbum;

@interface SFSpotifyAlbum : SFSpotifyMediaGroup

-(id)initWitAlbum:(SPAlbum *)theAlbum key:(id)theKey player:(SFSpotifyPlayer *)thePlayer;

@end
