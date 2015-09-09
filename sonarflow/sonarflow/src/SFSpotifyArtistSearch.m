#import "SFSpotifyArtistSearch.h"

#import <CocoaLibSpotify.h>
#import "SFSpotifySearch.h"
#import "SFSpotifyTrack.h"

@interface SFSpotifyArtistSearch ()

@property (nonatomic, copy) ArtistResultBlock completionBlock;
@property (nonatomic, strong) SFSpotifySearch *search;
@property (nonatomic, strong) SPArtistBrowse *browse;

@end


@implementation SFSpotifyArtistSearch {
	NSString *artistName;
	SPSession *session;
	SFSpotifySearch *search;
	SFSpotifyPlayer *player;
	id<SFMediaItem> parent;
}

- (id)initWithArtistName:(NSString *)theArtistName session:(SPSession *)theSession player:(SFSpotifyPlayer *)thePlayer parentForChildren:(id<SFMediaItem>)theParent {
    self = [super init];
    if (self) {
		artistName = theArtistName;
		session = theSession;
		player = thePlayer;
		parent = theParent;
    }
    return self;
}

@synthesize completionBlock;
@synthesize search;
@synthesize browse;

- (void)startWithCompletion:(ArtistResultBlock)theCompletionBlock {
	self.completionBlock = theCompletionBlock;
	self.search = [[SFSpotifySearch alloc] initWithQuery:[SFSpotifySearch queryForArtistName:artistName]
											session:session];
	[self.search startWithCompletion:^(NSArray *artists, NSArray *albums, NSArray *tracks, NSArray *playlists, NSError *error) {
		[self startArtistBrowse:[self matchingArtist:artists]];
		self.search = nil;
	}];
}

- (SPArtist *)matchingArtist:(NSArray *)artists {
	if([artists count] == 0) {
		return nil;
	}

	for(SPArtist *artist in artists) {
		if([artist.name isEqualToString:artistName]) {
			return artist;
		}
	}
	return [artists objectAtIndex:0];
}
	 
- (void)startArtistBrowse:(SPArtist *)artist {
	if(artist == nil) {
		completionBlock(nil, [NSError errorWithDomain:@"Spotify error" code:0 userInfo:nil]);
		return;
	}
	self.browse = [SPArtistBrowse browseArtist:artist inSession:session type:SP_ARTISTBROWSE_NO_ALBUMS];
	[SPAsyncLoading waitUntilLoaded:self.browse timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *result, NSArray *notLoaded) {
		[self handleBrowseResult];
	}];
}

- (void)handleBrowseResult {
	if(self.browse.loadError != nil) {
		completionBlock(nil, self.browse.loadError);
		return;
	}
	NSArray *tracks = [self wrapSPTracks:self.browse.topTracks];
	completionBlock(tracks, nil);
}

- (NSArray *)wrapSPTracks:(NSArray *)tracks {
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:tracks.count];
	for(SPTrack *track in tracks) {
		if(track.availability != SP_TRACK_AVAILABILITY_AVAILABLE) {
			continue;
		}

		SFSpotifyTrack *item = [[SFSpotifyTrack alloc] initWithTrack:track player:player];
		item.parent = parent;
		[result addObject:item];
	}
	
	return result;
}

@end
