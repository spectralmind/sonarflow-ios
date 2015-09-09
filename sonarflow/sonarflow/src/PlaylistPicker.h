#import <Foundation/Foundation.h>

#import "SFPlaylistsViewDelegate.h"

@class MediaViewControllerFactory;

@protocol SFPlaylist;
@protocol PlaylistPickerDelegate;

@interface PlaylistPicker : UINavigationController
		<SFPlaylistsViewDelegate> {
	id<PlaylistPickerDelegate> __weak playlistDelegate;
}

@property (nonatomic, weak) id<PlaylistPickerDelegate> playlistDelegate;

- (id)initWithFactory:(MediaViewControllerFactory *)factory;
- (void)setPrompt:(NSString *)prompt;

@end

@protocol PlaylistPickerDelegate

- (void)pickedPlaylist:(NSObject<SFPlaylist> *)playlist;

@end