#import "SFITunesPlayer.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "SFITunesDiscoveredArtist.h"
#import "SFITunesMediaItem.h"
#import "SFITunesAudioTrack.h"
#import "SFObserver.h"
#import "SFPlaybackQueue.h"

@interface SFITunesPlayer () <SFObserverDelegate>

@property (nonatomic, readwrite, assign) SFPlaybackState playbackState;
@property (nonatomic, readwrite, strong) id<SFMediaItem> nowPlaying;
@property (nonatomic, readwrite, strong) id<SFMediaItem> nowPlayingLeaf;
@property (nonatomic, strong) MPMoviePlayerController *playController;
@property (nonatomic, strong) SFObserver *loadingObserver;
@property (nonatomic, weak) NSTimer *timelineRefreshTimer;

@end


@implementation SFITunesPlayer {
	SFPlaybackQueue *playbackQueue;
}

- (id)init {
    self = [super init];
    if (self) {
		playbackQueue = [[SFPlaybackQueue alloc] init];
    }
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


@synthesize playbackState;
@synthesize nowPlayingLeaf;
@synthesize nowPlaying;
- (void)setNowPlaying:(id<SFMediaItem>)newNowPlaying {
	if(nowPlaying == newNowPlaying) {
		return;
	}
	self.loadingObserver = nil;
	self.nowPlayingLeaf = nil;
	nowPlaying = newNowPlaying;
}

@synthesize nowPlayingLeafPlaybackTime;
@synthesize loadingObserver;
@synthesize timelineRefreshTimer;
- (void)setTimelineRefreshTimer:(NSTimer *)newTimelineRefreshTimer {
	[timelineRefreshTimer invalidate];
	timelineRefreshTimer = newTimelineRefreshTimer;
}

- (void)setShuffle:(BOOL)shuffle {
	playbackQueue.shuffle = shuffle;
}

- (BOOL)shuffle {
	return playbackQueue.shuffle;
}

@synthesize playController;
- (void)setPlayController:(MPMoviePlayerController *)newPlayCongtroller {
	if(playController == newPlayCongtroller) {
		return;
	}
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	if(playController != nil) {
		[notificationCenter removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:playController];
		[playController stop];
		[notificationCenter removeObserver:self name:MPMovieDurationAvailableNotification object:playController];
		[notificationCenter removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:playController];
	}

	playController = newPlayCongtroller;
	playController.useApplicationAudioSession = NO;
	if(playController != nil) {
		[notificationCenter addObserver:self
							   selector:@selector(playbackStateChanged:)
								   name:MPMoviePlayerPlaybackStateDidChangeNotification
								 object:playController];
		[notificationCenter addObserver:self
							   selector:@selector(durationChanged:)
								   name:MPMovieDurationAvailableNotification
								 object:playController];
		[notificationCenter addObserver:self
							   selector:@selector(playbackFinished:)
								   name:MPMoviePlayerPlaybackDidFinishNotification
								 object:playController];
	}
	[self updatePlaybackState];
	[self updateNowPlayingLeafPlaybackTime];
}

- (void)playbackStateChanged:(NSNotification *)notification {
	[self updatePlaybackState];
}

- (void)durationChanged:(NSNotification *)notification {
	self.nowPlayingLeafDuration = [NSNumber numberWithFloat:self.playController.duration];
}

- (void)playbackFinished:(NSNotification *)notification {
	
	if(self.playController.currentPlaybackTime < self.playController.duration) {
		return;
	}
	
	[self skipToNextItem];
}

- (void)updatePlaybackState {
	self.playbackState = [self playbackStateFromPlayerState:self.playController.playbackState];
	if(self.playbackState == SFPlaybackStatePlaying) {
		self.timelineRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshTimelineTimerFired:)
																   userInfo:nil repeats:YES];
	}
	else {
		self.timelineRefreshTimer = nil;
	}
}

