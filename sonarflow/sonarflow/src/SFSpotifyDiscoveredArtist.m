#import "SFSpotifyDiscoveredArtist.h"

#import "SFSpotifyArtistSearch.h"
#import "SFSpotifyMediaItem.h"
#import "SFSpotifyPlayer.h"
#import "SFSpotifySearchFactory.h"
#import "SFSpotifyTrack.h"
#import "SPSession.h"

@interface SFSpotifyDiscoveredArtist () <SFSpotifyMediaItem>

@property (nonatomic, strong) SFSpotifyArtistSearch *currentSearch;
@property (nonatomic, readwrite, strong) NSArray *children;
@property (nonatomic, readwrite, assign, getter = isLoading) BOOL loading;

@end

@implementation SFSpotifyDiscoveredArtist {
	SFSpotifySearchFactory *searchFactory;
	SFSpotifyPlayer *player;
}

-(id)initWithKey:(RootKey *)theKey name:(NSString *)theName searchFactory:(SFSpotifySearchFactory *)theSearchFactory player:(SFSpotifyPlayer *)thePlayer {
	self = [super initWithKey:theKey name:theName];
	if(self == nil) {
		return nil;
	}
	
	searchFactory = theSearchFactory;
	player = thePlayer;
	loading = YES;
	
	return self;
}

@synthesize children;
@synthesize currentSearch;
@synthesize loading;

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
	[self startLoadingTracksIfNeeded];
	return [super createDetailViewControllerWithFactory:factory];
}

- (void)startLoadingTracksIfNeeded {
	if(self.children != nil || self.currentSearch != nil) {
		return;
	}
	
	self.currentSearch = [searchFactory searchForArtistName:self.name parentForChildren:self];
	[self.currentSearch startWithCompletion:^(NSArray *topTracks, NSError *error) {
		if(error != nil) {
			NSLog(@"Could not load discovery tracks: %@", error);
		}
		self.children = topTracks;
		self.loading = NO;
		self.currentSearch = nil;
	}];	
}

- (void)startPlayback {
	[self startLoadingTracksIfNeeded];
	[player play:self];
}

- (void)startPlaybackAtChildIndex:(NSUInteger)childIndex {
	[self startLoadingTracksIfNeeded];
	[player play:self startingAtIndex:childIndex];
}

- (NSArray *)tracks {
	return self.children;
}

@end
