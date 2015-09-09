#import "SFSpotifyFactory.h"

#import "RootKey.h"
#import "SFSpotifyChildrenFactory.h"
#import "SFSpotifyPlayer.h"
#import "SFSpotifyPlaylistBridge.h"
#import "SFSpotifyToplistBridge.h"
#import "SFSpotifyTrack.h"
#import "SPPlaylist.h"
#import "SPSession.h"
#import "SPTrack.h"
#import "SPToplist.h"


@implementation SFSpotifyFactory {
}

- (id)init {
    self = [super init];
    if (self) {
		player = [[SFSpotifyPlayer alloc] initWithSession:[SPSession sharedSession] factory:self];
		childrenFactory = [[SFSpotifyChildrenFactory alloc] initWithFactory:self];
    }
    return self;
}

@synthesize player;
@synthesize childrenFactory;

- (SFSpotifyTrack *)trackForSPTrack:(SPTrack *)spTrack {
	if(spTrack.availability != SP_TRACK_AVAILABILITY_AVAILABLE) {
		return nil;
	}
	
	if([spTrack.name length] == 0) {
		NSLog(@"Found track without name: %@", spTrack);
		return nil;
	}
	
	return [[SFSpotifyTrack alloc] initWithTrack:spTrack player:player];
}

- (SFSpotifyPlaylistBridge *)playlistBridgeForSPPlaylist:(SPPlaylist *)spPlaylist withName:(NSString *)name origin:(CGPoint)origin color:(UIColor *)theColor {
	RootKey *key = [RootKey rootKeyWithKey:spPlaylist.spotifyURL type:BubbleTypeDefault];
	return [[SFSpotifyPlaylistBridge alloc] initWithName:name key:key color:theColor player:player playlist:spPlaylist origin:origin factory:childrenFactory];
}

- (SFSpotifyToplistBridge *)toplistBridge {
	RootKey *key = [RootKey rootKeyWithKey:@"toptracks" type:BubbleTypeDefault];
	UIColor *color = [UIColor colorWithRed:0.9294117647 green:0.3568627451 blue:0.1294117647 alpha:1.0];
	
	CGPoint origin = CGPointMake(0, 500);
	SPToplist *toplist = [SPToplist toplistForLocale:[NSLocale currentLocale] inSession:[SPSession sharedSession]];

	SFSpotifyToplistBridge *bridge = [[SFSpotifyToplistBridge alloc] initWithToplist:toplist name:@"Spotify Top Tracks" origin:origin color:color key:key spotifyPlayer:player factory:childrenFactory];
	
	return bridge;
}

- (SFSpotifyToplistBridge *)userToplistBridge {
	RootKey *key = [RootKey rootKeyWithKey:@"usertoptracks" type:BubbleTypeDefault];
	UIColor *color = [UIColor colorWithRed:0.5882352941 green:0.7764705882 blue:0.2352941176 alpha:1.0];
	
	CGPoint origin = CGPointMake(900, 500);
	SPToplist *toplist = [SPToplist toplistForCurrentUserInSession:[SPSession sharedSession]];
	
	SFSpotifyToplistBridge *sfToplistBridge = [[SFSpotifyToplistBridge alloc] initWithToplist:toplist name:@"My Top Tracks" origin:origin color:color key:key spotifyPlayer:player factory:childrenFactory];
	
	return sfToplistBridge;
}


@end
