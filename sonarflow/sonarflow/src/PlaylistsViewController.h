#import <UIKit/UIKit.h>

#import "SFPlaylistsViewDelegate.h"

@class MediaViewControllerFactory;

@protocol PlaylistsViewControllerDelegate;

@interface PlaylistsViewController : UINavigationController
		<SFPlaylistsViewDelegate>

- (id)initWithFactory:(MediaViewControllerFactory *)theFactory;

@property (nonatomic, weak) id<PlaylistsViewControllerDelegate> playlistDelegate;

@end

@protocol PlaylistsViewControllerDelegate

- (void)addedPlaylist:(NSObject<SFPlaylist> *)playlist;

@end