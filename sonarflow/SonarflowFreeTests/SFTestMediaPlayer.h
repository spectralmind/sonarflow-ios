#import <Foundation/Foundation.h>

#import "SFMediaPlayer.h"

@interface SFTestMediaPlayer : NSObject <SFMediaPlayer>

@property (nonatomic, readwrite, assign) SFPlaybackState playbackState;
@property (nonatomic, readwrite, retain) id<SFMediaItem> nowPlaying;
@property (nonatomic, readwrite, retain) id<SFMediaItem> nowPlayingLeaf;
@property (nonatomic, readwrite, assign) NSTimeInterval nowPlayingLeafPlaybackTime;
@property (nonatomic, readwrite, retain) NSNumber *nowPlayingLeafDuration;
@property (nonatomic, readwrite, retain) NSArray *automaticPlaylists;
@property (nonatomic, readwrite, assign) BOOL canHandleRemoteControlEvents;

@end
