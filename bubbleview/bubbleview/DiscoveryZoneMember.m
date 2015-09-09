#import "DiscoveryZoneMember.h"
#import "DiscoveryZoneMember+Private.h"

#import "BubbleView.h"

@implementation DiscoveryZoneMember {
	NSArray *keyPath;
	BubbleView *bubbleView;
	float distanceFromCenter;
}

@synthesize keyPath;
@synthesize distanceFromCenter;
@synthesize bubbleView;


- (BOOL)isEqual:(id)object {
	if([object isKindOfClass:self.class] == NO) {
		return NO;
	}
	
	DiscoveryZoneMember *other = object;
	return [other.keyPath isEqualToArray:self.keyPath];
}

- (NSUInteger)hash {
	return [self.keyPath hash];
}

@end
