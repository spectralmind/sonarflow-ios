#import "SFSpotifySearch.h"

#import <CocoaLibSpotify.h>

@interface SFSpotifySearch ()

@property (nonatomic, copy) SearchResultBlock completionBlock;
@property (nonatomic, strong) SPSearch *currentSearch;

@end


@implementation SFSpotifySearch {
	NSString *query;
	SPSession *session;
}

+ (NSString *)queryForArtistName:(NSString *)artistName {
	NSString *escapedArtistName = [artistName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
	return [NSString stringWithFormat:@"artist:\"%@\"", escapedArtistName];
}

- (id)initWithQuery:(NSString *)theQuery session:(SPSession *)theSession {
	self = [super init];
	if (self) {
		query = theQuery;
		session = theSession;
	}
	return self;
}

@synthesize completionBlock;
@synthesize currentSearch;

- (void)startWithCompletion:(SearchResultBlock)theCompletionBlock {
	self.completionBlock = theCompletionBlock;
	self.currentSearch = [SPSearch searchWithSearchQuery:query inSession:session];
	
	[SPAsyncLoading waitUntilLoaded:self.currentSearch timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loaded, NSArray *notLoaded) {
		[self handleSearchResult];
	}];
}

- (void)handleSearchResult {
	if(self.currentSearch.searchError != nil) {
		NSLog(@"Spotify search encountered an error: %@", self.currentSearch.searchError);
		completionBlock(nil, nil, nil, nil, self.currentSearch.searchError);
		return;
	}

	completionBlock(self.currentSearch.artists, self.currentSearch.albums,
					self.currentSearch.tracks, self.currentSearch.playlists, nil);
}

@end
