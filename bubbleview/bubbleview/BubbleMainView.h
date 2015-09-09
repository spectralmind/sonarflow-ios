#import <UIKit/UIKit.h>
#import "AbstractBubbleView.h"
#import "LabelContainer.h"
#import "BVRimAnimationControllerDelegate.h"

@protocol BubbleMainViewDelegate;
@class Bubble;

@interface BubbleMainView : AbstractBubbleView <UIGestureRecognizerDelegate, LabelContainer, BVRimAnimationControllerDelegate>

@property (nonatomic, weak) IBOutlet id<BubbleMainViewDelegate> delegate;
@property (nonatomic, readonly, strong) UIView *zoomableView;

@property (nonatomic, readonly) CGRect bubbleBoundingRect;

@property (nonatomic, assign) BOOL ignoreNextTap;


- (void)startHighlightingBubbleAtLocation:(CGPoint)location;
- (void)fadeOutBubbleHighlight;
- (void)cancelBubbleHighlight;

- (CGRect)rectForBubbleAtKeyPath:(NSArray *)keyPath;

@end


@protocol BubbleMainViewDelegate

- (void)tappedBubbleAtKeyPath:(NSArray *)keyPath inRect:(CGRect)rect;
- (void)doubleTappedBubbleAtKeyPath:(NSArray *)keyPath inRect:(CGRect)rect;

- (void)tappedEmptyLocation:(CGPoint)location;
- (void)doubleTappedEmptyLocation:(CGPoint)location;

@end

