#import <Foundation/Foundation.h>

@protocol SFMediaItem;

typedef enum {
	SFPlaybackStatePaused,
	SFPlaybackStatePlaying
} SFPlaybackState;

@protocol SFMediaPlayer <NSObject>

@property (nonatomic, readonly, assign) SFPlaybackState playbackState;
@property (nonatomic, readonly, strong) id<SFMediaItem> nowPlaying;
@property (nonatomic, readonly, strong) id<SFMediaItem> nowPlayingLeaf;
@property (nonatomic, readonly, assign) NSTimeInterval nowPlayingLeafPlaybackTime;
@property (nonatomic, readonly, strong) NSNumber *nowPlayingLeafDuration;
@property (nonatomic, readonly, strong) NSArray *automaticPlaylists;
@property (nonatomic, assign) BOOL shuffle;
@property (nonatomic, readonly, assign) BOOL canHandleRemoteControlEvents;

- (void)skipToNextItem;
- (void)skipToPrevousItem;
- (void)setProgress:(float)progress;
- (void)pausePlayback;
- (void)resumePlayback;
- (void)togglePlayback;
- (BOOL)isNowPlayingItem:(id<SFMediaItem>)mediaItem;
@optional
- (void)handleRemoteControlEvent:(UIEvent *)event;
- (void)updateNowPlayingItem;

@end
