#import "SFSpotifyPlaylistBridge.h"

#import "CoalescingDispatcher.h"
#import "NSArray+NSNull.h"
#import "SFSpotifyChildrenFactory.h"
#import "SFSpotifyPlaylist.h"
#import "SPArtist.h"
#import "SPPlaylist.h"
#import "SPPlaylistItem.h"
#import "SPTrack.h"

@class SFSpotifyPlayer;

@implementation SFSpotifyPlaylistBridge {
	SPPlaylist *playlist;
	SFSpotifyChildrenFactory *childrenFactory;
	CoalescingDispatcher *dispatcher;
	SFSpotifyPlaylist *mediaItem;
}

- (id)initWithName:(NSString *)theName key:(id)theKey color:(UIColor *)theColor player:(SFSpotifyPlayer *)thePlayer playlist:(SPPlaylist *)thePlaylist origin:(CGPoint)theOrigin factory:(SFSpotifyChildrenFactory *)theChildrenFactory {
	self = [super init];
    if(self == nil) {
		return nil;
	}
	
	mediaItem = [[SFSpotifyPlaylist alloc] initWithName:theName key:theKey color:theColor player:thePlayer origin:theOrigin];
	if(mediaItem == nil) {
		return nil;
	}
	
	playlist = thePlaylist;
	childrenFactory = theChildrenFactory;
	
	__block SFSpotifyPlaylistBridge *blockSelf = self;
	dispatcher = [[CoalescingDispatcher alloc] initWithPeriod:1 block:^(){
		[blockSelf loadTracks];
	}];
	
	[self startObserving];
	[self loadTracks];
	
    return self;
}

- (void)dealloc {
	[self endObserving];
}

- (void)startObserving {
	[playlist addObserver:self forKeyPath:@"items" options:0 context:nil];	
}

- (void)endObserving {
	[playlist removeObserver:self forKeyPath:@"items"];	
}

#define kLoadTimeout 30.0

- (void)loadTracks {
	[self endObserving];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[SPAsyncLoading waitUntilLoaded:playlist timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedPlaylists, NSArray *notLoaded) {
		if (loadedPlaylists.count == 0) {
			return;
		}
		
		NSLog(@"loaded playlist %@", loadedPlaylists);
		NSAssert([loadedPlaylists count] == 1, @"Unexpected result");
		
		NSArray *tracks = [[[loadedPlaylists objectAtIndex:0] valueForKeyPath:@"items.@unionOfObjects.item"] arrayWithoutNSNullObjects];
		[SPAsyncLoading waitUntilLoaded:tracks timeout:kLoadTimeout then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
			NSLog(@"loaded %d playlist items, skipped %d", loadedItems.count, notLoadedItems.count);
			NSArray *covers = [[loadedItems valueForKeyPath:@"@unionOfObjects.album.cover"] arrayWithoutNSNullObjects];
			[SPAsyncLoading waitUntilLoaded:covers timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedCovers, NSArray *notLoaded) {
				[self createChildrenFromSPTracks:loadedItems];
				[self startObserving]; //TODO: This has a race condition: If the playlist changes before all tracks / covers are loaded, the change is lost!
				[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
			}];
		}];
	}];
}

- (NSArray *)tracksFromPlaylistItems:(NSArray *)items {
	NSMutableArray *tracks = [NSMutableArray arrayWithCapacity:items.count];
	for (SPPlaylistItem *anItem in items) {
		if (anItem.itemClass == [SPTrack class]) {
			[tracks addObject:anItem.item];
		}
		else {
			NSLog(@"Non-track playlist item: %@ with class %@", anItem, anItem.itemClass);
		}
	}
	return [NSArray arrayWithArray:tracks];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if([keyPath isEqualToString:@"items"]) {
		[dispatcher fireAfterPeriod];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)createChildrenFromSPTracks:(NSArray *)spTracks {
	NSArray *newChildren = [childrenFactory childrenFromSPTracks:spTracks];
	
	if(mediaItem.children == nil) {
		mediaItem.children = newChildren;
	}
	else {
		[self diffAndUpdateMediaItems:mediaItem withChildren:newChildren];
	}
	
	[self notifyDelegateWithMediaItem:mediaItem];
}

- (void)diffAndUpdateMediaItems:(id<SFSpotifyMediaItem>)mediaItemRoot withChildren:(NSArray *)newChildren {
			
	NSSet *oldChildrenSet = [NSSet setWithArray:mediaItemRoot.children];
	NSSet *newChildrenSet = [NSSet setWithArray:newChildren];
	
	NSMutableSet *addedChildrenSet = [newChildrenSet mutableCopy];
	[addedChildrenSet minusSet:oldChildrenSet];
	
	NSMutableSet *keptChildrenSet = [newChildrenSet mutableCopy];
	[keptChildrenSet intersectSet:oldChildrenSet];
	
	NSIndexSet *removedIndexes = [mediaItemRoot.children indexesOfObjectsPassingTest:^BOOL(id<SFSpotifyMediaItem> item, NSUInteger idx, BOOL *stop) {
		return [newChildrenSet containsObject:item] == NO;
	}];

	[mediaItemRoot removeChildrenAtIndexes:removedIndexes];
	
	for(id<SFSpotifyMediaItem> child in keptChildrenSet) {
		NSArray *subchildren = [child children];
		if(subchildren == nil) {
			continue;
		}
		
		id<SFSpotifyMediaItem> originalChild = [oldChildrenSet member:child];
		NSAssert(originalChild != nil, @"set inconsistency");
		[self diffAndUpdateMediaItems:originalChild withChildren:subchildren];
	}
	
	if(addedChildrenSet.count > 0) {
		NSLog(@"%@: adding item %@ ", [mediaItemRoot name], addedChildrenSet);
		NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(mediaItemRoot.children.count, addedChildrenSet.count)];
		[mediaItemRoot insertChildren:[addedChildrenSet allObjects] atIndexes:indexes];
	}
}


@end
