#import "SFNativeMediaPlayer.h"

#import <AVFoundation/AVFoundation.h>
#import "AppStatusObserver.h"
#import "Notifications.h"
#import "SFNativeTrack.h"
#import "AutomaticPlaylists.h"
#import "SFTrack.h"
#import "CoalescingDispatcher.h"
#import "History.h"
#import "NowPlaying.h"
#import "SFNativeMediaFactory.h"

#define kBecomeActiveDelay 0

@interface SFNativeMediaPlayer () <AppStatusObserverDelegate>

@property (nonatomic, readwrite, assign) SFPlaybackState playbackState;
@property (nonatomic, readwrite, strong) id<SFMediaItem> nowPlaying;

@property (nonatomic, strong) SFTrack *nowPlayingTrack;
@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;

@end

@implementation SFNativeMediaPlayer {
	SFNativeMediaFactory *mediaFactory;
	AppStatusObserver *statusObserver;
	BOOL canAccessPlayer;
	
	MPMusicPlayerController *musicPlayer;
	BOOL shuffle;
	
	NSTimer *timelineRefreshTimer;
	
	AutomaticPlaylists *automaticPlaylists;
	CoalescingDispatcher *nowPlayingChangedDispatcher;
	CoalescingDispatcher *playbackStateChangedDispatcher;
}

+ (NSSet *)keyPathsForValuesAffectingNowPlayingLeaf {
	return [NSSet setWithObject:@"nowPlayingTrack"];
}

- (id)initWithPersistentStore:(PersistentStore *)store mediaFactory:(SFNativeMediaFactory *)theMediaFactory {
	self = [super init];
	if(self)	{
		[self initLibraryPlayerWithPersistentStore:store];
		mediaFactory = theMediaFactory;
	}
	return self;
}

- (void)initLibraryPlayerWithPersistentStore:(PersistentStore *)store {
	statusObserver = [[AppStatusObserver alloc]
					  initWithBecomeActiveDelay:kBecomeActiveDelay];
	statusObserver.delegate = self;
	
	SFNativeMediaPlayer *blockSelf = self;
	nowPlayingChangedDispatcher = [[CoalescingDispatcher alloc] initWithPeriod:0.1 block:^{
		[blockSelf updateNowPlayingItem];
	}];
	playbackStateChangedDispatcher = [[CoalescingDispatcher alloc] initWithPeriod:0.1 block:^{
		[blockSelf updatePlaybackState];
	}];
	
	History *history = [[History alloc] initWithMaxSize:50
										 store:store player:self];
	NowPlaying *nowPlayingList = [[NowPlaying alloc] initWithPlayer:self];
	automaticPlaylists = [[AutomaticPlaylists alloc] initWithHistory:history
											nowPlaying:nowPlayingList];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@synthesize playbackState;
@synthesize nowPlaying;
@synthesize nowPlayingTrack;
- (void)setNowPlayingTrack:(SFTrack *)newNowPlayingTrack {
	if(nowPlayingTrack == newNowPlayingTrack) {
		return;
	}
	nowPlayingTrack = newNowPlayingTrack;
	self.nowPlayingLeafDuration = nowPlayingTrack.duration;
}

- (id<SFMediaItem>)nowPlayingLeaf {
	return self.nowPlayingTrack;
}
@synthesize shuffle;
- (void)setShuffle:(BOOL)newShuffle {
	if(shuffle == newShuffle) {
		return;
	}
	shuffle = newShuffle;
	[self setMusicPlayerShuffleMode];
}

- (void)setMusicPlayerShuffleMode {
	MPMusicShuffleMode mode = (shuffle ? MPMusicShuffleModeSongs : MPMusicShuffleModeOff);
	[self.musicPlayer setShuffleMode:mode];
}

- (void)playMediaItem:(id<SFNativeMediaItem>)mediaItem {
	[self playMediaItem:mediaItem startingAtIndex:NSNotFound];
}

- (void)playMediaItem:(id<SFNativeMediaItem>)mediaItem startingAtIndex:(NSUInteger)startIndex {
	NSArray *tracks = [mediaItem tracks];
	[automaticPlaylists queueChanged:tracks];
	self.nowPlaying = mediaItem;
	MPMediaItemCollection *itemCollection = [self newNativeCollectionFromTracks:tracks];
	if(itemCollection == nil) {
		NSDebug(@"Trying to play an empty list");
		[self pausePlayback];
		return;
	}
	
	MPMediaItem *trackMediaItem = nil;
	if(startIndex != NSNotFound) {
		trackMediaItem = [[tracks objectAtIndex:startIndex] mediaItem];
	}
	[self startPlaybackForTrack:trackMediaItem inMPCollection:itemCollection];
}

- (MPMediaItemCollection *)newNativeCollectionFromTracks:(NSArray *)tracks {
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:[tracks count]];
	for(NSObject<SFNativeTrack> *t in tracks) {
		MPMediaItem *mediaItem = [t mediaItem];
        if(mediaItem) {
            [items addObject:mediaItem];
        }
	}
	
	if([items count] == 0) {
		return nil;
	}
	
	return [[MPMediaItemCollection alloc] initWithItems:items];
}

- (void)startPlaybackForTrack:(MPMediaItem *)track
			   inMPCollection:(MPMediaItemCollection *)collection {
	if(!canAccessPlayer) {
		return;
	}
	
	[self.musicPlayer setQueueWithItemCollection:collection];
	[self resumePlayback];
	
	if(track != nil) { //Has to be set after startPlayback to fix #333 in iOS 5+
		self.musicPlayer.nowPlayingItem = track;
	}
}

