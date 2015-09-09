#import "SFSpotifyMediaItem.h"

#import "SFSpotifyMediaItemTracksProxy.h"
#import "SFSpotifyPlayer.h"
#import "SFSpotifyTrack.h"

@implementation SFSpotifyMediaItem {
	SFSpotifyPlayer *player;
}

// NOTE that these must sum up to 1.0
static const float kSizeFactor = 0.7;
static const float kDurationFactor = 0.3;

@synthesize key;
@synthesize name;
@synthesize parent;
@synthesize player;

- (id)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithName:(NSString *)theName key:(id)theKey player:(SFSpotifyPlayer *)thePlayer {
	self = [super init];
	if(self == nil) {
		return nil;
	}
	
	key = theKey;
	name = theName;
	player = thePlayer;
	
	return self;
}

- (NSArray *)children {
	return nil;
}

- (UIColor *)bubbleColor {
	return nil;
}

- (BOOL)mayHaveImage {
	return NO;
}

- (BOOL)mayHaveChildren {
	return YES;
}

- (BOOL)showAsBubble {
	return YES;
}

- (CGFloat)relativeSize {
	NSAssert(self.parent != nil, @"Missing parent");
	float relsize = 1.0;
	float relduration = 1.0;
	
	if([self.parent isKindOfClass:[SFSpotifyMediaItem class]]) {
		relsize = self.size / (CGFloat) (((SFSpotifyMediaItem *)self.parent).size);
		relduration = [self.duration floatValue] / [((SFSpotifyMediaItem *)self.parent).duration floatValue];
	}
	
	return relsize * kSizeFactor + relduration * kDurationFactor;
}

- (BOOL)hasDetailViewController {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (NSComparisonResult)compareKeys:(id<SFMediaItem>)other {
	return [[self.key description] compare:[other.key description]]; //TODO: Improve / remove this hack
}

-(NSArray *)keyPath {
	NSAssert(self.parent != nil, @"Missing parent");
	return [[self.parent keyPath] arrayByAddingObject:key];
}

- (NSNumber *)duration {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSUInteger)size {
	[self doesNotRecognizeSelector:_cmd];
	return 0;
}

- (NSString *)artistNameForDiscovery {
	if(self.children == nil || self.children.count == 0) {
		return nil;	
	}
	
	id<SFMediaItem, SFDiscoverableItem> firstBorn = [self.children objectAtIndex:0];
	return [firstBorn artistNameForDiscovery];
}

- (void)startPlayback {
	[self.player play:self];
}

- (void)startPlaybackAtChildIndex:(NSUInteger)childIndex {
	[self.player play:self startingAtIndex:childIndex];
}

- (BOOL)isLoading {
	return NO;
}

- (NSArray *)tracks {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id<SFMediaItem, SFPlaylist>)tracksProxy {
	return [[SFSpotifyMediaItemTracksProxy alloc] initWithMediaItem:self];
}

- (BOOL)isEqual:(id)object {
	NSAssert(self.key != nil, @"nil key encountered");
	
	if([object isKindOfClass:[self class]]==NO) {
		return NO;
	}
	
	id<SFMediaItem> other = object;
	return [self.key isEqual:other.key];
}

- (NSUInteger)hash {
	NSAssert(self.key != nil, @"nil key encountered");
	return [self.key hash];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@: %@", [self class], self.name];
}

@end
