#import "BubbleFactoryTests.h"

#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMock/OCMock.h>

#import "BubbleFactory.h"
#import "GenreDefinition.h"
#import "SFGenre.h"
#import "SFTrack.h"
#import "SFAlbum.h"
#import "Bubble.h"
#import "SFTrackTestHelper.h"
#import "ArtworkFactory.h"
#import "NameGenreMapper.h"

#import "SFCompositeMediaPlayer.h"
#import "SFTestMediaPlayer.h"

@implementation BubbleFactoryTests {
	BubbleFactory *sut;
	id testPlayer;
	id artworkFactoryMock;
	id nameGenreMapperMock;
}

- (void)setUp {
	artworkFactoryMock = [OCMockObject niceMockForClass:[ArtworkFactory class]];
	nameGenreMapperMock = [OCMockObject niceMockForClass:[NameGenreMapper class]];
	sut = [[BubbleFactory alloc] initWithImageFactory:nil];
	testPlayer = [[SFTestMediaPlayer alloc] init];
}

- (void)testBubbleForRootMediaItemWithGenre {
	NSString *genreName = @"Some Genre with miXed Case";
	NSArray *subgenres = @[];
	GenreDefinition *gdef = [[GenreDefinition alloc] initWithName:genreName origin:CGPointMake(0,0) color:[UIColor whiteColor] subgenres:subgenres];
	SFGenre *genre = [[SFGenre alloc] initWithGenreDefinition:gdef player:testPlayer];
	
	NSArray *results = [sut bubblesForRootMediaItems:@[genre]];
	
	Bubble *result = [results objectAtIndex:0];	
	STAssertEqualObjects(genre.key, result.key, @"Keys should be equal");
}

- (void)testChildrenForCollection {
	NSString *childName = @"Some CHILD with miXed case";
	SFGenre *child = [[SFGenre alloc] initWithName:childName player:testPlayer];
	id<SFMediaItem> mediaItem = [self albumWithChildren:@[child]];
	Bubble *anybubble = [[Bubble alloc] initWithKey:@"bUbble kEy"];

	NSArray *result = [sut bubblesForChildren:mediaItem.children ofBubble:anybubble avoidingBubbles:[NSArray array]];

	STAssertEquals([mediaItem.children count], [result count], @"Should have same size as mediaItems");
	Bubble *childBubble = [result objectAtIndex:0];
	STAssertEqualObjects(child.key, childBubble.key, @"Keys should be equal");
}

-(SFMediaCollection *)collectionWithChild:(SFMediaCollection *)child {
	SFMediaCollection *collection = [[SFMediaCollection alloc] initWithKey:@"somekey"];
	id collectionMock = [OCMockObject partialMockForObject:collection];
	[[[collectionMock stub] andReturn:[NSArray arrayWithObject:child]] children];
	child.parent = collection;
	return collection;
}

- (void)testUniqueTrackKey {
	NSString *genre = @"Electronic";
	NSString *artist = @"Caribou";
	NSString *album = @"Swim + Swim (Remixes)";
	//NSString *trackName = @"Odessa";
	NSNumber *trackNumber = @1;
	NSUInteger trackCd = 1;
	NSUInteger track1MediaItemId = 1;
	NSUInteger track2MediaItemId = 2;
	SFTrack *track1 = [SFTrackTestHelper trackWithId:track1MediaItemId genre:genre artist:artist albumArtist:artist album:album compilation:NO disc:trackCd trackNumber:trackNumber artworkFactory:artworkFactoryMock nameGenreMapper:nameGenreMapperMock player:testPlayer];
	SFTrack *track2 = [SFTrackTestHelper trackWithId:track2MediaItemId genre:genre artist:artist albumArtist:artist album:album compilation:NO disc:trackCd trackNumber:trackNumber artworkFactory:artworkFactoryMock nameGenreMapper:nameGenreMapperMock player:testPlayer];
	id<SFMediaItem> mediaItem = [self albumWithChildren:@[track1, track2]];
	Bubble *anybubble = [[Bubble alloc] initWithKey:@"bUbble kEy"];
	anybubble.radius = 1.;
	sut.childrenRadiusFactor = 1.;
	
	NSArray *result = [sut bubblesForChildren:mediaItem.children ofBubble:anybubble avoidingBubbles:[NSArray array]];
	
	STAssertEquals([mediaItem.children count], [result count], @"Should have same size as mediaItems");
	Bubble *childBubbleTrack1 = [result objectAtIndex:0];
	Bubble *childBubbleTrack2 = [result objectAtIndex:1];
	assertThat(childBubbleTrack1.key, isNot(childBubbleTrack2.key));
}

- (SFAlbum *)albumWithChildren:(NSArray *)children {
	SFAlbum *collection = [[SFAlbum alloc] initWithName:@"somealbum" player:testPlayer artworkFactory:artworkFactoryMock];
	id collectionMock = [OCMockObject partialMockForObject:collection];
	[[[collectionMock stub] andReturn:children] children];
	[[[collectionMock stub] andReturn:children] tracks];
	
	for (SFMediaCollection *child in children) {
		child.parent = collection;
	}
	
	return collection;
}

@end
