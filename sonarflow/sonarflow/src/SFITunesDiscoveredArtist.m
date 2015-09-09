#import "SFITunesDiscoveredArtist.h"

#import "SFITunesPlayer.h"
#import "SFITunesArtistSearch.h"

@interface SFITunesDiscoveredArtist ()

@property (nonatomic, strong) SFITunesArtistSearch *currentSearch;
@property (nonatomic, readwrite, strong) NSArray *children;
@property (nonatomic, readwrite) BOOL loading;

@end;

@implementation SFITunesDiscoveredArtist {
	SFITunesPlayer *player;
}


- (id)initWithKey:(RootKey *)theKey name:(NSString *)theName {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithKey:(RootKey *)theKey name:(NSString *)theName player:(SFITunesPlayer *)thePlayer {
    self = [super initWithKey:theKey name:theName];
    if(self == nil) {
		return nil;
    }
	player = thePlayer;
    return self;
}

@synthesize currentSearch;
@synthesize children;
@synthesize loading;

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
    [self startLoadingTracksIfNeeded];
    return [super createDetailViewControllerWithFactory:factory];
}

- (void)startLoadingTracksIfNeeded {
    if(self.children != nil || self.currentSearch != nil) {
        return;
    }
	
	self.loading = YES;
	
    self.currentSearch = [[SFITunesArtistSearch alloc] initWithArtistName:self.name parentForChildren:self];
    [self.currentSearch startWithCompletion:^(NSArray *topTracks, NSError *error) {
        if(error != nil) {
            NSLog(@"Discovered Artist: Could not load tracks: %@", error);
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
