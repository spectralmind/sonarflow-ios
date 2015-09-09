#import "MainViewController.h"

#import <math.h>
#import <QuartzCore/QuartzCore.h>

#import "AlertPrompt.h"
#import "AppFactory.h"
#import "CrosshairView.h"
#import "Formatter.h"
#import "GANHelper.h"
#import "HintViewController.h"
#import "LastfmSettings.h"
#import "LastfmSettingsStorage.h"
#import "LastfmSettingsViewController.h"
#import "MPVolumeView+AirPlay.h"
#import "Notifications.h"
#import "NSString+CGLogging.h"
#import "PlaylistEditor.h"
#import "PlaylistPicker.h"
#import "PlaylistsViewController.h"
#import "ScreenshotFactory.h"
#import "Scrobbler.h"
#import "SFAppIdentity.h"
#import "SFBubbleHierarchyView.h"
#import "SFMediaItem.h"
#import "SFMediaLibrary.h"
#import "SFMediaPlayer.h"
#import "SFPlaylist.h"
#import "SFRootItem.h"
#import "SFZoomHintView.h"
#import "TipView.h"
#import "TrackTitleView.h"
#import "UIImage+Stretchable.h"
#import "GANHelper.h"

#ifdef TESTFLIGHT
	#import "TestFlight.h"
#endif

#ifdef SF_SPOTIFY
	#import "SFSpotifyLibrary.h"
	#import "SpotifyLicenseViewController.h"
#endif

#define kTimelineChangeDisabledDelay 1.0
#define kTipDuration 3.0
#define kSliderLeftCapWidth 3
#define kScrobbleHintDuration 15.0
#define kLastfmLoginErrorHintDuration 5.5

static const NSTimeInterval kZoomHintViewFadeOutAnimationDuration = 2.5f;

@interface MainViewController() <ScrobblerDelegate, LastfmSettingsViewControllerDelegate,
		SFMediaLibraryDelegate, UIAlertViewDelegate, SFZoomHintViewDelegate>

@property (nonatomic, strong) LastfmSettings *currentLastfmSettings;
@property (nonatomic, strong) CrosshairView *crosshairView;
@property (nonatomic, strong) SFZoomHintView *zoomHintView;

@end

@implementation MainViewController {
	UIImageView *coverView;
	BubbleViewController *bubbleViewController;
	
	BOOL timelineIsChanging;
	NSTimer *timelineIsChangingTimeout;
	
	LastfmSettingsStorage *lastfmStorage;
	HintViewController *hintViewController;
	
	BOOL ignoreScrobbleNotification;
	HintTapDelegateBlock showLastfmSettingsBlock;

	BOOL isPlaying;
	BOOL discoveryMode;
	BOOL remoteControlEnabled;
	
	BOOL alertShowing;
}

- (void)awakeFromNib {
    [super awakeFromNib];

	[self initCommon];
}

- (void)initCommon {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowArtistInfoNotification:) name:SFShowArtistInfoNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStopLibraryPlayerNotification:) name:SFStopLibraryPlayerNotification object:nil];
	
	[self initLastfm];
	
	hintViewController = [[HintViewController alloc] init];
	MainViewController *blockSelf = self;
	showLastfmSettingsBlock = [^() {
		[blockSelf showPartners];
#ifdef TESTFLIGHT
		[TestFlight passCheckpoint:@"lastfm:scrobbleSuggestionTapped"];
#endif
		[blockSelf.ganHelper trackEvent:@"Last.fm" action:@"scrobbleSuggestionTapped" label:nil value:-1];
	} copy];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.library = nil;
}

- (void)setLibrary:(NSObject<SFMediaLibrary> *)newLibrary {
	if(_library == newLibrary) {
		return;
	}
	[_library.player removeObserver:self forKeyPath:@"playbackState"];
	[_library.player removeObserver:self forKeyPath:@"nowPlayingLeaf"];
	[_library.player removeObserver:self forKeyPath:@"nowPlayingLeafPlaybackTime"];
	[_library.player removeObserver:self forKeyPath:@"nowPlayingLeafDuration"];
	[_library.player removeObserver:self forKeyPath:@"shuffle"];
	[_library.player removeObserver:self forKeyPath:@"canHandleRemoteControlEvents"];
	_library = newLibrary;
	_library.delegate = self;
	[_library.player addObserver:self forKeyPath:@"playbackState" options:0 context:NULL];
	[_library.player addObserver:self forKeyPath:@"nowPlayingLeaf" options:0 context:NULL];
	[_library.player addObserver:self forKeyPath:@"nowPlayingLeafPlaybackTime" options:0 context:NULL];
	[_library.player addObserver:self forKeyPath:@"nowPlayingLeafDuration" options:0 context:NULL];
	[_library.player addObserver:self forKeyPath:@"shuffle" options:0 context:NULL];
	[_library.player addObserver:self forKeyPath:@"canHandleRemoteControlEvents" options:0 context:NULL];
	[self updateRemoteControlState];
}

