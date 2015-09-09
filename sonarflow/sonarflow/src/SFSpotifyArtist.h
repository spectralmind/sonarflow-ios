#import "SFSpotifyMediaGroup.h"

@class SPArtist;
@class SFSpotifyPlayer;

@interface SFSpotifyArtist : SFSpotifyMediaGroup

-(id)initWithArtist:(SPArtist *)theArtist key:(id)theKey player:(SFSpotifyPlayer *)thePlayer;

@end
