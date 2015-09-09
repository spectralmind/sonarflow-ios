#import "SFSpotifyPlayer.h"

#import <AVFoundation/AVFoundation.h>
#import <CocoaLibSpotify.h>
#import "AppStatusObserver.h"
#import "CoalescingDispatcher.h"
#import "SFMediaItem.h"
#import "SFObserver.h"
#import "SFSpotifyFactory.h"
#import "SFSpotifyMediaItem.h"
#import "SFSpotifyTrack.h"
#import "SFPlaybackQueue.h"

static const float kSeekDelay = 0.5f;

@interface SFSpotifyPlayer () <AppStatusObserverDelegate, SPSessionPlaybackDelegate, SFObserverDelegate, SPPlaybackManagerDelegate>

@property (nonatomic, strong) SPPlaybackManager *playbackManager;

@property (nonatomic, assign) SFPlaybackState playbackState;
@property (nonatomic, strong) id<SFMediaItem> nowPlaying;
@property (nonatomic, strong) SFObserver *loadingObserver;
@property (nonatomic, strong) id<SFMediaItem> nowPlayingLeaf;
@property (nonatomic, assign) float nowPlayingLeafProgress;
@property (nonatomic, assign) NSTimeInterval nowPlayingLeafPlaybackTime;
@property (nonatomic, strong) NSNumber *nowPlayingLeafDuration;

@end

@implementation SFSpotifyPlayer {
	SPSession *session;
	SFSpotifyFactory *factory;
	AppStatusObserver *appStatusObserver;
	SFPlaybackQueue *playbackQueue;
	CoalescingDispatcher *seekDispatcher;
	float seekProgress;
}

- (id)initWithSession:(SPSession *)theSession factory:(SFSpotifyFactory *)theFactory {
    self = [super init];
    if (self) {
		session = theSession;
		factory = theFactory;
		self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:theSession];
		self.playbackManager.delegate = self;
		appStatusObserver = [[AppStatusObserver alloc] init];
		appStatusObserver.delegate = self;
		session.playbackDelegate = self;
		playbackQueue = [[SFPlaybackQueue alloc] init];
		__block SFSpotifyPlayer *blockSelf = self;
		seekDispatcher = [[CoalescingDispatcher alloc] initWithPeriod:kSeekDelay block:^{
			[blockSelf sendProgressToPlayer];
		}];
    }
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.playbackManager = nil;
	appStatusObserver.delegate = nil;
}

@synthesize nowPlayingLeafDuration;

@synthesize playbackManager;
- (void)setPlaybackManager:(SPPlaybackManager *)newPlaybackManager {
	if(playbackManager == newPlaybackManager) {
		return;
	}
	
	[playbackManager removeObserver:self forKeyPath:@"currentTrack"];
	[playbackManager removeObserver:self forKeyPath:@"trackPosition"];
	[playbackManager removeObserver:self forKeyPath:@"isPlaying"];
	playbackManager = newPlaybackManager;
	[playbackManager addObserver:self forKeyPath:@"currentTrack" options:0 context:nil];
	[playbackManager addObserver:self forKeyPath:@"trackPosition" options:0 context:nil];
	[playbackManager addObserver:self forKeyPath:@"isPlaying" options:0 context:nil];
}

@synthesize loadingObserver;
@synthesize nowPlayingLeafPlaybackTime;

- (void)play:(id<SFSpotifyMediaItem>)mediaItem {
	[self stop];
	self.nowPlaying = mediaItem;
	[self playTracksOfMediaItemWhenLoaded:mediaItem];
}

- (void)playTracksOfMediaItemWhenLoaded:(id<SFSpotifyMediaItem>)mediaItem {
	if([mediaItem isLoading]) {
		NSLog(@"Waiting until mediaItem %@ is loaded", mediaItem);
		self.loadingObserver = [[SFObserver alloc] initWithObject:mediaItem keyPath:@"loading" delegate:self];
	}
	else {
		[self playTracksOfMediaItem:mediaItem];
	}
}

- (void)playTracksOfMediaItem:(id<SFSpotifyMediaItem>)mediaItem {
	NSLog(@"Playing tracks of mediaItem: %@", mediaItem);
	NSAssert([mediaItem isLoading] == NO, @"Item is still loading when starting to play");
	[playbackQueue replaceQueue:[mediaItem tracks]];
	[self playTrack:playbackQueue.currentItem];
}

- (void)play:(id<SFSpotifyMediaItem>)mediaItem startingAtIndex:(NSUInteger)index {
	NSAssert([mediaItem isLoading] == NO, @"Item is still loading when starting to play");
	self.nowPlaying = mediaItem;
	[playbackQueue replaceQueue:[mediaItem tracks] startingAtIndex:index];
	[self playTrack:playbackQueue.currentItem];
}

- (void)playTrack:(SFSpotifyTrack *)track {
	NSAssert(track == nil || [track isKindOfClass:[SFSpotifyTrack class]], @"Unexpected track type");
	NSError *error = nil;
	if(track != nil) {
		if([[AVAudioSession sharedInstance] setActive:YES error:&error] == NO) {
			NSLog(@"SFSpotifyPlayer: Could not activate audio session: %@", error);
			self.playbackState = SFPlaybackStatePaused;
			return;
		}
	}
	
	[playbackManager playTrack:track.spTrack callback:^(NSError *error) {
		if(error != nil) { 
			NSLog(@"SFSpotifyPlayer: Could not play track %@: %@", track, error);
			self.playbackState = SFPlaybackStatePaused;
		}
	}];
	
	NSLog(@"SFSpotifyPlayer: playing track %@", track);
}