- (id<SFMediaPlayer>)player {
	return self.library.player;
}

- (Scrobbler *)scrobbler {
	if(_scrobbler == nil) {
		_scrobbler = [self.factory newScrobbler];
		_scrobbler.delegate = self;
		_scrobbler.lastfmSettings = self.currentLastfmSettings;
	}
	
	return _scrobbler;
}

@synthesize playlistsViewController = _playlistsViewController;
- (PlaylistsViewController *)playlistsViewController {
	if(_playlistsViewController == nil) {
		_playlistsViewController = [[PlaylistsViewController alloc] initWithFactory:self.factory.mediaViewControllerFactory];
		_playlistsViewController.playlistDelegate = self;
	}
	
	return _playlistsViewController;
}

- (void)updateRemoteControlState {
	if([self.library.player canHandleRemoteControlEvents] == NO && remoteControlEnabled) {
		[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
	}
	else if([self.library.player canHandleRemoteControlEvents] && remoteControlEnabled == NO) {
		[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	}
}

- (void)initLastfm {
	lastfmStorage = [[LastfmSettingsStorage alloc] init];
	self.currentLastfmSettings = [lastfmStorage loadSettings];
	if(self.currentLastfmSettings == nil) {
		self.currentLastfmSettings = [LastfmSettings settingsWithScrobble:NO username:nil password:nil];
	}
	NSLog(@"Loaded previous Last.fm settings from %@: %@\n", lastfmStorage, self.currentLastfmSettings);
}

- (void)viewDidLoad {
	[super viewDidLoad];
	NSAssert(self.library != nil, @"Missing library");

	[self.factory configureSFBubbleHierarchyView:self.bubbleHierarchyView];
	bubbleViewController = [[BubbleViewController alloc] initWithLibrary:self.library factory:self.factory];
	bubbleViewController.delegate = self;
	bubbleViewController.bubbleFactory = [self.factory bubbleFactory];
	bubbleViewController.view = self.bubbleHierarchyView;
	bubbleViewController.ganHelper = self.ganHelper;

	[self addCoverViewBelowScrollView];
	[self addCrosshairView];
	[self showInformationForMediaItem:nil];

	[self showTimeline:NO animated:NO];
	[self adjustUIBeforeOrientation:self.interfaceOrientation];
	[self addHeaderBackground];
    [self addHeaderInsetBackground];
	[self skinTimeline];
	[self createTrackTitleGestureRecognizer];

	hintViewController.referenceView = self.infoButton;
	hintViewController.maxWidth = 160;
	[self.view insertSubview:hintViewController.view aboveSubview:self.tipView];
	
	discoveryMode = NO;
}

- (void)addCoverViewBelowScrollView {
	coverView = [[UIImageView alloc] initWithFrame:self.bubbleHierarchyView.frame];
	coverView.autoresizingMask = self.bubbleHierarchyView.autoresizingMask;
	coverView.backgroundColor = [UIColor clearColor];
	coverView.hidden = YES;
	coverView.contentMode = UIViewContentModeScaleAspectFill;
	coverView.alpha = [self.factory backgroundImageAlpha];
	coverView.clipsToBounds = YES;
	[self.bubbleHierarchyView.superview insertSubview:coverView belowSubview:self.bubbleHierarchyView];
}

- (void)addCrosshairView {
	self.crosshairView = [[CrosshairView alloc] initWithImage:[UIImage imageNamed:@"discovery_crosshair"]];
	self.crosshairView.center = self.bubbleHierarchyView.center;
	self.crosshairView.autoresizingMask = UIViewAutoresizingNone;
	self.crosshairView.hidden = YES;

	[self.bubbleHierarchyView.superview insertSubview:self.crosshairView aboveSubview:self.bubbleHierarchyView];
}

- (CGPoint)getCrosshairOffset {
	return CGPointZero;
}

- (void)addHeaderBackground {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)addHeaderInsetBackground {
	[self doesNotRecognizeSelector:_cmd];
}

- (NSInteger)headerBackgroundLeftCapWidth {
	[self doesNotRecognizeSelector:_cmd];
	return 0;
}

- (void)skinTimeline {
	UIImage *thumb = [UIImage imageNamed:@"slider_button.png"];
	UIImage *minimumTrack = [self stretchableSliderImageNamed:@"slider_left.png"];
	UIImage *maximumTrack = [self stretchableSliderImageNamed:@"slider_right.png"];
	
	[self.timeline setThumbImage:thumb forState:UIControlStateNormal];
	[self.timeline setMinimumTrackImage:minimumTrack forState:UIControlStateNormal];
	[self.timeline setMaximumTrackImage:maximumTrack forState:UIControlStateNormal];
}

- (UIImage *)stretchableSliderImageNamed:(NSString *)imageName {
	return [UIImage stretchableImageNamed:imageName leftCapWidth:kSliderLeftCapWidth topCapHeight:0];
}

- (void)createTrackTitleGestureRecognizer {
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
										 initWithTarget:self
										 action:@selector(handleTrackTitleTap:)];
    [self.trackTitleView addGestureRecognizer:singleTap];
}

- (void)handleTrackTitleTap:(UIGestureRecognizer *)gestureRecognizer {
	[self zoomInOnCurrentTrack];
}

- (NSArray *)currentTrackKeyPath {
	return [self.player.nowPlayingLeaf keyPath];
}

- (void)zoomInOnCurrentTrack {
	[self.bubbleHierarchyView zoomToBubbleAtKeyPath:[self currentTrackKeyPath]];
}

- (void)setPlayingAnimationForPlayState:(BOOL)trackIsPlaying andTrack:(NSObject *)track {
    if (track == nil) {
		[self.bubbleHierarchyView setNothingPlaying];
	} else if (trackIsPlaying) {
		[self.bubbleHierarchyView startPlayingBubbleAtKeyPath:[self currentTrackKeyPath]];
	} else {
		[self.bubbleHierarchyView pausePlayingBubbleAtKeyPath:[self currentTrackKeyPath]];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[self.bubbleHierarchyView attachPlaylistEditor:self.playlistEditor];
	if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		self.playlistEditor.delegate = self;
	}
	[self showZoomHintIfAppropriate];
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"Did appear");
	[self.zoomHintView startAnimation];
	[self centerCrosshair];
    [self.bubbleHierarchyView fadeOutBubbleHighlight];
    [self.library startLoadingIfNeeded];
	[self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
	return [self.player canHandleRemoteControlEvents];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.bubbleHierarchyView detachPlaylistEditor:self.playlistEditor];
}

