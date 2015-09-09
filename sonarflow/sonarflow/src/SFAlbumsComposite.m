#import "SFAlbumsComposite.h"

#import "SFMediaItem.h"
#import "MediaViewControllerFactory.h"

@implementation SFAlbumsComposite

- (id)initWithArtist:(id<SFMediaItem>)theArtist player:(SFNativeMediaPlayer *)thePlayer {
	NSString *name = NSLocalizedString(@"Tracks",
									   @"Name of a group of tracks");
    self = [super initWithName:name mediaItems:[theArtist children] player:thePlayer];
    if (self) {
    }
    return self;
}

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
	return [factory viewControllerForAlbum:self showAlbums:YES showArtists:self.showArtists showTracksNumber:NO];
}

@end
