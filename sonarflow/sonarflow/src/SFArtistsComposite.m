#import "SFArtistsComposite.h"

#import "SFMediaCollection.h"
#import "SFAlbumsComposite.h"
#import "MediaViewControllerFactory.h"

@implementation SFArtistsComposite

- (id)initWithGenre:(SFMediaCollection *)theGenre {
	NSString *name = NSLocalizedString(@"Albums",
									   @"Name of a group of albums");
    self = [super initWithName:name mediaItems:[theGenre children] player:theGenre.player];
    if (self) {
		self.showArtists = YES;
    }
    return self;
}

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
	return [factory viewControllerForArtist:self singleArtist:NO];
}

- (id<SFMediaItem>)allChildrenComposite {
	SFAlbumsComposite *composite = [[SFAlbumsComposite alloc] initWithArtist:self player:self.player];
	composite.showArtists = YES;
	return composite;
}

@end
