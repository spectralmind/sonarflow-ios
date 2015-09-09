#import "MainIPhoneViewController.h"

#import <math.h>
#import <MessageUI/MessageUI.h>

#import "AppFactory.h"
#import "ArtistInfoViewController.h"
#import "Formatter.h"
#import "MPVolumeView+AirPlay.h"
#import "Notifications.h"
#import "NSMutableArray+Replace.h"
#import "PlaylistsViewController.h"
#import "SFBubbleHierarchyView.h"
#import "SFMediaItem.h"
#import "UIImage+Stretchable.h"

#ifdef SF_SPOTIFY
	#import "SFSpotifyIPhoneHelpView.h"
#else
	#import "SFDefaultIPhoneHelpView.h"
#endif

#define kTopBarHeight 40
#define kAirplayPosXFromRight 93
#define kFooterLeftCapWidth 90

@implementation MainIPhoneViewController {
	@private
	BOOL interfaceIsVisible;
}

#pragma mark -
#pragma mark Initialization

- (void)viewDidLoad {
	[super viewDidLoad];
	
	interfaceIsVisible = YES;
	[self addAirPlayButton];
	[self addFooterBackground];
	[self showStandaloneButtons:NO animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self setBubbleViewPadding];
}


- (void)addAirPlayButton {
	CGRect frame = CGRectMake(self.footer.bounds.size.width - kAirplayPosXFromRight, 0,
							  self.playButton.frame.size.width, self.footer.bounds.size.height);
	MPVolumeView *volumeView = [self newVolumeViewInFrame:frame withSlider:NO];
	[self.footer addSubview:volumeView];
}

- (void)addFooterBackground {
	UIImage *background = [UIImage stretchableImageNamed:@"footer.png" leftCapWidth:kFooterLeftCapWidth topCapHeight:0];
	self.footerBackgroundView.image = background;
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
	NSLog(@"Received memory warning");

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[self setPlayButton:nil];
	[self setPauseButton:nil];
	[self setStandaloneHomeButton:nil];
	[self setStandalonePlaylistsButton:nil];
	
	[self setHeader:nil];
	[self setFooter:nil];
	[self setFooterBackgroundView:nil];
	
	[self setTimelineView:nil];
	[self setHelpView:nil];
	
	[super viewDidUnload];
}

#pragma mark - Virtual Methods

- (void)addHeaderInsetBackground {
	
}

- (void)addHeaderBackground {
	UIImage *background = [UIImage stretchableImageNamed:@"header.png" leftCapWidth:52 topCapHeight:0];
	self.headerBackgroundView.image = background;
}

- (void)showTimeline:(BOOL)show animated:(BOOL)animated {
	[super showTimeline:show animated:animated];
	
	CGRect timelineFrame = self.timelineView.frame;
	if(show) {
		timelineFrame.origin.y = kTopBarHeight;
	}
	else {
		timelineFrame.origin.y = -timelineFrame.size.height;
	}

	if(animated) {
		[UIView beginAnimations:@"ShowTimelineViewAnimation" context:nil];
	}
	self.timelineView.frame = timelineFrame;
	if(animated) {
		[UIView commitAnimations];
	}
}

- (void)showPlaylists {
	[super showPlaylists];
	
	[self presentModalViewController:self.playlistsViewController animated:YES];	
}

- (void)dismissPlaylists {
	[super dismissPlaylists];

	[self dismissModalViewControllerAnimated:YES];
}

- (BOOL)helpViewIsVisible {
	return self.helpView.alpha > 0.5;
}

- (void)showHelpView {
	if(self.helpView == nil) {
		[self loadHelpView];
		self.helpView.alpha = 0;
		[self.view addSubview:self.helpView];
	}
	
	[self adjustHelpViewFrame];
	self.helpView.alpha = 1;
}

- (void)showPartners {
	[self showHelpView];
	[self.helpView performSelector:@selector(scrollToPartners) withObject:nil afterDelay:0.5];	
}

- (void)loadHelpView {
	[[NSBundle mainBundle] loadNibNamed:@"SFIPhoneHelpView" owner:self options:nil];
	self.helpView.versionLabel.text = self.factory.versionString;
}

- (void)hideHelpView {
	self.helpView.alpha = 0;
}

- (void)adjustHelpViewFrame {
	CGRect helpFrame = self.view.bounds;
	CGFloat navBarHeight = kTopBarHeight;
	CGFloat toolBarHeight = self.footer.frame.size.height;
	helpFrame.origin.y = navBarHeight;
	helpFrame.size.height -= navBarHeight + toolBarHeight;
	self.helpView.frame = helpFrame;
}

