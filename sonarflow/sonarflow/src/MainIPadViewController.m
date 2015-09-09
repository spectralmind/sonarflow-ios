#import "MainIPadViewController.h"

#import <math.h>
#import <QuartzCore/QuartzCore.h>

#import "AppFactory.h"
#import "ArtistInfoIpadViewController.h"
#import "ArtistInfoSidebarViewController.h"
#import "ArtistSharingDelegate.h"
#import "BubbleOverlayController.h"
#import "DraggableSidebarViewController.h"
#import "Formatter.h"
#import "Notifications.h"
#import "PlaylistsViewController.h"
#import "SFBubbleHierarchyView.h"
#import "SFMediaItem.h"
#import "UIDevice+SystemVersion.h"
#import "UIImage+Stretchable.h"

#ifdef SF_SPOTIFY
	#define kHeaderInsetWidthLandscape (324+54)
	#define kHeaderInsetWidthPortrait (270+54)
#else
	#define kHeaderInsetWidthLandscape (324)
	#define kHeaderInsetWidthPortrait (270)
#endif

@interface MainIPadViewController () <OverlayCloseRequestDelegate, ArtistSharingDelegate, UIActionSheetDelegate>

@end

@implementation MainIPadViewController {
@private
	UIPopoverController *bubblePopoverController;
	UIPopoverController *playlistsPopoverController;
	
	BubbleOverlayController *overlayController;
	DraggableSidebarViewController *sidebarController;
	
	BOOL discovering;
}


#pragma mark - Initialization

- (void)viewDidLoad {		
	UIView *overlayView = [self createOverlayView];
	overlayController = [[BubbleOverlayController alloc] initWithOverlayView:overlayView];
	
	[self addVolumeView];
	[super viewDidLoad];
}


- (UIView *)createOverlayView {
	UIView *overlayView = [[UIView alloc] initWithFrame:self.screenshotHelperView.frame];
	overlayView.autoresizingMask = self.screenshotHelperView.autoresizingMask;
	overlayView.hidden = YES;
	
	[self.screenshotHelperView.superview addSubview:overlayView];
	
	return overlayView;
}

- (void)addVolumeView {
	MPVolumeView *volumeView = [self newVolumeViewInFrame:self.headerVolumeView.bounds withSlider:YES];
	[self.headerVolumeView addSubview:volumeView];
}


#define kSidebarWidth 320
#define kGripWidth 20

- (void)addSidebar {
	CGRect frame = self.screenshotHelperView.frame;
	frame.origin.x += (frame.size.width - kSidebarWidth);
	frame.size.width = kSidebarWidth;
	
	sidebarController = [self.factory sidebarControllerWithSharingDelegate:self];
	sidebarController.fullscreenRect = self.screenshotHelperView.frame;
	sidebarController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
	sidebarController.view.frame = frame;

	sidebarController.fullscreenController.view.backgroundColor = [UIColor clearColor];
	sidebarController.fullscreenController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	CGRect fullscreenRect = self.screenshotHelperView.superview.bounds;
	fullscreenRect.size.width = kSidebarWidth - kGripWidth;
	sidebarController.fullscreenController.view.frame = fullscreenRect;
	
	sidebarController.sidebarController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
	sidebarController.sidebarController.view.frame = CGRectMake(0, 0, kSidebarWidth - kGripWidth, frame.size.height);
	
	[self addChildViewController:sidebarController];
	[self.screenshotHelperView.superview insertSubview:sidebarController.view aboveSubview:self.screenshotHelperView];
	[sidebarController didMoveToParentViewController:self];

	sidebarController.view.hidden = YES;
	
	self.bubbleHierarchyView.discoveryZoneCenterOffset = [self getCrosshairOffset];
}

- (void)removeSidebar {
	[sidebarController.view removeFromSuperview];
	[sidebarController removeFromParentViewController];
	sidebarController = nil;
	
	NSLog(@"sidebar controller removed.");	
}

- (CGPoint)getCrosshairOffset {
	if(UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
		return CGPointMake(-kSidebarWidth/2, 0);
	}

	return CGPointZero;
}

- (void)toggleDiscoveryMode {	
	discovering = !discovering;
	
	if(discovering) {
		[self addSidebar];
	}
	else {
		[self removeSidebar];
	}
	
	if(UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
		self.sonarflowLogo.hidden = discovering;
		sidebarController.view.hidden = !discovering;
	}
	
	[super toggleDiscoveryMode];
}

