#import "SFArtistTests.h"

#import "SFArtist.h"
#import <OCMock/OCMock.h>
#import "SFTrack.h"
#import "SFTrackTestHelper.h"
#import "ArtworkFactory.h"
#import "SFAlbum.h"
#import "NameGenreMapper.h"
#import "SFNativeMediaFactory.h"

#import "SFCompositeMediaPlayer.h"
#import "SFTestMediaPlayer.h"
#import "SynchronousChildrenAddingHelper.h"

static NSString *TEST_ALBUM_NAME = @"AwesomeAlbum";

@implementation SFArtistTests {
	id artworkFactoryMock;
	id nativeMediaFactoryMock;
	id testPlayer;
	id nameGenreMapperMock;
	SFArtist *sut;
}

- (void)setUp {
	artworkFactoryMock = [OCMockObject niceMockForClass:[ArtworkFactory class]];
	nativeMediaFactoryMock = [OCMockObject niceMockForClass:[SFNativeMediaFactory class]];
	[[[nativeMediaFactoryMock stub] andCall:@selector(newAlbumWithName:) onObject:self] newAlbumWithName:[OCMArg any]];
	testPlayer = [[SFTestMediaPlayer alloc] init];
	nameGenreMapperMock = [OCMockObject niceMockForClass:[NameGenreMapper class]];

	sut = [[SFArtist alloc] initWithName:@"SomeName" player:testPlayer];
	id mockSut = [OCMockObject partialMockForObject:sut];
	[[[mockSut stub] andDo:[SynchronousChildrenAddingHelper synchronousChildrenAddingBlock]] addChildrenInMainThread:[OCMArg any]];
}

- (void)tearDown {
}

- (SFAlbum *)newAlbumWithName:(NSString *)name {
	return [[SFAlbum alloc] initWithName:name player:testPlayer artworkFactory:artworkFactoryMock];
}

- (SFTrack *)trackForAlbum:(NSString *)album {
	return [SFTrackTestHelper trackWithGenre:@"Foo" artist:@"Bar" albumArtist:@"Baz" album:album compilation:NO trackNumber:@0 artworkFactory:artworkFactoryMock nameGenreMapper:nameGenreMapperMock player:testPlayer];
}

- (void)testPushDownAlbum {
	SFTrack *track = [self trackForAlbum:TEST_ALBUM_NAME];
	
	[sut addTrack:track];
	[sut pushTracksIntoAlbumChildrenWithFactory:nativeMediaFactoryMock];
	
	NSArray *children = [sut children];
	STAssertEquals((NSUInteger)1, [children count], @"Children count mismatch");
	SFAlbum *album = [children objectAtIndex:0];
	STAssertEquals([SFAlbum class], [album class], @"Child should be album: %@", album);
	STAssertEqualObjects(track.albumName, [album name], @"Should have album name");
	STAssertFalse(album.compilation, @"Should not be compilation");
}

- (void)testCreateCompilationAlbum {
	SFTrack *track = [self trackForAlbum:TEST_ALBUM_NAME];
	
	sut.compilationArtist = YES;
	[sut addTrack:track];
	[sut pushTracksIntoAlbumChildrenWithFactory:nativeMediaFactoryMock];
	
	NSArray *children = [sut children];
	STAssertEquals((NSUInteger)1, [children count], @"Children count mismatch");
	SFAlbum *album = [children objectAtIndex:0];
	STAssertEquals([SFAlbum class], [album class], @"Child should be album: %@", album);
	STAssertTrue(album.compilation, @"Should be compilation for compilation artist");
}

- (void)testPushDownAlbumCaseInsensitive {
	[sut addTrack:[self trackForAlbum:@"An album"]];
	[sut addTrack:[self trackForAlbum:@"An ALbUM"]];
	[sut addTrack:[self trackForAlbum:@"an album"]];

	[sut pushTracksIntoAlbumChildrenWithFactory:nativeMediaFactoryMock];
	
	NSArray *children = [sut children];
	STAssertEquals((NSUInteger)1, [children count], @"Children count mismatch");
	SFAlbum *album = [children objectAtIndex:0];
	STAssertEquals([SFAlbum class], [album class], @"Child should be album: %@", album);
	STAssertEqualObjects(@"an album", [[album name] lowercaseString], @"Should have one of the album names");
}

- (void)testPushDownAlbumTwice {
	SFTrack *track1 = [self trackForAlbum:TEST_ALBUM_NAME];
	SFTrack *track2 = [self trackForAlbum:TEST_ALBUM_NAME];
	
	[sut addTrack:track1];
	[sut pushTracksIntoAlbumChildrenWithFactory:nativeMediaFactoryMock];
	[sut addTrack:track2];
	[sut pushTracksIntoAlbumChildrenWithFactory:nativeMediaFactoryMock];
	
	NSArray *children = [sut children];
	STAssertEquals((NSUInteger)1, [children count], @"Children count mismatch");
	SFAlbum *album1 = [children objectAtIndex:0];
	STAssertEquals([SFAlbum class], [album1 class], @"Child should be album: %@", album1);
	STAssertEqualObjects(track1.albumName, [album1 name], @"Should have album name");
	STAssertFalse(album1.compilation, @"Should not be compilation");
	SFAlbum *album2 = [children objectAtIndex:0];
	STAssertEquals([SFAlbum class], [album2 class], @"Child should be album: %@", album2);
	STAssertEqualObjects(track2.albumName, [album2 name], @"Should have album name");
	STAssertFalse(album2.compilation, @"Should not be compilation");
}


@end