#import "SFArtist.h"

#import "SFAlbum.h"
#import "SFTrack.h"
#import "SFAlbumsComposite.h"
#import "MediaViewControllerFactory.h"
#import "SFNativeMediaFactory.h"

@interface SFArtist ()

@end


@implementation SFArtist

@synthesize compilationArtist;

- (NSArray *)pushTracksIntoAlbumChildrenWithFactory:(SFNativeMediaFactory *)factory {
	NSMutableDictionary *albums = [self dictFromChildren];
	for(SFTrack *track in [self tempTracks]) {
		SFAlbum *album = [albums objectForKey:track.sortableAlbum];
		if(album == nil) {
			album = [factory newAlbumWithName:[track albumName]];
			album.sortableName = track.sortableAlbum;
			album.parent = self;
			album.item = track.mediaItem;
			album.compilation = self.compilationArtist;
			[albums setObject:album forKey:track.sortableAlbum];
		}
		[album addTrack:track];
	}
	
	NSArray *sortedAlbums = [self sortChildren:[albums allValues]];
	[self addChildrenInMainThread:sortedAlbums];
	return sortedAlbums;
}

- (NSMutableDictionary *)dictFromChildren {
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:self.children.count];
	for (SFAlbum *album in self.children) {
		if (![album isKindOfClass:[SFAlbum class]]) {
			continue;
		}
		[dict setObject:album forKey:album.sortableName];
	}
	
	return dict;
}

- (NSArray *)sortTracks:(NSArray *)tracks {
	return [tracks sortedArrayUsingFunction:sortTracksByAlbumNumber context:nil];
}

- (NSArray *)sortChildren:(NSArray *)children {
	return [children sortedArrayUsingSelector:@selector(compareKeys:)];
}

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
	return [factory viewControllerForArtist:self singleArtist:![self isCompilationArtist]];
}

- (id<SFMediaItem>)allChildrenComposite {
	return [[SFAlbumsComposite alloc] initWithArtist:self player:self.player];
}

- (NSString *)artistNameForDiscovery {
	return self.name;
}

@end