- (void)updateArtistInFocus:(NSString *)artistName {
	if(discovering == NO) {
		return;
	}
	
	ArtistInfoViewController *small = [self.factory sidebarArtistInfoSmall];
	if([small.artistName isEqualToString:artistName]) {
		return;
	}
	
	small.artistName = artistName;
	[small updateContents];

	ArtistInfoViewController *fullscreen = [self.factory sidebarArtistInfoFullscreenWithIpadDelegate:nil];
	fullscreen.artistName = artistName;
	[fullscreen updateContents];
	
	NSLog(@"focus on artist: %@", artistName);
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	if(UIDeviceOrientationIsPortrait(toInterfaceOrientation)) {
		self.sonarflowLogo.hidden = NO;
		sidebarController.view.hidden = YES;
	}
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	if(UIDeviceOrientationIsPortrait(fromInterfaceOrientation)) {
		self.sonarflowLogo.hidden = discovering;
		sidebarController.view.hidden = !discovering;
	}
	
	self.bubbleHierarchyView.discoveryZoneCenterOffset = [self getCrosshairOffset];
}

#pragma mark - Virtual Methods

- (void)addHeaderInsetBackground {
	UIImage *insetbackground = [UIImage stretchableImageNamed:@"header_inset.png" leftCapWidth:5 topCapHeight:0];
	self.headerInsetImageView.image = insetbackground;
}

- (void)addHeaderBackground {
}

- (void)showTimeline:(BOOL)show animated:(BOOL)animated {
	[super showTimeline:show animated:animated];

	CGFloat newAlpha = (show ? 1 : 0);

	if(animated) {
		[UIView beginAnimations:@"FadeTimelineAnimation" context:nil];
	}
	self.currentPlayTimeLabel.alpha = newAlpha;
	self.totalPlayTimeLabel.alpha = newAlpha;
	self.timeline.alpha = newAlpha;
	if(animated) {
		[UIView commitAnimations];
	}
}

- (void)showPlaylists {
	[super showPlaylists];

	if(playlistsPopoverController == nil) {
		playlistsPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.playlistsViewController];
		playlistsPopoverController.delegate = self;
	}
	else {
		playlistsPopoverController.popoverContentSize = self.playlistsViewController.contentSizeForViewInPopover;
	}
	
	//TODO: Replace when switching to a tab bar
	//		[playlistsPopoverController presentPopoverFromBarButtonItem:sender
	[playlistsPopoverController presentPopoverFromRect:[self.playlistBarButton frame]
												inView:self.headerView
							  permittedArrowDirections:UIPopoverArrowDirectionUp
											  animated:YES];
}

- (void)dismissPlaylists {
	[super dismissPlaylists];
	
	[playlistsPopoverController dismissPopoverAnimated:YES];
}

- (BOOL)helpViewIsVisible {
	return [overlayController isPresenting];
}

- (void)showHelpView {
	[self showHelpViewWithPartners:NO];
}

- (void)showPartners {
	[self showHelpViewWithPartners:YES];
}

- (void)showHelpViewWithPartners:(BOOL)scrollToPartners {
	[self.infoButton setEnabled:NO];
	
	SFIPadHelpViewController *hvc = [self.factory helpViewController];
	hvc.closeRequestDelegate = self;
	[overlayController presentController:hvc];
	hvc.versionLabel.text = [self.factory versionString];

	if(scrollToPartners) {
		[hvc performSelector:@selector(scrollToPartners) withObject:nil afterDelay:0.5];
	}
}


- (void)hideHelpView {
	[self.infoButton setEnabled:YES];	
	[overlayController dismissController];
}

- (void)adjustUIBeforeOrientation:(UIInterfaceOrientation)orientation {
	[super adjustUIBeforeOrientation:orientation];
    CGRect newHeaderInsetFrame = self.headerInsetView.frame;
	if(UIInterfaceOrientationIsLandscape(orientation)) {
		[self hideVolumeView:NO];
		newHeaderInsetFrame.size.width = kHeaderInsetWidthLandscape;
	}
	else {
		[self hideVolumeView:YES];
		newHeaderInsetFrame.size.width = kHeaderInsetWidthPortrait;
	}
    self.headerInsetView.frame = newHeaderInsetFrame;
}

- (void)hideVolumeView:(BOOL)hide {
	for(UIView *subview in self.headerVolumeView.subviews) {
		subview.hidden = hide;
	}
	
	self.headerVolumeView.hidden = hide;
}

