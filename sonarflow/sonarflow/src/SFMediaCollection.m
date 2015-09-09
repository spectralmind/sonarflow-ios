#import "SFMediaCollection.h"

#import "SFNativeMediaPlayer.h"

@implementation SFMediaCollection {
	@private
	id key;
	NSString *name;
	SFNativeMediaPlayer *player;
	
	SFMediaCollection *__weak parent;
}

- (id)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithKey:(id)theKey {
	return [self initWithKey:theKey name:nil player:nil];
}

- (id)initWithName:(NSString *)theName player:(SFNativeMediaPlayer *)thePlayer {
	return [self initWithKey:[theName lowercaseString] name:theName player:thePlayer];
}

- (id)initWithKey:(id)theKey name:(NSString *)theName player:(SFNativeMediaPlayer *)thePlayer {
    self = [super init];
    if (self) {
		key = theKey;
		name = theName;
		player = thePlayer;
    }
    return self;
}


@synthesize key;
@synthesize name;
@synthesize player;
@synthesize parent;
- (UIColor *)bubbleColor {
	return self.parent.bubbleColor;
}

- (CGFloat)relativeSize {
	return self.numTracks / (CGFloat) parent.numTracks;
}

- (NSArray *)keyPath {
	return [[self.parent keyPath] arrayByAddingObject:self.key];
}

- (NSComparisonResult)compareKeys:(id<SFMediaItem>)other {
	return [self.key compare:other.key];
}

- (NSNumber *)duration {
	return nil; // Not yet needed anywhere for collections
}

- (BOOL)mayHaveChildren {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (NSArray *)children {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (BOOL)showAsBubble {
	return YES;
}

- (BOOL)hasDetailViewController {
	return YES;
}

- (BOOL)mayHaveImage {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (void)startPlayback {
	[player playMediaItem:self];
}

- (void)startPlaybackAtChildIndex:(NSUInteger)childIndex; {
	[self.player playMediaItem:self startingAtIndex:childIndex];
}

- (NSUInteger)numTracks {
	[self doesNotRecognizeSelector:_cmd];
	return 0;
}

- (NSArray *)tracks {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSString *)sortableName {
	if (_sortableName == nil) {
		return self.name;
	}
	return _sortableName;
}

@end
