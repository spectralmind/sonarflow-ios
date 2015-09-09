#import "SFMenuTarget.h"

@implementation SFMenuTarget

+ (SFMenuTarget *)menuTargetWithMediaItem:(NSObject<SFMediaItem> *)theMediaItem boundingRect:(CGRect)theBoundingRect {
	if(theMediaItem == nil || CGRectIsNull(theBoundingRect)) {
		return nil;
	}

	return [[self alloc] initWithMediaItem:theMediaItem boundingRect:theBoundingRect];
}

- (id)initWithMediaItem:(NSObject<SFMediaItem> *)theMediaItem boundingRect:(CGRect)theBoundingRect {
    self = [super init];
    if (self) {
		mediaItem = theMediaItem;
		boundingRect = theBoundingRect;
    }
    return self;
}


@synthesize mediaItem;
@synthesize boundingRect;


@end