- (SFPlaybackState)playbackStateFromPlayerState:(MPMoviePlaybackState)playerState {
	switch(playerState) {
		case MPMoviePlaybackStateStopped:
		case MPMoviePlaybackStatePaused:
		case MPMoviePlaybackStateInterrupted:
			return SFPlaybackStatePaused;
		case MPMoviePlaybackStatePlaying:
		case MPMoviePlaybackStateSeekingForward:
		case MPMoviePlaybackStateSeekingBackward:
			return SFPlaybackStatePlaying;
		default:
			NSAssert(0, @"Unknown playback state");
			return SFPlaybackStatePaused;
	}
}

- (void)refreshTimelineTimerFired:(NSTimer *)timer {
	[self updateNowPlayingLeafPlaybackTime];
}

- (void)updateNowPlayingLeafPlaybackTime {
	self.nowPlayingLeafPlaybackTime = self.playController.currentPlaybackTime;
}

- (NSArray *)automaticPlaylists {
	return nil;
}

- (void)skipToNextItem {
	if([playbackQueue hasNextItem] == NO) {
		self.playbackState = SFPlaybackStatePaused;
		return; //TODO: improve behaviour
	}
	
	[playbackQueue skipToNextItem];
	[self playCurrentQueueItem];
}

- (void)skipToPrevousItem {
	if([playbackQueue hasPreviousItem] == NO) {
		self.playbackState = SFPlaybackStatePaused;
		return; //TODO: improve behaviour
	}
	
	[playbackQueue skipToPreviousItem];
	[self playCurrentQueueItem];
}

- (void)setProgress:(float)progress {
	if(self.nowPlayingLeafDuration == nil) {
		return;
	}
	self.playController.currentPlaybackTime = progress * self.playController.duration;
}

- (void)pausePlayback {
	[self.playController pause];
}

- (void)resumePlayback {
	[self.playController play];
}

- (BOOL)isNowPlayingItem:(id<SFMediaItem>)mediaItem {
	return [SFAbstractMediaPlayer isAudioTrack:(id<SFAudioTrack>)nowPlayingLeaf equivalentToMediaItem:mediaItem];
}

- (BOOL)canHandleRemoteControlEvents {
	return YES;
}

- (void)play:(id<SFITunesMediaItem>)mediaItem {
	self.nowPlaying = mediaItem;
	[self startPlayingWhenLoaded:mediaItem];
}

- (void)startPlayingWhenLoaded:(id<SFITunesMediaItem>) mediaItem {	
	if(mediaItem.loading) {
		NSLog(@"Waiting until %@ is loaded", mediaItem);
		self.loadingObserver = [[SFObserver alloc] initWithObject:mediaItem keyPath:@"loading" delegate:self];
	}
	else {
		[playbackQueue replaceQueue:[mediaItem tracks]];
		[self playCurrentQueueItem];
	}
}

- (void)play:(id<SFITunesMediaItem>)mediaItem startingAtIndex:(NSUInteger)index {
	NSAssert(mediaItem.loading == NO, @"Item is still loading when starting to play");

	self.nowPlaying = mediaItem;
	[playbackQueue replaceQueue:[mediaItem tracks] startingAtIndex:index];
	[self playCurrentQueueItem];
}

- (void)playCurrentQueueItem {
	NSAssert([(id<SFITunesMediaItem>)self.nowPlaying loading] == NO, @"Item is still loading when starting to play");

	SFITunesAudioTrack *track = playbackQueue.currentItem;
	self.nowPlayingLeaf = track;
	self.nowPlayingLeafDuration = nil;
	if(track != nil) {
		[self enableAudioSessionWithCategory:AVAudioSessionCategoryPlayback];
		self.playController = [[MPMoviePlayerController alloc] initWithContentURL:track.url];
		[self.playController play];
	}
	else {
		self.playController = nil;
		self.playbackState = SFPlaybackStatePaused;
	}
	[self publishNowPlayingInfoForQueue:playbackQueue];
}

#pragma mark - SFObserverDelegate

- (void)object:(id)object wasSetFrom:(id)oldValue to:(id)newValue {
	NSAssert(object == self.nowPlaying, @"Unexpected object observed");
	[playbackQueue replaceQueue:[object tracks]];
	[self playCurrentQueueItem];
}

@end
