#import "SFNativeMediaFactory.h"

#import "NameGenreMapper.h"
#import "PersistentStore.h"
#import "ArtworkFactory.h"
#import "SFTrack.h"
#import "SFGenre.h"
#import "SFAlbum.h"
#import "GenreXMLParser.h"
#import "SFNativeMediaPlayer.h"
#import "PlaylistsObserver.h"
#import "SFCompositeMediaPlayer.h"
#import "SFNativeMediaLibraryLoader.h"
#import "UserPlaylist.h"
#import "SFITunesDiscoveredArtist.h"
#import "SFITunesPlayer.h"

@implementation SFNativeMediaFactory {
	NSString *documentsDirectory;
	NameGenreMapper *nameGenreMapper;
	ArtworkFactory *artworkFactory;
	SFNativeMediaPlayer *nativePlayer;
	SFITunesPlayer *iTunesPlayer;
	id<SFMediaPlayer> player;
	PlaylistsObserver *playlistsObserver;

    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
	PersistentStore *store;
}

- (id)initWithDocumentsDirectory:(NSString *)theDocumentsDirectory imageFactory:(ImageFactory *)theImageFactory {
    self = [super init];
    if (self) {
		documentsDirectory = theDocumentsDirectory;
		nameGenreMapper = [[NameGenreMapper alloc] initWithGenreDefinitions:[self loadGenreDefintions]];
		artworkFactory = [[ArtworkFactory alloc] initWithImageFactory:theImageFactory];
		store = [[PersistentStore alloc] initWithContext:self.managedObjectContext];
		nativePlayer = [[SFNativeMediaPlayer alloc] initWithPersistentStore:store mediaFactory:self];
		iTunesPlayer = [[SFITunesPlayer alloc] init];
		player = [[SFCompositeMediaPlayer alloc] initWithPlayers:[NSArray arrayWithObjects:nativePlayer, iTunesPlayer, nil]];
		playlistsObserver = [[PlaylistsObserver alloc] initWithContext:self.managedObjectContext
																 store:store factory:self];
    }
    return self;
}


@synthesize nameGenreMapper;
@synthesize store;
@synthesize player;
@synthesize playlistsObserver;

- (NSArray *)loadGenreDefintions {
	BOOL shouldFlipAxes = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad);
	GenreXMLParser *genreParser = [[GenreXMLParser alloc] initWithFlipAxes:shouldFlipAxes];
	
    if([genreParser parse] == NO) {
		
        NSLog(@"could not parse xml genre file");
		return nil;
    }
	
	NSArray *results = genreParser.genres;
	
	return results;
}

- (SFNativeMediaLibraryLoader *)newLoaderWithGANHelper:(GANHelper *)ganHelper {
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	queue.maxConcurrentOperationCount = 5;
	return [[SFNativeMediaLibraryLoader alloc] initWithFactory:self ganHelper:ganHelper  operationQueue:queue lookupUnknownGenres:self.unknownGenreLookupEnabled];
}

- (SFTrack *)newTrackForNativeMediaItem:(MPMediaItem *)nativeMediaItem {
	return 	[[SFTrack alloc] initWithItem:nativeMediaItem
						   artworkFactory:artworkFactory nameGenreMapper:nameGenreMapper player:nativePlayer];
}

- (SFGenre *)newGenreWithDefinition:(GenreDefinition *)definition {
	return [[SFGenre alloc] initWithGenreDefinition:definition player:nativePlayer];
}

- (SFAlbum *)newAlbumWithName:(NSString *)name {
	return [[SFAlbum alloc] initWithName:name player:nativePlayer artworkFactory:artworkFactory];
}

- (SFITunesDiscoveredArtist *)newDiscoveredArtistWithKey:(id)key name:(NSString *)name {
	return [[SFITunesDiscoveredArtist alloc] initWithKey:key name:name player:iTunesPlayer];
}

- (id<SFPlaylist>)newPlaylistForDTO:(PlaylistDTO *)dto {
	return [[UserPlaylist alloc] initWithDTO:dto store:store player:nativePlayer];
}

#pragma mark -
#pragma mark Core Data stack

- (NSManagedObjectContext *)managedObjectContext {
    if(managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if(coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}

- (NSManagedObjectModel *)managedObjectModel {
    if(managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"Sonarflow" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if(persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
	NSString *storePath = [documentsDirectory stringByAppendingPathComponent: @"Sonarflow.sqlite"];
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES],NSInferMappingModelAutomaticallyOption, nil];
	
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSError *error = nil;
    if(![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
		
		//TODO:Migrate
		
		NSError *fileError = nil;
		if(![[NSFileManager defaultManager] removeItemAtPath:storePath error:&fileError]) {
			NSLog(@"Unresolved error %@, %@", fileError, [fileError userInfo]);
			abort();
		}
		
		//try again
		if(![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
    }    
    
    return persistentStoreCoordinator_;
}

@end
