#import "SFNativeMediaItemComposite.h"

#import "SFNativeMediaPlayer.h"

@implementation SFNativeMediaItemComposite {
	SFNativeMediaPlayer *player;
}

- (id)initWithName:(NSString *)theName mediaItems:(NSArray *)theMediaItems player:(SFNativeMediaPlayer *)thePlayer {
    self = [super initWithName:theName mediaItems:theMediaItems];
    if (self) {
        player = thePlayer;
    }
    return self;
}


@synthesize player;

- (void)startPlayback {
	[player playMediaItem:self];
}

- (void)startPlaybackAtChildIndex:(NSUInteger)childIndex {
	[player playMediaItem:self startingAtIndex:childIndex];
}

- (NSArray *)tracks {
	NSMutableArray *childTracks = [NSMutableArray array];
	for(NSObject<SFNativeMediaItem> *child in self.mediaItems) {
		NSAssert([child conformsToProtocol:@protocol(SFNativeMediaItem)], @"Child does not conform to HasTracks");
		[childTracks addObjectsFromArray:[child tracks]];
	}
	return childTracks;
}

- (NSUInteger)numTracks {
	return [[self tracks] count];
}

- (NSComparisonResult)compareKeys:(id<SFMediaItem>)other {
	[self doesNotRecognizeSelector:_cmd];
	return NSOrderedSame;
}

@end
