#import <CocoaLibSpotify.h>

#import "SFSpotifyLibrary.h"
#import "SFSpotifyToplist.h"
#import "SFSpotifyPlayer.h"
#import "SFSpotifyPlaylist.h"
#import "SFMediaLibraryHelper.h"
#import "RootKey.h"
#import "SFSpotifyDiscoveredArtist.h"
#import "SFMediaItemContainerDelegate.h"
#import "SFSpotifyFactory.h"
#import "SFSpotifySearchFactory.h"
#import "SFSpotifyToplistBridge.h"
#import "SFSpotifyPlaylistBridge.h"

static const NSInteger kLoginErrorCode = 6;

const uint8_t g_appkey[] = {
	0x01, 0x21, 0xFC, 0x36, 0x5E, 0xF8, 0x93, 0x98, 0x08, 0xDF, 0x07, 0x6F, 0x89, 0x14, 0x8A, 0xF9,
	0xA1, 0x68, 0x6B, 0xE1, 0x18, 0x0B, 0xCB, 0xA3, 0x16, 0x8D, 0x58, 0xBD, 0x66, 0xCC, 0xE2, 0x63,
	0x85, 0x00, 0x7B, 0xE8, 0x36, 0xFE, 0x55, 0x73, 0x19, 0x1F, 0x0E, 0x5D, 0x5D, 0x9E, 0xA0, 0x12,
	0x2C, 0x6C, 0x88, 0x9B, 0xF3, 0x70, 0xFE, 0x3F, 0x49, 0x6C, 0x9F, 0x4D, 0xCF, 0x0F, 0x49, 0x7D,
	0x34, 0x6C, 0xF4, 0xDF, 0x77, 0x16, 0x88, 0x55, 0x6E, 0xCE, 0xAC, 0x9F, 0x9E, 0xD9, 0xD6, 0x0E,
	0x1F, 0x8A, 0xCA, 0xA1, 0xF9, 0x07, 0x28, 0xE4, 0xF0, 0x8A, 0x43, 0x38, 0xF9, 0xB6, 0x59, 0xFD,
	0x79, 0x02, 0xBE, 0x5F, 0x82, 0x96, 0xBB, 0xEF, 0x5A, 0x95, 0x20, 0xC1, 0x84, 0xCC, 0xCD, 0x2B,
	0x19, 0xAE, 0x9C, 0x58, 0xF1, 0xD1, 0x4F, 0x69, 0xB4, 0x67, 0x42, 0x21, 0xD2, 0x0D, 0x25, 0x02,
	0x10, 0x12, 0x58, 0x2E, 0x17, 0x2C, 0x0C, 0x79, 0x7D, 0x3F, 0xED, 0x90, 0xEE, 0xFD, 0x82, 0x95,
	0x22, 0x0F, 0xFF, 0xF9, 0xF8, 0x92, 0x00, 0xF6, 0x87, 0x2B, 0xED, 0xB5, 0x50, 0x91, 0x13, 0x58,
	0xDD, 0x4F, 0x19, 0xA6, 0x6A, 0x21, 0x71, 0x07, 0x3B, 0x3E, 0xFF, 0xE2, 0xB6, 0x46, 0x4F, 0xFE,
	0xF2, 0xF6, 0xE1, 0xB8, 0x80, 0xBD, 0x66, 0x26, 0xA9, 0xF3, 0x7C, 0x60, 0x28, 0x43, 0xC1, 0xE8,
	0x86, 0x31, 0x92, 0x3D, 0x00, 0xC5, 0x33, 0xA5, 0x32, 0x24, 0x03, 0xD8, 0xE3, 0xEF, 0x52, 0xA7,
	0xAF, 0x5F, 0x0E, 0x63, 0xF9, 0x6E, 0x6C, 0xE7, 0xCB, 0x0C, 0x6D, 0xC8, 0xEC, 0x93, 0xD4, 0x55,
	0xE3, 0x9F, 0x36, 0xE9, 0x0C, 0x74, 0x7D, 0x85, 0x71, 0xCA, 0x0F, 0x1A, 0xF0, 0xDE, 0x05, 0xCC,
	0x90, 0xEA, 0xEA, 0x3C, 0x31, 0x68, 0x25, 0xC7, 0xCA, 0x7B, 0x4D, 0xEB, 0x58, 0x02, 0xF2, 0x87,
	0x23, 0x1D, 0xB0, 0x56, 0x7C, 0xD8, 0x3C, 0xE3, 0x93, 0xFD, 0x5F, 0xE9, 0xFB, 0x7E, 0x8A, 0x0A,
	0xD4, 0xAB, 0x60, 0x54, 0xA6, 0xE9, 0xB6, 0x40, 0x8F, 0xF1, 0x95, 0xC1, 0x18, 0xDF, 0xB5, 0xC0,
	0x26, 0xC2, 0x8D, 0x41, 0xF9, 0xF1, 0x4F, 0x6A, 0x7C, 0xF9, 0x22, 0xE7, 0xD0, 0x0A, 0xFC, 0xD7,
	0xC7, 0x78, 0x95, 0xAA, 0x68, 0x5F, 0x08, 0x6A, 0xA6, 0x48, 0x9C, 0x82, 0x9C, 0x4E, 0xD1, 0xB8,
	0x2F,
};