- (void)skipToNextItem {
	if(!canAccessPlayer) {
		return;
	}
	
	[self.musicPlayer skipToNextItem];
}

- (void)skipToPrevousItem {
	if(!canAccessPlayer) {
		return;
	}
	
	[self.musicPlayer skipToPreviousItem];
}

- (void)setProgress:(float)progress {
	if(!canAccessPlayer) {
		return;
	}
	
	if([self.nowPlayingLeaf duration] != nil) {
		NSTimeInterval newLength = [[self.nowPlayingLeaf duration] floatValue] * progress;
		[self.musicPlayer setCurrentPlaybackTime:newLength];
	}
}

- (void)pausePlayback {
	if(!canAccessPlayer) {
		return;
	}
	
	[self.musicPlayer pause];
}

- (void)resumePlayback {
	if(!canAccessPlayer) {
		return;
	}
	
	[self.musicPlayer play];
}

- (BOOL)isNowPlayingItem:(id<SFMediaItem>)mediaItem {
	return [SFAbstractMediaPlayer isAudioTrack:self.nowPlayingTrack equivalentToMediaItem:mediaItem];
}

- (NSArray *)automaticPlaylists {
	return [NSArray arrayWithObjects:automaticPlaylists.nowPlaying, automaticPlaylists.history, nil];
}

- (BOOL)canHandleRemoteControlEvents {
	return NO;
}

#pragma mark -
#pragma mark AppStatusObserverDelegate

- (void)appWillResignActive {
	canAccessPlayer = NO;
	self.musicPlayer = nil;
}

- (void)appDidEnterBackground {
	self.musicPlayer = nil;
}

- (void)appDidBecomeActive {
	canAccessPlayer = YES;
	[self initMusicPlayer];
	[self enableAudioSessionWithCategory:AVAudioSessionCategoryAmbient];
}

#pragma mark -
#pragma mark Private Methods

- (MPMusicPlayerController *)musicPlayer {
	if(musicPlayer == nil) {
		[self initMusicPlayer];
	}
	return musicPlayer;
}

- (void)setMusicPlayer:(MPMusicPlayerController *)newPlayer {
	if(musicPlayer != newPlayer) {
		#if !(TARGET_IPHONE_SIMULATOR)
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		if(musicPlayer != nil) {
			[notificationCenter removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:musicPlayer];
			[notificationCenter removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:musicPlayer];
			[musicPlayer endGeneratingPlaybackNotifications];
		}
		#endif
		
		musicPlayer = newPlayer;
		
		#if !(TARGET_IPHONE_SIMULATOR)
		// enable change notifications
		[notificationCenter addObserver:self
							   selector:@selector(nowPlayingItemChanged:)
								   name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
								 object:musicPlayer];
		
		[notificationCenter addObserver:self
							   selector:@selector(playbackStateChanged:)
								   name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
								 object:musicPlayer];
		
		[musicPlayer beginGeneratingPlaybackNotifications];
		#endif
	}
}

- (void)refreshTimelineTimerFired:(NSTimer *)timer {
	[self refreshTimeline];
}

- (void)refreshTimeline {
	if(!canAccessPlayer) {
		return;
	}
	
	self.nowPlayingLeafPlaybackTime = self.musicPlayer.currentPlaybackTime;
}

- (void)initMusicPlayer {
	if(!canAccessPlayer || musicPlayer != nil) {
		return;
	}
	
#if !(TARGET_IPHONE_SIMULATOR)
	MPMusicPlayerController *newPlayer = [MPMusicPlayerController iPodMusicPlayer];
	[newPlayer setRepeatMode:MPMusicRepeatModeNone];
	self.musicPlayer = newPlayer;
	[self setMusicPlayerShuffleMode];
#endif
	
	//Inform delegeat about current player state
	[self nowPlayingItemChanged:nil];
	[self playbackStateChanged:nil];
}

#pragma mark Notifications

- (void)nowPlayingItemChanged:(NSNotification *)notification {
	[nowPlayingChangedDispatcher fireAfterPeriod];
}

- (void)playbackStateChanged:(NSNotification *)notification {
	[playbackStateChangedDispatcher fireAfterPeriod];
}

- (void)updateNowPlayingItem {
	if(musicPlayer == nil) {
		self.nowPlayingTrack = nil;
		self.nowPlaying = nil;
		return;
	}

	MPMediaItem *item = self.musicPlayer.nowPlayingItem;
	if(item == nil) {
		self.nowPlayingTrack = nil;
		self.nowPlaying = nil;
	}
	else {
		SFTrack *track = [mediaFactory newTrackForNativeMediaItem:item];
		self.nowPlayingTrack = track;
		if(self.nowPlaying == nil) {
			self.nowPlaying = track;
		}
	}
	[automaticPlaylists nowPlayingTrackChanged:self.nowPlayingTrack];
	
	[self refreshTimeline];
	
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:SFNowPlayingItemChangedNotification
	 object:self];
}

- (void)updatePlaybackState {
	if(musicPlayer == nil) {
		self.playbackState = SFPlaybackStatePaused;
		return;
	}

	MPMusicPlaybackState playerState = self.musicPlayer.playbackState;
	[timelineRefreshTimer invalidate];
	if(playerState == MPMusicPlaybackStatePlaying) {
		timelineRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:1
																target:self
															  selector:@selector(refreshTimelineTimerFired:)
															  userInfo:nil
															   repeats:YES];
	}
	else {
		timelineRefreshTimer = nil;
	}
	
	self.playbackState = (playerState == MPMusicPlaybackStatePlaying) ? SFPlaybackStatePlaying : SFPlaybackStatePaused;
}

@end
