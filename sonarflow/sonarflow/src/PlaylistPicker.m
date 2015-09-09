#import "PlaylistPicker.h"

#import "MediaViewControllerFactory.h"

@interface PlaylistPicker ()

- (void)initCommon;

@end

@implementation PlaylistPicker

@synthesize playlistDelegate;

- (id)initWithFactory:(MediaViewControllerFactory *)factory {
	UIViewController *controller = [factory viewControllerForPlaylistsWithDelegate:self asPicker:YES];
	self = [super initWithRootViewController:controller];
	if(self) {
		[self initCommon];
	}
	return self;
}

- (void)initCommon {
	self.navigationBar.barStyle = UIBarStyleBlackOpaque;
	self.modalPresentationStyle = UIModalPresentationFormSheet;
}

- (void)setPrompt:(NSString *)prompt {
	NSAssert([self.viewControllers count] > 0, @"Missing view controller");
	
	UIViewController *root = [self.viewControllers objectAtIndex:0];
	root.navigationItem.prompt = prompt;
}

#pragma mark -
#pragma mark PlaylistsViewDelegate

- (void)addedPlaylist:(NSObject<SFPlaylist> *)playlist {
	[self.playlistDelegate pickedPlaylist:playlist];
}

- (void)selectedPlaylist:(NSObject<SFPlaylist> *)playlist {
	[self.playlistDelegate pickedPlaylist:playlist];
}

@end
