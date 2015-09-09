#import <Foundation/Foundation.h>

#import "SFPlaylist.h"
#import "SFNativeMediaItem.h"

@class PlaylistDTO;
@class PersistentStore;
@class SFNativeMediaPlayer;

@interface UserPlaylist : NSObject <SFPlaylist, SFNativeMediaItem>

- (id)initWithDTO:(PlaylistDTO *)thePlaylistDTO
			store:(PersistentStore *)theStore
		   player:(SFNativeMediaPlayer *)thePlayer;

@end
