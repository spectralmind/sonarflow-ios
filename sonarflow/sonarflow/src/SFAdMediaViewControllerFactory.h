#import "MediaViewControllerFactory.h"

@class AdMobHandler;

@interface SFAdMediaViewControllerFactory : MediaViewControllerFactory

- (id)initWithButtonFactory:(DismissButtonFactory *)theButtonFactory playlistEditor:(NSObject<PlaylistEditor> *)thePlaylistEditor imageFactory:(ImageFactory *)theImageFactory playbackDelegate:(id<PlaybackDelegate>)thePlaybackDelegate player:(NSObject<SFMediaPlayer> *)thePlayer library:(NSObject<SFMediaLibrary> *)theLibrary adHandler:(AdMobHandler *)theAdHandler;

@end
