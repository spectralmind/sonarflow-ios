#import "AppFactory.h"

#import "AnimationFactory.h"
#import "ArtistInfoIpadViewController.h"
#import "ArtistInfoIphoneViewController.h"
#import "ArtistInfoSidebarViewController.h"
#import "BubbleFactory.h"
#import "BubbleMainView.h"
#import "CollectionMenuController.h"
#import "Configuration.h"
#import "DismissButtonFactory.h"
#import "DraggableSidebarViewController.h"
#import "GitVersion.h"
#import "ImageFactory.h"
#import "ImageSubmitController.h"
#import "ImageSubmitter.h"
#import "MediaViewControllerFactory.h"
#import "PlaylistEditorImpl.h"
#import "ScreenshotFactory.h"
#import "Scrobbler.h"
#import "SFAppIdentity.h"
#import "SFAudioTrack.h"
#import "SFBubbleHierarchyView.h"
#import "SFIPadHelpViewController.h"
#import "SFZoomHintView.h"
#import "SFMediaItem.h"
#import "SFMediaLibrary.h"
#import "SFMediaPlayer.h"
#import "SFSmartistFactory.h"
#import "SMArtist.h"
#import "SNRLastFMEngine.h"
#import "UINavigationControllerAllowingKeyboardHide.h"
#import "UIViewController+SelfDismiss.h"

#if defined(SF_FREE)
	#import "AdMobHandler.h"
	#import "SFAdMediaViewControllerFactory.h"
	#define ADMOB_ID_STR macrostr(ADMOB_ID)
#elif defined(SF_SPOTIFY)
	#import "SFSpotifyMediaViewControllerFactory.h"
#endif

@interface AppFactory ()

@property (nonatomic, strong) DismissButtonFactory *buttonFactory;
@property (nonatomic, strong) SFSmartistFactory *smartistFactory;

@end


@implementation AppFactory {
	@private
	id<SFMediaLibrary> library;
	Configuration *configuration;
	id<PlaybackDelegate> playbackDelegate;

	ImageFactory *imageFactory;
	
	NSObject<PlaylistEditor> *playlistEditor;
	
	ScreenshotFactory *screenshotFactory;
	ImageSubmitController *imageSubmitController;
	ArtistInfoViewController *artistInfoViewController;
	DraggableSidebarViewController *sidebarController;
	ArtistInfoViewController *sidebarArtistInfoSmall;
	ArtistInfoViewController *sidebarArtistInfoFullscreen;
	UIViewController *rootViewController;
	SFAppIdentity *appIdentity;
}

- (id)initWithLibrary:(id<SFMediaLibrary>)theLibrary
		configuration:(Configuration *)theConfiguration
	 playbackDelegate:(id<PlaybackDelegate>)thePlaybackDelegate imageFactory:(ImageFactory *)theImageFactory
   rootViewController:(UIViewController *)theRootViewController {
	self = [super init];
	if(self) {
		library = theLibrary;
		configuration = theConfiguration;
		playbackDelegate = thePlaybackDelegate;
		imageFactory = theImageFactory;
		rootViewController = theRootViewController;
		appIdentity = [[SFAppIdentity alloc] init];
	}
	return self;
}

- (DismissButtonFactory *)buttonFactory {
	if(_buttonFactory == nil) {
		_buttonFactory = [[DismissButtonFactory alloc] init];
	}
	
	return _buttonFactory;
}

@synthesize imageSubmitter = _imageSubmitter;
- (ImageSubmitter *)imageSubmitter {
	if(_imageSubmitter == nil) {
		_imageSubmitter = [[ImageSubmitter alloc] initWithAppIdentity:appIdentity];
		_imageSubmitter.tradedoublerProgramID = [configuration stringForIdentifier:@"social.tradedoubler-programID"];
		_imageSubmitter.tradedoublerWebsiteID = [configuration stringForIdentifier:@"social.tradedoubler-websiteID"];
	}
	return _imageSubmitter;
}

@synthesize mediaViewControllerFactory = _mediaViewControllerFactory;
#if defined(SF_FREE)

