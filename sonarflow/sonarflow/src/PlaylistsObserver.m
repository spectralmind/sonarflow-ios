#import "PlaylistsObserver.h"

#import "PersistentStore.h"
#import "PlaylistDTO.h"
#import "SFNativeMediaFactory.h"
#import "UserPlaylist.h"

@interface PlaylistsObserver ()

@end


@implementation PlaylistsObserver {
	PersistentStore *store;
	SFNativeMediaFactory *factory;
	
	NSMutableArray *listeners;
	NSPredicate *playlistFilterPredicate;
}

- (id)initWithContext:(NSManagedObjectContext *)theContext
				store:(PersistentStore *)theStore
			  factory:(SFNativeMediaFactory *)theFactory {
	if(self = [super init]) {
		store = theStore;
		factory = theFactory;

		listeners = [[NSMutableArray alloc] init];
		playlistFilterPredicate = [NSPredicate predicateWithFormat:@"entity.name = \"Playlist\""];
		[self listenForChangesInContext:theContext];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)listenForChangesInContext:(NSManagedObjectContext *)context {
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(handleDataModelChange:)
		name:NSManagedObjectContextObjectsDidChangeNotification
		object:context];
}

- (void)addListener:(id<PlaylistsListener>)listener {
	[listeners addObject:listener];
}

- (void)removeListener:(id<PlaylistsListener>)listener {
	[listeners removeObject:listener];
}

- (void)handleDataModelChange:(NSNotification *)note {
	NSSet *deletedObjects = [[note userInfo] objectForKey:NSDeletedObjectsKey];
	NSSet *deletedPlaylistDTOs = [deletedObjects filteredSetUsingPredicate:playlistFilterPredicate];
	[self handleDeletedPlaylistDTOs:deletedPlaylistDTOs];
	
    NSSet *insertedObjects = [[note userInfo] objectForKey:NSInsertedObjectsKey];
	NSSet *insertedPlaylistDTOs = [insertedObjects filteredSetUsingPredicate:playlistFilterPredicate];
	[self handleInsertedPlaylistDTOs:insertedPlaylistDTOs];
}

- (void)handleDeletedPlaylistDTOs:(NSSet *)playlistDTOs {
	NSSet *playlists = [self playlistsFromDTOs:playlistDTOs];
	for(id<PlaylistsListener> listener in listeners) {
		[listener handleDeletedPlaylists:playlists];
	}
}

- (void)handleInsertedPlaylistDTOs:(NSSet *)playlistDTOs {
	NSSet *playlists = [self playlistsFromDTOs:playlistDTOs];
	for(id<PlaylistsListener> listener in listeners) {
		[listener handleInsertedPlaylists:playlists];
	}
}

- (NSSet *)playlistsFromDTOs:(NSSet *)playlistDTOs {
	NSMutableSet *playlists = [NSMutableSet setWithCapacity:[playlistDTOs count]];
	for(PlaylistDTO *dto in playlistDTOs) {
		if([dto.type isEqualToNumber:[NSNumber numberWithUnsignedInteger:PlaylistTypeNormal]] == NO) {
			continue;
		}
		id<SFPlaylist> playlist = [factory newPlaylistForDTO:dto];
		[playlists addObject:playlist];
	}
	return playlists;
}

@end
