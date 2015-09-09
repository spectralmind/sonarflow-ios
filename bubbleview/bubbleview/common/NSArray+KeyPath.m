#import "NSArray+KeyPath.h"

@implementation NSArray (KeyPath)

- (id)head {
	return [self objectAtIndex:0];
}

- (NSArray *)tail {
	if([self count] == 1) {
		return nil;
	}
	
	return [self subarrayWithRange:NSMakeRange(1, [self count] - 1)];
}

- (BOOL)hasParent {
	return [self count] > 0;
}

- (NSArray *)parent {
	NSAssert([self hasParent], @"Keypath has no parent!");
	
	return [self subarrayWithRange:NSMakeRange(0, [self count] - 1)];
}

@end
