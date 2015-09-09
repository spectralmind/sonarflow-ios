#import "BubbleViewTests.h"
#import "BubbleView.h"
#import <OCMock/OCMock.h>
#import "BubbleViewTestHelper.h"
#import "BubbleViewFactory.h"
#import "LabelContainer.h"
#import "Bubble.h"

@interface TestBubbleView : BubbleView {
@private
	NSArray *childBubbles;
}

@property (nonatomic, strong) NSArray *childBubbles;

@end

@implementation TestBubbleView

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

- (void)createBubbleBackgroundIfNeeded {
}

- (void)createLabelViewIfNeeded {
}

- (void)createCoverViewIfNeeded {
}

- (BOOL)isPartOfRect:(CGRect)rect {
	return YES;
}

@end

@interface BubbleViewTests ()

@end

static const NSString *SUT_KEY = @"SUTKey";

@implementation BubbleViewTests

- (void)setUp {
	helper = [[BubbleViewTestHelper alloc] init];
	labelContainerMock = [OCMockObject mockForProtocol:@protocol(LabelContainer)];
	sut = [[TestBubbleView alloc] initWithViewFactory:helper.viewFactoryMock dataSource:nil labelContainer:labelContainerMock sizeToShowChildren:10 sizeToShowTitle:10 fadeSize:1 coverSize:CGSizeMake(1, 1)];
	
	[sut setBubble:[helper bubbleMockWithKey:SUT_KEY] withKeyPath:[NSArray arrayWithObject:@"MockId"]];
}

- (void)tearDown {
}

- (void)setChildBubbles:(NSArray *)childBubbles {
	[helper setChildBubbles:childBubbles forParentKeyPath:[sut keyPath]];
	
	sut.childBubbles = childBubbles;
	[sut updateVisibilityForRect:CGRectZero];
}


- (void)testBubbleViewForKeyPathWithEmptyKeyPath {
	[self setChildBubbles:[NSArray arrayWithObjects:[helper bubbleMockWithKey:@"0Key"], nil]];

	BubbleView *result = [sut bubbleViewForKeyPath:[NSArray array] includeHiddenViews:YES allowParent:NO];
	
	STAssertEqualObjects(sut, result, @"Should return self for empty key path.");
}

- (void)testBubbleViewForKeyPathWithChildKey {
	NSString *childKey = @"AKey";
	[self setChildBubbles:[NSArray arrayWithObjects:[helper bubbleMockWithKey:@"0Key"], [helper bubbleMockWithKey:childKey], nil]];

	BubbleView *result = [sut bubbleViewForKeyPath:[NSArray arrayWithObject:childKey] includeHiddenViews:YES allowParent:NO];
	
	STAssertEqualObjects([helper viewMockForKey:childKey], result, @"Should return child.");
}

- (void)testBubbleViewForKeyPathWithUnknownKey {
	[self setChildBubbles:[NSArray arrayWithObject:[helper bubbleMockWithKey:@"AKey"]]];

	BubbleView *result = [sut bubbleViewForKeyPath:[NSArray arrayWithObject:@"UnknownKey"] includeHiddenViews:YES allowParent:YES];
	
	STAssertEqualObjects(sut, result, @"Should return self for unknown key: %@", result);
}

@end
