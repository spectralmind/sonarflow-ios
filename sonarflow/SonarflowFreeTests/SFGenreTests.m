#import "SFGenreTests.h"

#import "SFGenre.h"
#import "GenreDefinition.h"
#import <OCMock/OCMock.h>
#import "SFTrack.h"
#import "SFArtist.h"
#import "SFTrackTestHelper.h"
#import "ArtworkFactory.h"
#import "NameGenreMapper.h"

#import "SFCompositeMediaPlayer.h"
#import "SFTestMediaPlayer.h"
#import "SynchronousChildrenAddingHelper.h"

static NSString *TEST_ARTIST_NAME = @"AwesomeArtist";

@implementation SFGenreTests {
	SFGenre *sut;
	id testPlayer;
	id artworkFactoryMock;
	id nameGenreMapperMock;
}

- (void)setUp {
	artworkFactoryMock = [OCMockObject niceMockForClass:[ArtworkFactory class]];
	nameGenreMapperMock = [OCMockObject niceMockForClass:[NameGenreMapper class]];
	testPlayer = [[SFTestMediaPlayer alloc] init];
	GenreDefinition *gdef = [[GenreDefinition alloc] initWithName:@"SomeName" origin:CGPointMake(0,0) color:[UIColor whiteColor] subgenres:@[]];
	
	sut = [[SFGenre alloc] initWithGenreDefinition:gdef player:testPlayer];
	id mockSut = [OCMockObject partialMockForObject:sut];
	[[[mockSut stub] andDo:[SynchronousChildrenAddingHelper synchronousChildrenAddingBlock]] addChildrenInMainThread:[OCMArg any]];
}

- (void)tearDown {
}

- (SFTrack *)trackForAlbumArtist:(NSString *)albumArtist compilation:(BOOL)compilation {
	return [SFTrackTestHelper trackWithGenre:@"Foo" artist:@"Bar" albumArtist:albumArtist album:@"Baz" compilation:compilation trackNumber:@0 artworkFactory:artworkFactoryMock nameGenreMapper:nameGenreMapperMock player:testPlayer];
}

- (void)testPushDownArtist {
	SFTrack *track = [self trackForAlbumArtist:TEST_ARTIST_NAME compilation:NO];

	[sut addTrack:track];
	[sut pushTracksIntoArtistChildren];

	NSArray *children = [sut children];
	STAssertEquals((NSUInteger)1, [children count], @"Children count mismatch");
	SFArtist *artist = [children objectAtIndex:0];
	STAssertEquals([SFArtist class], [artist class], @"Child should be artist: %@", artist);
	STAssertEqualObjects(track.albumArtistName, [artist name], @"Should have album artist name");
}

- (void)testPushDownArtistCaseInsensitive {
	SFTrack *track1 = [self trackForAlbumArtist:@"Artist" compilation:NO];
	SFTrack *track2 = [self trackForAlbumArtist:@"ArtIst" compilation:NO];
	SFTrack *track3 = [self trackForAlbumArtist:@"artisT" compilation:NO];
	
	[sut addTrack:track1];
	[sut addTrack:track2];
	[sut addTrack:track3];
	[sut pushTracksIntoArtistChildren];
	
	NSArray *children = [sut children];
	STAssertEquals((NSUInteger)1, [children count], @"Children count mismatch");
	SFArtist *artist = [children objectAtIndex:0];
	STAssertEquals([SFArtist class], [artist class], @"Child should be artist: %@", artist);
	STAssertEqualObjects(@"artist", [[artist name] lowercaseString], @"Should have one of the artist names");
}

- (void)testPushDownCompilationArtist {
    SFTrack *track = [self trackForAlbumArtist:TEST_ARTIST_NAME compilation:YES];

	[sut addTrack:track];
	[sut pushTracksIntoArtistChildren];

	SFArtist *artist = [[sut children] objectAtIndex:0];
	STAssertEquals([SFArtist class], [artist class], @"Child should be artist: %@", artist);
	STAssertEqualObjects([SFTrack compilationArtist], [artist name], @"Should have compilation artist name");
}

- (void)testFindChildByName {
	int numArtists = 10;
	[self addTestTracksForArtists:numArtists];
	[sut pushTracksIntoArtistChildren];
	STAssertEquals((NSUInteger) numArtists, [sut.children count], @"Unexpected number of children");
	
	for(SFArtist *artist in sut.children) {
		id<SFMediaItem> result = [sut childWithKey:artist.key];
		STAssertEquals(artist.name, [result name], @"Should return collection with searched name: %@", artist);
	}
}

- (void)addTestTracksForArtists:(NSUInteger)numArtists {
	for(NSUInteger i = 0; i < numArtists; ++i) {
		NSString *artistName = [NSString stringWithFormat:@"%@ %u", TEST_ARTIST_NAME, i];
		[sut addTrack:[self trackForAlbumArtist:artistName compilation:NO]];
		[sut addTrack:[self trackForAlbumArtist:[artistName lowercaseString] compilation:NO]];
	}
}

- (void)testPushDownArtistTwice {
	SFTrack *track1 = [self trackForAlbumArtist:TEST_ARTIST_NAME compilation:NO];
	SFTrack *track2 = [self trackForAlbumArtist:TEST_ARTIST_NAME compilation:NO];
	
	[sut addTrack:track1];
	[sut pushTracksIntoArtistChildren];
	[sut addTrack:track2];
	[sut pushTracksIntoArtistChildren];
	
	NSArray *children = [sut children];
	STAssertEquals((NSUInteger)1, [children count], @"Children count mismatch");
	SFArtist *artist1 = [children objectAtIndex:0];
	STAssertEquals([SFArtist class], [artist1 class], @"Child should be artist: %@", artist1);
	STAssertEqualObjects(track1.albumArtistName, [artist1 name], @"Should have album artist name");
	SFArtist *artist2 = [children objectAtIndex:0];
	STAssertEquals([SFArtist class], [artist2 class], @"Child should be artist: %@", artist2);
	STAssertEqualObjects(track2.albumArtistName, [artist2 name], @"Should have album artist name");
}


@end
