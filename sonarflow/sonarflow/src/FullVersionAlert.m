#import "FullVersionAlert.h"

@interface FullVersionAlert () <UIAlertViewDelegate>

@end


@implementation FullVersionAlert

- (void)show {
	NSString *title = NSLocalizedString(@"Playlist limit reached",
										@"Title for the text that is shown if the user trys to create more playlists than allowed");
	NSString *message = NSLocalizedString(@"Create more playlists in the full version of sonarflow.",
										  @"Text that is shown if the user trys to create more playlists than allowed");
	NSString *getItTitle = NSLocalizedString(@"Get it now!",
											 @"Title for button that links to the full version");
	NSString *okTitle = NSLocalizedString(@"OK",
										  @"Title for confirming button");
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:self
										  cancelButtonTitle:nil
										  otherButtonTitles:getItTitle, okTitle, nil];
	[alert show];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == [alertView firstOtherButtonIndex]) {
		NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/at/app/id407248118?mt=8"];
		[[UIApplication sharedApplication] openURL:url];
    }
}

@end
