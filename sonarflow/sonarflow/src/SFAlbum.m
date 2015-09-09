#import "SFAlbum.h"

#import <MediaPlayer/MediaPlayer.h>

#import "ArtworkFactory.h"
#import "MediaViewControllerFactory.h"
#import "SFMediaLibraryHelper.h"
#import "SFTrack.h"

@interface SFAlbum ()

@property (nonatomic, strong) NSMutableArray *sortedTracks;

- (void)sortTracks;

@end


@implementation SFAlbum

- (id)initWithName:(NSString *)theName player:(SFNativeMediaPlayer *)thePlayer artworkFactory:(ArtworkFactory *)theArtworkFactory {
	if(self = [super initWithName:theName player:thePlayer]) {
		artworkFactory = theArtworkFactory;
	}
	return self;
}


@synthesize compilation;
@synthesize sortedTracks;
- (NSMutableArray *)sortedTracks {
	if(sortedTracks == nil) {
		sortedTracks = [[NSMutableArray alloc] init];
	}
	
	return sortedTracks;
}

- (NSUInteger)numTracks {
	return [sortedTracks count];
}

@synthesize item;

- (void)addTrack:(SFTrack *)track {
	track.parent = self;
	isSorted = NO;
	
	[self.sortedTracks addObject:track];
}

- (void)sortTracks {
	[self.sortedTracks sortUsingFunction:sortTracksByNumber context:nil];
	for(NSUInteger i = 0; i < [self.sortedTracks count]; ++i) {
		SFTrack *track = [self.sortedTracks objectAtIndex:i];
		track.key = [NSNumber numberWithUnsignedInteger:i];
	}
	isSorted = YES;
}

- (BOOL)mayHaveImage {
	return YES;
}

- (UIImage *)imageWithSize:(CGSize)size {
	return [artworkFactory artworkForMediaItem:self.item withSize:size];
}

- (BOOL)mayHaveChildren {
	return YES;
}

- (NSArray *)children {
	return self.tracks;
}

- (id<SFMediaItem>)childWithKey:(id)childKey {
	return [SFMediaLibraryHelper mediaItemForKey:childKey inArray:self.tracks];
}

- (NSArray *)tracks {
	if(!isSorted) {
		[self sortTracks];
	}
	return self.sortedTracks;
}

- (NSString *)artistName {
	return self.parent.name;
}

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
	return [factory viewControllerForAlbum:self showAlbums:NO showArtists:self.isCompilation showTracksNumber:YES];
}

- (NSString *)artistNameForDiscovery {
	return [self artistName];
}

@end
