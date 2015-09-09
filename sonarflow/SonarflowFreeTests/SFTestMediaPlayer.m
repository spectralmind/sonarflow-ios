#import "SFTestMediaPlayer.h"

#import "SFMediaItem.h"

@implementation SFTestMediaPlayer

@synthesize playbackState;
@synthesize nowPlaying;
@synthesize nowPlayingLeaf;
@synthesize nowPlayingLeafPlaybackTime;
@synthesize nowPlayingLeafDuration;
@synthesize automaticPlaylists;
@synthesize shuffle;
@synthesize canHandleRemoteControlEvents;

- (void)skipToNextItem {
}

- (void)skipToPrevousItem {
}

- (void)setProgress:(float)progress {
}

- (void)pausePlayback {
}

- (void)resumePlayback {
}

- (void)togglePlayback {
}

- (BOOL)isNowPlayingItem:(id<SFMediaItem>)mediaItem {
	return NO;
}

- (void)handleRemoteControlEvent:(UIEvent *)event {
}

@end
