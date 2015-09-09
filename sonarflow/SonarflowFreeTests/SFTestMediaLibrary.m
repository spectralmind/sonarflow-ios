#import "SFTestMediaLibrary.h"

#import "SFMediaLibraryHelper.h"
#import "SFTestRootMediaItem.h"

@implementation SFTestMediaLibrary {
	NSMutableArray *mediaItems;
}

- (id)init {
    self = [super init];
    if (self) {
        mediaItems = [[NSMutableArray alloc] init];
    }
    return self;
}

@synthesize mediaItems;
@synthesize playlists;
@synthesize player;
@synthesize delegate;

- (void)startLoadingIfNeeded {
}

- (NSObject<SFMediaItem> *)mediaItemForKeyPath:(NSArray *)keyPath {
	return [SFMediaLibraryHelper mediaItemForKeyPath:keyPath inArray:self.mediaItems];
}

- (BOOL)containsArtistWithName:(NSString *)artistName {
	return YES;
}

- (void)insertMediaItems:(NSArray *)newMediaItems atIndexes:(NSIndexSet *)indexes {
	[mediaItems insertObjects:newMediaItems atIndexes:indexes];
}

- (void)removeMediaItemsAtIndexes:(NSIndexSet *)indexes {
	[mediaItems removeObjectsAtIndexes:indexes];
}

- (void)insertPlaylists:(NSArray *)newPlaylists atIndexes:(NSIndexSet *)indexes {
	
}

- (void)removePlaylistsAtIndexes:(NSIndexSet *)indexes {
	
}

- (NSObject<SFPlaylist> *)newPlaylistWithName:(NSString *)name {
	return nil;
}

- (id<SFMediaItem>)mediaItemForDiscoveredArtistWithKey:(id)theKey name:(NSString *)artistName {
	return nil;
}

- (SFTestRootMediaItem *)addMediaItemWithKey:(id)aKey {
	SFTestRootMediaItem *mediaItem = [[SFTestRootMediaItem alloc] initWithKey:aKey];
	mediaItem.library = self;
	[self addMediaItem:mediaItem];
	return mediaItem;
}

- (void)addMediaItem:(id<SFMediaItem>)mediaItem {
	[self insertMediaItems:@[mediaItem] atIndexes:[NSIndexSet indexSetWithIndex:[mediaItems count]]];
}

- (void)removeMediaItem:(id<SFMediaItem>)mediaItem {
	[self removeMediaItemsAtIndexes:[NSIndexSet indexSetWithIndex:[mediaItems indexOfObject:mediaItem]]];
}

- (NSUInteger)size {
	NSUInteger sum = 0;
	for(SFTestRootMediaItem *item in self.mediaItems) {
		sum += [item totalSize];
	}
	return sum;
}

@end
