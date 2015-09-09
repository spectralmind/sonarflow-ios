#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BubbleView;
@class BubbleLabelView;
@class Bubble;
@class ViewCache;
@class BubbleGlowView;
@class BVRimAnimationView;
@class BVRimAnimationController;
@class BVResources;

@protocol CacheableView;
@protocol LabelContainer;
@protocol BubbleDataSource;

@interface BubbleViewFactory : NSObject

+ (BubbleViewFactory *)newDefaultFactory;

- (id)initWithFont:(UIFont *)theFont labelCountFont:(UIFont *)theLabelCountFont sizeToShowChildren:(CGFloat)theSizeToShowChildren sizeToShowTitle:(CGFloat)theSizeToShowTitle fadeSize:(CGFloat)theFadeSize coverSize:(CGSize)theCoverSize showCountLabel:(BOOL)theShowCountLabel;

@property (nonatomic, strong) BVResources *resources;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIFont *labelCountFont;
@property (nonatomic, assign) CGFloat bubbleScreenSizeToShowChildren;
@property (nonatomic, assign) CGFloat bubbleScreenSizeToShowTitle;
@property (nonatomic, assign) CGFloat bubbleFadeSize;
@property (nonatomic, assign) CGSize coverSize;
@property (nonatomic, assign) BOOL showCountLabel;

@property (nonatomic, weak) id<LabelContainer> labelContainer;
@property (nonatomic, weak) id<BubbleDataSource> dataSource;
@property (nonatomic, strong) BVRimAnimationController *rimAnimationController;

- (BubbleView *)dequeueBubbleViewForBubble:(Bubble *)bubble withKeyPath:(NSArray *)keyPath;
- (void)enqueueBubbleView:(BubbleView *)view;

- (UIView<CacheableView> *)dequeueBackgroundViewForBubble:(Bubble *)bubble;
- (void)enqueueBackgroundView:(UIView<CacheableView> *)view forBubble:(Bubble *)bubble;

- (BubbleLabelView *)dequeueLabelViewForBubble:(Bubble *)bubble;
- (void)enqueueLabelView:(BubbleLabelView *)view;

- (BubbleGlowView *)glowView;

- (void)setCurrentlyPlayingKeypath:(NSArray *)keyPath playStatePlaying:(BOOL)playing;

- (BVRimAnimationView *)dequeueRimAnimationView;
- (void)enqueueRimAnimationView:(BVRimAnimationView *)view;

- (void)printStatus;

@end
