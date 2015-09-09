#import "Bubble.h"
#import "BubbleDataSource.h"

#define kShadowOffset 1
#define kSubtextPadding 4

@interface Bubble ()

@end

@implementation Bubble {
	@private
	id key;
	
	CGPoint origin;
	CGFloat radius;
	UIColor *color;
	NSString *title;
	NSString *numElements;
	BubbleType type;
	
	BOOL isLeaf;
	BOOL mayHaveCover;
}

@synthesize key;
@synthesize origin;
@synthesize radius;
@synthesize color;
@synthesize title;
@synthesize numElements;
@synthesize type;
@synthesize isLeaf;
@synthesize mayHaveCover;

- (id)initWithKey:(id)theKey {
    self = [super init];
    if (self) {
		key = theKey;
		type = BubbleTypeDefault;
    }
    return self;
}


- (CGRect)rect {
	return CGRectMake(origin.x - radius, origin.y - radius, radius * 2, radius * 2);
}

- (BOOL)hasPosition {
	return (isnan(origin.x) || isnan(origin.y)) == NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Bubble: %@\n\tTitle: %@\n\tNumElements %@\n\tColor: %@ \n\tOrigin %@ \n\tRadius %f\n\tType %d", self.key, self.title, self.numElements, self.color, NSStringFromCGPoint(self.origin), self.radius, (int) self.type];
}

- (id)copyWithZone:(NSZone *)zone {
	Bubble *newBubble = [[[self class] allocWithZone:zone] initWithKey:self.key];

	newBubble.origin = self.origin;
	newBubble.radius = self.radius;
	newBubble.color = self.color;
	newBubble.title = self.title;
	newBubble.numElements = self.numElements;
	newBubble.type = self.type;

	newBubble.isLeaf = self.isLeaf;
	newBubble.mayHaveCover = self.mayHaveCover;
	newBubble.icon = self.icon;
	
	return newBubble;
}

@end
