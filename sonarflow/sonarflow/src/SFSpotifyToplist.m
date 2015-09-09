#import "SFSpotifyToplist.h"

#import "MediaViewControllerFactory.h"
#import "SFMediaItem.h"
#import "SFSpotifyChildrenFactory.h"
#import "SFSpotifyPlayer.h"
#import "SFSpotifyTrack.h"
#import "SPAlbum.h"
#import "SPSession.h"
#import "SPToplist.h"
#import "SPTrack.h"


@implementation SFSpotifyToplist {
	CGPoint origin;
}

@synthesize bubbleColor;
@synthesize origin;

- (id)initWithName:(NSString *)theName origin:(CGPoint)theOrigin color:(UIColor *)theColor key:(id)theKey spotifyPlayer:(SFSpotifyPlayer *)theSpotifyPlayer {
    self = [super initWithName:theName key:theKey player:theSpotifyPlayer];
    if (self) {
		origin = theOrigin;
		bubbleColor = theColor;
    }
	
    return self;
}

- (NSArray *)keyPath {
	return [NSArray arrayWithObject:self.key];
}

- (CGFloat)relativeSize {
	return 0.6;
}

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
	return [factory viewControllerForPlaylist:[self tracksProxy]];
}

- (NSString *)artistNameForDiscovery {
	if([[self.player.nowPlayingLeaf keyPath] objectAtIndex:0] == self.key) {
		NSAssert([self.player.nowPlayingLeaf conformsToProtocol:@protocol(SFDiscoverableItem)], @"Child is not discoverable");
		return [(id<SFDiscoverableItem>)self.player.nowPlayingLeaf artistNameForDiscovery];
	}
	
	return [super artistNameForDiscovery];
}

@end