- (void)handleShowArtistInfoNotification:(NSNotification *)note {
	id<SFMediaItem> artist = [note.userInfo objectForKey:SFShowArtistInfoNotificationArtistKey];
	[self showArtistInfoViewForArtist:artist];
	
	if (discoveryMode) {
		[self.ganHelper trackEvent:@"ArtistInfo" action:@"showArtistInfoWithDiscoveryOnForArtist:" label:artist.name value:-1];
	}
	else {
		[self.ganHelper trackEvent:@"ArtistInfo" action:@"showArtistInfoWithDiscoveryOffForArtist:" label:artist.name value:-1];
	}
}

- (void)handleStopLibraryPlayerNotification:(NSNotification *)note {
	[self.library.player pausePlayback];
}

- (void)showArtistInfoViewForArtist:(id<SFMediaItem>)artist {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)showPartners {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)toggleDiscoveryMode {
	
	self.crosshairView.hidden = discoveryMode;
	discoveryMode = !discoveryMode;
		
	[self.bubbleHierarchyView discoveryMode:discoveryMode];
	
	if(discoveryMode == NO) {
		[self.ganHelper trackEvent:@"Discovery" action:@"disabled" label:nil value:-1];
		[bubbleViewController updatedDiscoveryZone:nil];
#ifdef TESTFLIGHT
		[TestFlight passCheckpoint:@"discovery:disabled"];
#endif
	}
	else {
		[self.ganHelper trackEvent:@"Discovery" action:@"enabled" label:nil value:-1];
#ifdef TESTFLIGHT
		[TestFlight passCheckpoint:@"discovery:enabled"];
#endif
	}
	
	self.toggleDiscoveryButton.selected = discoveryMode;
}

#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// deprecated in iOS 6
	return YES;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
								duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self adjustUIBeforeOrientation:toInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
										 duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self adjustUIAfterOrientation:toInterfaceOrientation];	
}

- (void)centerCrosshair {
	CGPoint offset = [self getCrosshairOffset];	
	self.crosshairView.center = CGPointMake(self.bubbleHierarchyView.center.x+offset.x, self.bubbleHierarchyView.center.y+offset.y);
}

#pragma mark -
#pragma mark Music Player User Interface

-(IBAction)homeButtonPressed {
	[self.bubbleHierarchyView zoomOut];
#ifdef TESTFLIGHT
	[TestFlight passCheckpoint:@"ui:homeButton"];
#endif
	[self.ganHelper trackEvent:@"UI" action:@"homeButtonPressed" label:nil value:-1];
}

- (IBAction)playPauseButtonPressed {
	[self.player togglePlayback];
}

- (IBAction)nextSong {
	[self.player skipToNextItem];
}

