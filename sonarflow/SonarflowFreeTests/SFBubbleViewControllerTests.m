#import "SFBubbleViewControllerTests.h"

#import <OCMock/OCMock.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#import "AppFactory.h"
#import "Bubble.h"
#import "BubbleDataSource.h"
#import "BubbleFactory.h"
#import "BubbleViewController.h"
#import "ImageFactory.h"
#import "SFBubbleHierarchyView.h"
#import "SFTestMediaLibrary.h"
#import "SFTestRootMediaItem.h"

typedef BOOL (^CheckBlock)(id);
typedef void (^InvocationBlock)(NSInvocation *);

@interface SFBubbleViewControllerTests ()

@property (nonatomic, strong) id<BubbleDataSource> dataSource;

@end

@implementation SFBubbleViewControllerTests {
	BubbleViewController *sut;

	id factoryMock;
	id imageFactoryMock;
	id viewMock;
	CheckBlock dataSourceCaptureBlock;
	id<BubbleDataSource> dataSource;
	SFTestMediaLibrary *testMediaLibrary;
	BubbleFactory *bubbleFactory;
}

@synthesize dataSource;

- (void)setUp {
	factoryMock = [OCMockObject niceMockForClass:[AppFactory class]];
	imageFactoryMock = [OCMockObject niceMockForClass:[ImageFactory class]];
	viewMock = [OCMockObject niceMockForClass:[SFBubbleHierarchyView class]];
	dataSourceCaptureBlock = ^(id value){
		self.dataSource = value;
		return YES;
	};
	[[viewMock stub] setBubbleDataSource:[OCMArg checkWithBlock:dataSourceCaptureBlock]];

	testMediaLibrary = [[SFTestMediaLibrary alloc] init];
	bubbleFactory = [[BubbleFactory alloc] initWithImageFactory:imageFactoryMock];
	bubbleFactory.maxBubbleRadius = 100;
	bubbleFactory.childrenRadiusFactor = 0.9;
}

- (void)initSut {
	sut = [[BubbleViewController alloc] initWithLibrary:testMediaLibrary factory:factoryMock];
	sut.bubbleFactory = bubbleFactory;
	sut.view = viewMock;
}

- (NSArray *)bubblesForItems:(NSArray *)items {
	NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[items count]];
	for(id<SFMediaItem> item in items) {
		[result addObject:[[Bubble alloc] initWithKey:item.key]];
	}	
	return result;
}

- (void)testSetDataSource {
	[self initSut];

	STAssertNotNil(dataSource, @"Should set view dataSource");
}

- (void)testEmptyLibraryBubbles {
	[self initSut];

	NSArray *result = [dataSource childrenForKeyPath:[NSArray array]];

	STAssertEquals((NSUInteger) 0, [result count], @"Unexpected number of children");
}

- (void)testGetInitialChildren {
	id<SFMediaItem, SFRootItem> root1 = [testMediaLibrary addMediaItemWithKey:@"Foo"];
	[self initSut];
	
	NSArray *result = [dataSource childrenForKeyPath:[NSArray array]];
	
	STAssertEquals((NSUInteger) 1, [result count], @"Unexpected number of children");
	[self assertKey:root1.key isContainedInBubbles:result];
}

- (void)testGetRootChildren {
	[self initSut];
	id<SFMediaItem, SFRootItem> root1 = [testMediaLibrary addMediaItemWithKey:@"Foo"];
	id<SFMediaItem, SFRootItem> root2 = [testMediaLibrary addMediaItemWithKey:@"Bar"];
	
	NSArray *result = [dataSource childrenForKeyPath:[NSArray array]];

	STAssertEquals((NSUInteger) 2, [result count], @"Unexpected number of children");
	[self assertKey:root1.key isContainedInBubbles:result];
	[self assertKey:root2.key isContainedInBubbles:result];
}

- (void)testGetRootChildrenAfterRemove {
	id<SFMediaItem, SFRootItem> root1 = [testMediaLibrary addMediaItemWithKey:@"Foo"];
	[self initSut];
	id<SFMediaItem, SFRootItem> root2 = [testMediaLibrary addMediaItemWithKey:@"Bar"];
	
	NSArray *resultBefore = [[dataSource childrenForKeyPath:[NSArray array]] copy];
	[testMediaLibrary removeMediaItem:root1];
	NSArray *resultAfter = [dataSource childrenForKeyPath:[NSArray array]];
	
	STAssertEquals((NSUInteger) 2, [resultBefore count], @"Unexpected number of children");
	STAssertEquals((NSUInteger) 1, [resultAfter count], @"Unexpected number of children");
	[self assertKey:root2.key isContainedInBubbles:resultAfter];
}

- (void)testGetEmptyChildren {
	SFTestRootMediaItem *root1 = [testMediaLibrary addMediaItemWithKey:@"Foo"];
	[self initSut];
	
	[dataSource childrenForKeyPath:[NSArray array]];
	NSArray *childResult = [dataSource childrenForKeyPath:[root1 keyPath]];
	
	STAssertEquals((NSUInteger) 0, [childResult count], @"Unexpected number of children");
}

- (void)testGetExinstingChildren {
	SFTestRootMediaItem *root1 = [testMediaLibrary addMediaItemWithKey:@"Foo"];
	SFTestMediaItem *child = [root1 addChildWithKey:@"Bar"];
	[self initSut];

	[dataSource childrenForKeyPath:[NSArray array]];
	NSArray *childResult = [dataSource childrenForKeyPath:[root1 keyPath]];
	
	STAssertEquals((NSUInteger) 1, [childResult count], @"Unexpected number of children");
	[self assertKey:child.key isContainedInBubbles:childResult];
}

