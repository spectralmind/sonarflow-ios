#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol PlaylistsListener;
@class PersistentStore;
@class SFNativeMediaFactory;

@interface PlaylistsObserver : NSObject

- (id)initWithContext:(NSManagedObjectContext *)theContext
				store:(PersistentStore *)theStore
			  factory:(SFNativeMediaFactory *)theFactory;

- (void)addListener:(id<PlaylistsListener>)listener;
- (void)removeListener:(id<PlaylistsListener>)listener;

@end

@protocol PlaylistsListener

- (void)handleDeletedPlaylists:(NSSet *)deletedPlaylists;
- (void)handleInsertedPlaylists:(NSSet *)insertedPlaylists;

@end
