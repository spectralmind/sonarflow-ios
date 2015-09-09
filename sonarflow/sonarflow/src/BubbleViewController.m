#import "BubbleViewController.h"

#import "AppFactory.h"
#import "Bubble.h"
#import "BubbleFactory.h"
#import "BubbleMainView.h"
#import "DiscoveredBubbleLayouter.h"
#import "DiscoveryCoordinator.h"
#import "DiscoveryZone.h"
#import "DiscoveryZoneMember.h"
#import "GANHelper.h"
#import "NSArray+KeyPath.h"
#import "NSString+CGLogging.h"
#import "RootKey.h"
#import "SFArrayObserver.h"
#import "SFBubbleHierarchyView.h"
#import "SFKeyPathMap.h"
#import "SFMediaItem.h"
#import "SFMediaLibrary.h"
#import "SFRootItem.h"
#import "SFSyncNotificationView.h"
#import "SMSimilarArtist.h"

@interface BubbleViewController () <BubbleDataSource, BubbleHierarchyViewDelegate, SFBubbleHierarchyViewTrackDelegate, SFArrayObserverDelegate, DiscoveryResultDelegate>

@property (nonatomic, strong) NSSet *currentDiscoveryZone;
@property (nonatomic, strong) NSSet *discoveredSimilarArtists;

@end


@implementation BubbleViewController {
	NSObject<SFMediaLibrary> *library;
	SFArrayObserver *mediaItemsObserver;
	SFKeyPathMap *observersMap;
	SFKeyPathMap *bubblesMap;
	SFKeyPathMap *layoutedChildBubblesMap;
	SFKeyPathMap *pendingChildrenMap;
	SFSyncNotificationView *syncNotificationView;
	
	DiscoveryCoordinator *discoveryCoordinator;
	NSMutableDictionary *bubbleMap;
	NSCache *discoveredArtistCache;
}

- (id)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithLibrary:(NSObject<SFMediaLibrary> *)theLibrary factory:(AppFactory *)factory {
    self = [super init];
    if (self) {
		library = theLibrary;
		mediaItemsObserver = [[SFArrayObserver alloc] initWithObject:library keyPath:@"mediaItems" delegate:self];


		observersMap = [[SFKeyPathMap alloc] init];
		bubblesMap = [[SFKeyPathMap alloc] init];
		layoutedChildBubblesMap = [[SFKeyPathMap alloc] init];
		pendingChildrenMap = [[SFKeyPathMap alloc] init];
		discoveryCoordinator = [[DiscoveryCoordinator alloc] initWithFactory:factory.smartistFactory library:library];

		discoveryCoordinator.resultDelegate = self;
		bubbleMap = [[NSMutableDictionary alloc] initWithCapacity:5];
		discoveredArtistCache = [[NSCache alloc] init];
		discoveredArtistCache.countLimit = 15;
    }
	
    return self;
}


#pragma mark Properties

- (void)setView:(SFBubbleHierarchyView *)aView {
	if(_view != aView) {
		_view = aView;

		_view.bubbleDelegate = self;
		_view.bubbleDataSource = self;
		_view.trackDelegate = self;
		
		_view.bubbleCheck = ^BOOL(AbstractBubbleView *bubble) {			
			return YES;
		};
		
		[self showSyncNotification];
		
		[self restartWithMediaItems:library.mediaItems];
	}
}

#pragma mark - SFArrayObserverDelegate

- (void)object:(NSObject *)object wasSetFrom:(id)oldValue to:(id)newValue {
	if(object == library) {
		[self restartWithMediaItems:newValue];
	}
	else {
		NSAssert([object conformsToProtocol:@protocol(SFMediaItem)], @"observed object does not conform to SFMediaItem");
		id<SFMediaItem> parent = (id<SFMediaItem>)object;
		NSArray *parentKeyPath = [parent keyPath];
		[observersMap removeChildrenOfKeyPath:parentKeyPath];
		[layoutedChildBubblesMap removeObjectsForKeyPath:parentKeyPath];
		[pendingChildrenMap removeObjectsForKeyPath:parentKeyPath];
		[self addChildren:newValue forKeyPath:[parent keyPath]];
	}
}

