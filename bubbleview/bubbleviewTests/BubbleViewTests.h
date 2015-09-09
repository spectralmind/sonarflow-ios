#import <SenTestingKit/SenTestingKit.h>

@class TestBubbleView;
@class BubbleViewTestHelper;

@interface BubbleViewTests : SenTestCase {
	BubbleViewTestHelper *helper;
	id labelContainerMock;
	TestBubbleView *sut;
}

@end