- (void)stop {
	playbackManager.isPlaying = NO;
	[playbackQueue clearQueue];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(object == self.playbackManager) {		
		if([@"trackPosition" isEqualToString:keyPath]) {
			self.nowPlayingLeafProgress = self.playbackManager.trackPosition / [[self.nowPlayingLeaf duration] floatValue];
			self.nowPlayingLeafPlaybackTime = self.playbackManager.trackPosition;
		}
		else if([@"currentTrack" isEqualToString:keyPath]) {
			[self handleCurrentTrackChange];
		}
		else if([@"isPlaying" isEqualToString:keyPath]) {
			if(self.playbackManager.isPlaying) {
				// does not work correctly, isPlaying is set to YES as soon as playback is scheduled
				// wait for SPPlaybackManagerDelegate call instead
				//self.playbackState = SFPlaybackStatePlaying;
			} 
			else {
				self.playbackState = SFPlaybackStatePaused;	
			}
		}
    }
	else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)handleCurrentTrackChange {
	self.nowPlayingLeaf = [self playlistTrackForSPTrack:self.playbackManager.currentTrack];
	[self updateNowPlayingInfo];
}

- (void)updateNowPlayingInfo  {
	[self publishNowPlayingInfoForQueue:playbackQueue];
	self.nowPlayingLeafDuration = [self.nowPlayingLeaf duration];
}

- (SFSpotifyTrack *)playlistTrackForSPTrack:(SPTrack *)spTrack {
	for(SFSpotifyTrack *track in playbackQueue.queue) {
		if(track.spTrack == spTrack) {
			return track;
		}
	}
	return nil;
}

- (void)playNextTrack {
	NSAssert([playbackQueue hasNextItem], @"No more tracks");
	NSLog(@"SFSpotifyPlayer: playing next track");
	[playbackQueue skipToNextItem];
	[self playTrack:playbackQueue.currentItem];
}

- (void)playPreviousTrack {
	NSAssert([playbackQueue hasPreviousItem], @"No previous tracks");
	NSLog(@"SFSpotifyPlayer: playing previous track");
	[playbackQueue skipToPreviousItem];
	[self playTrack:playbackQueue.currentItem];
}

- (BOOL)hasMoreTracks {
	return [playbackQueue hasNextItem];
}

- (BOOL)hasPreviousTrack{
	return [playbackQueue hasPreviousItem];
}

#pragma mark - SFMediaPlayer interface

@synthesize playbackState;
@synthesize nowPlaying;
- (void)setNowPlaying:(id<SFMediaItem>)newNowPlaying {
	if(nowPlaying == newNowPlaying) {
		return;
	}

	self.loadingObserver = nil;
	self.nowPlayingLeaf = nil;
	nowPlaying = newNowPlaying;
}
@synthesize nowPlayingLeaf;
@synthesize nowPlayingLeafProgress;
- (void)setShuffle:(BOOL)shuffle {
	playbackQueue.shuffle = shuffle;
	[self updateNowPlayingInfo];
}
- (BOOL)shuffle {
	return playbackQueue.shuffle;
}

@synthesize automaticPlaylists;

- (void)skipToNextItem {
	if([self hasMoreTracks]) {
		[self playNextTrack];
	}
}

- (void)skipToPrevousItem {
	if([self hasPreviousTrack]) {
		[self playPreviousTrack];
	}
}

- (void)setProgress:(float)newProgress {
	seekProgress = newProgress;
	[seekDispatcher fireAfterPeriod];
}

- (void)sendProgressToPlayer {
	NSTimeInterval newTime = [self.nowPlayingLeaf duration].floatValue * seekProgress;
	[self.playbackManager seekToTrackPosition:newTime];
}

- (void)pausePlayback {
	self.playbackManager.isPlaying = NO;
}

- (void)resumePlayback {
	if(self.playbackManager.currentTrack == nil) {
		return;
	}
	
	self.playbackManager.isPlaying = YES;
	self.playbackState = SFPlaybackStatePlaying;
}

- (BOOL)isNowPlayingItem:(id<SFMediaItem>)mediaItem {
	return [SFAbstractMediaPlayer isAudioTrack:(id<SFAudioTrack>)self.nowPlayingLeaf equivalentToMediaItem:mediaItem];
}

- (BOOL)canHandleRemoteControlEvents {
	return YES;
}

#pragma mark - AppStatusObserverDelegate

- (void)appDidBecomeActive {
	[self enableAudioSessionWithCategory:AVAudioSessionCategoryPlayback];
}

#pragma mark - SPSessionPlaybackDelegate

- (void)sessionDidLosePlayToken:(id<SPSessionPlaybackProvider>)aSession {
	UIAlertView *view = [[UIAlertView alloc] initWithTitle:nil message:@"Spotify has been paused because your account is used somewhere else." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[view show];
}

-(void)sessionDidEndPlayback:(id <SPSessionPlaybackProvider>)aSession {
	if([self hasMoreTracks]) {
		[self playNextTrack];
	}
	else {
		self.nowPlayingLeaf = nil;
	}
}

#pragma mark - SFObserverDelegate

- (void)object:(NSObject *)object wasSetFrom:(id)oldValue to:(id)newValue {
	NSAssert(object == self.nowPlaying, @"Unexpected object observed");
	[self playTracksOfMediaItem:(id<SFSpotifyMediaItem>)self.nowPlaying];
}

#pragma mark - SPPlaybackManagerDelegate

- (void)playbackManagerWillStartPlayingAudio:(SPPlaybackManager *)aPlaybackManager {
	self.playbackState = SFPlaybackStatePlaying;
}


@end
