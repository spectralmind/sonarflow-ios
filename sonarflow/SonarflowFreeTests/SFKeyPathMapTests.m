#import "SFKeyPathMapTests.h"

#import <OCMock/OCMock.h>

#import "SFKeyPathMap.h"

@implementation SFKeyPathMapTests {
	SFKeyPathMap *sut;
	NSArray *parentKeyPath;
	NSArray *testKeyPath;
	NSArray *otherKeyPath;
	NSArray *unknownKeyPath;
	
	id testObject;
}

- (void)setUp {
	sut = [[SFKeyPathMap alloc] init];
	
	parentKeyPath = @[@"Foo"];
	testKeyPath = [parentKeyPath arrayByAddingObject:@"Bar"];
	otherKeyPath = @[@"Baz"];
	unknownKeyPath = @[@"Unknown", @"Key", @"Path"];
	testObject = @"Valuable Data";

	[sut setObject:@"RootValue" forKeyPath:[NSArray array]];
	[sut setObject:@"parentValue" forKeyPath:parentKeyPath];
	[sut setObject:testObject forKeyPath:testKeyPath];
	[sut setObject:@"otherValue" forKeyPath:otherKeyPath];
}

- (void)testObjectForKeyPathUnknown {
	STAssertNil([sut objectForKeyPath:unknownKeyPath], @"Should not return object for unknown keyPath");
}

- (void)testObjectForEmptyKeyPath {
	STAssertNotNil([sut objectForKeyPath:[NSArray array]], @"Should return object");
}

- (void)testObjectForKeyPathTest {
	STAssertEqualObjects(testObject, [sut objectForKeyPath:testKeyPath], @"Should return object for testKeyPath");
}

- (void)testRemoveBubbleForKeyPathUnknown {
	[sut removeObjectsForKeyPath:unknownKeyPath];

	STAssertNil([sut objectForKeyPath:unknownKeyPath], @"Should not return object for unknown keyPath");
}

- (void)testRemoveObjectsForKeyPath {
	[sut removeObjectsForKeyPath:parentKeyPath];
	
	STAssertNotNil([sut objectForKeyPath:[NSArray array]], @"Should not remove root object");
	STAssertNil([sut objectForKeyPath:parentKeyPath], @"Should remove object");
	STAssertNil([sut objectForKeyPath:testKeyPath], @"Should remove child objects");
	STAssertNotNil([sut objectForKeyPath:otherKeyPath], @"Should not remove other objects");
}

- (void)testRemoveChildrenOfKeyPath {
	[sut removeChildrenOfKeyPath:parentKeyPath];
	
	STAssertNotNil([sut objectForKeyPath:[NSArray array]], @"Should not remove root object");
	STAssertNotNil([sut objectForKeyPath:parentKeyPath], @"Should not remove parent object");
	STAssertNil([sut objectForKeyPath:testKeyPath], @"Should remove child objects");
	STAssertNotNil([sut objectForKeyPath:otherKeyPath], @"Should not remove other objects");
}

- (void)testRemoveChildrenOfRootKeyPath {
	[sut removeChildrenOfKeyPath:[NSArray array]];
	
	STAssertNotNil([sut objectForKeyPath:[NSArray array]], @"Should not remove root object");
	STAssertNil([sut objectForKeyPath:parentKeyPath], @"Should remove child objects");
	STAssertNil([sut objectForKeyPath:testKeyPath], @"Should remove child objects");
	STAssertNil([sut objectForKeyPath:otherKeyPath], @"Should remove child objects");
}

- (void)testRemoveAllObjects {
	[sut removeAllObjects];
	
	STAssertNil([sut objectForKeyPath:[NSArray array]], @"Should remove all objects");
	STAssertNil([sut objectForKeyPath:parentKeyPath], @"Should remove all objects");
	STAssertNil([sut objectForKeyPath:testKeyPath], @"Should remove all objects");
	STAssertNil([sut objectForKeyPath:otherKeyPath], @"Should remove all objects");
}

@end
