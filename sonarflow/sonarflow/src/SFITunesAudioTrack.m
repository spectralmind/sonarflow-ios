#import "SFITunesAudioTrack.h"

@implementation SFITunesAudioTrack {
	NSString *name;
	NSString *album;
	NSString *artist;
}

- (id)initWithURL:(NSURL *)theUrl name:(NSString *)theName artist:(NSString *)theArtistName album:(NSString *)theAlbumName duration:(NSNumber *)theDuration buyLink:(NSURL *)theBuyLink parent:(id<SFITunesMediaItem>)theParent {
	self = [super init];
	if(self == nil) {
		return nil;
	}
	
	name = theName;
	album = theAlbumName;
	artist = theArtistName;
	url = theUrl;
	duration = theDuration;
	buyLink = theBuyLink;
	
	parent = theParent;
	return self;
}


- (BOOL)mayHaveChildren {
	return  NO;
}

- (NSArray *)children {
	return nil;
}

@synthesize name;
@synthesize key;
@synthesize parent;
@synthesize url;
@synthesize duration;
@synthesize buyLink;

- (BOOL)showAsBubble {
	return NO;
}

- (BOOL)hasDetailViewController {
	return NO;
}

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
	return nil;
}

- (BOOL)mayHaveImage {
	return YES;
}

- (UIImage *)imageWithSize:(CGSize)size {
	return nil;
}

- (void)startPlayback {
	
}

- (void)startPlaybackAtChildIndex:(NSUInteger)childIndex {
	
}

- (NSString *)artistName {
	return artist;
}

- (NSString *)albumName {
	return album;
}

- (NSString *)albumArtistName {
	return artist;
}

- (BOOL)isEquivalentToAudioTrack:(id<SFAudioTrack>)otherTrack  {
	if([otherTrack isKindOfClass:[SFITunesAudioTrack class]] == NO) {
		return NO;
	}
	SFITunesAudioTrack *otherITunesTrack = (SFITunesAudioTrack *)otherTrack;
	return [self.url isEqual:otherITunesTrack.url];
}

- (NSArray *)tracks {
	return [NSArray arrayWithObject:self];
}

- (NSArray *)keyPath {
	return [[self.parent keyPath] arrayByAddingObject:url];
}

- (BOOL)loading {
	return NO;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@: %@ - %@ (%@)", [self class], self.name, self.artistName, self.url];
}

@end
