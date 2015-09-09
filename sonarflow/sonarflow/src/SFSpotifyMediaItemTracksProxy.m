#import "SFSpotifyMediaItemTracksProxy.h"

#import "SFArrayObserver.h"

static NSString * const kSFSpotifyMediaItemTracksProxyKey = @"SFSpotifyMediaItemTracksProxy";

@interface SFSpotifyMediaItemTracksProxy () <SFArrayObserverDelegate>

@property (nonatomic, readwrite, strong) NSArray *children;

@end


@implementation SFSpotifyMediaItemTracksProxy {
	SFSpotifyMediaItem *mediaItem;
	SFArrayObserver *childrenObserver;
}

- (id)initWithMediaItem:(SFSpotifyMediaItem *)theMediaItem {
	self = [super initWithName:theMediaItem.name key:kSFSpotifyMediaItemTracksProxyKey player:theMediaItem.player];
	if (self) {
		mediaItem = theMediaItem;
		childrenObserver = [[SFArrayObserver alloc] initWithObject:mediaItem keyPath:@"children" delegate:self];
		[self rebuildChildren];
	}
	return self;
}

@synthesize children;

- (BOOL)mayHaveChildren {
	return YES;
}

- (BOOL)showAsBubble {
	return NO;
}

- (BOOL)mayHaveImage {
	return mediaItem.mayHaveImage;
}

- (UIImage *)imageWithSize:(CGSize)size {
	return [mediaItem imageWithSize:size];
}

- (NSArray *)tracks {
	return self.children;
}

- (void)object:(NSObject *)object wasSetFrom:(id)oldValue to:(id)newValue {
	[self rebuildChildren];
}

- (void)objects:(NSArray *)objects wereInsertedAtIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	[self rebuildChildren];
}

- (void)objects:(NSArray *)objects wereDeletedAtIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	[self rebuildChildren];
}

- (void)objects:(NSArray *)oldObjects wereReplacedWithObjects:(NSArray *)newObjects atIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	[self rebuildChildren];
}

- (void)rebuildChildren {
	self.children = [mediaItem tracks];
}

- (BOOL)isReadOnly {
	return YES;
}

@end
