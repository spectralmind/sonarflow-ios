#import "SFSpotifyAlbum.h"

#import "MediaViewControllerFactory.h"
#import "SPAlbum.h"
#import "SPArtist.h"
#import "SPImage.h"

@implementation SFSpotifyAlbum {
	SPAlbum *album;
}

-(id)initWitAlbum:(SPAlbum *)theAlbum key:(id)theKey player:(SFSpotifyPlayer *)thePlayer  {
	self = [super initWithName:nil key:theKey player:thePlayer];
	if(self == nil) {
		return nil;
	}
	
	album = theAlbum;
	[album.cover startLoading];
	
	return self;
}

- (BOOL)mayHaveImage {
	return YES;
}

- (UIImage *)imageWithSize:(CGSize)size {
	return album.cover.image;
}

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
	return [factory viewControllerForAlbum:self showAlbums:NO showArtists:NO showTracksNumber:YES];
}

- (NSString *)artistName {
	return album.artist.name;
}

- (NSString *)name {
	return album.name;
}

@end