- (void)setPlayPauseButtonToPlay:(BOOL)play {
	[super setPlayPauseButtonToPlay:play];

	if(play) {
		[self.playPauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
	}
	else {
		[self.playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
	}
}

- (void)showPreview:(UIViewController *)viewController inRect:(CGRect)rect {
	[super showPreview:viewController inRect:rect];

	if(bubblePopoverController == nil) {
		bubblePopoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
		bubblePopoverController.delegate = self;
	}
	else {
		bubblePopoverController.contentViewController = viewController;
		bubblePopoverController.popoverContentSize = viewController.contentSizeForViewInPopover;
	}
	
	CGRect intRect = CGRectIntegral(rect);
	[bubblePopoverController presentPopoverFromRect:intRect
											 inView:self.bubbleHierarchyView
						   permittedArrowDirections:UIPopoverArrowDirectionAny
										   animated:YES];
}

#pragma mark - Orientation

- (UIView *)rotatingHeaderView {
	return self.headerView;
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
	NSLog(@"Received memory warning");

	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	overlayController = nil;
	
	[self setHeaderView:nil];
	[self setPlaylistBarButton:nil];
	[self setPlayPauseButton:nil];
	[self setTitleLabel:nil];
	[self setSubtitleLabel:nil];
	
	[self setHeaderInsetView:nil];
	[self setHeaderInsetImageView:nil];
	[self setHeaderVolumeView:nil];
	[self setSonarflowLogo:nil];

	[super viewDidUnload];
}

#pragma mark - UIPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
	[self.bubbleHierarchyView fadeOutBubbleHighlight];
	return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
}

#pragma mark -

- (void)showArtistInfoViewForArtist:(id<SFMediaItem>)artist {
	ArtistInfoIpadViewController *viewController = (ArtistInfoIpadViewController *)[self.factory artistInfoViewControllerForArtistName:artist.name];
	NSAssert([viewController isKindOfClass:[ArtistInfoIpadViewController class]], @"Unexpected type of ArtistInfoViewController");
	[self hidePopoverControllers];
	
	if(discovering && sidebarController.view.hidden == NO) {
		NSLog(@"not showing separate artist info, using sidebar.");
		[self updateArtistInFocus:artist.name];
		return;
	}
	
	viewController.artistInfoIpadDelegate = self;
	viewController.sharingDelegate = self;
	[self.infoButton setEnabled:NO];

	[overlayController presentController:viewController];	
}

#pragma mark - OverlayCloseRequestDelegate
- (void)dismissOverlay:(UIViewController *)presentedViewController {
	NSLog(@"received delegated dismiss request.\n");
	[self.infoButton setEnabled:YES];
	[overlayController dismissController];
	[self.bubbleHierarchyView fadeOutBubbleHighlight];	
}

#pragma mark - ArtistSharingDelegate
- (void)shareArtist:(NSString *)artistName fromButton:(UIView *)sender {
	NSLog(@"delegated share request received for %@", artistName);

	[self showPopoverForSharingSelection:sender];
}

- (void)showPopoverForSharingSelection:(UIView *)sender {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Share..." delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter" ,nil];
	[sheet showFromRect:sender.frame inView:sender.superview animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch(buttonIndex) {
		case -1:
			break;
			
		case 0:
			[self selectedFacebookForSharing];
			break;
			
		case 1:
			[self selectedTwitterForSharing];
			break;
			
		default:
			NSAssert(NO, @"invalid button index %d", buttonIndex);
	}
}

#pragma mark -

- (void)selectedFacebookForSharing {
	ArtistInfoViewController *artistinfo = [self.factory sidebarArtistInfoSmall];
	[super shareArtistOnFacebook:artistinfo.artistName];
}

- (void)selectedTwitterForSharing {
	ArtistInfoViewController *artistinfo = [self.factory sidebarArtistInfoSmall];
	[super shareArtistOnTwitter:artistinfo.artistName];
}

#pragma mark Private Methods

- (void)hidePopoverControllers {
	//Don't use accessors (we don't want to create them if they don't exist yet
	if([bubblePopoverController isPopoverVisible]) {
		[bubblePopoverController dismissPopoverAnimated:YES];
	}
	if([playlistsPopoverController isPopoverVisible]) {
		[playlistsPopoverController dismissPopoverAnimated:YES];
	}
}

@end
