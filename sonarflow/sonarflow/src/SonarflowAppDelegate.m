#import "SonarflowAppDelegate.h"

#import "Appirater.h"
#import "MainViewController.h"
#import "SFMediaLibrary.h"
#import "GANHelper.h"
#import "PlaylistEditor.h"
#import "AppFactory.h"
#import "BubbleFactory.h"
#import "Configuration.h"
#import "ImageSubmitter.h"
#import "ImageFactory.h"

#ifdef TESTFLIGHT
	#import "TestFlight.h"
#endif

#ifdef SF_SPOTIFY
	#import "SFSpotifyLibrary.h"
	#import "SPSession.h"
#else
	#import "SFNativeMediaLibrary.h"
	#import "SFNativeMediaPlayer.h"
#endif


@implementation SonarflowAppDelegate {
	@private
	Configuration *configuration;
	AppFactory *factory;

	GANHelper *ganHelper;
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application
		didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
#ifdef TESTFLIGHT
	[TestFlight takeOff:@"ab53b1edbf049e82fea877098870cc5c_NzgyNjEyMDEyLTA0LTE3IDA5OjI0OjQ5LjQxMjYxNA"];

	if([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)]) {
		NSString *identifier = [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
		[TestFlight setDeviceIdentifier:identifier];
	}
#endif
	
	NSString *devSettingsPath = [[NSBundle mainBundle] pathForResource:@"Configuration"
		ofType:@"plist"];
	
	[Configuration initWithDevelopmentSettingsPath:devSettingsPath];
	configuration = [Configuration sharedConfiguration];
	
#if !defined(DEBUG) && !defined(TESTFLIGHT)
	// only use GAN in AppStore Releases
	ganHelper = [[GANHelper alloc] initWithConfiguration:configuration];
#endif
	[ganHelper trackPageView:@"/app_entry_point"];
	ImageFactory *imageFactory = [[ImageFactory alloc] init];
	NSObject<SFMediaLibrary> *library = nil;
#ifdef SF_SPOTIFY
	SFSpotifyLibrary *spotifyLibrary = [[SFSpotifyLibrary alloc] init];
	spotifyLibrary.mainViewController = self.rootViewController;
	library = spotifyLibrary;
#else
	BOOL otherbubbleFix = [configuration genreLookupEnabled];
	if(otherbubbleFix == NO) {
		NSLog(@"warning! other bubble fix is forced inactive.");
	}
	
	library = [[SFNativeMediaLibrary alloc] initWithDocumentsDirectory:[self applicationDocumentsDirectory] ganHelper:ganHelper imageFactory:imageFactory otherBubbleFixup:otherbubbleFix];
#endif
	factory = [self newAppFactoryWithLibrary:library imageFactory:imageFactory];

	self.viewController.library = library;
	self.viewController.playlistEditor = [factory playlistEditor];
	self.viewController.factory = factory;
	self.viewController.scrobbler = [factory newScrobbler];
	self.viewController.ganHelper = ganHelper;
	
	self.window.backgroundColor = self.rootViewController.view.backgroundColor;
	self.window.rootViewController = self.rootViewController;
	[self.window addSubview:self.rootViewController.view];
	[self.window makeKeyAndVisible];
	
    [Appirater appLaunched:YES];
	return YES;
}


- (AppFactory *)newAppFactoryWithLibrary:(NSObject<SFMediaLibrary> *)library imageFactory:(ImageFactory *)imageFactory {
	AppFactory *result = [[AppFactory alloc] initWithLibrary:library configuration:configuration playbackDelegate:self.viewController imageFactory:imageFactory rootViewController:self.viewController];
	result.playlistEditorDelegate = self.viewController;
	result.menuControllerRootView = self.window;
	return result;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	return [factory.imageSubmitter.facebook handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	NSLog(@"willResignActive");
	[ganHelper trackPageView:@"/app_exit_point"];
	BOOL didZoomBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"DidZoomBefore"];
	if (!didZoomBefore) {
		[ganHelper trackEvent:@"Zoom" action:@"appClosedWhileUserNeverZoomed" label:nil value:-1];
	}
}

#ifdef SF_SPOTIFY
//TODO: Use UIApplicationWillTerminateNotification in SFSpotifyLibrary instead
- (void)applicationWillTerminate:(UIApplication *)application {
	[[SPSession sharedSession] logout:nil];
}
#endif

- (void)applicationDidEnterBackground:(UIApplication *)application {
	NSLog(@"didEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	NSLog(@"willEnterForeground");
	[ganHelper trackPageView:@"/app_entry_point"];
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSLog(@"didBecomeActive");
}

#pragma mark -
#pragma mark Application's Documents directory

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


@end