- (void)objects:(NSArray *)objects wereInsertedAtIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	if(object == library) {
		[self addRootMediaItems:objects];
	}
	else {
		NSAssert([object conformsToProtocol:@protocol(SFMediaItem)], @"observed object does not conform to SFMediaItem");
		id<SFMediaItem> parent = (id<SFMediaItem>)object;
		[self addChildren:objects forKeyPath:[parent keyPath]];
	}
}

- (void)objects:(NSArray *)objects wereDeletedAtIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	for(NSObject<SFMediaItem> *mediaItem in objects) {
		[self removeMediaItem:mediaItem];
	}
}

- (void)objects:(NSArray *)oldObjects wereReplacedWithObjects:(NSArray *)newObjects atIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	[self objects:oldObjects wereDeletedAtIndexes:indexes ofObject:object];
	[self objects:newObjects wereInsertedAtIndexes:indexes ofObject:object];
}

- (void)restartWithMediaItems:(NSArray *)mediaItems {
	[self removeAllItems];
	[self addRootMediaItems:mediaItems];
}

- (void)removeAllItems {
	NSLog(@"BVC: Removing all items");
	[observersMap removeAllObjects];
	[bubblesMap removeAllObjects];
	[layoutedChildBubblesMap removeAllObjects];
	[pendingChildrenMap removeAllObjects];
	[self showSyncNotification];
}

- (void)addRootMediaItems:(NSArray *)rootMediaItems {
	if(rootMediaItems.count == 0) {
		return;
	}
	
	[self addChildren:rootMediaItems forKeyPath:[NSArray array]];

	[self hideSyncNotification];
	[self.view zoomOut];
}

- (void)addChildren:(NSArray *)children forKeyPath:(NSArray *)keyPath {
	[self addPendingChildren:children forKeyPath:keyPath];
	[self updateBubblesAlongKeyPath:keyPath];
	[_view reloadChildrenAtKeyPath:keyPath];
}

- (void)addPendingChildren:(NSArray *)children forKeyPath:(NSArray *)keyPath {
	NSMutableArray *pendingChildren = [pendingChildrenMap objectForKeyPath:keyPath];
	if(pendingChildren == nil) {
		pendingChildren = [NSMutableArray arrayWithCapacity:[children count]];
		[pendingChildrenMap setObject:pendingChildren forKeyPath:keyPath];
	}
	[pendingChildren addObjectsFromArray:children];
	[self observeChildrenOfMediaItems:pendingChildren];
}

- (void)removeMediaItem:(NSObject<SFMediaItem> *)mediaItem {
	NSArray *keyPath = [mediaItem keyPath];
	[self removeReferencesToKeyPath:keyPath];
	[self updateBubblesAlongKeyPath:[keyPath parent]];
	[_view removeBubbleAtKeyPath:keyPath];
}

- (void)updateBubblesAlongKeyPath:(NSArray *)keyPath {
	NSMutableArray *currentKeyPath = [[NSMutableArray alloc] init];
	Bubble *parentBubble = nil;
	for(id key in keyPath) {
		[currentKeyPath addObject:key];
		Bubble *bubble = [self bubbleForKeyPath:currentKeyPath];
		[self.bubbleFactory updateBubble:bubble withParent:parentBubble fromMediaItem:[self mediaItemForKeyPath:currentKeyPath]];
		parentBubble = bubble;
	}
}

- (void)removeReferencesToKeyPath:(NSArray *)keyPath {
	if([keyPath hasParent]) {
		[self removeChildWithKey:[keyPath lastObject] fromParentKeyPath:[keyPath parent]];
	}
	[observersMap removeObjectsForKeyPath:keyPath];
	[bubblesMap removeObjectsForKeyPath:keyPath];
	[pendingChildrenMap removeObjectsForKeyPath:keyPath];
}