- (IBAction)previousSong {
	[self.player skipToPrevousItem];
}

- (IBAction)beganSettingTimelinePosition {
	[timelineIsChangingTimeout invalidate];
	timelineIsChangingTimeout = nil;
	timelineIsChanging = YES;
}

- (IBAction)setTimelinePosition {
	float relativeTime = self.timeline.value;
	[self.player setProgress:relativeTime];
	if(self.player.nowPlayingLeafDuration != nil) {
		float absoluteTime = [self.player.nowPlayingLeafDuration floatValue] * relativeTime;
		self.currentPlayTimeLabel.text = [Formatter formatDuration:absoluteTime];
	}
}

- (IBAction)finishedSettingTimelinePosition {
	[timelineIsChangingTimeout invalidate];
	timelineIsChangingTimeout =
		[NSTimer scheduledTimerWithTimeInterval:kTimelineChangeDisabledDelay
										 target:self
									   selector:@selector(timelineIsChangingTimeoutTimerFired:)
									   userInfo:nil
										repeats:NO];
}

- (IBAction)playlistsButtonPressed {
	[self showPlaylists];
}

- (IBAction)infoButtonPressed {
	[self toggleHelpView];
}

- (void)toggleHelpView {
	if([self helpViewIsVisible]) {
		[self hideHelpView];
	}
	else {
		[self showHelpView];
		[self.ganHelper trackEvent:@"UI" action:@"helpViewShown" label:nil value:-1];
	}
}

- (BOOL)helpViewIsVisible {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (void)showHelpViewOnFirstLaunch {    
    BOOL didLaunchBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"DidLaunchBefore"];
	didLaunchBefore = NO;
    if(didLaunchBefore == NO){
        [self showHelpView];        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DidLaunchBefore"];        
    }
}

- (void)showHelpView {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)hideHelpView {
	[self doesNotRecognizeSelector:_cmd];
}

- (IBAction)shuffleButtonPressed {
	self.player.shuffle = !self.player.shuffle;
	if (self.player.shuffle) {
		[self.ganHelper trackEvent:@"Playback" action:@"shuffleEnabled" label:nil value:-1];
	}
	else {
		[self.ganHelper trackEvent:@"Playback" action:@"shuffleDisabled" label:nil value:-1];
	}
}

- (void)setShuffleButtonToShuffle:(BOOL)shuffle; {
	self.shuffleEnabledButton.hidden = !shuffle;
	self.shuffleButton.hidden = shuffle;
}

- (IBAction)visitSonarflow {
	NSURL *url = [NSURL URLWithString:@"http://www.sonarflow.com"];
#ifdef TESTFLIGHT
	[TestFlight passCheckpoint:@"ui:visitSonarflow"];
#endif
	[[UIApplication sharedApplication] openURL:url];
}

- (IBAction)visitSpectralmind {
	NSURL *url = [NSURL URLWithString:@"http://www.spectralmind.com"];
#ifdef TESTFLIGHT
	[TestFlight passCheckpoint:@"ui:visitSpectralmind"];
#endif
	[[UIApplication sharedApplication] openURL:url];
}

- (IBAction)rateApp {
	[[UIApplication sharedApplication] openURL:[self.factory.appIdentity rateURL]];
}

- (IBAction)tappedToggleDiscoveryButton {
	[self toggleDiscoveryMode];
}

- (void)shareArtistOnFacebook:(NSString *)artistName {
	UIViewController *submitController = [self.factory facebookSubmitControllerForImage:[self takeScreenshot] withArtistName:artistName done:[self facebookSharingDoneBlock]];
	[self presentModalViewController:submitController animated:YES];
}

- (void)shareArtistOnTwitter:(NSString *)artistName {
	UIViewController *submitController = [self.factory twitterSubmitControllerForImage:[self takeScreenshot] withArtistName:artistName done:[self twitterSharingDoneBlock]];
	[self presentModalViewController:submitController animated:YES];
}

- (void (^)(BOOL shared))facebookSharingDoneBlock {
	return [^(BOOL shared){
		if (shared) {
			[self.ganHelper trackEvent:@"Sharing" action:@"facebookShared" label:nil value:-1];
		}
		else {
			[self.ganHelper trackEvent:@"Sharing" action:@"facebookSharingAborted" label:nil value:-1];
		}
	} copy];
}

- (void (^)(BOOL shared))twitterSharingDoneBlock {
	return [^(BOOL shared){
		if (shared) {
			[self.ganHelper trackEvent:@"Sharing" action:@"twitterShared" label:nil value:-1];
		}
		else {
			[self.ganHelper trackEvent:@"Sharing" action:@"twitterSharingAborted" label:nil value:-1];
		}
	} copy];
}

