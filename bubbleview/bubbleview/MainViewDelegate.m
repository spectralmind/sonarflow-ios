#import "MainViewDelegate.h"
#import "BubbleHierarchyView+Private.h"

static const CGFloat kDoubleTapZoomScaleFactor = 1.5;

@implementation MainViewDelegate

- (id)initWithView:(BubbleHierarchyView *)theView {
    self = [super init];
    if (self) {
		view = theView;
    }
    return self;
}

#pragma mark -
#pragma mark BubbleMainViewDelegate

- (void)tappedBubbleAtKeyPath:(NSArray *)keyPath inRect:(CGRect)rect {
	CGRect localRect = [view convertRect:rect fromView:view.bubbleMainView];
	[view.bubbleDelegate tappedBubbleAtKeyPath:keyPath inRect:localRect];
}

- (void)doubleTappedBubbleAtKeyPath:(NSArray *)keyPath inRect:(CGRect)rect {
	CGRect localRect = [view convertRect:rect fromView:view.bubbleMainView];
	[view.bubbleDelegate doubleTappedBubbleAtKeyPath:keyPath inRect:localRect];
}

- (void)tappedEmptyLocation:(CGPoint)location {
	[view.bubbleDelegate tappedEmptyLocation:location];
}

- (void)doubleTappedEmptyLocation:(CGPoint)location {
	[view increaseZoomByFactor:kDoubleTapZoomScaleFactor aroundBubbleLocation:location];
}

@end
