#import "NSArray+StartsWithTests.h"

#import "NSArray+StartsWith.h"

@implementation NSArray_StartsWithTests {
	NSArray *sut;
}

- (void)setUp {
	sut = @[@"Foo", @"Bar", @"Baz"];
}


- (void)testStartsWith {
	[self assertStartsWith:@[]];
	[self assertStartsWith:@[@"Foo"]];
	[self assertStartsWith:@[@"Foo", @"Bar"]];
	[self assertStartsWith:@[@"Foo", @"Bar", @"Baz"]];
	[self assertStartsNotWith:@[@"Foo", @"Foo"]];
	[self assertStartsNotWith:@[@"Bar"]];
	[self assertStartsNotWith:@[@"Baz"]];
	[self assertStartsNotWith:@[@"Foo", @"Bar", @"Baz", @"Baz"]];
	[self assertStartsNotWith:nil];
}

- (void)assertStartsWith:(NSArray *)other {
	STAssertTrue([sut startsWith:other], @"Should start with %@", other);
}

- (void)assertStartsNotWith:(NSArray *)other {
	STAssertFalse([sut startsWith:other], @"Should not start with %@", other);
}

@end