- (UIImage *)takeScreenshot {
	ScreenshotFactory *screenshotFactory = [self.factory screenshotFactory];
	UIImage *image = [screenshotFactory createScreenshotOfView:self.screenshotHelperView];
	return image;
}

- (IBAction)visitLastfm {
	NSURL *url = [NSURL URLWithString:@"http://www.last.fm"];
	[[UIApplication sharedApplication] openURL:url];	
}

- (IBAction)showLastfmSettings {
	NSLog(@"should display lastFM settings panel.\n");

	LastfmSettingsViewController *dialog = [[LastfmSettingsViewController alloc] initWithSettings:self.currentLastfmSettings];
	
	dialog.lastfmDelegate = self;
	dialog.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:dialog animated:YES];
}

#ifdef SF_SPOTIFY
- (IBAction)spotifyLogout {
	[((SFSpotifyLibrary *)self.library) showLoginDialog];
}

- (IBAction)showSpotifyLicense {
    SpotifyLicenseViewController *controller = [[SpotifyLicenseViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:navController animated:YES];
}
#endif

- (void)showSharingNotAvailableAsNothingIsPlaying {
	NSString *title = NSLocalizedString(@"Sharing not possible",
										@"Title for sharing not available message");
	NSString *message = NSLocalizedString(@"Cannot not share anything if no track is playing.",
										  @"Sharing not available message");
	[self showErrorAlertWithTitle:title withMessage:message];
}

- (void)showErrorAlertWithTitle:(NSString *)title withMessage:(NSString *)message {
	if(alertShowing) {
		NSLog(@"Swallowing alert %@: %@", title, message);
		return;
	}

	NSString *buttonTitle = NSLocalizedString(@"OK",
											  @"Title accepting/dismissing message button title");
	alertShowing = YES;
	UIAlertView *view = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:buttonTitle, nil];
	[view show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	alertShowing = NO;
}


- (IBAction)giveFeedback {
	NSString *destination = NSLocalizedString(@"appsupport@sonarflow.com",
											  @"Destination for feedback mails");
	
	NSString *subjectFormat = NSLocalizedString(@"%@ feedback %@",
												@"Subject format string for feedback mails (including the version information)");
	NSString *subject = [NSString stringWithFormat:subjectFormat, [self.factory appName], [self.factory versionString]];
	
	NSString *messageBodyTemplate = NSLocalizedString(@"I tried %@ and want to give some feedback:\n\n",
											  @"Template message body for feedback mails");
	NSString *messageBody = [NSString stringWithFormat:messageBodyTemplate, [self.factory appName]];
	
#ifdef DEBUG
	messageBody = [messageBody stringByAppendingFormat:@"\n\nConfiguration:\n\n%@",[self.factory devConfiguration]];
#endif

	if(![MFMailComposeViewController canSendMail]) {
#ifdef TESTFLIGHT
		[TestFlight passCheckpoint:@"ui:userCannotSendFeedback"];
#endif
		
		NSString *noMailTitle = NSLocalizedString(@"No Mail Support",
												  @"Title for the message that informs the user that the current device can't send emails");
		NSString *noMailMessage = NSLocalizedString(@"Your device is not set up for the delivery of email.",
													@"Message that informs the user that the current device can't send emails");
		NSString *buttonTitle = NSLocalizedString(@"OK",
												  @"Title for confirming button");
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:noMailTitle
															message:noMailMessage
														   delegate:nil
												  cancelButtonTitle:nil
												  otherButtonTitles:buttonTitle, nil];
		[alertView show];
		return;
	}
	
	NSData *imageData = UIImageJPEGRepresentation([self takeScreenshot], 1.0);
	
	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;
	[controller setToRecipients:[NSArray arrayWithObject:destination]];
	[controller setSubject:subject];
	[controller setMessageBody:messageBody isHTML:NO];
	
	[controller addAttachmentData:imageData mimeType:@"image/jpg" fileName:@"screenShot.jpg"];
	
	[self presentModalViewController:controller animated:YES];
	[self.ganHelper trackEvent:@"Sharing" action:@"mailOpened" label:nil value:-1];
}

- (IBAction)crossPromotedProductTapped {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.factory.appIdentity storeURLForCrossPromo]]];
}

- (MPVolumeView *)newVolumeViewInFrame:(CGRect)frame withSlider:(BOOL)showSlider {
	MPVolumeView *volumeView = [[MPVolumeView alloc] init];
	if([volumeView supportsAirPlay]) {
		volumeView.showsVolumeSlider = showSlider;
		volumeView.showsRouteButton = YES;
	}
	else if(!showSlider) {
		return nil;
	}
	
	CGSize volumeSize = frame.size;
	volumeSize = [volumeView sizeThatFits:volumeSize];
	CGFloat yOffset = (frame.size.height - volumeSize.height) * 0.5;
	CGRect volumeFrame = CGRectMake(frame.origin.x, frame.origin.y + yOffset,
									volumeSize.width, volumeSize.height);
	volumeView.frame = volumeFrame;
	
	volumeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
		UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self skinVolumeView:volumeView];
    
	return volumeView;
}

