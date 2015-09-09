#import "SFNativeMediaLibraryLoader.h"

#import <MediaPlayer/MediaPlayer.h>

#import "AppStatusObserver.h"
#import "DeviceInformation.h"
#import "GANHelper.h"
#import "GenreDefinition.h"
#import "NameGenreMapper.h"
#import "SFAlbum.h"
#import "SFArtist.h"
#import "SFGenre.h"
#import "SFGenreFetcher.h"
#import "SFGenreFetcherRequestData.h"
#import "SFMediaLibraryHelper.h"
#import "SFNativeMediaFactory.h"
#import "SFTrack.h"

//Raphael: 5 seconds is more than enough in my tests for wifi sync to an iPad 2, but I've doubled the duration to accomodate for slower WiFi and older devices.
static const NSTimeInterval kLibraryChangedInBackgroundReloadDelay = 10.0;

#define kFlushItemsInterval 1000

@interface SFNativeMediaLibraryLoader () <AppStatusObserverDelegate>

@property (nonatomic, strong) NSMutableDictionary *genresByName;
@property (nonatomic, strong) NSDate *libraryChangeNotificationDate;

@end


@implementation SFNativeMediaLibraryLoader {
	SFNativeMediaFactory *factory;
	GANHelper *ganHelper;
	NSOperationQueue *operationQueue;
	BOOL loading;
	BOOL needsReload;
	BOOL shouldCancelLoading;
	BOOL isDelaying;
	
	NSUInteger librarySize;

	AppStatusObserver *statusObserver;
	BOOL appIsActive;
	
	SFGenreFetcher *genreFetcher;
}