- (void)removeChildWithKey:(id)key fromParentKeyPath:(NSArray *)parentKeyPath {
	NSMutableArray *parentBubbles = [layoutedChildBubblesMap objectForKeyPath:parentKeyPath];
	for(Bubble *bubble in parentBubbles) {
		if([bubble.key isEqual:key]) {
			[parentBubbles removeObject:bubble];
			break;
		}
	}
	
	NSMutableArray *parentChildren = [pendingChildrenMap objectForKeyPath:parentKeyPath];
	for(id<SFMediaItem> child in parentChildren) {
		if([child.key isEqual:key]) {
			[parentChildren removeObject:child];
			break;
		}
	}
}

- (void)showSyncNotification {
	if(syncNotificationView == nil) {
		[self createSyncNotificationView];
	}
	[syncNotificationView showAnimated];
}

- (void)createSyncNotificationView {
	syncNotificationView = [[SFSyncNotificationView alloc] initWithFrame:self.view.frame];
	syncNotificationView.autoresizingMask = self.view.autoresizingMask;
	[self.view.superview insertSubview:syncNotificationView aboveSubview:self.view];
}

- (void)hideSyncNotification {
	[syncNotificationView hideAnimated];
}

#pragma mark -
#pragma mark BubbleHierarchyViewDelegate

- (void)tappedBubbleAtKeyPath:(NSArray *)keyPath inRect:(CGRect)rect {
	id<SFMediaItem> mediaItem = [self mediaItemForKeyPath:keyPath];
	[self.delegate tappedMediaItem:mediaItem inRect:rect];
}

- (void)doubleTappedBubbleAtKeyPath:(NSArray *)keyPath inRect:(CGRect)rect {
	id<SFMediaItem> mediaItem = [self mediaItemForKeyPath:keyPath];
	[self.delegate doubleTappedMediaItem:mediaItem inRect:rect];
}

- (void)tappedEmptyLocation:(CGPoint)location {
	[self.delegate tappedEmptyLocation:location];
}

- (void)updatedDiscoveryZone:(DiscoveryZone *)newContents {
	[self updateArtistInFocus:newContents];
	[discoveryCoordinator zoneContentChangedTo:newContents];
	
	NSSet *query = [NSSet setWithArray:newContents.members];
		
	self.currentDiscoveryZone = query;
	if(query.count == 0) {
		[self emptySimilarityZone];
		return;
	}

	[self.delegate discoveryInProgress:YES];
	[self logDiscoveryQueryBubbleNames:newContents];
}

- (void)updateArtistInFocus:(DiscoveryZone *)zone {

	if(zone.members.count == 0) {
		return;
	}
	
	DiscoveryZoneMember *closest = [zone.members objectAtIndex:0];
	[self.delegate updateArtistInFocus:[discoveryCoordinator artistNameForDiscoveryFromKeyPath:closest.keyPath]];
}

- (void)logDiscoveryQueryBubbleNames:(DiscoveryZone *)newContents {
	NSMutableString *bubbleNames = [[NSMutableString alloc] init];
	for(DiscoveryZoneMember *m in newContents.members) {
		RootKey *key = [m.keyPath objectAtIndex:0];
		if(key.type == BubbleTypeDefault) {
			[bubbleNames appendFormat:@" '%@'", m.keyPath.lastObject];
		}
		else {
			[bubbleNames appendFormat:@" '%@'", key.key];
		}
	}
	
	NSLog(@"discovery: %d (%@) size: %f\n", newContents.members.count, bubbleNames, newContents.radius);
}

- (void)userZoomed {
	static BOOL trackedUserZoom = NO;
	if (trackedUserZoom) {
		return;
	}
	BOOL didZoomBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"DidZoomBefore"];
	if (didZoomBefore) {
		trackedUserZoom = YES;
		return;
	}
	
	[self.ganHelper trackEvent:@"Zoom" action:@"userDidZoomFirstTime" label:nil value:-1];
	trackedUserZoom = YES;
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DidZoomBefore"];
}

