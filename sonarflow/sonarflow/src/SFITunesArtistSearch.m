#import "SFITunesArtistSearch.h"
#import "SFITunesHelper.h"

#import "SFObserver.h"
#import "SFITunesAudioTrack.h"

#import "Configuration.h"

@interface SFITunesArtistSearch () <SFObserverDelegate>

@property (nonatomic, strong) NSString* artistName;
@property (nonatomic, strong) SFITunesHelper* helper;
@property (nonatomic, copy) iTunesArtistResultBlock completionBlock;

@property (nonatomic, strong) SFObserver *helperObserver;
@end

@implementation SFITunesArtistSearch {
	id<SFITunesMediaItem> parent;
}

@synthesize artistName;
@synthesize helper;
@synthesize helperObserver;
@synthesize completionBlock;

- (id)initWithArtistName:(NSString *)theArtistName parentForChildren:(id<SFITunesMediaItem>)theParent {
	self = [super init];
	if(self == nil) {
		return nil;
	}
	
	self.artistName = theArtistName;
	parent = theParent;
	return self;
}



- (void)startWithCompletion:(iTunesArtistResultBlock)theCompletionBlock {
	self.completionBlock = theCompletionBlock;
    
    NSString *iTunesApiUrl = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"iTunesApiUrl"];
    SFITunesHelper *theHelper = [[SFITunesHelper alloc] initWithBaseURL:iTunesApiUrl];
    self.helper = theHelper;
	
	SFObserver *theObserver = [[SFObserver alloc] initWithObject:theHelper keyPath:@"searchInProgress" delegate:self];
	self.helperObserver = theObserver;
	
    NSString *country = [self localeForSearch];
    NSString *artistQuery = [NSString stringWithFormat:@"media=music&entity=song&attribute=artistTerm&limit=10&country=%@&term=%@", country, [SFITunesHelper encodeURL:self.artistName]];
    [self.helper executeRequest:@"search" query:artistQuery];
}


- (NSString *)localeForSearch {
	NSString *setting = [[Configuration sharedConfiguration] stringForIdentifier:@"search_store"];
	
	if([setting isEqualToString:@"local"]) {
		return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
	}
	
	return setting;
}

- (void)object:(NSObject *)object wasSetFrom:(id)oldValue to:(id)newValue {
	if(self.helper.searchInProgress == NO) {
		[self handleSearchResult];
		return;
	}
	else {
		NSLog(@"Search is still in progress.");
	}
}

- (void)handleSearchResult {
	if(self.helper.searchError != nil) {
		NSLog(@"search encountered an error: %@", self.helper.searchError);
		self.completionBlock(nil, self.helper.searchError);
		return;
	}
    
    NSMutableArray *tracks = [NSMutableArray arrayWithCapacity:self.helper.searchResults.count];
    for (NSDictionary *trackDict in self.helper.searchResults) {
        NSNumber *duration = [trackDict objectForKey:@"trackTimeMillis"];
		NSURL *previewUrl = [NSURL URLWithString:[trackDict objectForKey:@"previewUrl"]];
		NSURL *buyUrl = [NSURL URLWithString:[trackDict objectForKey:@"trackViewUrl"]];
		
		NSNumber *durationInSeconds = [NSNumber numberWithFloat:[duration doubleValue]/1000.0];
		SFITunesAudioTrack *track = [[SFITunesAudioTrack alloc] initWithURL:previewUrl name:[trackDict objectForKey:@"trackName"] artist:[trackDict objectForKey:@"artistName"] album:[trackDict objectForKey:@"collectionName"] duration:durationInSeconds buyLink:buyUrl parent:parent];
        [tracks addObject:track];
    }
    
	self.completionBlock(tracks, nil);
}


@end
