#import "DismissButtonFactory.h"

@implementation DismissButtonFactory

- (UIBarButtonItem *)doneButtonForViewController:(UIViewController *)controller {
	if(controller.navigationItem.rightBarButtonItem != nil) {
		return controller.navigationItem.rightBarButtonItem;
	}
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return nil;
	}
	
	NSString *title = NSLocalizedString(@"Hide",
										@"Title for button that dismisses modal view controller that can be brought back easily");
	return [self dismissButtonWithTitle:title style:UIBarButtonItemStyleDone forViewController:controller];
}

- (UIBarButtonItem *)cancelButtonForViewController:(UIViewController *)controller {
	NSString *title = NSLocalizedString(@"Cancel",
										@"Title for button that cancels and dismisses a modal dialog");
	return [self dismissButtonWithTitle:title style:UIBarButtonItemStylePlain forViewController:controller];
}

//TODO: Is it really necessary to differentiate between 'Close' and 'Hide'? Or was this difference introduced by accident?
- (UIBarButtonItem *)closeButtonForViewController:(UIViewController *)controller {
	NSString *title = NSLocalizedString(@"Close",
										@"Title for button that dismisses a modal dialog");

	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return nil;
	}
	
	return [self dismissButtonWithTitle:title style:UIBarButtonItemStylePlain forViewController:controller];
}


- (UIBarButtonItem *)dismissButtonWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style forViewController:(UIViewController *)controller {
	return [[UIBarButtonItem alloc]
			 initWithTitle:title
			 style:style
			 target:controller
			 action:@selector(dismiss)];
}

@end