#pragma mark -
#pragma mark BubbleDataSource

- (UIImage *)coverForKeyPath:(NSArray *)keyPath {
	id<SFMediaItem> mediaItem = [self mediaItemForKeyPath:keyPath];
	NSAssert([mediaItem mayHaveImage], @"MediaItem for Bubble does not have an image");
	return [mediaItem imageWithSize:self.bubbleFactory.coverSize];
}

- (NSArray *)childrenForKeyPath:(NSArray *)keyPath {
	[self layoutChildrenForKeyPath:keyPath];
	NSArray *layoutedBubbles = [layoutedChildBubblesMap objectForKeyPath:keyPath];
	if([keyPath count] == 0) {
		return [layoutedBubbles arrayByAddingObjectsFromArray:[bubbleMap allValues]];
	}

	return layoutedBubbles;
}

- (Bubble *)bubbleForKeyPath:(NSArray *)keyPath {
	return [bubblesMap objectForKeyPath:keyPath];
}

- (void)layoutChildrenForKeyPath:(NSArray *)keyPath {
	NSMutableArray *pendingChildren = [pendingChildrenMap objectForKeyPath:keyPath];
	if([pendingChildren count] == 0) {
		return;
	}
	
	NSMutableArray *layoutedBubbles = [layoutedChildBubblesMap objectForKeyPath:keyPath];	
	if(layoutedBubbles == nil) {
		layoutedBubbles = [[NSMutableArray alloc] init];
		[layoutedChildBubblesMap setObject:layoutedBubbles forKeyPath:keyPath];
	}
	
	NSArray *newBubbles = [self createBubblesForChildren:pendingChildren ofKeyPath:keyPath avoidingBubbles:layoutedBubbles];
	for(Bubble *bubble in newBubbles) {
		[bubblesMap setObject:bubble forKeyPath:[keyPath arrayByAddingObject:bubble.key]];
	}
	[layoutedBubbles addObjectsFromArray:newBubbles];
	
	[pendingChildren removeAllObjects];
}

- (NSArray *)createBubblesForChildren:(NSArray *)children ofKeyPath:(NSArray *)keyPath avoidingBubbles:(NSArray *)bubblesToAvoid{
	if([keyPath count] == 0) {
		return [_bubbleFactory bubblesForRootMediaItems:children];
	}

	return [_bubbleFactory bubblesForChildren:children ofBubble:[bubblesMap objectForKeyPath:keyPath] avoidingBubbles:bubblesToAvoid];
}

- (void)observeChildrenOfMediaItems:(NSArray *)mediaItems {
	for(NSObject<SFMediaItem> *mediaItem in mediaItems) {
		[self observeChildrenOfMediaItem:mediaItem];
	}
}

- (void)observeChildrenOfMediaItem:(NSObject<SFMediaItem> *)mediaItem {
	if([mediaItem mayHaveChildren] == NO) {
		return;
	}
	
	NSArray *keyPath = [mediaItem keyPath];
	if([observersMap objectForKeyPath:keyPath] != nil) {
		return;
	}
	
	SFArrayObserver *arrayObserver = [[SFArrayObserver alloc] initWithObject:mediaItem keyPath:@"children" delegate:self];
	[observersMap setObject:arrayObserver forKeyPath:keyPath];
	[self addPendingChildren:mediaItem.children forKeyPath:keyPath];
}

#pragma mark -
#pragma mark SFBubbleHierarchyViewTrackDelegate

- (NSObject<SFMediaItem> *)mediaItemForKeyPath:(NSArray *)keyPath {
	RootKey *key = [keyPath objectAtIndex:0];
	if(key.type == BubbleTypeDiscovered) {
		NSAssert([keyPath count] == 1, @"Unexpected key path length");
		return [self discoveredArtistForKey:key];
	}
	else {
		return [library mediaItemForKeyPath:keyPath];
	}
}