- (MediaViewControllerFactory *)mediaViewControllerFactory {
	if(_mediaViewControllerFactory == nil) {
		AdMobHandler *adHandler = [[AdMobHandler alloc] init];
		adHandler.publisherId = [self adMobId];
		adHandler.viewController = rootViewController;
		_mediaViewControllerFactory = [[SFAdMediaViewControllerFactory alloc] initWithButtonFactory:self.buttonFactory playlistEditor:self.playlistEditor imageFactory:imageFactory playbackDelegate:playbackDelegate player:library.player library:library adHandler:adHandler];
	}
	return _mediaViewControllerFactory;
}

- (NSString *)adMobId {
	const char *adMobIdCStr = ADMOB_ID_STR;
	return [NSString stringWithFormat:@"%s", adMobIdCStr];
}

#elif defined(SF_SPOTIFY)

- (MediaViewControllerFactory *)mediaViewControllerFactory {
	if(_mediaViewControllerFactory == nil) {
		_mediaViewControllerFactory = [[SFSpotifyMediaViewControllerFactory alloc] initWithButtonFactory:self.buttonFactory playlistEditor:self.playlistEditor imageFactory:imageFactory playbackDelegate:playbackDelegate player:library.player library:library];
	}
	return _mediaViewControllerFactory;
}

#else

- (MediaViewControllerFactory *)mediaViewControllerFactory {
	if(_mediaViewControllerFactory == nil) {
		_mediaViewControllerFactory = [[MediaViewControllerFactory alloc] initWithButtonFactory:self.buttonFactory playlistEditor:self.playlistEditor imageFactory:imageFactory playbackDelegate:playbackDelegate player:library.player library:library];
	}
	return _mediaViewControllerFactory;
}

#endif

- (UITableViewCell *)editModeHeaderCell {
	return nil;
}

- (NSObject<PlaylistEditor> *)playlistEditor {
	if(playlistEditor == nil) {
		[self createPlaylistEditor];
	}
	
	return playlistEditor;
}

- (void)createPlaylistEditor {
	playlistEditor = [[PlaylistEditorImpl alloc] initWithLibrary:library
														 factory:self];
	playlistEditor.delegate = self.playlistEditorDelegate;
}

- (CollectionMenuController *)newMenuController {
	return [[CollectionMenuController alloc] initWithRootView:self.menuControllerRootView];
}

- (void)configureSFBubbleHierarchyView:(SFBubbleHierarchyView *)bubbleHierarchyView {
	bubbleHierarchyView.bubbleTextFont = self.bubbleFont;
	bubbleHierarchyView.bubbleCountFont = self.bubbleCountFont;
	bubbleHierarchyView.bubbleScreenSizeToShowChildren = [self bubbleScreenSizeToShowChildren];
	bubbleHierarchyView.bubbleScreenSizeToShowTitle = [configuration bubbleSizeToShowTitle];
	bubbleHierarchyView.bubbleFadeSize = [configuration bubbleFadeSize];
	bubbleHierarchyView.coverSize = [configuration bubbleCoverSize];
	bubbleHierarchyView.showCountLabel = [configuration bubbleEnableCountDisplay];
}

- (CGFloat)bubbleScreenSizeToShowChildren {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return [configuration bubbleSizeToShowChildren];
	} else {
		return [configuration bubbleSizeToShowChildren] * [configuration bubbleSizeToShowChildrenIphoneFactor];
	}
}

- (UIFont *)bubbleFont {
	CGFloat fontSize = [[configuration numberForIdentifier:@"bubbles.font_size"] floatValue];
	return [UIFont boldSystemFontOfSize:fontSize];
}

- (UIFont *)bubbleCountFont {
	CGFloat fontSize = [[configuration numberForIdentifier:@"bubbles.font_size"] floatValue] - 2;
	return [UIFont systemFontOfSize:fontSize];
}

- (AnimationFactory *)animationFactory {
	AnimationFactory *factory = [[AnimationFactory alloc] init];
	factory.animationDuration = [[configuration numberForIdentifier:@"animation.duration"] floatValue];
	return factory;
}

