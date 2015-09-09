#import "SFNativeMediaLibrary.h"

#import <MediaPlayer/MediaPlayer.h>
#import "AppStatusObserver.h"
#import "SFNativeMediaPlayer.h"
#import "SFGenre.h"
#import "GANHelper.h"
#import "SFNativeMediaFactory.h"
#import "PersistentStore.h"
#import "SFNativeMediaLibraryLoader.h"
#import "PlaylistDTO.h"
#import "UserPlaylist.h"
#import "PersistentStore.h"
#import "PlaylistsObserver.h"
#import "SFMediaLibraryHelper.h"
#import "SFITunesDiscoveredArtist.h"


@interface SFNativeMediaLibrary () <SFNativeMediaLibraryLoaderDelegate,
	AppStatusObserverDelegate, PlaylistsListener>

@property (nonatomic, readwrite, strong) NSArray *mediaItems;
@property (nonatomic, readwrite, strong) NSMutableArray *playlists;

@end


@implementation SFNativeMediaLibrary {
	GANHelper *ganHelper;
	SFNativeMediaFactory *factory;
	SFNativeMediaLibraryLoader *loader;
	SFNativeMediaPlayer *player;
	AppStatusObserver *statusObserver;

	NSMutableArray *mediaItems;
}

- (id)initWithDocumentsDirectory:(NSString *)documentsDirectory ganHelper:(GANHelper *)theGanHelper imageFactory:(ImageFactory *)theImageFactory otherBubbleFixup:(BOOL)unknownGenreLookupEnabled {
	self = [super init];
	if(self) {
		ganHelper = theGanHelper;
		factory = [[SFNativeMediaFactory alloc] initWithDocumentsDirectory:documentsDirectory imageFactory:theImageFactory];
		factory.unknownGenreLookupEnabled = unknownGenreLookupEnabled;
		
		player = factory.player;

		statusObserver = [[AppStatusObserver alloc]
						  initWithBecomeActiveDelay:0];
		statusObserver.delegate = self;
		
		[factory.playlistsObserver addListener:self];
	}
	return self;
}

- (void)dealloc {
	[factory.playlistsObserver removeListener:self];
}

@synthesize mediaItems;
@synthesize playlists;
@synthesize player;
@synthesize delegate;

- (void)startLoadingIfNeeded {
	if(loader == nil) {
		loader = [factory newLoaderWithGANHelper:ganHelper];
		loader.delegate = self;
	}
	[loader startIfNecessary];
	if(self.playlists == nil) {
		self.playlists = [self loadPlaylists];
	}
}

- (NSMutableArray *)loadPlaylists {
	NSArray *dtos = [factory.store playlists];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[dtos count]];
	for(PlaylistDTO *dto in dtos) {
		id<SFPlaylist> playlist = [self newPlaylistForDTO:dto];
		[result addObject:playlist];
	}

	return result;
}

- (NSObject<SFMediaItem> *)mediaItemForKeyPath:(NSArray *)keyPath {
	return [SFMediaLibraryHelper mediaItemForKeyPath:keyPath inArray:self.mediaItems];
}

-(BOOL)containsArtistWithName:(NSString *)artistName {
	for(id<SFMediaItem> item in mediaItems) {
		id<SFMediaItem> result = [item childWithKey:[artistName lowercaseString]];
		if(result != nil) {
			return YES;
		}
	}

	return NO;
}

- (id<SFPlaylist>)newPlaylistWithName:(NSString *)name {
	PlaylistDTO *dto = [factory.store addPlaylist];
	dto.name = name;
	dto.order = [NSNumber numberWithInteger:[self.playlists count]];
	return [self newPlaylistForDTO:dto];
}

- (id<SFPlaylist>)newPlaylistForDTO:(PlaylistDTO *)dto {
	return [factory newPlaylistForDTO:dto];
}

- (void)insertMediaItems:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
	[mediaItems insertObjects:array atIndexes:indexes];
}

- (void)removeMediaItemsAtIndexes:(NSIndexSet *)indexes {
	[mediaItems removeObjectsAtIndexes:indexes];
}

- (void)insertPlaylists:(NSArray *)newPlaylists atIndexes:(NSIndexSet *)indexes {
	[self.playlists insertObjects:newPlaylists atIndexes:indexes];
}

- (void)removePlaylistsAtIndexes:(NSIndexSet *)indexes {
	[self.playlists removeObjectsAtIndexes:indexes];
}

- (id<SFMediaItem>)mediaItemForDiscoveredArtistWithKey:(id)theKey name:(NSString *)artistName {
	return [factory newDiscoveredArtistWithKey:theKey name:artistName];
}

#pragma mark - SFNativeMediaLibraryLoaderDelegate

- (void)willStartLoading {
	self.mediaItems = [NSMutableArray arrayWithCapacity:10];
}


- (void)loadedGenre:(SFGenre *)genre {
	[self insertMediaItems:[NSArray arrayWithObject:genre]
				 atIndexes:[NSIndexSet indexSetWithIndex:[self.mediaItems count]]];
}

- (void)didFinishLoading {
	if([player respondsToSelector:@selector(updateNowPlayingItem)]) {
		[player updateNowPlayingItem];
	}
}

- (void)loadingFailedWithError:(NSError *)error {
	[self.delegate libraryDidEncounterError:error];
}

#pragma mark - AppStatusObserverDelegate

- (void)appWillResignActive {
	[factory.store save];
}

#pragma mark - PlaylistsListener

- (void)handleDeletedPlaylists:(NSSet *)deletedPlaylists {
	[self removePlaylistsAtIndexes:[self indexSetForPlaylists:deletedPlaylists]];
}

- (void)handleInsertedPlaylists:(NSSet *)insertedPlaylists {
	NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.playlists count], [insertedPlaylists count])];
	NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
	NSArray *insertedPlaylistsArray = [insertedPlaylists sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	[self insertPlaylists:insertedPlaylistsArray atIndexes:indexes];
}

- (NSIndexSet *)indexSetForPlaylists:(NSSet *)playlistSet {
	NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
	for(id<SFPlaylist> playlist in playlistSet) {
		NSUInteger index = [self.playlists indexOfObject:playlist];
		NSAssert(index != NSNotFound, @"Unknown playlist deleted");
		[indexes addIndex:index];
	}
	return indexes;
}

@end
