#import "SFTrackTests.h"
#import "SFTrack.h"
#import <OCMock/OCMock.h>
#import <MediaPlayer/MediaPlayer.h>
#import "NameGenreMapper.h"
#import "SFTrackTestHelper.h"
#import "ArtworkFactory.h"

#import "SFCompositeMediaPlayer.h"
#import "SFTestMediaPlayer.h"

@implementation SFTrackTests {
	id artworkFactoryMock;
	id testPlayer;
	id nameGenreMapperMock;
}

- (void)setUp {
	artworkFactoryMock = [OCMockObject niceMockForClass:[ArtworkFactory class]];
	testPlayer = [[SFTestMediaPlayer alloc] init];
	nameGenreMapperMock = [OCMockObject mockForClass:[NameGenreMapper class]];
}

- (void)tearDown {
}

- (SFTrack *)trackWithMappedGenre:(NSString *)genre artist:(NSString *)artist albumArtist:(NSString *)albumArtist album:(NSString *)album compilation:(BOOL)compilation trackNumber:(NSNumber *)trackNumber {
	NSString *trackGenre = @"TrackGenre";
	[[[nameGenreMapperMock stub] andReturn:genre] mappedNameForGenreName:trackGenre];
	[[[nameGenreMapperMock stub] andReturn:genre] mappedNameForGenreName:trackGenre usingArtistName:artist];
	if (artist == nil) {
		[[[nameGenreMapperMock stub] andReturn:genre] mappedNameForGenreName:trackGenre usingArtistName:[SFTrack unknownArtist]];
	}
	return [SFTrackTestHelper trackWithGenre:trackGenre artist:artist albumArtist:albumArtist album:album compilation:compilation trackNumber:trackNumber artworkFactory:artworkFactoryMock nameGenreMapper:nameGenreMapperMock player:testPlayer];
}

- (void)testNilGenreCaching {
	id mediaItemMock = [OCMockObject mockForClass:[MPMediaItem class]];
	[[[mediaItemMock expect] andReturn:nil] valueForProperty:MPMediaItemPropertyGenre];
	SFTrack *sut = [[SFTrack alloc] initWithItem:mediaItemMock artworkFactory:artworkFactoryMock nameGenreMapper:nameGenreMapperMock player:testPlayer];
	
	NSString *result = sut.genre;
	NSString *result2 = sut.genre;
	
	STAssertEquals((NSUInteger)0, [result length], @"Should return empty genre");
	STAssertEquals((NSUInteger)0, [result2 length], @"Should return empty genre");
	[mediaItemMock verify];
}

- (void)testKeyPath {
	NSString *mappedGenreName = @"SomeGenre";
	NSString *artistName = @"SomeArtist";
	NSString *albumArtistName = @"";
	NSString *albumName = @"SomeAlbum";
	NSNumber *trackNumber = @0;
	SFTrack *sut = [self trackWithMappedGenre:mappedGenreName artist:artistName albumArtist:albumArtistName album:albumName compilation:NO trackNumber:trackNumber];

	NSArray *result = [sut keyPath];
	
	[self assertValidKeyPath:result withGenreName:mappedGenreName artistName:artistName albumName:albumName];
}

- (void)testKeyPathWithAlbumArtist {
	NSString *mappedGenreName = @"SomeGenre";
	NSString *artistName = @"SomeArtist";
	NSString *albumArtistName = @"AlbumArtist";
	NSString *albumName = @"SomeAlbum";
	NSNumber *trackNumber = @0;
	SFTrack *sut = [self trackWithMappedGenre:mappedGenreName artist:artistName albumArtist:albumArtistName album:albumName compilation:NO trackNumber:trackNumber];
	
	NSArray *result = [sut keyPath];
	
	[self assertValidKeyPath:result withGenreName:mappedGenreName artistName:albumArtistName albumName:albumName];
}

- (void)testCompilationKeyPath {
	NSString *mappedGenreName = @"SomeGenre";
	NSString *artistName = @"SomeArtist";
	NSString *albumArtistName = @"";
	NSString *albumName = @"SomeAlbum";
	NSNumber *trackNumber = @0;
	SFTrack *sut = [self trackWithMappedGenre:mappedGenreName artist:artistName albumArtist:albumArtistName album:albumName compilation:YES trackNumber:trackNumber];
	
	NSArray *result = [sut keyPath];
	
	[self assertValidKeyPath:result withGenreName:mappedGenreName artistName:[SFTrack compilationArtist] albumName:albumName];
}

- (void)testKeyPathWithoutMappedGenre {
	SFTrack *sut = [self trackWithMappedGenre:nil artist:@"Foo" albumArtist:@"Baz" album:@"Bar" compilation:NO trackNumber:nil];
	
	STAssertThrows([sut keyPath], @"Should throw for missing genre name");
}

- (void)testKeyPathWithoutMappedGenre2 {
	SFTrack *sut = [self trackWithMappedGenre:nil artist:@"Foo" albumArtist:@"Baz" album:@"Bar" compilation:YES trackNumber:nil];
	
	STAssertThrows([sut keyPath], @"Should throw for missing genre name");
}

- (void)testKeyPathWithoutArtist {
	NSString *mappedGenreName = @"SomeGenre";
	NSString *artistName = nil;
	NSString *albumArtistName = @"";
	NSString *albumName = @"SomeAlbum";
	NSNumber *trackNumber = @0;
	SFTrack *sut = [self trackWithMappedGenre:mappedGenreName artist:artistName albumArtist:albumArtistName album:albumName compilation:NO trackNumber:trackNumber];
	
	NSArray *result = [sut keyPath];
	
	[self assertValidKeyPath:result withGenreName:mappedGenreName artistName:[SFTrack unknownArtist] albumName:albumName];
}

- (void)testKeyPathWithoutAlbum {
	NSString *mappedGenreName = @"SomeGenre";
	NSString *artistName = @"SomeArtist";
	NSString *albumArtistName = @"";
	NSString *albumName = nil;
	NSNumber *trackNumber = @0;
	SFTrack *sut = [self trackWithMappedGenre:mappedGenreName artist:artistName albumArtist:albumArtistName album:albumName compilation:NO trackNumber:trackNumber];
	
	NSArray *result = [sut keyPath];
	
	[self assertValidKeyPath:result withGenreName:mappedGenreName artistName:artistName albumName:[SFTrack unknownAlbum]];
}

- (void)assertValidKeyPath:(NSArray *)keyPath withGenreName:(NSString *)genreName artistName:(NSString *)artistName albumName:(NSString *)albumName {
	STAssertEquals((NSUInteger)4, [keyPath count], @"Should have four elements: %@", keyPath);
	STAssertTrue([self genreEqual:genreName toKeyPathObject:[keyPath objectAtIndex:0]], @"Should be lowercase genre with additional text");
	STAssertEqualObjects([artistName lowercaseString], [keyPath objectAtIndex:1], @"Should be artist");
	STAssertEqualObjects([albumName lowercaseString], [keyPath objectAtIndex:2], @"Should be album");
}

- (BOOL)genreEqual:(NSString *)genreName toKeyPathObject:(id)keyPathObject {
	return [[keyPathObject description] rangeOfString:[genreName lowercaseString]].location != NSNotFound;
}

@end
