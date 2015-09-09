#import "BubbleMainView.h"
#import <QuartzCore/QuartzCore.h>
#import "Bubble.h"
#import "BubbleView.h"
#import "BubbleLabelView.h"
#import "UIImage+Stretchable.h"
#import "UIImage+ColorMask.h"
#import "NSString+CGLogging.h"

#define TRANSLATE(point) CGPointMake((bubbleViewRect.origin.x+point.x)*zoomfactor, (bubbleViewRect.origin.y+point.y)*zoomfactor)

static const NSTimeInterval kRecenTapInterval = 0.1f;

@interface BubbleMainView ()

@property (nonatomic, strong) BubbleView *glowingView;
@property (nonatomic, strong) NSDate *lastTapDate;
@property (nonatomic, readonly) UIView *labelContainerView;
@property (nonatomic, readonly) UIView *topmostLabelContainerView;

@end

@implementation BubbleMainView {
	@private
	id<BubbleMainViewDelegate> __weak delegate;
	
	UIView *scrollViewZoomDummy;
	UIView *labelContainerView;
	UIView *topmostLabelContainerView;
	
	BOOL ignoreNextTap;
	
	CGRect bubbleBoundingRect;
	
	BubbleView *glowingView;
	
	NSDate *lastTapDate;
}

@synthesize bubbleBoundingRect;

- (void)initCommon {
	[super initCommon];

	bubbleBoundingRect = CGRectZero;
	scrollViewZoomDummy = [[UIView alloc] initWithFrame:CGRectZero];
	scrollViewZoomDummy.hidden = YES;
	labelContainerView = [[UIView alloc] initWithFrame:CGRectZero];
	topmostLabelContainerView = [[UIView alloc] initWithFrame:CGRectZero];
	
	[self addSubview:labelContainerView];
	[self insertSubview:topmostLabelContainerView aboveSubview:labelContainerView];
	
	[self createGestureRecognizers];
}

@synthesize lastTapDate;

- (void)createGestureRecognizers {
	UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc]
										 initWithTarget:self
										 action:@selector(handleDoubleTap:)];
	UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
										 initWithTarget:self
										 action:@selector(handleSingleTap:)];

	[doubleTapRecognizer setNumberOfTapsRequired:2];
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
	
    [self addGestureRecognizer:doubleTapRecognizer];
    [self addGestureRecognizer:singleTapRecognizer];
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
	if(gestureRecognizer.state != UIGestureRecognizerStateEnded) {
		return;
	}
	
	self.lastTapDate = [NSDate date];

	if(ignoreNextTap) {
		self.glowingView = nil;
		ignoreNextTap = NO;
		return;
	}
	
	CGPoint location = [gestureRecognizer locationInView:self];
	BubbleView *bubbleView = [self bubbleViewForLocation:location];
	if(bubbleView != nil) {
		CGRect localBounds = [self convertRect:bubbleView.bounds fromView:bubbleView];
		[self.delegate tappedBubbleAtKeyPath:[bubbleView keyPath] inRect:localBounds];
	}
	else {
		[self.delegate tappedEmptyLocation:location];
		self.glowingView = nil;
	}	
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
	if(gestureRecognizer.state != UIGestureRecognizerStateEnded) {
		return;
	}
	
	CGPoint location = [gestureRecognizer locationInView:self];
	BubbleView *bubbleView = [self bubbleViewForLocation:location];

	if(bubbleView != nil) {
		CGRect localBounds = [self convertRect:bubbleView.bounds fromView:bubbleView];
		[self.delegate doubleTappedBubbleAtKeyPath:[bubbleView keyPath] inRect:localBounds];
	}
	else {
		[self.delegate doubleTappedEmptyLocation:(CGPoint)location];
		self.glowingView = nil;
	}
}

- (void)startHighlightingBubbleAtLocation:(CGPoint)location {
	BubbleView *bubbleView = [self bubbleViewForLocation:location];
	self.glowingView = bubbleView;
}

- (void)fadeOutBubbleHighlight {
	self.glowingView = nil;
}

- (void)cancelBubbleHighlight {
	[self.glowingView cancelGlow];
	self.glowingView = nil;
}

@synthesize delegate;
@synthesize labelContainerView;
@synthesize topmostLabelContainerView;

- (UIView *)zoomableView {
	return scrollViewZoomDummy;
}

@synthesize ignoreNextTap;
@synthesize glowingView;

- (void)setGlowingView:(BubbleView *)newGlowingView {
	if(glowingView == newGlowingView) {
		return;
	}
	
	[glowingView fadeOutGlow];
	glowingView = newGlowingView;
	[glowingView showGlow];
}

- (void)handleZoomScaleChange {
	[self updateBounds];

	[super handleZoomScaleChange];
}

