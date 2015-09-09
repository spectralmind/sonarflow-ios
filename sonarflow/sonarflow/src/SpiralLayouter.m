#import "SpiralLayouter.h"
#import "Bubble.h"

@implementation SpiralLayouter

- (NSArray *)sortAndLayoutBubbles:(NSArray *)bubbles inRadius:(CGFloat)radius avoidingBubbles:(NSArray *)theBubblesToAvoid {	
	self.A = ((Bubble *)[bubbles objectAtIndex:0]).radius / 2;
	NSArray *layouted = [super sortAndLayoutBubbles:bubbles inRadius:radius avoidingBubbles:theBubblesToAvoid];
	return layouted;
}

@end
