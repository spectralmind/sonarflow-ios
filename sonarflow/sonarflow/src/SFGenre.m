#import "SFGenre.h"

#import "GenreDefinition.h"
#import "SFArtist.h"
#import "SFNativeMediaPlayer.h"
#import "SFTrack.h"
#import "SFArtistsComposite.h"
#import "MediaViewControllerFactory.h"
#import "RootKey.h"

#import "SFMediaItem.h"

NSInteger sortTracksByArtistAlbumNumber(SFTrack *first, SFTrack *second, void *context) {
	NSInteger result = [first.sortableAlbumArtist compare:second.sortableAlbumArtist];
	if(result == NSOrderedSame) {
		return sortTracksByAlbumNumber(first, second, context);
	}
	
	return result;
}

@implementation SFGenre {
	GenreDefinition *genreDefinition;
}

+ (id)keyForGenreName:(NSString *)genreName {
	return [[RootKey alloc] initWithKey:[genreName lowercaseString] type:BubbleTypeDefault];
}

- (id)initWithGenreDefinition:(GenreDefinition *)theGenreDefinition player:(SFNativeMediaPlayer *)thePlayer {
    self = [super initWithKey:[SFGenre keyForGenreName:theGenreDefinition.name]
						 name:theGenreDefinition.name player:thePlayer];
    if (self) {
		genreDefinition = theGenreDefinition;
    }
    return self;
}


- (NSArray *)keyPath {
	return [NSArray arrayWithObject:self.key];
}

- (CGPoint)origin {
	return genreDefinition.origin;
}

- (UIColor *)bubbleColor {
	return genreDefinition.color;
}

@synthesize relativeSize;

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
	return [factory viewControllerForGenre:self];
}

- (id<SFMediaItem>)allChildrenComposite {
	return [[SFArtistsComposite alloc] initWithGenre:self];
}

- (NSArray *)pushTracksIntoArtistChildren {
	if(self.numTracks == 0) {
		return 0;
	}

	NSMutableDictionary *artists = [self dictFromChildren];
	for(SFTrack *track in [self tempTracks]) {
		SFArtist *artist = [artists objectForKey:track.sortableAlbumArtist];
		if(artist == nil) {
			artist = [[SFArtist alloc] initWithName:[track albumArtistName] player:self.player];
			artist.sortableName = track.sortableAlbumArtist;
			artist.parent = self;
			artist.compilationArtist = [track isCompilation];
			[artists setObject:artist forKey:track.sortableAlbumArtist];
		}
		[artist addTrack:track];
	}

	NSArray *sortedArtists = [self sortChildren:[artists allValues]];
	[self addChildrenInMainThread:sortedArtists];
	return sortedArtists;
}

- (NSMutableDictionary *)dictFromChildren {
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:self.children.count];
	for (SFArtist *artist in self.children) {
		if (![artist isKindOfClass:[SFArtist class]]) {
			continue;
		}
		[dict setObject:artist forKey:artist.sortableName];
	}
	
	return dict;
}

- (NSArray *)sortChildren:(NSArray *)children {
	return [children sortedArrayUsingSelector:@selector(compareKeys:)];
}

- (NSArray *)sortTracks:(NSArray *)tracks {
	return [tracks sortedArrayUsingFunction:sortTracksByArtistAlbumNumber context:nil];
}

- (NSString *)artistNameForDiscovery {
	NSArray *path = [self.player.nowPlayingLeaf keyPath];
	if([[path objectAtIndex:0] isEqual:self.key] == NO) {
		return [self randomArtistName];
	}
	
	if([self.player.nowPlayingLeaf conformsToProtocol:@protocol(SFDiscoverableItem)] == NO) {
		return [self randomArtistName];
	}
	
	id<SFDiscoverableItem> discoverable = (id<SFDiscoverableItem>)self.player.nowPlayingLeaf;
	return [discoverable artistNameForDiscovery];
}

- (NSString *)randomArtistName {
	srandom([self.children count]);
	NSUInteger index = random() % [self.children count];
	SFArtist *artist = [self.children objectAtIndex:index];
	NSAssert([artist isKindOfClass:[SFArtist class]], @"Unexpected child");
	return artist.name;
}

@end
