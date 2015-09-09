#import <Foundation/Foundation.h>

@protocol SFPlaylist;

@protocol SFPlaylistsViewDelegate <NSObject>

- (void)addedPlaylist:(NSObject<SFPlaylist> *)playlist;
- (void)selectedPlaylist:(NSObject<SFPlaylist> *)playlist;

@end