- (void)skinVolumeView:(MPVolumeView *)volumeView {
    UISlider *volumeViewSlider = [self volumeSliderForVolumeView:volumeView];
    
    UIImage *thumb = [UIImage imageNamed:@"slider_button.png"];
    UIImage *minimumTrack = [self stretchableSliderImageNamed:@"slider_left.png"];
    UIImage *maximumTrack = [self stretchableSliderImageNamed:@"slider_right.png"];
    UIImage *minimumVolume = [UIImage imageNamed:@"minimum_volume_indicator.png"];
    UIImage *maximumVolume = [UIImage imageNamed:@"maximum_volume_indicator.png"];
    
    [volumeViewSlider setThumbImage:thumb forState:UIControlStateNormal];
    [volumeViewSlider setMinimumTrackImage:minimumTrack forState:UIControlStateNormal];
    [volumeViewSlider setMaximumTrackImage:maximumTrack forState:UIControlStateNormal];
    [volumeViewSlider setMinimumValueImage:minimumVolume];
	[volumeViewSlider setMaximumValueImage:maximumVolume];
}

- (UISlider *)volumeSliderForVolumeView:(MPVolumeView *)volumeView {
    for (UIView *view in [volumeView subviews]){
		if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
            return (UISlider *) view;
		}
	}
    return nil;
}

#pragma mark Virtual Methods

- (void)showTimeline:(BOOL)show animated:(BOOL)animated {
}

- (void)showPlaylists {
}

- (void)dismissPlaylists {
}

- (void)adjustUIBeforeOrientation:(UIInterfaceOrientation)orientation {
}

- (void)adjustUIAfterOrientation:(UIInterfaceOrientation)orientation {
	[self.bubbleHierarchyView adjustUIAfterOrientation];
	[self centerCrosshair];
}

- (void)updatePlayPauseButton {
}

- (void)setPlayPauseButtonToPlay:(BOOL)play {
}

- (void)setPlaylistsButtonToEditMode:(BOOL)editMode {
}

- (void)showPreview:(UIViewController *)viewController inRect:(CGRect)rect {
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
	NSLog(@"Received memory warning");

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	bubbleViewController = nil;
	[self setBubbleHierarchyView:nil];
	
	[self setTimeline:nil];
	[self setCurrentPlayTimeLabel:nil];
	[self setTotalPlayTimeLabel:nil];

	[self setScreenshotHelperView:nil];

	[self setTipView:nil];
    [self setHeaderBackgroundView:nil];
	[self setTrackTitleView:nil];
    [self setShuffleButton:nil];
    [self setShuffleEnabledButton:nil];
	[self setInfoButton:nil];
	[self setToggleDiscoveryButton:nil];

	coverView = nil;
	coverView = nil;
	
	[self setOverlayContainerView:nil];
	[super viewDidUnload];
}

#pragma mark -
#pragma mark BubbleViewControllerDelegate

- (void)tappedMediaItem:(id<SFMediaItem>)mediaItem inRect:(CGRect)rect {
// TODO: Check disabled because of hack in SFSpotifyTrack
//	if([mediaItem hasDetailViewController] == NO) {
//		//TODO: play?
//		return;
//	}

	if([mediaItem respondsToSelector:@selector(createDetailViewControllerWithFactory:)] == NO) {
		return;
	}
	
	UIViewController *detailViewController = [mediaItem createDetailViewControllerWithFactory:self.factory.mediaViewControllerFactory];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[self showPreview:navigationController inRect:rect];
}

- (void)doubleTappedMediaItem:(id<SFMediaItem>)mediaItem inRect:(CGRect)rect {
	[self.bubbleHierarchyView fadeOutBubbleHighlight];
	[mediaItem startPlayback];
}

- (void)tappedEmptyLocation:(CGPoint)location {
}

- (void)discoveryInProgress:(BOOL)active {
	if(active) {
		[self.crosshairView startAnimating];
	}
	else {
		[self.crosshairView stopAnimating];
		[self.ganHelper trackEvent:@"Discovery" action:@"discovered" label:nil value:-1];
	}
}

- (void)updateArtistInFocus:(NSString *)artistName {
	// NOP, only implemented on iPad.
}

- (void)showZoomHintIfAppropriate {
#ifdef SF_SPOTIFY
	return;
#endif
	
	static BOOL showZoomHint = YES; // show on every fresh start
	if (!showZoomHint) {
		return;
	}
	
	showZoomHint = NO;
	
	[self showZoomHint];
}

