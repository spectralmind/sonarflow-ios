#import "NSArray+SingleElement.h"

@implementation NSArray (SingleElement)

+ (NSArray *)arrayWithArrayOrObject:(id)arrayOrObject {
	if([arrayOrObject isKindOfClass:[NSArray class]]) {
		return arrayOrObject;
	}
	
	return @[arrayOrObject];
}

@end
