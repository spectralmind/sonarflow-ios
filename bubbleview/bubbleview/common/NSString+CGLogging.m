#import "NSString+CGLogging.h"

@implementation NSString (CGLogging)

+ (NSString *)stringFromRect:(CGRect)rect {
	return [NSString stringWithFormat:@"%@ %@",
			[self stringFromPoint:rect.origin],
			[self stringFromSize:rect.size]];
}

+ (NSString *)stringFromPoint:(CGPoint)point {
	return [NSString stringWithFormat:@"(%.2f, %.2f)", point.x, point.y];
}

+ (NSString *)stringFromSize:(CGSize)size {
	return [NSString stringWithFormat:@"(%.2f, %.2f)", size.width, size.height];
}


@end