- (id)initWithFactory:(SFNativeMediaFactory *)theFactory ganHelper:(GANHelper *)theGanHelper operationQueue:(NSOperationQueue *)theOperationQueue lookupUnknownGenres:(BOOL)lookupEnabled {
    self = [super init];
    if (self) {
		factory = theFactory;
		
		ganHelper = theGanHelper;
		operationQueue = theOperationQueue;
		_lookupEnabled = lookupEnabled;
		
		needsReload = YES;
		appIsActive = ([UIApplication sharedApplication].applicationState == UIApplicationStateActive);

		statusObserver = [[AppStatusObserver alloc]
						  initWithBecomeActiveDelay:0];
		statusObserver.delegate = self;
				
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter addObserver:self
							   selector:@selector(mediaLibraryChanged:)
								   name:MPMediaLibraryDidChangeNotification
								 object:nil];
		[[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
	}
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
}

@synthesize delegate;
@synthesize loading;
@synthesize genresByName;
@synthesize libraryChangeNotificationDate;

- (void)startIfNecessary {
	if(needsReload && !loading && appIsActive) {
		if([self shouldDelayReload]) {
			[self delayReload];
			return;
		}
		
		[self loadLibrary];
	}
}

- (BOOL)shouldDelayReload {
	return [self syncsAreRunningInBackground] && [self reloadDelay] > 0;
}

- (void)delayReload {
	if(isDelaying) {
		return;
	}
	isDelaying = YES;
	[self performSelector:@selector(startAfterDelayCallback) withObject:nil afterDelay:[self reloadDelay]];
}

- (BOOL)syncsAreRunningInBackground {
	return [DeviceInformation isRunningOnOSVersion5OrNewer];
}

- (NSTimeInterval)reloadDelay {
	return kLibraryChangedInBackgroundReloadDelay - [self timeIntervalSinceLastChange];
}

- (NSTimeInterval)timeIntervalSinceLastChange {
	NSTimeInterval timeIntervalSinceLibraryChange = -[[[MPMediaLibrary defaultMediaLibrary] lastModifiedDate] timeIntervalSinceNow];
	if(self.libraryChangeNotificationDate == nil) {
		return timeIntervalSinceLibraryChange;
	}
	
	NSTimeInterval timeIntervalSinceChangeNotification = -[self.libraryChangeNotificationDate timeIntervalSinceNow];
	return fminf(timeIntervalSinceLibraryChange, timeIntervalSinceChangeNotification);
}

- (void)startAfterDelayCallback {
	isDelaying = NO;
	[self startIfNecessary];
}

- (void)loadLibrary {
	needsReload = NO;
	shouldCancelLoading = NO;
	loading = YES;
	[delegate willStartLoading];
	
	NSLog(@"Begining to load library");
	NSInvocationOperation *op =
	[[NSInvocationOperation alloc]
	 initWithTarget:self 
	 selector:@selector(loadLibraryThread)
	 object:nil];
	[operationQueue addOperation:op];
}

- (void)cancel {
	needsReload = YES;
	shouldCancelLoading = YES;	
}

- (void)loadLibraryThread {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSDate *start = [NSDate date];
	
	if(self.lookupEnabled) {
		genreFetcher = [[SFGenreFetcher alloc] init];
	} else {
		genreFetcher = nil;
	}
	
	[self loadSongsAndAndAssignTracks];
	
	NSTimeInterval genresDuration = [[NSDate date] timeIntervalSinceDate:start];
	NSLog(@"Finished fetching genres after %.3f seconds", genresDuration);
		
	if(shouldCancelLoading) {
		NSLog(@"Cancelling after genres");
		[self performSelectorOnMainThread:@selector(loadLibraryCancelled) withObject:nil waitUntilDone:NO];
		return;
	}
	NSArray *artists = [self createArtistsInGenres];
	
	NSTimeInterval artistsDuration = [[NSDate date] timeIntervalSinceDate:start];
	NSLog(@"Finished fetching %u artists after %.3f seconds", [artists count], artistsDuration);
	
	if(shouldCancelLoading) {
		NSLog(@"Cancelling after artists");
		[self performSelectorOnMainThread:@selector(loadLibraryCancelled) withObject:nil waitUntilDone:NO];
		return;
	}
		
	NSUInteger numAlbums = [self createAlbumsInArtists:artists];
	
	NSTimeInterval albumsDuration = [[NSDate date] timeIntervalSinceDate:start];
	NSLog(@"Finished fetching %u albums after %.3f seconds", numAlbums, albumsDuration);
	
	if(shouldCancelLoading) {
		NSLog(@"Cancelling after albums");
		[self performSelectorOnMainThread:@selector(loadLibraryCancelled) withObject:nil waitUntilDone:NO];
		return;
	}
	
	if(self.lookupEnabled) {
		NSArray *fetchedGenres = [genreFetcher waitForResults];
		[self loadAdditionalGenres:fetchedGenres];
		
		NSTimeInterval lookupDuration = [[NSDate date] timeIntervalSinceDate:start];
		NSLog(@"Finished genre lookups after %.3f seconds", lookupDuration);
	}
	
		
	[self sendStatisticsForGenreDuration:genresDuration artistsDuration:artistsDuration albumsDuration:albumsDuration];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[self performSelectorOnMainThread:@selector(loadLibraryCompleted) withObject:nil waitUntilDone:NO];
	
	genreFetcher = nil;
}

- (void)loadAdditionalGenres:(NSArray *)genres {
	NSMutableDictionary *touchedGenres = [NSMutableDictionary dictionary];
	
	NSUInteger savedArtists = 0;
	NSUInteger nonsavedArtists = 0;
	for(SFGenreFetcherRequestData *request in genres) {
		
		GenreDefinition *genreDefinition = [self genreFromRequestData:request];
		SFGenre *genre = [self genreForDefinition:genreDefinition];
		if(genreDefinition != [factory.nameGenreMapper catchAllGenreDefinition]) {
			++savedArtists;
		}
		else {
			++nonsavedArtists;
		}
		
		for(MPMediaItem *mediaItem in request.mediaItems) {
			[self addMediaItem:mediaItem toGenre:genre];
		}
		
		MPMediaItem *mediaItem = [request.mediaItems objectAtIndex:0];
		NSString *artistName = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
		NSAssert(artistName != nil, @"artist without valid name should have been filtered by :320");
		[factory.nameGenreMapper registerGenreLookupResult:genreDefinition forArtistName:artistName];
		
		[touchedGenres setObject:genre forKey:genre.name];
		librarySize += request.mediaItems.count;
	}
	
	NSLog(@"Saved %d artists from ending up in the Other Bubble. %d artists still there.", savedArtists, nonsavedArtists);
	[ganHelper trackEvent:@"iPodLibrary" action:@"changed" label:@"savedOtherBubbleArtists" value:savedArtists];
	[ganHelper trackEvent:@"iPodLibrary" action:@"changed" label:@"nonsavedOtherBubbleArtists" value:savedArtists];
	
	for(SFGenre *genre in touchedGenres.allValues) {
		NSLog(@"updating genre: %@", genre.name);
		NSArray *artists = [genre pushTracksIntoArtistChildren];
		for(SFArtist *artist in artists) {
			[artist pushTracksIntoAlbumChildrenWithFactory:factory];
		}
	
		[self signalGenreLoaded:genre];
	}
}

- (NSArray *)loadNativeMediaItemsFromNativeLibrary {
	MPMediaQuery *allTracksQuery = [MPMediaQuery songsQuery];
	return [allTracksQuery items];
}

- (void)loadSongsAndAndAssignTracks {
	NSArray *items;
	
	@autoreleasepool {
		items = [self loadNativeMediaItemsFromNativeLibrary];
		if(items == nil) {
			[self performSelectorOnMainThread:@selector(loadLibraryFailed) withObject:nil waitUntilDone:NO];
			return;
		}
		
		librarySize = [items count];
		[ganHelper trackEvent:@"iPodLibrary" action:@"changed" label:@"numTracks" value:librarySize];
		NSLog(@"Library size: %d tracks", librarySize);
		if(librarySize == 0) {
			NSString *message = NSLocalizedString(@"There is no music on your device. You might want to add some using iTunes.",
												  @"No music on device message");
			NSError *error = [NSError errorWithDomain:@"LibraryError" code:1 userInfo:[NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey]];
			[delegate performSelectorOnMainThread:@selector(loadingFailedWithError:) withObject:error waitUntilDone:NO];
			return;
		}
		
		self.genresByName = [NSMutableDictionary dictionary];
		for(MPMediaItem *item in items) {
			//Prevent the consumed memory from becoming too large
			@autoreleasepool {
				[self addTrackForMediaItem:item];
				
				if(shouldCancelLoading) {
					break;
				}
			}
		}
		
		[genreFetcher lookupRegisteredMediaItems];
	}
	
	for(NSString *name in self.genresByName) {
		SFGenre *genre = [self.genresByName objectForKey:name];
		[self signalGenreLoaded:genre];
		NSLog(@"loaded genre: %@", name);
	}
}

- (void)signalGenreLoaded:(SFGenre *)genre {
	genre.relativeSize = [genre numTracks] / (CGFloat) librarySize;
	[delegate performSelectorOnMainThread:@selector(loadedGenre:)
							   withObject:genre waitUntilDone:YES];
}

- (void)signalGenreUpdated:(SFGenre *)genre {
	genre.relativeSize = [genre numTracks] / (CGFloat) librarySize;
}

- (void)addMediaItem:(MPMediaItem *)mediaItem toGenre:(SFGenre *)genre {
	SFTrack *track = [factory newTrackForNativeMediaItem:mediaItem];
	[genre addTrack:track];
}

- (NSArray *)nativeMediaItemsFromMPMediaItems:(NSArray *)mpMediaItems inGenre:(SFGenre *)genre {
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:mpMediaItems.count];
	
	for(MPMediaItem *item in mpMediaItems) {
		SFTrack *track = [factory newTrackForNativeMediaItem:item];
		[result addObject:track];
	}
	
	return result;
}

