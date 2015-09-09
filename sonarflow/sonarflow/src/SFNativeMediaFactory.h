#import <Foundation/Foundation.h>

@protocol SFMediaPlayer;
@protocol SFPlaylist;
@class SFTrack;
@class SFGenre;
@class GenreDefinition;
@class SFAlbum;
@class MPMediaItem;
@class NameGenreMapper;
@class PersistentStore;
@class SFNativeMediaPlayer;
@class PlaylistsObserver;
@class SFNativeMediaLibraryLoader;
@class GANHelper;
@class PlaylistDTO;
@class ImageFactory;
@class SFITunesDiscoveredArtist;
@class SFITunesPlayer;

@interface SFNativeMediaFactory : NSObject

- (id)initWithDocumentsDirectory:(NSString *)theDocumentsDirectory imageFactory:(ImageFactory *)theImageFactory;

@property (nonatomic, readonly) NameGenreMapper *nameGenreMapper;
@property (nonatomic, readonly) PersistentStore *store;
@property (nonatomic, readonly) id<SFMediaPlayer> player;
@property (nonatomic, readonly) PlaylistsObserver *playlistsObserver;

@property (nonatomic, assign) BOOL unknownGenreLookupEnabled;

- (SFNativeMediaLibraryLoader *)newLoaderWithGANHelper:(GANHelper *)ganHelper;

- (SFTrack *)newTrackForNativeMediaItem:(MPMediaItem *)nativeMediaItem;
- (SFGenre *)newGenreWithDefinition:(GenreDefinition *)definition;
- (SFAlbum *)newAlbumWithName:(NSString *)name;
- (SFITunesDiscoveredArtist *)newDiscoveredArtistWithKey:(id)key name:(NSString *)name;
- (id<SFPlaylist>)newPlaylistForDTO:(PlaylistDTO *)dto;

@end