- (id<SFMediaItem>)discoveredArtistForKey:(RootKey *)key {
	NSString *artistName = key.key;
	id<SFMediaItem> artist = [discoveredArtistCache objectForKey:artistName];
	if(artist == nil) {
		NSLog(@"SFDiscoveredArtist cache miss for %@", artistName);
		artist = [library mediaItemForDiscoveredArtistWithKey:key name:artistName];
		if(artist != nil) {
			[discoveredArtistCache setObject:artist forKey:artistName];
		}
	}

	return artist;	
}

#pragma mark - DiscoveryResultDelegate

#define kMaxSimilarityResults	5

- (void)doneWithSimilarityQuery:(NSArray *)newSimilarArtists fromZone:(DiscoveryZone *)zone {
	
	[self.delegate discoveryInProgress:NO];
	
	int discoveredArtistsInQuery = 0;
	for(DiscoveryZoneMember *queryArtist in self.currentDiscoveryZone) {
		RootKey *key = [queryArtist.keyPath objectAtIndex:0];
		if(key.type == BubbleTypeDiscovered) {
			++discoveredArtistsInQuery;
		}
	}
	
	NSArray *acceptedArtists = [self filterSimilarArtistResults:newSimilarArtists withNumberOfQuerySimilarityBubbles:discoveredArtistsInQuery];
	
	NSLog(@"discovery: requests done: %d", acceptedArtists.count);
	
	NSMutableSet *updatedSimilarArtists = [NSMutableSet setWithArray:acceptedArtists];

	NSMutableSet *droppedArtists = [NSMutableSet setWithSet:self.discoveredSimilarArtists];
	[droppedArtists minusSet:updatedSimilarArtists];
	
	NSMutableSet *addedArtists = [NSMutableSet setWithSet:updatedSimilarArtists];
	[addedArtists minusSet:self.discoveredSimilarArtists];

	for(DiscoveryZoneMember *queryArtist in self.currentDiscoveryZone) {
		RootKey *key = [queryArtist.keyPath objectAtIndex:0];
		if(key.type == BubbleTypeDiscovered) {
			SMSimilarArtist *similar = [[SMSimilarArtist alloc] init];
			similar.artistName = key.key;
			[updatedSimilarArtists addObject:similar];
			[droppedArtists removeObject:similar];
		}
	}

	NSMutableSet *keptArtist = [NSMutableSet setWithArray:acceptedArtists];
	[keptArtist intersectSet:self.discoveredSimilarArtists];
	NSSet *movedArtists = [self updatePlacementForDiscoveredArtists:keptArtist toZone:zone];

	self.discoveredSimilarArtists = updatedSimilarArtists;
	
	[self removeDiscoveryBubbles:droppedArtists];
	[self layoutDiscoveryBubbles:addedArtists forZone:zone];
	[self layoutDiscoveryBubbles:movedArtists forZone:zone];
	[self.view reloadChildrenAtKeyPath:[NSArray array]];
}

- (void)removeDiscoveryBubbles:(NSSet *)bubbles {
	for(SMSimilarArtist *artist in bubbles) {
		NSLog(@"discovery: removed similar: %@ (%f)", artist.artistName, artist.matchValue);
		[bubbleMap removeObjectForKey:artist.artistName];
	}
}

- (NSArray *)filterSimilarArtistResults:(NSArray *)artists withNumberOfQuerySimilarityBubbles:(int)additional {
	NSMutableArray *acceptedArtists = [[NSMutableArray alloc]initWithCapacity:kMaxSimilarityResults];
	int i = 0;
	for(SMSimilarArtist *sa in artists) {
		
		BOOL artistExists = [library containsArtistWithName:sa.artistName];
		if(artistExists) {
			NSLog(@"Suppressing discovered artist already in library: %@", sa.artistName);
			continue;
		}
		
		[acceptedArtists addObject:sa];
		
		++i;
		if(i>=5) {
			break;
		}
		
		if(i+additional >= 7) {
			break;
		}
	}
	
	return acceptedArtists;
}

