#import "SFTestRootMediaItem.h"

#import "RootKey.h"
#import "SFTestMediaLibrary.h"

@implementation SFTestRootMediaItem

@synthesize library;
@synthesize origin;

- (id)initWithKey:(id)theKey {
	RootKey *rootKey = [[RootKey alloc] initWithKey:theKey type:BubbleTypeDefault];
    self = [super initWithKey:rootKey];
    if (self) {
    }
    return self;
}

- (float)relativeSize {
	return [self totalSize] / (CGFloat) [library size];
}

- (UIColor *)bubbleColor {
	return [UIColor clearColor];
}

- (NSArray *)keyPath {
	return @[self.key];
}

@end
