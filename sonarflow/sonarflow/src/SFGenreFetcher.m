#import "SFGenreFetcher.h"

#import "SFGenreFetcherRequestData.h"
#import "SFSmartistFactory.h"
#import "SMArtist.h"

@interface SFGenreFetcher () <SMArtistDelegate>
@end

@implementation SFGenreFetcher {
	SMArtist *smartist;
	NSMutableDictionary *artists;
	NSMutableArray *results;
	NSCondition *fetchCondition;
	NSUInteger resultSize;
}

- (id)init {
	self = [super init];
	if(self == nil) {
		return nil;
	}
	
	SFSmartistFactory *factory = [[SFSmartistFactory alloc] init];
	smartist = [factory newSmartistWithDelegate:self];
	
	artists = [NSMutableDictionary dictionary];
	resultSize = 0;
	
	return self;
}

- (void)registerMediaItem:(id)object forLookupWithArtistName:(NSString *)artistName {
	NSMutableArray *artistItems = [artists objectForKey:artistName];
	
	if(artistItems == nil) {
		artistItems = [NSMutableArray array];
		[artists setObject:artistItems forKey:artistName];
	}
	
	NSAssert(artistItems != nil, @"should have an artist items array by now!");
	[artistItems addObject:object];
}

- (void)lookupRegisteredMediaItems {

	fetchCondition = [[NSCondition alloc] init];
	results = [NSMutableArray array];
	resultSize = artists.count;
	
	for(NSString *artist in artists.allKeys) {
		NSArray *items = [artists objectForKey:artist];
		SFGenreFetcherRequestData *data = [SFGenreFetcherRequestData genreFetcherRequestDataWithArtistName:artist mediaItems:items];		
		[smartist getArtistGenresWithArtistName:artist clientId:data  priority:NO];
	}
}

- (void)doneWebRequestWithArtistGenresResult:(SMArtistGenresResult *)theResult {
	NSAssert([theResult.clientId isKindOfClass:[SFGenreFetcherRequestData class]], @"invalid smartist result");
	SFGenreFetcherRequestData *data = theResult.clientId;
	
	data.results = theResult.genres;
	data.error = theResult.error;
	data.recognizedArtist = theResult.recognizedArtistName;
	[results addObject:data];
	
	[self checkForCompletion];
}


- (void)checkForCompletion {
	if([self hasPendingRequests]) {
		return;
	}
	
	[fetchCondition lock];
	[fetchCondition signal];
	[fetchCondition unlock];
}

- (BOOL)hasPendingRequests {
	return results.count < resultSize;
}


- (NSArray *)waitForResults {
	[fetchCondition lock];
	while([self hasPendingRequests]) {
		[fetchCondition wait];
	}

	[fetchCondition unlock];

	return results;
}

@end
