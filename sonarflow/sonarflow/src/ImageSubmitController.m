//
//  ImageSubmitController.m
//  sonarflow
//
//  Created by Raphael Charwot on 17.03.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "ImageSubmitController.h"
#import "UIImage+Stretchable.h"
#import "UIDevice+SystemVersion.h"

#ifdef TESTFLIGHT
	#import "TestFlight.h"
#endif

#define kDefaultServiceSegmentIndex 0

#define kIPhonePortraitTopMargin 10

#define kIPhonePortraitWithkeyboardTextHeight 54
//segment + button hidden by keyboard and done bar

#define kIPhonePortraitNokeyboardTextHeight 75
#define kIPhonePortraitNokeyboardTextToSegmentVertical 110
#define kIPhonePortraitNokeyboardSegmentToButtonVertical 22

#define kIPhoneLandscapeWithkeyboardTextHeight 65
#define kIPhoneLandscapeWithkeyboardTextToSegmentHorizontal 23
//button hidden by keyboard and done bar
//no image and track info displayed
//segment next to text

#define kIPhoneLandscapeNokeyboardTopMargin 16
#define kIPhoneLandscapeWithkeyboardTopMargin 10

#define kIPhoneLandscapeNokeyboardTextHeight 65
#define kIPhoneLandscapeNokeyboardTextToButtonVertical 24
//segment next to text


#define kIPadPortraitControllerWidth 370
#define kIPadPortraitControllerHeight 548

#define kIPadPortraitWithkeyboardTextHeight 130
#define kIPadPortraitWithkeyboardTextToSegmentVertical 67
#define kIPadPortraitWithkeyboardSegmentToButtonVertical 44

#define kIPadLandscapeControllerWidth 530
#define kIPadLandscapeControllerHeight 396

#define kIPadLandscapeWithkeyboardTextHeight 75
#define kIPadLandscapeWithkeyboardTextToSegmentVertical 27
#define kIPadLandscapeWithkeyboardSegmentToButtonVertical 12


@implementation ImageSubmitController {
@private
	BOOL keyboardVisible;
	UIView *songInfoView;
}


- (void)viewDidLoad {
	UIImage *buttonBackgroundImage = [UIImage stretchableImageNamed:@"button_submit_image.png" leftCapWidth:9 topCapHeight:0];
	[self.submitButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
	UIImage *messageBackgroundImage = [UIImage stretchableImageNamed:@"message_background.png" leftCapWidth:12 topCapHeight:12];
	[self.messageBackground setImage:messageBackgroundImage];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated {
	[self hideActivityIndicator];
	self.imagePreview.image = self.image;
	self.messageView.placeholder = self.messagePlaceholder;
	self.messageView.text = [self getPredefinedMessage];
	
	[self attachKeyboardToolbarIphone];
	[self hideActivityIndicator];
	
	self.navigationItem.title = [@"Share on " stringByAppendingString:[self getSelectedWebserviceName]];
}

- (void)viewWillDisappear:(BOOL)animated {
	if (self.doneBlock != nil) {
		self.doneBlock(NO);
	}
	
	[super viewWillDisappear:animated];
}

- (NSString *)getPredefinedMessage {
	NSString *format = NSLocalizedString(@"Using %@ I have just discovered \'%@\'!", @"Pre-filled message in the share artist dialog");
	return [NSString stringWithFormat:format, [self appName], self.artist];
}

- (NSString *)appName {
	if(self.service == kTwitter) {
		return @"@Sonarflow";
	}
	
	return @"Sonarflow";
}

- (void)attachKeyboardToolbarIphone {
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		UIToolbar *keyboardToolbar = [UIToolbar new];
		keyboardToolbar.barStyle = UIBarStyleDefault;
		[keyboardToolbar sizeToFit];
		UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClickedIphone:)];
		NSArray *buttons = [NSArray arrayWithObjects:flexibleSpace,doneButton, nil];
		keyboardToolbar.items = buttons;
		self.messageView.inputAccessoryView = keyboardToolbar;
	}
}

- (void)doneClickedIphone:(id)sender {
	[self.messageView resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
		return;
	}
	
	if(keyboardVisible == NO) {
		keyboardVisible = YES;
		
		CGRect frame = self.view.frame;
		frame.origin.y = -170.0;
		self.view.frame = frame;
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
		return;
	}

	if (keyboardVisible) {
		keyboardVisible = NO;
		
		CGRect frame = self.view.frame;
		frame.origin.y = 0;
		self.view.frame = frame;
	}
}