const size_t g_appkey_size = sizeof(g_appkey);

@interface SFSpotifyLibrary () <SPSessionDelegate, SFMediaItemContainerDelegate>
@property (nonatomic, retain) SFSpotifyPlaylistBridge *starredBridge;
@property (nonatomic, retain) SFSpotifyToplistBridge *toplistBridge;
@property (nonatomic, retain) SFSpotifyToplistBridge *userToplistBridge;
@end

@implementation SFSpotifyLibrary {
	NSMutableArray *mediaItems;
	SFSpotifyFactory *factory;
	SFSpotifySearchFactory *searchFactory;
	BOOL loggedIn;
}


@synthesize mediaItems;
@synthesize playlists;

@synthesize delegate;

@synthesize toplistBridge;
@synthesize userToplistBridge;
@synthesize starredBridge;
@synthesize mainViewController;

- (id)init {
    self = [super init];
    if (self) {
        mediaItems = [[NSMutableArray alloc] init];
		[self initializeSession];
		factory = [[SFSpotifyFactory alloc] init];
		searchFactory = [[SFSpotifySearchFactory alloc] initWithPlayer:factory.player];
    }
	
    return self;
}

- (void)initializeSession {
	NSError *error = nil;
	if([SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size] userAgent:@"com.spectralmind.Sonarflow" loadingPolicy:SPAsyncLoadingImmediate error:&error] == NO) {
		NSLog(@"Could not initialize spotify session: %@", error);
	}
	
	[[SPSession sharedSession] setDelegate:self];
}

- (void)startLoadingIfNeeded {
	[self login];
}

- (void)loadLibrary {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	[mediaItems willChangeValueForKey:@"mediaItems"];
	[mediaItems removeAllObjects];
	[mediaItems didChangeValueForKey:@"mediaItems"];
	
	[SPAsyncLoading waitUntilLoaded:[SPSession sharedSession] timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedession, NSArray *notLoaded) {
		// The session is logged in and loaded — now wait for the userPlaylists to load.
		NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Session loaded.");		
		[self populateRootLevel];
	}];
}

- (void)populateRootLevel {
	[self loadStarredPlaylist];
	[self loadToplists];
	//[self addUserPlaylists];
}

- (void)loadStarredPlaylist {
	[SPAsyncLoading waitUntilLoaded:[SPSession sharedSession].starredPlaylist timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loaded, NSArray *notLoaded) {
		if (loaded.count == 0) {
			return;
		}
		self.starredBridge = [factory playlistBridgeForSPPlaylist:[loaded objectAtIndex:0] withName:@"My Starred Tracks" origin:CGPointMake(450, 0) color:[UIColor yellowColor]];
		starredBridge.delegate = self;
	}];
}

- (void)loadToplists {
	self.toplistBridge = [factory toplistBridge];
	toplistBridge.delegate = self;
	
	self.userToplistBridge = [factory userToplistBridge];
	userToplistBridge.delegate = self;
}

- (void)bridge:(SFSpotifyBridge *)theBridge discoveredMediaItem:(id<SFMediaItem>)mediaItem {
	[self insertMediaItems:[NSArray arrayWithObject:mediaItem] atIndexes:[NSIndexSet indexSetWithIndex:mediaItems.count]];
}

