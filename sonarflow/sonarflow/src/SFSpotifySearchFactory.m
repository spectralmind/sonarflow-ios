#import "SFSpotifySearchFactory.h"

#import "SPSession.h"
#import "SFSpotifyArtistSearch.h"
#import "SFSpotifyPlayer.h"

@implementation SFSpotifySearchFactory {
	SFSpotifyPlayer *player;
}

- (id)initWithPlayer:(SFSpotifyPlayer *)thePlayer {
    self = [super init];
    if (self) {
		player = thePlayer;
    }
    return self;
}

- (SFSpotifyArtistSearch *)searchForArtistName:(NSString *)name parentForChildren:(id<SFMediaItem>)parent {
	return [[SFSpotifyArtistSearch alloc] initWithArtistName:name session:[SPSession sharedSession] player:player parentForChildren:parent];
}

@end
