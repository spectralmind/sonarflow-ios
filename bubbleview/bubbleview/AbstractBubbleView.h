#import <UIKit/UIKit.h>
#import "CacheableView.h"
#import "Faulter.h"

@protocol BubbleDataSource;
@class AbstractBubbleView;
@class Bubble;
@class BubbleView;
@class BubbleViewFactory;

typedef BOOL (^BubbleViewCheckBlock) (AbstractBubbleView *);

@interface AbstractBubbleView : UIView <CacheableView>

- (id)init;
- (id)initWithViewFactory:(BubbleViewFactory *)theViewFactory dataSource:(id<BubbleDataSource>) theDataSource;
;
- (void)initCommon;

@property (nonatomic, readonly, weak) BubbleViewFactory *viewFactory;
@property (nonatomic, readonly, weak) id<BubbleDataSource> dataSource;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, assign) CGPoint childrenCenterOffset;

- (BOOL)hasChildViews;
- (void)addChildViewForBubble:(Bubble *)bubble delayed:(BOOL)delayed;

- (BOOL)isPartOfRect:(CGRect)rect;
- (void)willBecomeHidden;
- (void)willBecomeVisible;
- (void)removeChildViews;
- (void)removeChildViewForKey:(id)key;
- (void)removeChildView:(BubbleView *)childView;
- (void)removeBubbleAtKeyPath:(NSArray *)aKeyPath;
- (void)reloadChildrenAtKeyPath:(NSArray *)aKeyPath;
- (void)reloadBubbleAtKeyPath:(NSArray *)aKeyPath;
- (void)reloadBubble;
- (void)reloadChildViews;
- (void)layoutInnerViews;

- (void)updateVisibilityForRect:(CGRect)rect;
- (BubbleView *)bubbleViewForLocation:(CGPoint)location;
- (BubbleView *)bubbleViewForKeyPath:(NSArray *)aKeyPath includeHiddenViews:(BOOL)includeHiddenViews allowParent:(BOOL)allowParent;
- (NSArray *)visibleBubbleViewsInKeyPath:(NSArray *)aKeyPath;
- (NSArray *)visibleBubbleViewsInCircleAt:(CGPoint)centerLocation withRadius:(CGFloat)radius satisfyingCheck:(BubbleViewCheckBlock)check;

- (void)handleZoomScaleChange;
- (void)setChildZoomScale:(BubbleView *)view;
- (void)addBubbleSubview:(BubbleView *)view;
- (void)didAddChildViews;

- (NSArray *)keyPath;

//Pure virtual
- (BOOL)shouldShowChildren;
- (NSArray *)childBubbles;
- (BOOL)shouldHideLabelView;

@end
