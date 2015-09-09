#import "SFSpotifyPlaylist.h"

#import "MediaViewControllerFactory.h"
#import "SFMediaItem.h"
#import "SFSpotifyPlayer.h"
#import "SFSpotifyTrack.h"
#import "SPArtist.h"
#import "SPAlbum.h"
#import "SPImage.h"
#import "SPPlaylist.h"
#import "SPPlaylistItem.h"
#import "SPSession.h"
#import "SPTrack.h"

@implementation SFSpotifyPlaylist  {
	CGPoint origin;
}

- (id)initWithName:(NSString *)theName key:(id)theKey color:(UIColor *)theColor player:(SFSpotifyPlayer *)thePlayer  origin:(CGPoint)theOrigin {
	self = [super initWithName:theName key:theKey player:thePlayer];
    if(self == nil) {
		return nil;
	}
	
	origin = theOrigin;
	bubbleColor = theColor;

    return self;
}

@synthesize origin;

- (NSArray *)keyPath {
	return [NSArray arrayWithObject:self.key];
}

- (CGFloat)relativeSize {
	return 1.0;
}

@synthesize bubbleColor;

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
	return [factory viewControllerForPlaylist:[self tracksProxy]];
}

// TODO: REMOVE CODE DUPLICATION (see SFSpotifyToplist) !!!
- (NSString *)artistNameForDiscovery {
	if([[self.player.nowPlayingLeaf keyPath] objectAtIndex:0] == self.key) {
		NSAssert([self.player.nowPlayingLeaf conformsToProtocol:@protocol(SFDiscoverableItem)], @"Child is not discoverable");
		return [(id<SFDiscoverableItem>)self.player.nowPlayingLeaf artistNameForDiscovery];
	}
	
	return [super artistNameForDiscovery];
}

- (BOOL)isReadOnly {
	return YES;
}

@end