- (void)addTrackForMediaItem:(MPMediaItem *)mediaItem {
	NSString *genreName = [mediaItem valueForProperty:MPMediaItemPropertyGenre];
	GenreDefinition *genreDefinition = [factory.nameGenreMapper genreDefinitionForName:genreName];
	if(self.lookupEnabled && genreDefinition == [factory.nameGenreMapper catchAllGenreDefinition]) {
		BOOL success = [self genreLookupWithMediaItem:mediaItem];
		if(success) {
			return;
		}
	}
	
	SFGenre *genre = [self genreForDefinition:genreDefinition];
	[self addMediaItem:mediaItem toGenre:genre];
}

- (BOOL)genreLookupWithMediaItem:(MPMediaItem *)mediaItem {
	NSString *artistName = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
	if(artistName.length == 0) {
		return false;
	}

	[genreFetcher registerMediaItem:mediaItem forLookupWithArtistName:artistName];
	return true;
}

- (GenreDefinition *)genreFromRequestData:(SFGenreFetcherRequestData *)data {
	
	GenreDefinition *defaultGenreDefinition = [factory.nameGenreMapper catchAllGenreDefinition];
	GenreDefinition *genreDefinition = defaultGenreDefinition;
	for(NSString *genreName in data.results) {
		genreDefinition = [factory.nameGenreMapper genreDefinitionForName:genreName];
		if(defaultGenreDefinition != genreDefinition) {
			break;
		}
	}
	
	return genreDefinition;
}

