#import "UserPlaylist.h"

#import "PersistentStore.h"
#import "PlaylistDTO.h"
#import "PlaylistEntryDTO.h"
#import "SFArrayObserver.h"
#import "SFNativeMediaPlayer.h"
#import "SFNativeTrack.h"

@interface UserPlaylist () <SFArrayObserverDelegate>

@property (nonatomic, readonly) PlaylistDTO *playlistDTO;
@property (nonatomic, readwrite, strong) NSArray *children;
@property (nonatomic, strong) SFArrayObserver *playlistObserver;

@end


@implementation UserPlaylist {
	@private
	PlaylistDTO *playlistDTO;
	PersistentStore *store;
	SFNativeMediaPlayer *player;

	BOOL updating;
	NSMutableArray *children;
}

- (id)initWithDTO:(PlaylistDTO *)thePlaylistDTO
			store:(PersistentStore *)theStore
		   player:(SFNativeMediaPlayer *)thePlayer {
	self = [super init];
	if(self) {
		playlistDTO = thePlaylistDTO;
		store = theStore;
		player = thePlayer;
	}
	return self;
}

@synthesize children;
- (NSArray *)children {
	if(children == nil) {
		[self updateChildren];
		if(children != nil) {
			self.playlistObserver = [[SFArrayObserver alloc] initWithObject:playlistDTO keyPath:@"entries" delegate:self];
		}
	}
	return children;
}

@synthesize playlistObserver;

- (void)updateChildren {
	if(updating) {
		return; //Accessing sortedEntries can cause the fault to trigger and KVO to become active -> ignore this call
	}
	updating = YES;
	self.children = [[playlistDTO sortedEntries] mutableCopy];
	updating = NO;
}

@synthesize playlistDTO;

- (id)key {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSArray *)keyPath {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id<SFMediaItem>)parent {
	return nil;
}

- (NSNumber *)duration {
	return nil; //Not needed atm.
}

- (BOOL)mayHaveChildren {
	return YES;
}

- (void)insertChildren:(NSArray *)newChildren atIndexes:(NSIndexSet *)indexes {
	[children insertObjects:newChildren atIndexes:indexes];
}

- (void)removeChildrenAtIndexes:(NSIndexSet *)indexes {
    [children removeObjectsAtIndexes:indexes];
}

- (BOOL)isEditable {
	return YES;
}

- (void)deleteChildAtIndex:(NSUInteger)index {
	PlaylistEntryDTO *entry = [self.children objectAtIndex:index];
	[store deleteEntry:entry];
//	[self removeChildrenAtIndexes:[NSIndexSet indexSetWithIndex:index]];
	[self updateEntryOrder];
}

- (void)moveChildFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
	PlaylistEntryDTO *entry = [self.children objectAtIndex:fromIndex];
	[self removeChildrenAtIndexes:[NSIndexSet indexSetWithIndex:fromIndex]];
	[self insertChildren:[NSArray arrayWithObject:entry] atIndexes:[NSIndexSet indexSetWithIndex:toIndex]];
	[self updateEntryOrder];
}

- (BOOL)showAsBubble {
	return NO;
}

- (BOOL)hasDetailViewController {
	return YES;
}

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
	//TODO
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (BOOL)mayHaveImage {
	return NO;
}

- (void)startPlayback {
	[player playMediaItem:self];
}

- (void)startPlaybackAtChildIndex:(NSUInteger)childIndex; {
	[player playMediaItem:self startingAtIndex:childIndex];
}

- (NSComparisonResult)compareKeys:(id<SFMediaItem>)other {
	[self doesNotRecognizeSelector:_cmd];
	return NSOrderedSame;
}

- (void)updateEntryOrder {
	NSUInteger index = 0;
	for(PlaylistEntryDTO *entry in self.children) {
		if([entry.order unsignedIntegerValue] != index) {
			entry.order = [NSNumber numberWithUnsignedInteger:index];
		}
		++index;
	}
}

- (BOOL)isReadOnly {
	return NO;
}

- (NSString *)name {
	return [playlistDTO name];
}

- (NSNumber *)order {
	return [playlistDTO order];
}

- (void)setOrder:(NSNumber *)order {
	if(![playlistDTO.order isEqualToNumber:order]) {
		playlistDTO.order = order;
	}
}

- (void)addMediaItem:(id<SFMediaItem>)mediaItem {
	NSAssert([mediaItem conformsToProtocol:@protocol(SFNativeMediaItem)], @"MediaItem does not conform to HasTracks");
	id<SFNativeMediaItem> hasTracks = (id<SFNativeMediaItem>)mediaItem;
	NSArray *tracks = [hasTracks tracks];
	NSMutableSet *newEntries = [[NSMutableSet alloc] initWithCapacity:[tracks count]];
	NSUInteger nextOrder = [self numTracks];
	for(id<SFNativeTrack> track in [hasTracks tracks]) {
		NSAssert([track conformsToProtocol:@protocol(SFNativeTrack)], @"Track does not conform to SFNativeTrack");
		PlaylistEntryDTO *entry = [store addEntryFromTrack:track];
		entry.order = [NSNumber numberWithUnsignedInteger:nextOrder];
		++nextOrder;
		[newEntries addObject:entry];
	}
	[playlistDTO addEntries:newEntries];
	[store save];
}

- (void)clear {
	[playlistDTO removeEntries:playlistDTO.entries];
}

- (void)deleteList {
	[store deletePlaylist:playlistDTO];
}

- (BOOL)isEqualToPlaylist:(id<SFPlaylist>)playlist {
	return [self isEqual:playlist];
}

#pragma mark -
#pragma mark HasTracks

- (NSUInteger)numTracks {
	return [self.children count];
}

- (NSArray *)tracks {
	return self.children;
}

- (BOOL)isEqual:(id)object {
	if(![object isKindOfClass:[UserPlaylist class]]) {
		return NO;
	}
	
	UserPlaylist *otherPlaylist = (UserPlaylist *)object;
	return [self.playlistDTO isEqual:otherPlaylist.playlistDTO];
}

- (NSUInteger)hash {
	return [playlistDTO hash];
}

#pragma mark - SFArrayObserverDelegate

- (void)object:(NSObject *)object wasSetFrom:(NSArray *)oldValue to:(NSArray *)newValue {
	[self updateChildren];
}

- (void)objects:(NSArray *)objects wereInsertedAtIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	[self updateChildren];
}

- (void)objects:(NSArray *)objects wereDeletedAtIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	[self updateChildren];
}

- (void)objects:(NSArray *)oldObjects wereReplacedWithObjects:(NSArray *)newObjects atIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	[self updateChildren];
}

@end