- (void)showZoomHint {
	NSLog(@"showZoomHint");
	self.overlayContainerView.backgroundColor = [UIColor clearColor];
	self.overlayContainerView.hidden = NO;
	self.zoomHintView = [self.factory newZoomHintView];
	self.zoomHintView.delegate = self;
	CGRect rect = self.overlayContainerView.frame;
	rect.origin = CGPointZero;
	self.zoomHintView.frame = rect;
	[self.overlayContainerView addSubview:self.zoomHintView];
}


#pragma mark - SFZoomHintViewDelegate

- (void)zoomHintViewDidFinishAnimation:(SFZoomHintView *)zoomHintView {
	[UIView animateWithDuration:kZoomHintViewFadeOutAnimationDuration
						  delay:0
						options:UIViewAnimationOptionBeginFromCurrentState |
	 UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 self.overlayContainerView.alpha = .0f;
					 }
					 completion:^(BOOL finished){
						 self.overlayContainerView.hidden = YES;
						 [zoomHintView removeFromSuperview];
						 self.zoomHintView = nil;
					 }];
}


#pragma mark -
#pragma mark PlaybackDelegate

- (void)tappedMediaItem:(id<SFMediaItem>)mediaItem {
	[mediaItem startPlayback];
}
- (void)tappedChildIndex:(NSUInteger)index inMediaItem:(id<SFMediaItem>)mediaItem {
	[mediaItem startPlaybackAtChildIndex:index];
}

#pragma mark -
#pragma mark PlaylistEditorDelegate

- (void)presentPlaylistPicker:(PlaylistPicker *)picker {
	[self presentModalViewController:picker animated:YES];
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		CGRect superBounds = picker.view.superview.bounds;
		superBounds.size.width = 320;
		picker.view.superview.bounds = superBounds;
    }
}

#pragma mark -
#pragma mark PlaylistsViewControllerDelegate

- (void)addedPlaylist:(NSObject<SFPlaylist> *)playlist {
	[self.playlistEditor setPreviousPlaylist:playlist];
	[self dismissPlaylists];
	[self showAddToPlaylistTipForPlaylist:playlist];
}

- (void)showAddToPlaylistTipForPlaylist:(NSObject<SFPlaylist> *)playlist {
	NSString *textFormat = NSLocalizedString(@"Tap and hold any bubble to add songs to playlist '%@'.",
											 @"Format for 'add to playlist' tip");
	NSString *text = [NSString stringWithFormat:textFormat, [playlist name]];
	[self showTip:text forDuration:kTipDuration];
}

