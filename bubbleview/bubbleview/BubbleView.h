#import <UIKit/UIKit.h>
#import "AbstractBubbleView.h"
#import "BVRimAnimationState.h"

@protocol BubbleDataSource;
@protocol LabelContainer;
@class BubbleLabelView;
@class BubbleViewFactory;
@class Bubble;
@class BubbleGlowView;

@interface BubbleView : AbstractBubbleView

- (id)initWithViewFactory:(BubbleViewFactory *)theViewFactory dataSource:(id<BubbleDataSource>)theDataSource labelContainer:(id<LabelContainer>)theLabelContainer sizeToShowChildren:(CGFloat)theSizeToShowChildren sizeToShowTitle:(CGFloat)theSizeToShowTitle fadeSize:(CGFloat)theFadeSize coverSize:(CGSize)theCoverSize;

@property (nonatomic, readonly) Bubble *bubble;

- (void)setBubble:(Bubble *)newBubble withKeyPath:(NSArray *)newKeyPath;
- (void)updateBubble:(Bubble *)newBubble;

- (BubbleView *)bubbleViewForLocation:(CGPoint)location;

- (void)setCenterOffset:(CGPoint)offset;

- (void)showGlow;
- (void)fadeOutGlow;
- (void)cancelGlow;

- (void)setRimAnimationState:(BVRimAnimationState)state offset:(NSTimeInterval)offset;
- (void)removeRimAnimation;

- (void)startBounceAnimation;

- (void)showShadow;
- (void)hideShadow;

@end
