#import "PlaylistsViewController.h"

#import "MediaViewControllerFactory.h"

@interface PlaylistsViewController ()

@end


@implementation PlaylistsViewController {
	MediaViewControllerFactory *factory;
}


- (id)initWithFactory:(MediaViewControllerFactory *)theFactory {
	UIViewController *controller = [theFactory viewControllerForPlaylistsWithDelegate:self asPicker:NO];
	self = [super initWithRootViewController:controller];
	if(self) {
		factory = theFactory;
		[self initPlaylistsViewController];
	}
	return self;
}

- (void)initPlaylistsViewController {
	self.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}



#pragma mark -
#pragma mark PlaylistsViewDelegate

- (void)addedPlaylist:(NSObject<SFPlaylist> *)playlist {
	[self.playlistDelegate addedPlaylist:playlist];
}

- (void)selectedPlaylist:(NSObject<SFPlaylist> *)playlist {
	UIViewController *viewController = [factory viewControllerForPlaylist:playlist];
	[self pushViewController:viewController animated:YES];
}

@end