- (void)showTip:(NSString *)tip forDuration:(NSTimeInterval)duration {
	[self.tipView showTip:tip forDuration:duration];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
		didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	if(error != nil) {
		NSLog(@"Mail error %d: %@", [error code], [error localizedDescription]);
	}
	
	if (result == MFMailComposeResultSent) {
		[self.ganHelper trackEvent:@"Sharing" action:@"mailSent" label:nil value:-1];
	}
	else {
		[self.ganHelper trackEvent:@"Sharing" action:@"mailNotSent" label:nil value:-1];
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - ScrobblerDelegate <NSObject>

- (void)scrobblerDidFailToAuthenticate {
	NSLog(@"scrobbler failed to authenticate!\n");
	[hintViewController showHint:@"Could not log into last.fm. Please check your last.fm settings." forDuration:kLastfmLoginErrorHintDuration withTapDelegate:showLastfmSettingsBlock];
}

- (void)scrobblerSkippedScrobbling {
	NSLog(@"scrobbler failed to authenticate!\n");
	if(ignoreScrobbleNotification) {
		return;
	}
	
	ignoreScrobbleNotification = YES;
	[hintViewController showHint:@"Do you want to scrobble? Just enable it in the last.fm settings." forDuration:kScrobbleHintDuration withTapDelegate:showLastfmSettingsBlock];
}

- (void)scrobblerFailedToAuthenticate {
}


#pragma mark -
#pragma mark Private Methods

- (void)timelineIsChangingTimeoutTimerFired:(NSTimer *)timer {
	timelineIsChangingTimeout = nil;
	timelineIsChanging = NO;
}

#pragma mark - LastfmSettings delegation
- (void)finishedWithLastfmSettings:(LastfmSettings *)settings {
	NSLog(@"updating last.fm settings: %@\n", settings);
	
	self.currentLastfmSettings = settings;
	
	[lastfmStorage storeSettings:settings];
	self.scrobbler.lastfmSettings = settings;

	NSLog(@"dismissing ... \n");
	[self dismissModalViewControllerAnimated:YES];
}

- (void)didCancelLastfmSettings {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)verifyLastfmLoginWithUsername:(NSString *)username password:(NSString *)password completion:(LastfmLoginCompletionBlock)completionBlock {
	
	[self.scrobbler verifyAccountWithUsername:username withPassword:password completion:completionBlock];
}

- (void)createNewLastfmAccount {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.last.fm/join"]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if(object == self.library.player) {
		[self handleMediaPlayerChange:change forKeyPath:keyPath];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)libraryDidEncounterError:(NSError *)libraryError {
	NSString *title = NSLocalizedString(@"Library",
										@"Title for library error messages");
	[self showErrorAlertWithTitle:title withMessage:[libraryError localizedDescription]];
}

- (void)handleMediaPlayerChange:(NSDictionary *)change forKeyPath:(NSString *)keyPath {
	if([keyPath isEqualToString:@"playbackState"]) {
		[self handlePlaybackStateChanged];
	}
	else if([keyPath isEqualToString:@"nowPlayingLeaf"]) {
		[self handleNowPlayingTrackChanged];
	}
	else if([keyPath isEqualToString:@"nowPlayingLeafPlaybackTime"]) {
		[self handleNowPlayingPlaybackTimeChanged];
	}
	else if([keyPath isEqualToString:@"nowPlayingLeafDuration"]) {
		[self updatePlaybackDuration];
	}
	else if([keyPath isEqualToString:@"shuffle"]) {
		[self handleShuffleChanged];
	}
	else if([keyPath isEqualToString:@"canHandleRemoteControlEvents"]) {
		[self updateRemoteControlState];
	}
	else {
		NSAssert(0, @"Unexpected keyPath changed");
	}
}

- (void)handlePlaybackStateChanged {
	isPlaying = (self.player.playbackState == SFPlaybackStatePlaying);
	[self setPlayPauseButtonToPlay:isPlaying];
	[self setPlayingAnimationForPlayState:isPlaying andTrack:self.player.nowPlayingLeaf];
	[self.scrobbler playbackStateChangedToPlaying:isPlaying];
	if (isPlaying) {
		[self postStopYoutubePlaybackNotification];
	}
}

- (void)postStopYoutubePlaybackNotification {
	[[NSNotificationCenter defaultCenter] postNotificationName:SFStopYoutubeNotification object:self userInfo:nil];
}

- (void)handleNowPlayingTrackChanged {
	[self showInformationForMediaItem:self.player.nowPlayingLeaf];
	[self showImageForMediaItem:self.player.nowPlayingLeaf];
	[self showTimeline:(self.player.nowPlayingLeaf != nil) animated:YES];
	[self setPlayingAnimationForPlayState:isPlaying andTrack:self.player.nowPlayingLeaf];
	[self.scrobbler nowPlayingLeafChanged:self.player.nowPlayingLeaf];
}

- (void)showInformationForMediaItem:(id<SFMediaItem>)mediaItem {
	[self.trackTitleView showInformationForMediaItem:mediaItem];
	[self updatePlaybackDuration];
}

- (void)updatePlaybackDuration {
	NSNumber *duration = self.player.nowPlayingLeafDuration;
	if(duration == nil) {
		self.totalPlayTimeLabel.hidden = YES;
		return;
	}
	self.totalPlayTimeLabel.hidden = NO;
	self.totalPlayTimeLabel.text = [Formatter formatDuration:[duration floatValue]];
	[self handleNowPlayingPlaybackTimeChanged];
}

- (void)showImageForMediaItem:(id<SFMediaItem>)mediaItem {
	CGSize imageSize = CGSizeMake(CGRectGetWidth(coverView.frame), CGRectGetHeight(coverView.frame));
	UIImage *image = nil;
	if([mediaItem mayHaveImage]) {
		image = [mediaItem imageWithSize:imageSize];
	}

	coverView.image = image;
	coverView.hidden = NO;
}

- (void)handleNowPlayingPlaybackTimeChanged {
	if(timelineIsChanging) {
		return;
	}
	
	if(self.player.nowPlayingLeafDuration == nil) {
		self.timeline.hidden = YES;
	}
	else {
		self.timeline.hidden = NO;
		self.timeline.value = self.player.nowPlayingLeafPlaybackTime / [self.player.nowPlayingLeafDuration floatValue];
	}
	self.currentPlayTimeLabel.text = [Formatter formatDuration:self.player.nowPlayingLeafPlaybackTime];
}

- (void)handleShuffleChanged {
	[self setShuffleButtonToShuffle:self.player.shuffle];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
	NSAssert([self.player canHandleRemoteControlEvents] && [self.player respondsToSelector:@selector(handleRemoteControlEvent:)], @"Received remote control event that can not be handled");
	NSLog(@"Received remote control event: %@", receivedEvent);
	[self.player handleRemoteControlEvent:receivedEvent];
}

@end
