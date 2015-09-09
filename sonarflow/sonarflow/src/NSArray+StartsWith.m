#import "NSArray+StartsWith.h"

@implementation NSArray (StartsWith)

- (BOOL)startsWith:(NSArray *)array {
	if(array == nil || [array count] > [self count]) {
		return NO;
	}

	for(int i = 0; i < [array count]; ++i) {
		if([[self objectAtIndex:i] isEqual:[array objectAtIndex:i]] == NO) {
			return NO;
		}
	}
	return YES;
}

@end