- (void)bridge:(SFSpotifyBridge *)theBridge removedMediaItem:(id<SFMediaItem>)mediaItem {
	NSLog(@"shall remove media item %@", mediaItem);
	NSUInteger index = [self.mediaItems indexOfObject:mediaItem];
	NSAssert(index != NSNotFound, @"removing unknown item!");
	[self removeMediaItemsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (void)insertMediaItems:(NSArray *)newMediaItems atIndexes:(NSIndexSet *)indexes {
	[mediaItems insertObjects:newMediaItems atIndexes:indexes];
}

- (void)removeMediaItemsAtIndexes:(NSIndexSet *)indexes {
	[mediaItems removeObjectsAtIndexes:indexes];
}

- (void)insertPlaylists:(NSArray *)newPlaylists atIndexes:(NSIndexSet *)indexes {
}

- (void)removePlaylistsAtIndexes:(NSIndexSet *)indexes {
}

-(NSObject<SFPlaylist> *)newPlaylistWithName:(NSString *)name order:(NSInteger)order {
	return nil;
}

- (void)login {
	if(loggedIn) {
		return;
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"SpotifyCredential"]
        && [defaults objectForKey:@"SpotifyUsername"]) {
        NSString *credential = [defaults objectForKey:@"SpotifyCredential"];
        NSString *username = [defaults objectForKey:@"SpotifyUsername"];
		[[SPSession sharedSession] attemptLoginWithUserName:username existingCredential:credential];
		// attemptlogin might tell delegate that it failed if session is expired, or password was changed inbetween
    }
	else {
		[self showLoginDialog];
	}
}

- (void)showLoginDialog {
	[self removeSpotifyCredentials];
	loggedIn = NO;
	SPLoginViewController *loginViewController = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
	loginViewController.allowsCancel = NO;
	[self.mainViewController presentModalViewController:loginViewController animated:YES];
}

- (void)removeSpotifyCredentials {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"SpotifyCredential"];
	[defaults removeObjectForKey:@"SpotifyUsername"];
	[defaults synchronize];
}

- (NSObject<SFMediaPlayer> *)player {
	return self.spotifyPlayer;
}

- (SFSpotifyPlayer *)spotifyPlayer {
	return factory.player;
}

- (NSObject<SFMediaItem> *)mediaItemForKeyPath:(NSArray *)keyPath {
	return [SFMediaLibraryHelper mediaItemForKeyPath:keyPath inArray:mediaItems];
}

- (BOOL)containsArtistWithName:(NSString *)artistName {
	return NO;
}

- (id<SFMediaItem>)mediaItemForDiscoveredArtistWithKey:(id)theKey name:(NSString *)artistName {
	return [[SFSpotifyDiscoveredArtist alloc] initWithKey:theKey name:artistName searchFactory:searchFactory player:factory.player];
}

#pragma mark - SPSessionDelegate

- (void)sessionDidLoginSuccessfully:(SPSession *)aSession {
	loggedIn = YES;

	NSLog(@"Spotify did login successfully");
	[self loadLibrary];
}

- (void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error {
	[self removeSpotifyCredentials];
	NSLog(@"Spotify did fail with error: %@", error);
	if(error.code == kLoginErrorCode) { // Workaround for #1614
		NSLog(@"Ignoring login error: %@, should be displayed by spotify itself", error);
		return;
	}
	[self.delegate libraryDidEncounterError:error];
}

- (void)sessionDidLogOut:(SPSession *)aSession {
	[self removeSpotifyCredentials];
	NSLog(@"Spotify did log out");

	[self willChangeValueForKey:@"mediaItems"];
	mediaItems = [[NSMutableArray alloc] init];
	[self didChangeValueForKey:@"mediaItems"];
}

- (void)session:(SPSession *)aSession recievedMessageForUser:(NSString *)aMessage {
	NSLog(@"Spotify did receive message: %@", aMessage);
}

- (void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error {
	NSLog(@"Spotify did encounter network error: %@", error);
}

- (void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage {
	//	NSLog(@"Spotify did log message: %@", aMessage);
}

-(UIViewController *)viewControllerToPresentLoginViewForSession:(SPSession *)aSession {
	return self.mainViewController;
}

- (NSObject<SFPlaylist> *)newPlaylistWithName:(NSString *)name {
	return nil; //TODO: Implement?
}

-(void)session:(SPSession *)session didGenerateLoginCredentials:(NSString *)credential forUserName:(NSString *)userName {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:credential forKey:@"SpotifyCredential"];
    [defaults setObject:userName forKey:@"SpotifyUsername"];
    [defaults synchronize];
}


@end
