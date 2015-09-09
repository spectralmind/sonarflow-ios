#import "NSArray+NSNull.h"

@implementation NSArray (NSNull)

- (NSArray *)arrayWithoutNSNullObjects {
	NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:self.count];
	for (id o in self) {
		if ([o isKindOfClass:[NSNull class]]) {
			continue;
		}
		
		[newArray addObject:o];
	}
	return newArray;
}

@end