- (void)adjustUIAfterOrientation:(UIInterfaceOrientation)orientation {
	[super adjustUIAfterOrientation:orientation];

	[self adjustHelpViewFrame];
}

- (void)setPlayPauseButtonToPlay:(BOOL)play {
	[super setPlayPauseButtonToPlay:play];
	
	if(play) {
		self.playButton.hidden = YES;
		self.pauseButton.hidden = NO;
	}
	else {
		self.pauseButton.hidden = YES;
		self.playButton.hidden = NO;
	}
}

- (void)showPreview:(UIViewController *)viewController inRect:(CGRect)rect {
	[super showPreview:viewController inRect:rect];

	[self presentModalViewController:viewController animated:YES];	
}

- (void)tappedEmptyLocation:(CGPoint)location {
	[self toggleInterfaceVisibilty];
}

- (void)showArtistInfoViewForArtist:(id<SFMediaItem>)artist {
	ArtistInfoViewController *viewController = [self.factory artistInfoViewControllerForArtistName:artist.name];
	viewController.sharingDelegate = self;
	[self pushViewContollerToPresentingViewController:viewController];
}

- (void)pushViewContollerToPresentingViewController:(UIViewController *)newController {
	// Hack: We need to know that the MediaCollectionViewController was previously presented modally AND is a UINavigationController AND sent this notification!
	UINavigationController *currentNavigationController = (UINavigationController *)self.modalViewController;
	NSAssert([currentNavigationController isKindOfClass:[UINavigationController class]], @"Unexpected or missing modalViewController");
	[currentNavigationController pushViewController:newController animated:YES];
}

#pragma mark - Private Methods

- (void)toggleInterfaceVisibilty {
	interfaceIsVisible = !interfaceIsVisible;
	
	[self showTopBar:interfaceIsVisible];
	[self showBottomBar:interfaceIsVisible];
	[self showStandaloneButtons:!interfaceIsVisible animated:YES];
	
	[self setBubbleViewPadding];
}

- (void)setBubbleViewPadding {
	if (interfaceIsVisible) {
		self.bubbleHierarchyView.bubbleContentInsets = UIEdgeInsetsMake([self topBarSize], 0.0f, [self bottomBarSize], 0.0f);
	} else {
		self.bubbleHierarchyView.bubbleContentInsets = UIEdgeInsetsZero;
	}
}

- (NSUInteger)topBarSize {
	return self.header.bounds.size.height;
}

- (NSUInteger)bottomBarSize {
	return self.footer.bounds.size.height;
}

- (void)showTopBar:(BOOL)show {
	CGRect barFrame = self.header.frame;
	if(show) {
		barFrame.origin.y = 0;
	}
	else {
		barFrame.origin.y = -barFrame.size.height;
	}
	
	[UIView beginAnimations:@"showTopBar" context:nil];
	self.header.frame = barFrame;
	[UIView commitAnimations];
}

- (void)showBottomBar:(BOOL)show {
	CGRect barFrame = self.footer.frame;
	CGFloat height = self.view.bounds.size.height;
	if(show) {
		barFrame.origin.y = height - barFrame.size.height;
	}
	else {
		barFrame.origin.y = height;
	}

	[UIView beginAnimations:@"showBottomBar" context:nil];
	self.footer.frame = barFrame;
	[UIView commitAnimations];
}

- (void)showStandaloneButtons:(BOOL)show animated:(BOOL)animated {
	CGFloat alpha = (show ? 1 : 0);
	
	if(animated) {
		[UIView beginAnimations:@"showButtons" context:nil];
	}
	self.standaloneHomeButton.alpha = alpha;
	self.standalonePlaylistsButton.alpha = alpha;
	if(animated) {
		[UIView commitAnimations];
	}
}

- (void)shareArtistOnTwitter:(NSString *)artistName {
	UIViewController *submitController = [self.factory twitterSubmitControllerForImage:[self takeScreenshot] withArtistName:artistName done:[self twitterSharingDoneBlock]];

	[self.presentedViewController presentModalViewController:submitController animated:YES];	
}

- (void)shareArtistOnFacebook:(NSString *)artistName {
	UIViewController *submitController = [self.factory facebookSubmitControllerForImage:[self takeScreenshot] withArtistName:artistName done:[self facebookSharingDoneBlock]];
	
	[self.presentedViewController presentModalViewController:submitController animated:YES];	
}

@end
