#import "BubbleViewTestHelper.h"
#import <OCMock/OCMock.h>
#import <SenTestingKit/SenTestingKit.h>
#import "BubbleViewFactory.h"
#import "Bubble.h"
#import "BubbleView.h"

@implementation BubbleViewTestHelper


- (id)init {
    self = [super init];
    if (self) {
		viewFactoryMock = [OCMockObject mockForClass:[BubbleViewFactory class]];
		_dataSourceMock = [OCMockObject mockForProtocol:@protocol(BubbleDataSource)];
		viewsByKey = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return self;
}


@synthesize viewFactoryMock;

- (id)bubbleMockWithKey:(id)key {
	id bubbleMock = [OCMockObject niceMockForClass:[Bubble class]];
	[[[bubbleMock stub] andReturn:key] key];
	return bubbleMock;
}

- (void)setChildBubbles:(NSArray *)childBubbles forParentKeyPath:(NSArray *)keyPath {
	for(Bubble *bubble in childBubbles) {
		id childViewMock = [OCMockObject niceMockForClass:[BubbleView class]];
		[[[childViewMock stub] andReturn:bubble] bubble];
		[viewsByKey setObject:childViewMock forKey:bubble.key];
		[[[viewFactoryMock expect] andReturn:childViewMock] dequeueBubbleViewForBubble:bubble withKeyPath:[keyPath arrayByAddingObject:bubble.key]];
		
		[[viewFactoryMock expect] enqueueBubbleView:childViewMock]; //In Deconstructor
	}
}

- (id)viewMockForKey:(id)key {
	id viewMock = [viewsByKey objectForKey:key];
	NSAssert(viewMock != nil, @"No view mock for key: %@", key);
	
	return viewMock;
}

@end
