#import "SFSpotifyBridge.h"

#import "SFSpotifyMediaItem.h"

@implementation SFSpotifyBridge {
	BOOL hasAddedMediaItem;
}

@synthesize delegate;

- (void)notifyDelegateWithMediaItem:(id<SFSpotifyMediaItem>)item {
	NSAssert(self.delegate != nil, @"no delegate!");
	
	if(item.children.count > 0) {
		if(hasAddedMediaItem == NO) {
			[self.delegate bridge:self discoveredMediaItem:item];
			hasAddedMediaItem = YES;
		}
	}
	else {
		if(hasAddedMediaItem) {
			[self.delegate bridge:self removedMediaItem:item];
			hasAddedMediaItem = NO;
		}
	}	
}

@end