- (SFGenre *)genreForDefinition:(GenreDefinition *)definition {
	SFGenre *genre = [genresByName objectForKey:definition.name];
	if(genre == nil) {
		genre = [factory newGenreWithDefinition:definition];
		[genresByName setObject:genre forKey:definition.name];
	}
	
	return genre;
}

- (NSArray *)createArtistsInGenres {
	NSMutableArray *artists = [[NSMutableArray alloc] init];
	NSUInteger numArtists = 0;
	for(NSString *name in genresByName) {
		@autoreleasepool {
			SFGenre *genre = [genresByName objectForKey:name];
			NSArray *genreArtists = [genre pushTracksIntoArtistChildren];
			NSString *label = [NSString stringWithFormat:@"artistsIn%@", name];
			[ganHelper trackEvent:@"iPodLibrary" action:@"changed" label:label value:[genreArtists count]];
			[artists addObjectsFromArray:genreArtists];
			
			if(shouldCancelLoading) {
				break;
			}
		}
	}
	
	[ganHelper trackEvent:@"iPodLibrary" action:@"changed" label:@"artists" value:numArtists];
	return artists;
}

- (NSUInteger)createAlbumsInArtists:(NSArray *)artists {
	NSUInteger numAlbums = 0;
	for(SFArtist *artist in artists) {
		@autoreleasepool {
			NSAssert([artist isKindOfClass:[SFArtist class]], @"Genre has non-artist child");
			NSArray *artistAlbums = [artist pushTracksIntoAlbumChildrenWithFactory:factory];
			numAlbums += [artistAlbums count];
			
			if(shouldCancelLoading) {
				break;
			}
		}
	}
	
	return numAlbums;
}

- (void)sendStatisticsForGenreDuration:(NSTimeInterval)genresDuration artistsDuration:(NSTimeInterval)artistsDuration albumsDuration:(NSTimeInterval)albumsDuration {
    [ganHelper trackEvent:@"iPodLibrary" action:@"loadTime" label:@"genres" value:(NSInteger)(genresDuration * 1000)];
	[ganHelper trackEvent:@"iPodLibrary" action:@"loadTime" label:@"artists" value:(NSInteger)(artistsDuration * 1000)];
	[ganHelper trackEvent:@"iPodLibrary" action:@"loadTime" label:@"albums" value:(NSInteger)(albumsDuration * 1000)];
	NSInteger usedGenres = [genresByName count];
	[ganHelper trackEvent:@"iPodLibrary" action:@"changed" label:@"genresInUse" value:usedGenres];
}

- (void)loadLibraryCompleted {
	NSLog(@"Finished loading library");
	loading = NO;
	[delegate didFinishLoading];
	
	[self startIfNecessary];
}

- (void)loadLibraryFailed {
	NSLog(@"Failed loading library");
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	loading = NO;
	if(needsReload) {
		[self startIfNecessary];
	}
	else {
		NSLog(@"Could not load library");
	}	
}

- (void)loadLibraryCancelled {
	NSLog(@"loadLibraryCancelled");
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	loading = NO;
	[self startIfNecessary];
}

#pragma mark -

- (void)mediaLibraryChanged:(id)notification {
	NSLog(@"Media library changed");
	self.libraryChangeNotificationDate = [NSDate date];
	[self cancel];
	[self startIfNecessary];
}

#pragma mark - AppStatusObserverDelegate

- (void)appWillResignActive {
	appIsActive = NO;
}

- (void)appDidEnterBackground {
	if(self.isLoading) {
		[self cancel];
	}
}

- (void)appDidBecomeActive {
	appIsActive = YES;
	[self startIfNecessary];
}

@end
