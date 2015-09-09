#import "BubbleHierarchyView.h"
#import "AbstractBubbleView.h"

@class BubbleViewFactory;

@interface BubbleHierarchyView ()

#pragma mark Hidden from library user

@property (nonatomic, readonly) BubbleMainView *bubbleMainView;

@property (nonatomic, copy) BubbleViewCheckBlock bubbleCheck;


#pragma mark Private

@property (nonatomic, assign) CGFloat requiredMaxZoomScale;
@property (nonatomic, assign) CGFloat requiredMinZoomScale;
@property (nonatomic, readonly) CGFloat minimumBubbleSizeForParent;
@property (nonatomic, readonly) CGFloat minimumBubbleSizeForLeaf;

- (void)initBubbleHierarchyView;
- (void)calculatePaddingAndZoomLimits;
- (void)updateContentSize;
- (void)calculateZoomLimits;
- (BOOL)isNotInteracting;
- (void)synchronizeZoomScale;
- (void)updatePaddingInset;
- (void)calcAndSetPaddingInset;
- (void)updateBubbleViewVisibility;
- (UIEdgeInsets)summedInsets;

- (void)adjustScaleForBubble:(Bubble *)bubble;
- (void)zoomToSubview:(UIView *)subview;
- (void)increaseZoomByFactor:(CGFloat)zoomFactor aroundBubbleLocation:(CGPoint)location;

- (void)createGestureRecognizers;

@end
