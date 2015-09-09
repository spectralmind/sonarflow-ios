#import "SFSpotifyTrack.h"

#import <MediaPlayer/MediaPlayer.h>

#import "MediaViewControllerFactory.h"
#import "SFSpotifyAlbum.h"
#import "SFSpotifyPlayer.h"
#import "SPAlbum.h"
#import "SPArtist.h"
#import "SPImage.h"
#import "SPTrack.h"


@implementation SFSpotifyTrack {
	SPTrack *track;
}

+ (NSSet *)keyPathsForValuesAffectingStarred {
	return [NSSet setWithObject:@"spTrack.starred"];
}

- (id)initWithTrack:(SPTrack *)theTrack player:(SFSpotifyPlayer *)thePlayer {
	self = [super initWithName:nil key:theTrack.spotifyURL player:thePlayer];
	if(self == nil) {
		return nil;
	}
	
	track = theTrack;
	return self;
}

- (void)setStarred:(BOOL)starred {
	track.starred = starred;
}

- (BOOL)starred {
	return track.starred;
}

- (SPTrack *)spTrack {
	return track;
}

- (NSNumber *)duration {
	return [NSNumber numberWithFloat:track.duration];
}

- (BOOL)mayHaveChildren {
	return NO;
}

- (NSString *)artistNameForDiscovery {
	return [self artistName];
}

- (NSString *)artistName {
	return track.album.artist.name;
}

- (NSString *)albumName {
	return track.album.name;
}

- (NSString *)albumArtistName {
	return [self artistName];
}

- (NSString *)name {
	return track.name;
}

- (BOOL)isEquivalentToAudioTrack:(id<SFAudioTrack>)otherTrack {
	if([otherTrack isKindOfClass:[SFSpotifyTrack class]] == NO) {
		return NO;
	}

	SFSpotifyTrack *otherSpotifyTrack = (SFSpotifyTrack *)otherTrack;
	return [self.spTrack.spotifyURL isEqual:otherSpotifyTrack.spTrack.spotifyURL];
}

-(NSString *)description {
	return [NSString stringWithFormat:@"SFSpotifyTrack with key '%@' and name '%@'", [self key], [self name]];
}

- (BOOL)mayHaveImage {
	return YES;
}

- (UIImage *)imageWithSize:(CGSize)size {
	return track.album.cover.image;
}

- (MPMediaItemArtwork *)artwork {
	if(track.album.cover.image == nil) {
		return nil;
	}
	
	return [[MPMediaItemArtwork alloc] initWithImage:track.album.cover.image];
}

//Messy: Needs "NO" to start playback on tap in lists, but it has a controller that is shown when tapping a bubble
//TODO: Fix and re-enable check in MainViewController for "hasDetailViewController"
- (BOOL)hasDetailViewController {
	return NO;
}

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
	return [factory viewControllerForPlaylist:[self tracksProxy]];
}

- (NSUInteger)size {
	return 1;
}

- (NSArray *)tracks {
	return [NSArray arrayWithObject:self];
}

- (NSString *)countToShow {
	if([self.parent isKindOfClass:[SFSpotifyAlbum class]]) {
		return [NSString stringWithFormat:@"%d", track.trackNumber];
	}
	
	return nil;
}

@end
