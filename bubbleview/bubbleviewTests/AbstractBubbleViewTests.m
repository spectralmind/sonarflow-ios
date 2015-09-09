#import "AbstractBubbleViewTests.h"
#import "AbstractBubbleView.h"
#import <OCMock/OCMock.h>
#import "BubbleViewTestHelper.h"
#import "BubbleViewFactory.h"
#import "Bubble.h"
#import "BubbleView.h"

@interface TestAbstractBubbleView : AbstractBubbleView {
@private
	NSArray *childBubbles;
}

@property (nonatomic, strong) NSArray *childBubbles;
@property (nonatomic, strong, readwrite) NSArray *keyPath;

@end

@implementation TestAbstractBubbleView

@synthesize childBubbles;

//Stub out BubbleView's view interaction
- (void)addBubbleSubview:(BubbleView *)view {
}

- (BOOL)shouldShowChildren {
	return YES;
}

- (CGRect)convertRect:(CGRect)rect toView:(UIView *)view {
	return rect;
}

- (BOOL)isPartOfRect:(CGRect)rect {
	return YES;
}

@end

@interface AbstractBubbleViewTests ()

@end


@implementation AbstractBubbleViewTests

- (void)setUp {
	helper = [[BubbleViewTestHelper alloc] init];
	sut = [[TestAbstractBubbleView alloc] initWithViewFactory:helper.viewFactoryMock dataSource:helper.dataSourceMock];
}

- (void)tearDown {
}

- (void)setChildBubbles:(NSArray *)childBubbles {
	[helper setChildBubbles:childBubbles forParentKeyPath:[sut keyPath]];
	
	sut.childBubbles = childBubbles;
	[sut updateVisibilityForRect:CGRectZero];
}

- (void)testBubbleViewForKeyPathWithNilKeyPath {
	NSString *key = @"AKey";
	
	[self setChildBubbles:[NSArray arrayWithObject:[helper bubbleMockWithKey:key]]];
	BubbleView *result = [sut bubbleViewForKeyPath:nil includeHiddenViews:YES allowParent:NO];
	
	STAssertNil(result, @"Should return nil for nil keyPath: %@", result);
}

- (void)testBubbleViewForKeyPathWithEmptyKeyPath {
	NSString *key = @"AKey";
	[self setChildBubbles:[NSArray arrayWithObject:[helper bubbleMockWithKey:key]]];

	BubbleView *result = [sut bubbleViewForKeyPath:[NSArray array] includeHiddenViews:YES allowParent:NO];
	
	STAssertNil(result, @"Should return nil for empty keyPath: %@", result);
}

- (void)testBubbleViewForKeyPathWithUnknownKey {
	NSString *key = @"AKey";
	[self setChildBubbles:[NSArray arrayWithObject:[helper bubbleMockWithKey:key]]];

	BubbleView *result = [sut bubbleViewForKeyPath:[NSArray arrayWithObject:@"otherkey"] includeHiddenViews:YES allowParent:NO];
	
	STAssertNil(result, @"Should return nil for key mismatch: %@", result);
}

- (void)testBubbleViewForKeyPathWithChildKey {
	NSString *key = @"AKey";
	[self setChildBubbles:[NSArray arrayWithObjects:[helper bubbleMockWithKey:@"0Key"], [helper bubbleMockWithKey:key], nil]];

	BubbleView *result = [sut bubbleViewForKeyPath:[NSArray arrayWithObject:key] includeHiddenViews:YES allowParent:NO];
	
	STAssertEqualObjects([helper viewMockForKey:key], result, @"Should return child.");
}

- (void)testBubbleViewForKeyPathWithSubChildKey {
	NSString *key = @"AKey";
	NSString *subKey = @"OtherKey";
	id bubbleMock = [helper bubbleMockWithKey:key];
	[self setChildBubbles:[NSArray arrayWithObjects:[helper bubbleMockWithKey:@"0Key"], bubbleMock, nil]];
	BubbleView *subKeyView = [OCMockObject niceMockForClass:[BubbleView class]];
	id keyView = [helper viewMockForKey:key];
	[[[keyView expect] andReturn:subKeyView] bubbleViewForKeyPath:[NSArray arrayWithObject:subKey] includeHiddenViews:YES allowParent:NO];
	
	BubbleView *result = [sut bubbleViewForKeyPath:[NSArray arrayWithObjects:key, subKey, nil] includeHiddenViews:YES allowParent:NO];
	
	[keyView verify];
	STAssertEqualObjects(subKeyView, result, @"Should return child of child");
}

@end