- (void)adjustIpadViewSizeForOrientation:(UIInterfaceOrientation)orientation {
	//self.view.frame = CGRectMake(0, 0, kIPadPortraitControllerWidth, 400);
	self.navigationController.view.superview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin; 
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		self.navigationController.view.superview.frame = CGRectMake(0, 0, kIPadPortraitControllerWidth, kIPadPortraitControllerHeight);
		self.navigationController.view.superview.center = self.navigationController.view.superview.superview.center;
	} else {
		self.navigationController.view.superview.frame = CGRectMake(0, 0, kIPadLandscapeControllerWidth, kIPadLandscapeControllerHeight);
		self.navigationController.view.superview.center = self.navigationController.view.superview.superview.center;
	}
}

- (void)viewDidUnload {
	self.contentContainerView = nil;
	self.imagePreview = nil;
	self.messageContainerView = nil;
	self.messageView = nil;
	self.submitButton = nil;
	self.shareView = nil;
	[self setMessageBackground:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// deprecated in iOS 6
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation) &&
		UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		return NO;
	} else {
		return YES;
	}
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		return UIInterfaceOrientationMaskPortrait;
	}
	else {
		return UIInterfaceOrientationMaskAll;
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[UIView beginAnimations:@"Update UI" context:nil];
	[UIView setAnimationDuration:duration];

	[UIView commitAnimations];
}

- (IBAction)submitImage {
	[self showActivityIndicator];
	NSString *message = self.messageView.text;
	self.imageSubmitter.delegate = self;

	[self.imageSubmitter submitToWebservice:[self getSelectedWebservice] withImage:self.image withText:message];
#ifdef TESTFLIGHT
	[TestFlight passCheckpoint:@"social:tryToPostImage"];
#endif
}


- (WebService)getSelectedWebservice {
	return self.service;
}

- (NSString *)getSelectedWebserviceName {
	switch([self getSelectedWebservice]) {
		case kFacebook:
			return @"Facebook";
		case kTwitter:
			return @"Twitter";
			
		default:
			return @"Unknown!";
	}
}

- (void)showActivityIndicator {
	[self.activityIndicator startAnimating];
	self.submitButton.hidden = YES;
}

- (void)hideActivityIndicator {
	[self.activityIndicator stopAnimating];
	self.submitButton.hidden = NO;
}

#pragma mark -
#pragma mark ImageSubmitterDelegate

- (void)didFinishSubmittingImage {
	[self hideActivityIndicator];
	if (self.doneBlock != nil) {
		self.doneBlock(YES);
	}
	self.doneBlock = nil;
	[self dismissModalViewControllerAnimated:YES];
#ifdef TESTFLIGHT
	[TestFlight passCheckpoint:@"social:imageSuccessfullyPosted"];
#endif
}

- (void)didCancelSubmittingImage {
	[self hideActivityIndicator];
}

- (void)didFailSubmittingImage {
	[self hideActivityIndicator];
	[self showDefaultError];
}

- (void)didFailToUseServiceWithMessage:(NSString *)failMessage {
	[self hideActivityIndicator];
	[self showErrorWithMessage:failMessage];
}

- (void)showInfoWithMessage:(NSString *)errorMessage {
	NSString *title = NSLocalizedString(@"Info",
										@"Title for info message");
	NSString *buttonTitle = NSLocalizedString(@"OK",
											  @"Title accepting/dismissing message button title");
	[self showAlertWithTitle:title withMessage:errorMessage withButtonTitle:buttonTitle];
}

- (void)showErrorWithMessage:(NSString *)errorMessage {
	NSString *title = NSLocalizedString(@"Sharing failed",
										@"Title for failed upload message");
	NSString *buttonTitle = NSLocalizedString(@"OK",
											  @"Title accepting/dismissing message button title");
	[self showAlertWithTitle:title withMessage:errorMessage withButtonTitle:buttonTitle];
}

- (void)showDefaultError {
	NSString *title = NSLocalizedString(@"Upload failed",
										@"Title for failed upload message");
	NSString *message = NSLocalizedString(@"Could not share your image, please try again later.",
										  @"Failed upload message");
	NSString *buttonTitle = NSLocalizedString(@"OK",
											  @"Title accepting/dismissing message button title");
	[self showAlertWithTitle:title withMessage:message withButtonTitle:buttonTitle];
}

- (void)showAlertWithTitle:(NSString *)title withMessage:(NSString *)message withButtonTitle:(NSString *)buttonTitle {
	UIAlertView *view = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:buttonTitle, nil];
	[view show];
}

@end
