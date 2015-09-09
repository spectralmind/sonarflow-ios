#import <Foundation/Foundation.h>

@protocol PlaybackDelegate;
@protocol SFMediaItem;
@protocol SFMediaPlayer;
@protocol SFMediaLibrary;
@protocol SFPlaylist;
@protocol PlaylistEditor;
@protocol SFPlaylistsViewDelegate;
@class DismissButtonFactory;
@class ImageFactory;
@class SFSectionsTableViewController;

@interface MediaViewControllerFactory : NSObject

- (id)initWithButtonFactory:(DismissButtonFactory *)theButtonFactory playlistEditor:(NSObject<PlaylistEditor> *)thePlaylistEditor imageFactory:(ImageFactory *)theImageFactory playbackDelegate:(id<PlaybackDelegate>)thePlaybackDelegate player:(NSObject<SFMediaPlayer> *)thePlayer library:(NSObject<SFMediaLibrary> *)theLibrary;

@property (nonatomic, readonly) ImageFactory *imageFactory;
@property (weak, nonatomic, readonly) NSObject<SFMediaPlayer> *player;

- (UIViewController *)viewControllerForGenre:(id<SFMediaItem>)genre;
- (UIViewController *)viewControllerForArtist:(id<SFMediaItem>)artist singleArtist:(BOOL)singleArtist;
- (UIViewController *)viewControllerForAlbum:(id<SFMediaItem>)album showAlbums:(BOOL)theShowAlbums showArtists:(BOOL)theShowArtists showTracksNumber:(BOOL)theShowTrackNumbers;
- (UIViewController *)viewControllerForDiscoveredArtist:(id<SFMediaItem>)artist;

- (UIViewController *)viewControllerForPlaylistsWithDelegate:(id<SFPlaylistsViewDelegate>)delegate asPicker:(BOOL)asPicker;
- (UIViewController *)viewControllerForPlaylist:(NSObject<SFPlaylist> *)playlist;
- (UIViewController *)viewControllerForTrack:(id<SFMediaItem>)track;

//Virtual
- (SFSectionsTableViewController *)viewControllerWithTitle:(NSString *)title sections:(NSArray *)sections;
- (NSArray *)childrenSectionsForArtist:(NSObject<SFMediaItem> *)artist singleArtist:(BOOL)singleArtist;

@end
