#import "Scrobbler.h"

#import "Configuration.h"
#import "SFAudioTrack.h"
#import "AppStatusObserver.h"
#import "LastfmSettings.h"
#import "SNRLastFMEngine.h"
#import "SFMediaItem.h"
#import "SFTimeTracker.h"

static const NSTimeInterval kLoginDelay = 1.5;

static const NSTimeInterval kScrobbleAfterSeconds = 4*60;
static const NSTimeInterval kMinimumTrackLength = 30;


@interface Scrobbler ()

@property (nonatomic, strong) NSObject<SFMediaItem, SFAudioTrack> *lastNowPlayingTrack;
@property (nonatomic, strong) NSObject<SFMediaItem, SFAudioTrack> *lastScrobbledTrack;
@property (nonatomic, strong) NSObject<SFMediaItem, SFAudioTrack> *currentTrack;

@end


@implementation Scrobbler {
	SNRLastFMEngine *lastfmEngine;
	LastfmSettings *lastfmSettings;

	id<ScrobblerDelegate> __weak delegate;

	BOOL playing;
	SFTimeTracker *playbackTimeTracker;

	BOOL ignoreRequestsUntilNextLogin;
}

- (id)initWithLastfmEngine:(SNRLastFMEngine *)theLastfmEngine {
	self = [super init];
	if(self) {
		lastfmEngine = theLastfmEngine;
		playbackTimeTracker = [[SFTimeTracker alloc] init];
		
		ignoreRequestsUntilNextLogin = YES;
	}
	
	return self;
}


@synthesize lastfmSettings;
- (void)setLastfmSettings:(LastfmSettings *)newLastfmSettings {
	if(lastfmSettings != newLastfmSettings) {
		lastfmSettings = [newLastfmSettings copy];
	}
	
	[self updateLoginFromSettings];
}

@synthesize delegate;
@synthesize lastNowPlayingTrack;
@synthesize lastScrobbledTrack;
@synthesize currentTrack;

- (void)updateLoginFromSettings {
	if(self.lastfmSettings.scrobble == NO) {
		return;
	}

	[self openSessionWithUsername:self.lastfmSettings.username password:self.lastfmSettings.password];
}

- (void)openSessionWithUsername:(NSString *)username password:(NSString *)password {
	//NSLog(@"login %@ - %@",username,password);
	[lastfmEngine retrieveAndStoreSessionKeyWithUsername:username password:password completionHandler:^(NSError *error, NSDictionary *response) {
		if(error != nil) {
			NSLog(@"Lastfm authentication error: %@", error);
			ignoreRequestsUntilNextLogin = YES;
			[delegate scrobblerDidFailToAuthenticate];
			return;
		}
		
		ignoreRequestsUntilNextLogin = NO;
		[self trySubmitNowPlayingTrack:self.currentTrack];
	}];
}

- (void)nowPlayingLeafChanged:(id<SFMediaItem>)mediaItem {
	NSObject<SFMediaItem, SFAudioTrack> *filteredTrack = [self filterMediaItem:mediaItem];
	if(self.currentTrack == filteredTrack) {
		return;
	}
	
	[self tryScrobbleTrack:self.currentTrack playDuration:[playbackTimeTracker duration]];
	
	//NSLog(@"new track: %@",newTrack.name);
	self.currentTrack = filteredTrack;
	[playbackTimeTracker reset];
	[self updateTimeTrackerState];
	[self trySubmitNowPlayingTrack:self.currentTrack];
}

- (NSObject<SFMediaItem, SFAudioTrack> *)filterMediaItem:(id<SFMediaItem>)mediaItem {
	if([mediaItem conformsToProtocol:@protocol(SFAudioTrack)] == NO) {
		return nil;
	}
	
	NSObject<SFMediaItem, SFAudioTrack> *track = (NSObject<SFMediaItem, SFAudioTrack> *)mediaItem;
	if([self isTrackRelevantForLastfm:track] == NO) {
		return nil;
	}
	
	return track;
}
	   
- (BOOL)isTrackRelevantForLastfm:(NSObject<SFMediaItem, SFAudioTrack>*)track {
   return [track.duration integerValue] >= kMinimumTrackLength;
}

- (void)playbackStateChangedToPlaying:(BOOL)newPlaying {
	if(newPlaying == playing) {
		return;
	}
	
	//NSLog(@"playing: %i",newPlaying);
	playing = newPlaying;
	[self updateTimeTrackerState];
	[self trySubmitNowPlayingTrack:self.currentTrack];
}

- (void)updateTimeTrackerState {
	playbackTimeTracker.active = (playing && self.currentTrack != nil);
}

- (void)trySubmitNowPlayingTrack:(NSObject<SFMediaItem, SFAudioTrack> *)track {
	if(playing == NO || track == nil || [self.lastNowPlayingTrack isEquivalentToAudioTrack:track]) {
		return;
	}

	if(lastfmSettings.scrobble == NO || [lastfmEngine isAuthenticated] == NO) {
		return;
	}
	
	[lastfmEngine updateNowPlayingTrackWithName:track.name album:[track albumName] artist:[track artistName] albumArtist:[track albumArtistName] trackNumber:0 duration:[track.duration integerValue] completionHandler:^(NSDictionary *response, NSError *error) {
		if(error != nil) {
			NSLog(@"failed to submit 'now playing' track! %@\n", error);
			return;
		}
		
		self.lastNowPlayingTrack = track;
		NSLog(@"NowPlaying complete, response: %@", response);
	}];
}

- (void)tryScrobbleTrack:(NSObject<SFMediaItem, SFAudioTrack> *)track playDuration:(NSTimeInterval)playDuration {
	if([self isTrack:track eligibleForScrobblingAfterDuration:playDuration] == NO) {
		return;
	}
	
	if(lastfmSettings.scrobble == NO || [lastfmEngine isAuthenticated] == NO) {
		[delegate scrobblerSkippedScrobbling];
		return;
	}
	
	NSLog(@"scrobbling %@",self.currentTrack.name);
	[lastfmEngine scrobbleTrackWithName:track.name album:[track albumName] artist:[track artistName] albumArtist:[track albumArtistName] trackNumber:0 duration:[track.duration integerValue] timestamp:[[NSDate date] timeIntervalSince1970] completionHandler:^(NSDictionary *response, NSError *error) {
		if(error != nil) {
			NSLog(@"failed to scrobble a track! %@\n", error);
			return;
		}
		
		self.lastScrobbledTrack = track;
		NSLog(@"Scrobble complete, response: %@", response);
	}];
}

- (BOOL)isTrack:(NSObject<SFMediaItem, SFAudioTrack> *)track eligibleForScrobblingAfterDuration:(NSTimeInterval)duration {
	if([self.lastScrobbledTrack isEquivalentToAudioTrack:track]) {
		return NO;
	}
	
	if([track.name length] == 0) {
		return NO;
	}

	return duration > fminf(kScrobbleAfterSeconds, [[track duration] floatValue] / 2.0);
}

- (void)verifyAccountWithUsername:(NSString *)username withPassword:(NSString *)password  completion:(LastfmLoginCompletionBlock)completion {
	NSLog(@"verifying username %@...\n", username);
	[lastfmEngine retrieveAndStoreSessionKeyWithUsername:username password:password completionHandler:^(NSError *error, NSDictionary *response) {
		NSLog(@"verification done: %@\n", error);
		if(error != nil) {
			completion(NO);
			return;
		}
		
		completion(YES);
	}];
}

@end