- (ScreenshotFactory *)screenshotFactory {
	if(screenshotFactory == nil) {
		screenshotFactory = [[ScreenshotFactory alloc] init];
	}
	return screenshotFactory;
}

- (UIViewController *)facebookSubmitControllerForImage:(UIImage *)image withArtistName:(NSString *)artistName done:(void (^)(BOOL shared))doneBlock {
	return [self imageSubmitControllerForImage:image withArtistName:artistName andWebservice:kFacebook done:doneBlock];
}

- (UIViewController *)twitterSubmitControllerForImage:(UIImage *)image withArtistName:(NSString *)artistName done:(void (^)(BOOL shared))doneBlock {
	return [self imageSubmitControllerForImage:image withArtistName:artistName andWebservice:kTwitter done:doneBlock];
}

- (UIViewController *)imageSubmitControllerForImage:(UIImage *)image withArtistName:(NSString *)artistName andWebservice:(WebService)service done:(void (^)(BOOL shared))doneBlock {
	ImageSubmitController *controller = [self imageSubmitController];
	controller.image = image;
    controller.artist = artistName;
	controller.service = service;
	controller.doneBlock = doneBlock;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];

	navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

	return navigationController;
}

- (ImageSubmitController *)imageSubmitController {
	if(imageSubmitController == nil) {
		NSString *messagePlaceholder = NSLocalizedString(@"Add a comment...",
														 @"Default placeholder message for shared screenshots");
		
		imageSubmitController = [[ImageSubmitController alloc] initWithNibName:@"ImageSubmitController" bundle:nil];
		imageSubmitController.imageSubmitter = self.imageSubmitter;
		imageSubmitController.messagePlaceholder = messagePlaceholder;
		imageSubmitController.navigationItem.rightBarButtonItem = [self.buttonFactory cancelButtonForViewController:imageSubmitController];
	}
	return imageSubmitController;
}

- (PlaylistPicker *)playlistPicker {
	PlaylistPicker *picker = [[PlaylistPicker alloc] initWithFactory:self.mediaViewControllerFactory];
	return picker;
}

- (BubbleFactory *)bubbleFactory {
	BubbleFactory *bubbleFactory = [[BubbleFactory alloc] initWithImageFactory:imageFactory];
	bubbleFactory.maxBubbleRadius = [[configuration numberForIdentifier:@"bubbles.max_bubble_radius"] floatValue];
	bubbleFactory.toplayerMinBubbleRadius = [configuration bubbleSizeToShowTitle] / 2.0;
	bubbleFactory.childrenRadiusFactor = [[configuration numberForIdentifier:@"bubbles.children_radius_factor"] floatValue];
	bubbleFactory.maxTextLength = [[configuration numberForIdentifier:@"bubbles.max_text_length"] integerValue];
	bubbleFactory.coverSize = [configuration bubbleCoverSize];
	return bubbleFactory;
}

- (ArtistInfoViewController *)artistInfoViewControllerForArtistName:(NSString *)artistName {
	ArtistInfoViewController *controller = [self artistInfoViewController];
	controller.artistName = artistName;
	controller.navigationItem.title = artistName;

	return controller;
}

- (SFSmartistFactory *)smartistFactory {
	if(_smartistFactory != nil) {
		return _smartistFactory;
	}
	
	_smartistFactory = [[SFSmartistFactory alloc] init];
	return _smartistFactory;
}


- (ArtistInfoViewController *)artistInfoViewController {
	if(artistInfoViewController == nil) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			artistInfoViewController = [[ArtistInfoIpadViewController alloc] init];
		} else {
			artistInfoViewController = [[ArtistInfoIphoneViewController alloc] init];
		}
		
		[artistInfoViewController useSmartistInstanceFromFactory:self.smartistFactory];
		artistInfoViewController.navigationItem.rightBarButtonItem = [self.buttonFactory closeButtonForViewController:artistInfoViewController];
	}
	
	artistInfoViewController.updateWhenViewAppearsNextTime = YES;

	return artistInfoViewController;
}

