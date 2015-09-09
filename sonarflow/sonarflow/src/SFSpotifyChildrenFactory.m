#import "SFSpotifyChildrenFactory.h"

#import "SFSpotifyFactory.h"
#import "SFSpotifyArtist.h"
#import "SFSpotifyAlbum.h"
#import "SPAlbum.h"
#import "SPArtist.h"
#import "SPTrack.h"

static const NSUInteger kExpectedTracksPerAlbum = 12;
static const NSUInteger kExpectedAlbumsPerArtist = 5;

@implementation SFSpotifyChildrenFactory {
	SFSpotifyFactory *factory;
}

- (id)initWithFactory:(SFSpotifyFactory *)theFactory {
    self = [super init];
    if (self) {
        factory = theFactory;
    }
    return self;
}

- (NSArray *)childrenFromSPTracks:(NSArray *)tracks {
	if([tracks count] == 0) {
		return nil;
	}
	
	NSMutableArray *newTrackHierarchy = [[NSMutableArray alloc] initWithCapacity:tracks.count];
	NSDate *start = [NSDate date];
	
	NSArray *sortedTracks = [self sortSPTracks:tracks];
	SPTrack *firstTrack = [sortedTracks objectAtIndex:0];
	SPArtist *currentArtist = firstTrack.album.artist;
	SPAlbum *currentAlbum = firstTrack.album;
	
	NSMutableArray *artistChildren = [[NSMutableArray alloc] initWithCapacity:kExpectedAlbumsPerArtist];
	NSMutableArray *albumTracks = [[NSMutableArray alloc] initWithCapacity:kExpectedTracksPerAlbum];
	for(SPTrack *spTrack in sortedTracks) {
		NSAssert(spTrack != nil, @"nil item encountered");
		NSAssert(spTrack.loaded, @"unloaded track encountered!");
		
		SFSpotifyTrack *track = [factory trackForSPTrack:spTrack];
		if(track == nil) {
			continue;
		}
		
		if([currentAlbum.name isEqualToString:spTrack.album.name] == NO) {
			[self addTracks:albumTracks ofAlbum:currentAlbum toArray:artistChildren];
			albumTracks = [[NSMutableArray alloc] initWithCapacity:kExpectedTracksPerAlbum];
			currentAlbum = spTrack.album;
		}
		
		if([currentArtist.name isEqualToString:spTrack.album.artist.name] == NO) {
			[self addChildren:artistChildren ofArtist:currentArtist toArray:newTrackHierarchy];
			artistChildren = [[NSMutableArray alloc] initWithCapacity:kExpectedAlbumsPerArtist];
			currentArtist = spTrack.album.artist;
		}
		[albumTracks addObject:track];
	}
	
	[self addTracks:albumTracks ofAlbum:currentAlbum toArray:artistChildren];
	[self addChildren:artistChildren ofArtist:currentArtist toArray:newTrackHierarchy];
	
	NSLog(@"built hierarchy: %d items in %2.3f s", sortedTracks.count, [[NSDate date] timeIntervalSinceDate:start]);
	return newTrackHierarchy;
}

- (NSArray *)sortSPTracks:(NSArray *)tracks {
	NSArray *sorting = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"album.artist.name" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"album.name" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"trackNumber" ascending:YES], nil];
	return [tracks sortedArrayUsingDescriptors:sorting];
}

- (void)addChildren:(NSArray *)artistChildren ofArtist:(SPArtist *)artist toArray:(NSMutableArray *)array {
	SFSpotifyArtist *artistItem = [[SFSpotifyArtist alloc] initWithArtist:artist key:artist.spotifyURL player:factory.player];
	artistItem.children = artistChildren;
	[array addObject:artistItem];
}

- (void)addTracks:(NSArray *)tracks ofAlbum:(SPAlbum *)album toArray:(NSMutableArray *)array {
	if(tracks.count <= 1) {				
		[array addObjectsFromArray:tracks];
		return;
	}

	SFSpotifyAlbum *albumItem = [[SFSpotifyAlbum alloc] initWitAlbum:album key:album.spotifyURL player:factory.player];
	albumItem.children = tracks;
	[array addObject:albumItem];
}


@end