- (void)testGetAddedChildren {
	SFTestRootMediaItem *root1 = [testMediaLibrary addMediaItemWithKey:@"Foo"];
	[self initSut];
	[dataSource childrenForKeyPath:[NSArray array]];

	SFTestMediaItem *child = [root1 addChildWithKey:@"Bar"];
	NSArray *childResult = [dataSource childrenForKeyPath:[root1 keyPath]];
	
	STAssertEquals((NSUInteger) 1, [childResult count], @"Unexpected number of children");
	[self assertKey:child.key isContainedInBubbles:childResult];
}

- (void)testGetChildrenAfterRemove {
	SFTestRootMediaItem *root1 = [testMediaLibrary addMediaItemWithKey:@"Foo"];
	SFTestMediaItem *child1 = [root1 addChildWithKey:@"Bar"];
	[self initSut];
	SFTestMediaItem *child2 = [root1 addChildWithKey:@"Baz"];
	[dataSource childrenForKeyPath:[NSArray array]];

	NSArray *childResultBefore = [[dataSource childrenForKeyPath:[root1 keyPath]] copy];
	[root1 removeChild:child2];
	NSArray *childResultAfter = [dataSource childrenForKeyPath:[root1 keyPath]];
	
	STAssertEquals((NSUInteger) 2, [childResultBefore count], @"Unexpected number of children");
	STAssertEquals((NSUInteger) 1, [childResultAfter count], @"Unexpected number of children");
	[self assertKey:child1.key isContainedInBubbles:childResultAfter];
}

- (void)testBubbleSizeAfterAddedChildren {
	SFTestRootMediaItem *root = [testMediaLibrary addMediaItemWithKey:@"Foo"];
	[testMediaLibrary addMediaItemWithKey:@"Bar"];
	SFTestMediaItem *child = [root addChildWithKey:@"Foo"];
	[child addChildWithKey:@"Foo"];
	[self initSut];
	[dataSource childrenForKeyPath:[NSArray array]];
	[dataSource childrenForKeyPath:[root keyPath]];
	
	Bubble *rootBefore = [[dataSource bubbleForKeyPath:[root keyPath]] copy];
	Bubble *childBefore = [[dataSource bubbleForKeyPath:[child keyPath]] copy];
	[child addChildWithKey:@"Bar"];
	Bubble *rootAfter = [[dataSource bubbleForKeyPath:[root keyPath]] copy];
	Bubble *childAfter = [[dataSource bubbleForKeyPath:[child keyPath]] copy];
	
	assertThat(@(rootBefore.radius), is(greaterThan(@(childBefore.radius))));
	assertThat(@(rootAfter.radius), is(greaterThan(@(childAfter.radius))));
	assertThat(@(rootBefore.radius), is(lessThan(@(rootAfter.radius))));
	assertThat(@(childBefore.radius), is(lessThan(@(childAfter.radius))));
}

- (void)testBubbleSizeAfterRemovedChildren {
	SFTestRootMediaItem *root = [testMediaLibrary addMediaItemWithKey:@"Foo"];
	[testMediaLibrary addMediaItemWithKey:@"Bar"];
	SFTestMediaItem *child = [root addChildWithKey:@"Foo"];
	[child addChildWithKey:@"Foo"];
	SFTestMediaItem *subChild = [child addChildWithKey:@"Bar"];
	[self initSut];
	[dataSource childrenForKeyPath:[NSArray array]];
	[dataSource childrenForKeyPath:[root keyPath]];
	
	Bubble *rootBefore = [[dataSource bubbleForKeyPath:[root keyPath]] copy];
	Bubble *childBefore = [[dataSource bubbleForKeyPath:[child keyPath]] copy];
	[child removeChild:subChild];
	Bubble *rootAfter = [[dataSource bubbleForKeyPath:[root keyPath]] copy];
	Bubble *childAfter = [[dataSource bubbleForKeyPath:[child keyPath]] copy];
	
	assertThat(@(rootBefore.radius), is(greaterThan(@(childBefore.radius))));
	assertThat(@(rootAfter.radius), is(greaterThan(@(childAfter.radius))));
	assertThat(@(rootBefore.radius), is(greaterThan(@(rootAfter.radius))));
	assertThat(@(childBefore.radius), is(greaterThan(@(childAfter.radius))));
}

- (void)testBubbleSizeAfterAddedChildrenWithoutKnowingAllBubbles {
	SFTestRootMediaItem *root = [testMediaLibrary addMediaItemWithKey:@"Foo"];
	[testMediaLibrary addMediaItemWithKey:@"Bar"];
	SFTestMediaItem *child = [root addChildWithKey:@"Foo"];
	[child addChildWithKey:@"Foo"];
	[self initSut];
	[dataSource childrenForKeyPath:[NSArray array]];
	
	Bubble *rootBefore = [[dataSource bubbleForKeyPath:[root keyPath]] copy];
	[child addChildWithKey:@"Bar"];
	Bubble *rootAfter = [[dataSource bubbleForKeyPath:[root keyPath]] copy];
	
	assertThat(@(rootBefore.radius), is(lessThan(@(rootAfter.radius))));
}

- (void)assertKey:(id)key isContainedInBubbles:(NSArray *)bubbles {
	for(Bubble *bubble in bubbles) {
		if([bubble.key isEqual:key]) {
			return;
		}
	}
	STFail(@"Key %@ is not contained in bubbles %@", key, bubbles);
}

@end
