#import <Foundation/Foundation.h>

@protocol SFMediaPlayer;
@protocol SFPlaylist;
@protocol SFMediaItem;

@protocol SFMediaLibraryDelegate;

@protocol SFMediaLibrary <NSObject>

@property (nonatomic, readonly, strong) NSArray *mediaItems;
@property (nonatomic, readonly, strong) NSMutableArray *playlists;
@property (nonatomic, readonly) NSObject<SFMediaPlayer> *player;
@property (nonatomic, weak) id<SFMediaLibraryDelegate> delegate;

- (void)startLoadingIfNeeded;

- (NSObject<SFMediaItem> *)mediaItemForKeyPath:(NSArray *)keyPath;
- (BOOL)containsArtistWithName:(NSString *)artistName;

- (void)insertMediaItems:(NSArray *)newMediaItems atIndexes:(NSIndexSet *)indexes;
- (void)removeMediaItemsAtIndexes:(NSIndexSet *)indexes;

- (void)insertPlaylists:(NSArray *)newPlaylists atIndexes:(NSIndexSet *)indexes;
- (void)removePlaylistsAtIndexes:(NSIndexSet *)indexes;

- (NSObject<SFPlaylist> *)newPlaylistWithName:(NSString *)name;

- (id<SFMediaItem>)mediaItemForDiscoveredArtistWithKey:(id)theKey name:(NSString *)artistName;

@end


@protocol SFMediaLibraryDelegate <NSObject>

- (void)libraryDidEncounterError:(NSError *)error;

@end
