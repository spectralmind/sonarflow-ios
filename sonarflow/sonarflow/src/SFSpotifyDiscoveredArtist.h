#import "SFAbstractDiscoveredArtist.h"

@class SFSpotifySearchFactory;
@class SFSpotifyPlayer;

@interface SFSpotifyDiscoveredArtist : SFAbstractDiscoveredArtist

-(id)initWithKey:(RootKey *)theKey name:(NSString *)theName searchFactory:(SFSpotifySearchFactory *)theSearchFactory player:(SFSpotifyPlayer *)thePlayer;

@end
