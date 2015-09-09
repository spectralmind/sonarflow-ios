#import "SFCompositeMediaPlayer.h"

#import "SFObserver.h"

@interface SFCompositeMediaPlayer () <SFObserverDelegate>

@property (nonatomic, readwrite, strong) NSArray *automaticPlaylists;
@property (nonatomic, strong) id<SFMediaPlayer> activePlayer;

@end


@implementation SFCompositeMediaPlayer {
	NSArray *players;
	NSMutableArray *playerObservers;
}

- (id)initWithPlayers:(NSArray *)thePlayers {
    self = [super init];
    if (self) {
		players = thePlayers;
		[self createPlayerObservers];
		[self updateAutomaticPlaylists]; //TODO: should observe all player's "automaticPlaylists"
		self.activePlayer = [self findActivePlayer];
    }
    return self;
}


- (void)createPlayerObservers {
	playerObservers = [[NSMutableArray alloc] initWithCapacity:[players count]];
	for(NSObject<SFMediaPlayer> *player in players) {
		[playerObservers addObject:[[SFObserver alloc] initWithObject:player keyPath:@"nowPlaying" delegate:self]];
	}
}

- (id<SFMediaPlayer>)findActivePlayer {
	for(id<SFMediaPlayer> player in players) {
		if(player.nowPlaying != nil) {
			return player;
		}
	}
	
	return nil;
}

@synthesize automaticPlaylists;
@synthesize activePlayer;
- (void)setActivePlayer:(id<SFMediaPlayer>)newActivePlayer {
	if(activePlayer == newActivePlayer) {
		return;
	}
	
	activePlayer = newActivePlayer;
	for(id<SFMediaPlayer> player in players) {
		if(player != activePlayer) {
			[player pausePlayback];
		}
	}
}

+ (NSSet *)keyPathsForValuesAffectingPlaybackState {
	return [NSSet setWithObject:@"activePlayer.playbackState"];
}

+ (NSSet *)keyPathsForValuesAffectingNowPlaying {
	return [NSSet setWithObject:@"activePlayer.nowPlaying"];
}

+ (NSSet *)keyPathsForValuesAffectingNowPlayingLeaf {
	return [NSSet setWithObject:@"activePlayer.nowPlayingLeaf"];
}

+ (NSSet *)keyPathsForValuesAffectingNowPlayingLeafPlaybackTime{
	return [NSSet setWithObject:@"activePlayer.nowPlayingLeafPlaybackTime"];
}

+ (NSSet *)keyPathsForValuesAffectingShuffle {
	return [NSSet setWithObject:@"activePlayer.shuffle"];
}

+ (NSSet *)keyPathsForValuesAffectingCanHandleRemoteControlEvents {
	return [NSSet setWithObject:@"activePlayer.canHandleRemoteControlEvents"];
}

+ (NSSet *)keyPathsForValuesAffectingNowPlayingLeafDuration {
	return [NSSet setWithObject:@"activePlayer.nowPlayingLeafDuration"];
}

- (SFPlaybackState)playbackState {
	return self.activePlayer.playbackState;
}

- (id<SFMediaItem>)nowPlaying {
	return self.activePlayer.nowPlaying;
}

- (id<SFMediaItem>)nowPlayingLeaf {
	return self.activePlayer.nowPlayingLeaf;
}

- (NSTimeInterval)nowPlayingLeafPlaybackTime {
	return self.activePlayer.nowPlayingLeafPlaybackTime;
}

- (NSNumber *)nowPlayingLeafDuration {
	return self.activePlayer.nowPlayingLeafDuration;
}

- (void)setShuffle:(BOOL)shuffle {
	for(id<SFMediaPlayer> player in players) {
		player.shuffle = shuffle;
	}
}

- (BOOL)shuffle {
	return [self.activePlayer shuffle];
}

- (BOOL)canHandleRemoteControlEvents {
	return self.activePlayer.canHandleRemoteControlEvents;
}

- (void)updateAutomaticPlaylists {
	NSMutableArray *result = [NSMutableArray array];
	for(id<SFMediaPlayer> player in players) {
		[result addObjectsFromArray:player.automaticPlaylists];
	}
	self.automaticPlaylists = result;
}

- (void)skipToNextItem {
	[self.activePlayer skipToNextItem];
}

- (void)skipToPrevousItem {
	[self.activePlayer skipToPrevousItem];
}

- (void)setProgress:(float)progress {
	[self.activePlayer setProgress:progress];
}

- (void)pausePlayback {
	[self.activePlayer pausePlayback];
}

- (void)resumePlayback {
	[self.activePlayer resumePlayback];
}

- (void)togglePlayback {
	[self.activePlayer togglePlayback];
}

- (BOOL)isNowPlayingItem:(id<SFMediaItem>)mediaItem {
	return [self.activePlayer isNowPlayingItem:mediaItem];
}

- (void)handleRemoteControlEvent:(UIEvent *)event {
	[self.activePlayer handleRemoteControlEvent:event];
}

- (void)updateNowPlayingItem {
	if([self.activePlayer respondsToSelector:@selector(updateNowPlayingItem)]) {
		[self.activePlayer updateNowPlayingItem];
	}
}

- (void)object:(NSObject *)object wasSetFrom:(id)oldValue to:(id)newValue {
	if(newValue == nil) {
		return;
	}
	if(self.activePlayer == object) {
		return;
	}

	self.activePlayer = (id<SFMediaPlayer>)object;
}

@end