#define kMaximumBubbleDistanceFromNewCenter	250

- (NSSet *)updatePlacementForDiscoveredArtists:(NSSet *)artists toZone:(DiscoveryZone *)zone {
	NSMutableSet *updatedBubbles = [[NSMutableSet alloc] initWithCapacity:artists.count];
	for(SMSimilarArtist *artist in artists) {
		Bubble *bubble = [bubbleMap objectForKey:artist.artistName];
		
		CGPoint vect = CGPointMake(bubble.origin.x - zone.center.x, bubble.origin.y - zone.center.y);
		CGFloat distance = sqrtf(vect.x*vect.x + vect.y*vect.y);
		
		distance *= self.view.zoomScale;
		
		if(distance > kMaximumBubbleDistanceFromNewCenter) {
			RootKey *key = bubble.key;
			NSLog(@"Bubble: %@ distance %f -> moving", key.key, distance);
			[updatedBubbles addObject:artist];
		}
	}
	
	return updatedBubbles;
}

#define kDiscoveryBubbleSize 64.0
#define kiPhoneScaleFactor 0.666
#define kLayoutMaxRadius	300.0

- (void)layoutDiscoveryBubbles:(NSSet *)artists forZone:(DiscoveryZone *)zone {
	
	if(artists.count == 0) {
		return;
	}
	
	BOOL isIpad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
	CGFloat sizeFactor = isIpad ? 1.0 : kiPhoneScaleFactor;
	CGFloat bubbleRadius = sizeFactor*kDiscoveryBubbleSize/self.view.zoomScale;
	
	NSMutableArray *layoutedBubbles = [bubbleMap.allValues mutableCopy];
	NSMutableArray *bubbles = [[NSMutableArray alloc] initWithCapacity:[artists count]];
	for(SMSimilarArtist *artist in artists) {
		Bubble *bubble = [self.bubbleFactory bubbleForDiscoveredArtist:artist withRadius:bubbleRadius];
		[bubbles addObject:bubble];
		[bubbleMap setObject:bubble forKey:artist.artistName];
	}
	
	CGRect layoutRect = CGRectInset(self.view.bubbleMainView.bubbleBoundingRect, bubbleRadius, bubbleRadius);
	CGPoint center = CGPointMake(zone.center.x, zone.center.y);
	DiscoveredBubbleLayouter *layouter = [[DiscoveredBubbleLayouter alloc] initWithCenterLocation:center withBounds:layoutRect withNumberOfBubbles:artists.count];
	
	float layoutRadius = fmaxf(150, zone.radius-50.0) / self.view.zoomScale;
	layoutRadius *= sizeFactor;
	
	NSLog(@"discovery: layout in %@, center: %@ radius: %f, bubbles: %d", [NSString stringFromRect:layoutRect], [NSString stringFromPoint:center], layoutRadius, bubbles.count);

	[layouter sortAndLayoutBubbles:bubbles inRadius:layoutRadius avoidingBubbles:layoutedBubbles];

	int i = 1;
	while(layouter.failedBubbles.count > 0 && layoutRadius < sizeFactor*kLayoutMaxRadius/self.view.zoomScale) {
		layoutRadius *= 1.1;
		++i;
		[layoutedBubbles addObjectsFromArray:layouter.succeededBubbles];
		[layouter sortAndLayoutBubbles:layouter.failedBubbles inRadius:layoutRadius avoidingBubbles:layoutedBubbles];
	}
	
	if(layouter.failedBubbles.count > 0) {
		NSLog(@"Layout: failed after pass %d: %d, last radius %f", i, layouter.failedBubbles.count, layoutRadius);		
	}
}

- (void)emptySimilarityZone {
	NSLog(@"empty discovery zone.");
	[bubbleMap removeAllObjects];
	[self.view reloadChildrenAtKeyPath:[NSArray array]];
	self.discoveredSimilarArtists = nil;
}

@end
