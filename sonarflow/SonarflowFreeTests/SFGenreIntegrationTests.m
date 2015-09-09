#import "SFGenreIntegrationTests.h"

#import <OCMock/OCMock.h>
#import "SFGenre.h"
#import "SFArtist.h"
#import "SFTrack.h"
#import "SFAlbum.h"
#import "NameGenreMapper.h"
#import "GenreDefinition.h"
#import "SFTrackTestHelper.h"
#import "ArtworkFactory.h"
#import "SFNativeMediaFactory.h"

#import "SFCompositeMediaPlayer.h"
#import "SFTestMediaPlayer.h"
#import "SynchronousChildrenAddingHelper.h"

@implementation SFGenreIntegrationTests {
	id artworkFactoryMock;
	id testPlayer;
	id nativeMediaFactoryMock;
	id nameGenreMapperMock;
}

- (void)setUp {
	artworkFactoryMock = [OCMockObject niceMockForClass:[ArtworkFactory class]];
	testPlayer = [[SFTestMediaPlayer alloc] init];
	nativeMediaFactoryMock = [OCMockObject niceMockForClass:[SFNativeMediaFactory class]];
	[[[nativeMediaFactoryMock stub] andCall:@selector(newAlbumWithName:) onObject:self] newAlbumWithName:[OCMArg any]];
	nameGenreMapperMock = [OCMockObject mockForClass:[NameGenreMapper class]];
}

- (void)tearDown {
}

- (SFAlbum *)newAlbumWithName:(NSString *)name {
	return [[SFAlbum alloc] initWithName:name player:testPlayer artworkFactory:artworkFactoryMock];
}

- (SFTrack *)trackWithId:(NSUInteger)trackId artist:(NSString *)artist albumArtist:(NSString *)albumArtist album:(NSString *)album compilation:(BOOL)compilation disc:(NSUInteger)disc trackNumber:(NSNumber *)trackNumber {
	return [SFTrackTestHelper trackWithId:trackId genre:@"NotUsed" artist:artist albumArtist:albumArtist album:album compilation:compilation disc:disc trackNumber:trackNumber artworkFactory:artworkFactoryMock nameGenreMapper:nameGenreMapperMock player:testPlayer];
}

- (void)testTracksSortedEqually {
	GenreDefinition *gdef = [[GenreDefinition alloc] initWithName:@"SomeName" origin:CGPointMake(0,0) color:[UIColor whiteColor] subgenres:@[]];
	SFGenre *genre1 = [[SFGenre alloc] initWithGenreDefinition:gdef player:testPlayer];

	[self addTestTracks:genre1];
	NSArray *tracksBeforePush = [genre1 tracks];
	[self pushDownTracks:genre1];
	NSArray *tracksAfterPush = [genre1 tracks];
	
	for(NSUInteger i = 0; i != [tracksBeforePush count]; ++i) {
		STAssertEquals(i + 1, [[[tracksBeforePush objectAtIndex:i] mediaItemId] unsignedIntegerValue], @"Unexpected track order: %@", tracksBeforePush);
	}

	STAssertEqualObjects(tracksBeforePush, tracksAfterPush, @"Should be same order of tracks");
}

- (void)addTestTracks:(SFGenre *)genre {
	[genre addTrack:[self trackWithId:5 artist:@"Ignore2" albumArtist:@"Foo" album:@"a1" compilation:YES disc:1 trackNumber:@1]];
	[genre addTrack:[self trackWithId:6 artist:@"Ignore5" albumArtist:@"Bar" album:@"A1" compilation:YES disc:1 trackNumber:@2]];
	[genre addTrack:[self trackWithId:7 artist:@"Ignore8" albumArtist:@"Foo" album:@"A2" compilation:NO disc:1 trackNumber:@1]];
	[genre addTrack:[self trackWithId:8 artist:@"Ignore6" albumArtist:@"foo" album:@"a2" compilation:NO disc:1 trackNumber:@2]];
	[genre addTrack:[self trackWithId:3 artist:@"Ignore1" albumArtist:@"artist" album:@"A1" compilation:NO disc:2 trackNumber:@1]];
	[genre addTrack:[self trackWithId:2 artist:@"Ignore3" albumArtist:@"artist" album:@"a1" compilation:NO disc:1 trackNumber:@2]];
	[genre addTrack:[self trackWithId:4 artist:@"Ignore0" albumArtist:@"ArtIst2" album:@"A0" compilation:NO disc:2 trackNumber:@1]];
	[genre addTrack:[self trackWithId:1 artist:@"Ignore1" albumArtist:@"ARTIST" album:@"A1" compilation:NO disc:1 trackNumber:@1]];
}

- (void)pushDownTracks:(SFGenre *)genre {
	id mockGenre = [OCMockObject partialMockForObject:genre];
	[[[mockGenre stub] andDo:[SynchronousChildrenAddingHelper synchronousChildrenAddingBlock]] addChildrenInMainThread:[OCMArg any]];

	[genre pushTracksIntoArtistChildren];
	[genre releaseLocalTracks];
	for(SFArtist *artist in [genre children]) {
		id mockArtist = [OCMockObject partialMockForObject:artist];
		[[[mockArtist stub] andDo:[SynchronousChildrenAddingHelper synchronousChildrenAddingBlock]] addChildrenInMainThread:[OCMArg any]];
		
		NSAssert([artist isKindOfClass:[SFArtist class]], @"Genre has non-artist child");
		[artist pushTracksIntoAlbumChildrenWithFactory:nativeMediaFactoryMock];
		[artist releaseLocalTracks];
	}
}


@end
