#import "LastfmSettingsViewController.h"

#import "LastfmSettingsTableViewController.h"

@implementation LastfmSettingsViewController {
	LastfmSettingsTableViewController *viewController;
}

- (id)initWithSettings:(LastfmSettings *)settings {
	LastfmSettingsTableViewController *theViewController = [[LastfmSettingsTableViewController alloc] initWithNibName:@"LastfmSettingsTableViewController" bundle:nil];
    self = [super initWithRootViewController:theViewController];
    if (self) {
		viewController = theViewController;
		[viewController resetWithSettings:settings];
    }
	
    return self;
}


- (void)setLastfmDelegate:(id<LastfmSettingsViewControllerDelegate>)delegate {
	viewController.delegate = delegate;
}

- (id<LastfmSettingsViewControllerDelegate>)lastfmDelegate {
	return viewController.delegate;
}

@end