- (void)updateBounds {
	CGRect scaledBounds = CGRectMake(bubbleBoundingRect.origin.x * self.zoomScale,
									 bubbleBoundingRect.origin.y * self.zoomScale,
									 bubbleBoundingRect.size.width * self.zoomScale,
									 bubbleBoundingRect.size.height * self.zoomScale);
	self.bounds = scaledBounds;
	self.center = CGPointMake(CGRectGetWidth(scaledBounds) * 0.5, CGRectGetHeight(scaledBounds) * 0.5);
	scrollViewZoomDummy.center = self.center;

	self.labelContainerView.bounds = scaledBounds;
	self.labelContainerView.frame = scaledBounds;
	
	self.topmostLabelContainerView.bounds = scaledBounds;
	self.topmostLabelContainerView.frame = scaledBounds;	
}

- (BOOL)shouldShowChildren {
	return YES;
}

- (BOOL)isPartOfRect:(CGRect)rect {
	return YES; //Prevent children from being removed.
}

- (void)updateDummyBounds {
	scrollViewZoomDummy.bounds = bubbleBoundingRect;
}

- (void)addChildViewForBubble:(Bubble *)bubble delayed:(BOOL)delayed {
	[super addChildViewForBubble:bubble delayed:delayed];
	[self updateBoundsForBubble:bubble];
}

- (void)updateBoundsForBubble:(Bubble *)bubble {
	if(bubble.type == BubbleTypeDefault) {
		bubbleBoundingRect = CGRectUnion(bubbleBoundingRect, [bubble rect]);
		[self updateDummyBounds];
		[self updateBounds];
	}
}

- (void)removeChildViews {
	[super removeChildViews];
	bubbleBoundingRect = CGRectZero;
	[self updateDummyBounds];
	[self updateBounds];
}

- (void)addBubbleSubview:(BubbleView *)view {
	if(view.bubble.type == BubbleTypeDiscovered) {
		[self insertSubview:view belowSubview:topmostLabelContainerView];
	}
	else {
		[self insertSubview:view belowSubview:labelContainerView];
	}
}

- (BubbleView *)bubbleViewForLocation:(CGPoint)location {	
	BubbleLabelView *regularLabel = [self labelViewForLocation:location inContainer:labelContainerView];
	if(regularLabel != nil) {
		return regularLabel.owner;
	}
	
	BubbleLabelView *discoveredLabel = [self labelViewForLocation:location inContainer:topmostLabelContainerView];
	if(discoveredLabel != nil) {
		return discoveredLabel.owner;
	}

	return [super bubbleViewForLocation:location];
}

- (BubbleLabelView *)labelViewForLocation:(CGPoint)location inContainer:(UIView *)container{
	UIView *view = [container hitTest:location withEvent:nil];
	if(view != nil && view != container) {
		NSAssert([view isKindOfClass:[BubbleLabelView class]], @"Invalid hit result from labelContainerView");
		BubbleLabelView *labelView = (BubbleLabelView *)view;
		return labelView;
	}
	
	return nil;
}

- (NSArray *)keyPath {
	return [NSArray array];
}

- (CGRect)rectForBubbleAtKeyPath:(NSArray *)keyPath {
	BubbleView *bubbleView = [self bubbleViewForKeyPath:keyPath includeHiddenViews:NO allowParent:NO];
	if(bubbleView == nil) {
		return CGRectZero;
	}

	CGRect localBounds = [self convertRect:bubbleView.bounds fromView:bubbleView];
	return localBounds;
}


#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	NSLog(@"1: %@  /  2: %@\n",gestureRecognizer.class,otherGestureRecognizer.class);
	return YES;
}

#pragma mark LabelContainer

- (void)addLabelView:(BubbleLabelView *)labelView {
	if(labelView.owner.bubble.type == BubbleTypeDefault) {
		[labelContainerView addSubview:labelView];
	}
	else {
		[topmostLabelContainerView addSubview:labelView];
	}
}

- (CGPoint)labelPointFromPoint:(CGPoint)point inView:(UIView *)view {
	CGPoint inMainView = [self convertPoint:point fromView:view];
	CGPoint inLabelContainer = [self convertPoint:inMainView toView:labelContainerView];
	return inLabelContainer;
}

#pragma mark - Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if([self hadRecentTap]) {
		NSLog(@"Ignoring touch due to recent tap");
		return;
	}
	
	if(ignoreNextTap || [[event allTouches] count] != 1) {
		[self cancelBubbleHighlight];
		return;
	}
	
	UITouch *touch = [touches anyObject];
	[self startHighlightingBubbleAtLocation:[touch locationInView:self]];
}

- (BOOL)hadRecentTap {
	if(self.lastTapDate == nil) {
		return NO;
	}
	
	return [self.lastTapDate timeIntervalSinceNow] >= -kRecenTapInterval;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}


@end
