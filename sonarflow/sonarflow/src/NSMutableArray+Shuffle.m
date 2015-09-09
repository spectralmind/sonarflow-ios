#import "NSMutableArray+Shuffle.h"

@implementation NSMutableArray (Shuffle)

- (void)shuffle {
	[self shuffleRange:NSMakeRange(0, [self count])];
}

- (void)shuffleRange:(NSRange)range {
    for(NSUInteger i = 0; i < range.length - 1; ++i) {
        int nElements = range.length - i;
        int a = range.location + i;
		int b = a + arc4random_uniform(nElements);
        [self exchangeObjectAtIndex:a withObjectAtIndex:b];
    }
}

@end