- (DraggableSidebarViewController *)sidebarControllerWithSharingDelegate:(id<ArtistSharingDelegate>)delegate {
	if(sidebarController == nil) {
		sidebarController = [[DraggableSidebarViewController alloc] init];

		ArtistInfoViewController *sidebarFullscreen = [self sidebarArtistInfoFullscreenWithIpadDelegate:sidebarController];
		sidebarFullscreen.sharingDelegate = delegate;
		sidebarController.fullscreenController = sidebarFullscreen;

		
		ArtistInfoViewController *sidebar = [self sidebarArtistInfoSmall];
		sidebar.sharingDelegate = delegate;
		sidebarController.sidebarController = sidebar;
	}
	
	[(ArtistInfoViewController *)sidebarController.fullscreenController setUpdateWhenViewAppearsNextTime:YES];
	[(ArtistInfoViewController *)sidebarController.sidebarController setUpdateWhenViewAppearsNextTime:YES];
	
	return sidebarController;
}

- (ArtistInfoViewController *)sidebarArtistInfoSmall {
	if(sidebarArtistInfoSmall == nil) {
		sidebarArtistInfoSmall = [[ArtistInfoSidebarViewController alloc] init];
		[sidebarArtistInfoSmall useSmartistInstanceFromFactory:self.smartistFactory];
	}
	
	return sidebarArtistInfoSmall;
}

- (ArtistInfoViewController *)sidebarArtistInfoFullscreenWithIpadDelegate:(id<OverlayCloseRequestDelegate>)delegate {
	if(sidebarArtistInfoFullscreen == nil && delegate != nil) {
		
		ArtistInfoIpadViewController *fullscreenArtistInfoController = [[ArtistInfoIpadViewController alloc] init];
		fullscreenArtistInfoController.artistInfoIpadDelegate = delegate;
		sidebarArtistInfoFullscreen = fullscreenArtistInfoController;
		[sidebarArtistInfoFullscreen useSmartistInstanceFromFactory:self.smartistFactory];
	}
	
	return sidebarArtistInfoFullscreen;
	
}


- (SFIPadHelpViewController *)helpViewController {
	SFIPadHelpViewController *hvc = [[SFIPadHelpViewController alloc] initWithNibName:@"SFIPadHelpViewController" bundle:nil];
	
	UIBarButtonItem *button = [self.buttonFactory closeButtonForViewController:artistInfoViewController];
	hvc.navigationItem.rightBarButtonItem = button;
	NSLog(@"button is %@.\n", button);
	
	return hvc;
}

- (Scrobbler *)newScrobbler {
	SNRLastFMEngine *lastfmEngine = [[SNRLastFMEngine alloc] init];
	lastfmEngine.apikey = [configuration lastfmApiKey];
	lastfmEngine.apisecret = [configuration lastfmApiSecret];

	Scrobbler *scrobbler = [[Scrobbler alloc] initWithLastfmEngine:lastfmEngine];

	return scrobbler;
}

- (NSString *)versionString {
	NSString *marketingVersionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	__unused NSString *developmentVersionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	__unused NSString *gitCommitVersion = GIT_VERSION;
	
#if defined(TESTFLIGHT)
	if ([[developmentVersionNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
		return [NSString stringWithFormat:@"v. %@-TF-%@", marketingVersionNumber, gitCommitVersion];
	}
	else {
		return [NSString stringWithFormat:@"v. %@-TF-%@", marketingVersionNumber, developmentVersionNumber];
	}
#elif defined(DEBUG)
	return [NSString stringWithFormat:@"v. %@-DBG-%@", marketingVersionNumber, gitCommitVersion];
#else
	NSString *versionFormat = NSLocalizedString(@"v. %@",
												@"Format string for the version information");
	return [NSString stringWithFormat:versionFormat, marketingVersionNumber];
#endif
}

- (NSString *)appName {
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
}

- (CGFloat)backgroundImageAlpha {
	return [[configuration numberForIdentifier:@"background.cover_alpha"] floatValue];
}

- (NSString *)devConfiguration {
	return [configuration settingsValues];
}

- (SFAppIdentity *)appIdentity {
	return appIdentity;
}

- (SFZoomHintView *)newZoomHintView {
	SFZoomHintView *view = [[SFZoomHintView alloc] init];
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	return view;
}

@end
