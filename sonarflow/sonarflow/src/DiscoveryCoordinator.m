#import "DiscoveryCoordinator.h"

#import "AppFactory.h"
#import "BubbleView.h"
#import "DiscoveryResultMerger.h"
#import "DiscoveryZone.h"
#import "DiscoveryZoneMember.h"
#import "RootKey.h"
#import "SFDiscoverableItem.h"
#import "SFMediaItem.h"
#import "SFMediaLibrary.h"
#import "SFSmartistFactory.h"
#import "SMArtist.h"

@interface DiscoveryCoordinator() <SMArtistDelegate>

@property (nonatomic, strong) DiscoveryResultMerger *merger;
@property (nonatomic, strong) NSSet *queryBubbles;

@end

@implementation DiscoveryCoordinator {
	SMArtist *smartist;
	id<SFMediaLibrary> library;
	NSObject<DiscoveryResultDelegate> *resultDelegate;
}

- (id)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithFactory:(SFSmartistFactory *)factory library:(id<SFMediaLibrary>)theLibrary {
    self = [super init];
    if(self == nil) {
        return nil;
    }
	
	smartist = [factory newSmartistWithDelegate:self];
	library = theLibrary;
	
    return self;
}


@synthesize queryBubbles;
@synthesize merger;
@synthesize resultDelegate;

- (void)zoneContentChangedTo:(DiscoveryZone *)discoverZone {
	
	if(discoverZone.members.count == 0) {
		self.queryBubbles = nil;
		return;
	}
	
	DiscoveryResultMerger *discoverymerger = [[DiscoveryResultMerger alloc] initWithExpectedResultCount:discoverZone.members.count andDelegate:resultDelegate];
	discoverymerger.queryZone = discoverZone;
	self.merger = discoverymerger;

	NSSet *allQueryBubbles = [NSSet setWithArray:discoverZone.members];	
	self.queryBubbles = allQueryBubbles;

	for(DiscoveryZoneMember *member in allQueryBubbles) {
		NSString *artistName = [self artistNameForDiscoveryFromKeyPath:member.keyPath];
		if(artistName == nil) {
			continue;
		}
		
		[smartist getArtistSimilarityWithArtistName:artistName clientId:member priority:YES];
	}
	
	NSLog(@"%d discovery requests sent.", allQueryBubbles.count);
}

- (NSString *)artistNameForDiscoveryFromKeyPath:(NSArray *)keyPath {
	
	id rootkey = [keyPath objectAtIndex:0];
	NSAssert([rootkey isKindOfClass:[RootKey class]], @"invalid root key");
	RootKey *key = rootkey;
	if(key.type == BubbleTypeDiscovered) {
		return key.key;
	}
	
	id<SFMediaItem> mediaItem = [library mediaItemForKeyPath:keyPath];
	if([mediaItem conformsToProtocol:@protocol(SFDiscoverableItem)] == NO) {
		return nil;
	}
    
	id<SFDiscoverableItem> discoverableItem = (id<SFDiscoverableItem>)mediaItem;
	return [discoverableItem artistNameForDiscovery];
}

- (void)doneWebRequestWithArtistSimilarityResult:(SMArtistSimilarityResult *)theResult {
	if([self.queryBubbles member:theResult.clientId] == nil) {
		NSLog(@"discarding stale SMArtist result for %@", theResult.recognizedArtistName);
		return;
	}
	
    if(theResult.error != nil) {
        NSLog(@"Discovery: cannot retrieve SMArtist result: %@: %@", theResult.error.domain, [theResult.error.userInfo valueForKey:NSLocalizedDescriptionKey]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to retrieve similar artists. Please try again later." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    
	NSLog(@"got smartist result for %@: (%d)", theResult.recognizedArtistName, theResult.similarArtists.count);
	[self.merger incorporateResult:theResult];
}



@end
