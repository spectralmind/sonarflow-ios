#import "SFCompositeMediaPlayerTests.h"

#import <OCMock/OCMock.h>

#import "SFCompositeMediaPlayer.h"
#import "SFTestMediaPlayer.h"

@implementation SFCompositeMediaPlayerTests {
	id testPlayer1;
	id testPlayer2;
	NSArray *testPlayers;
	SFCompositeMediaPlayer *sut;
	NSMutableDictionary *observedChanges;
}

+ (NSArray *)keyPathsToObserve {
	return [NSArray arrayWithObjects:@"playbackState", @"nowPlaying", @"nowPlayingLeaf", @"nowPlayingLeafPlaybackTime", @"nowPlayingLeafDuration", @"shuffle", @"canHandleRemoteControlEvents", nil];
}

- (void)setUp {
	testPlayer1 = [OCMockObject partialMockForObject:[[SFTestMediaPlayer alloc] init]];
	testPlayer2 = [OCMockObject partialMockForObject:[[SFTestMediaPlayer alloc] init]];
	sut = [[SFCompositeMediaPlayer alloc] initWithPlayers:[NSArray arrayWithObjects:testPlayer1, testPlayer2, nil]];
	observedChanges = [[NSMutableDictionary alloc] init];
	for(NSString *keyPath in [SFCompositeMediaPlayerTests keyPathsToObserve]) {
		[sut addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
	}
}

- (void)tearDown {
	for(NSString *keyPath in [SFCompositeMediaPlayerTests keyPathsToObserve]) {
		[sut removeObserver:self forKeyPath:keyPath];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if(object == sut) {
		[observedChanges setObject:[change objectForKey:NSKeyValueChangeNewKey] forKey:keyPath];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)testPlayerChanges {
	[[testPlayer1 expect] pausePlayback];
	[[testPlayer2 reject] pausePlayback];
	
	[testPlayer2 setNowPlaying:[OCMockObject niceMockForProtocol:@protocol(SFMediaItem)]]; 
	
	for(NSString *keyPath in [SFCompositeMediaPlayerTests keyPathsToObserve]) {
		STAssertNotNil([observedChanges objectForKey:keyPath], @"Missing observation for keyPath: %@", keyPath);
	}
	STAssertEquals([testPlayer2 nowPlaying], sut.nowPlaying, @"Unexpected nowPlaying");
	[testPlayer1 verify];
}

@end
