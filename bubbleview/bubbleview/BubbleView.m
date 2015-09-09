#import "BubbleView.h"

#import <QuartzCore/QuartzCore.h>

#import "Bubble.h"
#import "BubbleDataSource.h"
#import "BubbleGlowView.h"
#import "BubbleLabelView.h"
#import "BubbleViewFactory.h"
#import "BVRimAnimationView.h"
#import "Faulter.h"
#import "LabelContainer.h"

#define kCoverAngle -M_PI / 20.0
#define kCoverOffset -30

static NSString *kAnimationKey = @"transform";
static const NSTimeInterval kBubbleMoveAnimationTime = 0.5;

@interface BubbleView ()

@property (nonatomic, strong) BVRimAnimationView *rimAnimationView;
@property (nonatomic, strong, readwrite) NSArray *keyPath;

@end

@implementation BubbleView {
	@private
	id<LabelContainer> labelContainer;
	CGPoint centerOffset;
	
	CGFloat minimumSizeToShowChildren;
	CGFloat minimumSizeToShowLabel;
	CGFloat maximumSizeToShowLabel;
	CGFloat maximumSizeToShowBackground;
	CGFloat minimumSizeToShowCover;
	CGFloat fadeSize;
	
	CGSize coverSize;
	
	Faulter *backgroundFaulter;
	Faulter *labelFaulter;
	Faulter *coverFaulter;
	
	BVRimAnimationView *rimAnimationView;
}

- (id)initWithViewFactory:(BubbleViewFactory *)theViewFactory dataSource:(id<BubbleDataSource>)theDataSource labelContainer:(id<LabelContainer>)theLabelContainer sizeToShowChildren:(CGFloat)theSizeToShowChildren sizeToShowTitle:(CGFloat)theSizeToShowTitle fadeSize:(CGFloat)theFadeSize coverSize:(CGSize)theCoverSize {
    self = [super initWithViewFactory:theViewFactory dataSource:theDataSource];
    if (self) {
		labelContainer = theLabelContainer;
		minimumSizeToShowChildren = theSizeToShowChildren;
		minimumSizeToShowLabel = theSizeToShowTitle;
		fadeSize = theFadeSize;
		maximumSizeToShowLabel = minimumSizeToShowChildren + fadeSize;
		minimumSizeToShowCover = 120;
		maximumSizeToShowBackground = minimumSizeToShowChildren + fadeSize;
		coverSize = theCoverSize;

		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
	[self releaseSubviews];
	NSLog(@"releasing %@\n", self);
}

- (void)setCenter:(CGPoint)newCenter {
	[super setCenter:newCenter];
	[self updateLabelCenter];
	[self updateCoverCenter];
}

- (void)setAlpha:(CGFloat)alpha {
	[super setAlpha:alpha];
	[self layoutLabelView];
}

- (void)didMoveToSuperview {
	[super didMoveToSuperview];	
	if(self.superview == nil) {
		return;
	}

	[self layoutLabelView];
}

@synthesize bubble;
@synthesize keyPath;
@synthesize rimAnimationView;
- (void)setRimAnimationView:(BVRimAnimationView *)newRimAnimationView {
	if(rimAnimationView == newRimAnimationView) {
		return;
	}
	[rimAnimationView removeFromSuperview];
	[self.viewFactory enqueueRimAnimationView:rimAnimationView];
	rimAnimationView = newRimAnimationView;
}

- (void)setBubble:(Bubble *)newBubble withKeyPath:(NSArray *)newKeyPath {
	if(keyPath != newKeyPath) {
		keyPath = newKeyPath;
	}
	
	if(bubble == newBubble) {
		return;
	}

	bubble = [newBubble copy];
	
	if(bubble == nil) {
		return;
	}

	self.alpha = 1.0;
	[self updateViewCenter];
	[self updateViewBounds];
}

- (void)updateBubble:(Bubble *)newBubble {
	NSAssert([bubble.key isEqual:newBubble.key], @"newBubble must have same key");
	UIColor *oldColor = bubble.color;
	UIImage *oldIcon = bubble.icon;
	bubble = [newBubble copy];
	if(bubble.color != oldColor) {
		backgroundFaulter = nil;
		labelFaulter = nil;
	}
	if(bubble.icon != oldIcon) {
		labelFaulter = nil;
	}
	[UIView animateWithDuration:kBubbleMoveAnimationTime animations:^{
		[self updateViewCenter];
		[self updateViewBounds];
	}];
}

- (void)removeBubbleAtKeyPath:(NSArray *)aKeyPath {
	[self reloadBubble];
	[super removeBubbleAtKeyPath:aKeyPath];
}

- (void)reloadChildrenAtKeyPath:(NSArray *)aKeyPath {
	[self reloadBubble];
	[super reloadChildrenAtKeyPath:aKeyPath];
}

- (void)reloadBubble {
	[self updateBubble:[self.dataSource bubbleForKeyPath:[self keyPath]]];
}

- (void)willBeEnqueuedToCache {
	[super willBeEnqueuedToCache];
	[self releaseSubviews];
}

- (void)releaseSubviews {
	backgroundFaulter = nil;
	labelFaulter = nil;
	coverFaulter = nil;
	self.rimAnimationView = nil;
}

- (void)willBecomeHidden {
	[self hideLabelView];
}

- (void)willBecomeVisible {
	[self layoutInnerViews];
}

- (void)didAddChildViews {
	[self layoutInnerViews];
	
	[super didAddChildViews];
}

- (void)handleZoomScaleChange {
	[self updateViewCenter];
	[self updateViewBounds];
	[super handleZoomScaleChange];
}

- (void)updateViewCenter {
	self.center = CGPointMake(centerOffset.x + self.bubble.origin.x * self.zoomScale,
							  centerOffset.y + self.bubble.origin.y * self.zoomScale);
	[self updateLabelCenter];
	[self updateCoverCenter];
}

- (void)updateViewBounds {
	if(self.bubble == nil) {
		return;
	}

	CGSize bubbleSize = CGSizeMake(2 * self.bubble.radius, 2 * self.bubble.radius);
	
	CGSize scaledBubbleSize = CGSizeMake(bubbleSize.width * self.zoomScale, bubbleSize.height * self.zoomScale);
	
	CGRect viewBounds = self.bounds;
	viewBounds.size = scaledBubbleSize;
	self.bounds = CGRectIntegral(viewBounds);

	CGPoint boundsCenter = CGPointMake(viewBounds.origin.x + viewBounds.size.width * 0.5,
									   viewBounds.origin.y + viewBounds.size.height * 0.5);
	[self setChildrenCenterOffset:boundsCenter];
	
	if(self.hidden == NO) {
		[self layoutInnerViews];
	}
}

- (void)layoutInnerViews {
	[super layoutInnerViews];
	[self layoutBubbleBackground];
	[self layoutCoverView];
	[self layoutLabelView];
}	

- (void)layoutBubbleBackground {
	if([self shouldHideBackground]) {
		[backgroundFaulter allowFaulting];
		if([backgroundFaulter isFault] == NO) {
			[backgroundFaulter.element setHidden:YES];
			[self glowSubview].hidden = YES;
			rimAnimationView.hidden = YES;
		}
		return;
	}
	
	[self createBubbleBackgroundIfNeeded];
	[self addRimAnimationViewIfNeeded];

	CGFloat alpha = [self backgroundAlpha];
	[self adjustSubview:backgroundFaulter.element withAlpha:alpha];
	[self adjustSubview:[self glowSubview] withAlpha:alpha];
	[self adjustSubview:self.rimAnimationView withAlpha:alpha];
}

- (BOOL)shouldHideBackground {
	if([self hasChildViews] == NO) {
		return NO;
	}

	return CGRectGetWidth(self.bounds) > maximumSizeToShowBackground;
}

- (CGFloat)backgroundAlpha {
	if([self hasChildViews] == NO) {
		return 1.0;
	}

	return [self fadingAlphaUntilMaximum:maximumSizeToShowBackground];
}

- (void)createBubbleBackgroundIfNeeded {
	if(backgroundFaulter != nil) {
		return;
	}
	
	RealizeBlock realizeBlock = ^id(void) {
		UIView<CacheableView> *backgroundView = [self.viewFactory dequeueBackgroundViewForBubble:self.bubble];
		[self addSubview:backgroundView];
		return backgroundView;
	};
	FaultBlock faultBlock = ^(id element) {
		UIView<CacheableView> *backgroundView = element;
		[backgroundView removeFromSuperview];
		[self.viewFactory enqueueBackgroundView:backgroundView forBubble:self.bubble];
	};

	backgroundFaulter = [[Faulter alloc] initWithRealizeBlock:realizeBlock faultBlock:faultBlock];
}

- (void)addRimAnimationViewIfNeeded {
	if(self.rimAnimationView != nil && self.rimAnimationView.superview != self) {
		[self insertSubview:self.rimAnimationView aboveSubview:backgroundFaulter.element];
	}
}

- (void)adjustSubview:(UIView *)subview withAlpha:(CGFloat)alpha {
	subview.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
	subview.bounds = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
	subview.alpha = alpha;
	subview.hidden = NO;
}

- (void)layoutLabelView {
	if([self shouldHideLabelView]) {
		[self hideLabelView];
		return;
	}

	[self createLabelViewIfNeeded];
	BubbleLabelView *labelView = labelFaulter.element;
	labelView.hidden = NO;
	labelView.alpha = fminf([self labelAlpha], self.alpha);

	[self updateLabelCenter];
}

- (BOOL)shouldHideLabelView {
	if(self.superview == nil) {
		return YES;
	}

	if ([self isTopLayer]) {
		return NO;
	}
	
	CGFloat width = CGRectGetWidth(self.bounds);
	if(width < minimumSizeToShowLabel) {
		return YES;
	}

	if([self hasChildViews] == NO) {
		return NO;
	}

	return width > maximumSizeToShowLabel;
}

- (BOOL)isTopLayer {
	return [[self keyPath] count] == 1;
}

- (void)hideLabelView {
	[labelFaulter allowFaulting];
	if([labelFaulter isFault] == NO) {
		[labelFaulter.element setHidden:YES];
	}
}

- (void)createLabelViewIfNeeded {
	if(labelFaulter != nil) {
		return;
	}
	
	RealizeBlock realizeBlock = ^id(void) {
		BubbleLabelView *labelView = [self.viewFactory dequeueLabelViewForBubble:self.bubble];
		labelView.owner = self;
		[labelContainer addLabelView:labelView];
		return labelView;
	};
	FaultBlock faultBlock = ^(id element) {
		BubbleLabelView *labelView = element;
		[labelView removeFromSuperview];
		[self.viewFactory enqueueLabelView:labelView];
	};

	labelFaulter = [[Faulter alloc] initWithRealizeBlock:realizeBlock faultBlock:faultBlock];
}

- (CGFloat)labelAlpha {
	if([self hasChildViews] == NO) {
		return 1.0;
	}

	return [self fadingAlphaUntilMaximum:maximumSizeToShowLabel];
}

- (void)updateLabelCenter {
	if(labelFaulter == nil || [labelFaulter couldBecomeFault] || self.superview == nil) {
		return;
	}

	CGPoint labelCenterInLabelContainer = [labelContainer labelPointFromPoint:self.center inView:self.superview];

	BubbleLabelView *labelView = labelFaulter.element;
	labelView.center = labelCenterInLabelContainer;
}

- (void)layoutCoverView {
	if([self shouldHideCoverView]) {
		[coverFaulter allowFaulting];
		if([coverFaulter isFault] == NO) {
			[coverFaulter.element setHidden:YES];
		}
		
		return;
	}

	[self createCoverViewIfNeeded];
	UIImageView	*coverView = coverFaulter.element;
	if(coverView.image == nil) {
		coverView.image = [self.dataSource coverForKeyPath:[self keyPath]];
	}

	coverView.hidden = NO;
	coverView.alpha = [self coverAlpha];

	[self updateCoverCenter];
}

- (BOOL)shouldHideCoverView {
	if(self.bubble.mayHaveCover == NO) {
		return YES;
	}
	
	if(CGRectGetWidth(self.bounds) < minimumSizeToShowCover) {
		return YES;
	};
	
	return [self shouldHideBackground];
}

- (void)createCoverViewIfNeeded {
	if(coverFaulter != nil) {
		return;
	}

	RealizeBlock realizeBlock = ^id(void) {
		UIImage *cover = [self.dataSource coverForKeyPath:[self keyPath]];
		UIImageView *coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, coverSize.width*3.0f, coverSize.height)];
        coverView.image = cover;
        coverView.contentMode = UIViewContentModeScaleAspectFit;
        coverView.transform = CGAffineTransformMakeRotation(kCoverAngle);
		[self addSubview:coverView];
		return coverView;
	};
	FaultBlock faultBlock = ^(id element) {
		UIImageView *coverView = element;
		[coverView removeFromSuperview];
	};

	coverFaulter = [[Faulter alloc] initWithRealizeBlock:realizeBlock faultBlock:faultBlock];
}

- (CGFloat)coverAlpha {
	return fminf([self fadingAlphaFromMinimum:minimumSizeToShowCover],
				 [self backgroundAlpha]);
}

- (void)updateCoverCenter {
	if(coverFaulter == nil || [coverFaulter couldBecomeFault]) {
		return;
	}

	UIImageView	*coverView = coverFaulter.element;
	coverView.center = CGPointMake(CGRectGetMidX(self.bounds),
								   CGRectGetMidY(self.bounds) + kCoverOffset);
}

- (BOOL)shouldShowChildren {
	return [self.bubble isLeaf] == NO &&
		CGRectGetWidth(self.bounds) > minimumSizeToShowChildren;
}

- (void)setChildZoomScale:(BubbleView *)view {
	[super setChildZoomScale:view];

	view.center = CGPointMake(self.bounds.size.width * 0.5 + view.bubble.origin.x * self.zoomScale,
							  self.bounds.size.height * 0.5 + view.bubble.origin.y * self.zoomScale);
	view.alpha = [self childAlpha];
}
				  
- (CGFloat)childAlpha {
	return [self fadingAlphaFromMinimum:minimumSizeToShowChildren];
}

- (CGFloat)fadingAlphaFromMinimum:(CGFloat)minimum {
	CGFloat fadingEnd = minimum + fadeSize;
	CGFloat size = CGRectGetWidth(self.bounds);
	return [self fadingAlphaForDelta:fadingEnd - size];
}

- (CGFloat)fadingAlphaUntilMaximum:(CGFloat)maximum {
	CGFloat fadingStart = maximum - fadeSize;
	CGFloat size = CGRectGetWidth(self.bounds);
	return [self fadingAlphaForDelta:size - fadingStart];
}

- (CGFloat)fadingAlphaForDelta:(CGFloat)delta {
	if(delta < 0) {
		return 1.0;
	}

	return 1.0 - delta / fadeSize;
}

- (BubbleView *)bubbleViewForLocation:(CGPoint)location {
	if([self isInCircle:location] == NO) {
		return nil;
	}

	BubbleView *hitView = [super bubbleViewForLocation:location];

	if(hitView == nil && [self shouldHideBackground] == NO) {
		hitView = self;
	}

	return hitView;
}

- (BOOL)isInCircle:(CGPoint)location {
	CGFloat radius = self.bounds.size.width * 0.5;
	CGFloat deltaX = location.x - radius;
	CGFloat deltaY = location.y - radius;
	CGFloat distance = sqrt(deltaX * deltaX + deltaY * deltaY);
	return distance < radius;
}

- (BubbleView *)bubbleViewForKeyPath:(NSArray *)aKeyPath includeHiddenViews:(BOOL)includeHiddenViews allowParent:(BOOL)allowParent {
	if([aKeyPath count] == 0) {
		return self;
	}
	
	BubbleView *matchingChild = [super bubbleViewForKeyPath:aKeyPath includeHiddenViews:includeHiddenViews allowParent:allowParent];
	if(matchingChild == nil && allowParent) {
		return self;
	}

	return matchingChild;
}

- (void)setCenterOffset:(CGPoint)offset {
	centerOffset = offset;
	[self updateViewCenter];
}

- (void)showGlow {
	BubbleGlowView *glowView = [self.viewFactory glowView];
	[self adjustSubview:glowView withAlpha:[self backgroundAlpha]];
	[self addSubview:glowView];
	[glowView startTouchAnimation];
}

- (void)fadeOutGlow {
	[[self glowSubview] endTouchAnimation];
}

- (void)cancelGlow {
	[[self glowSubview] detatchFromCurrentBubble];
}

- (BubbleGlowView *)glowSubview {
	for (id view in self.subviews) {
		if ([view isKindOfClass:[BubbleGlowView class]]) {
			return view;
		}
	}
	
	return nil;
}

- (void)setRimAnimationState:(BVRimAnimationState)state offset:(NSTimeInterval)offset {
	if(self.rimAnimationView == nil) {
		self.rimAnimationView = [self.viewFactory dequeueRimAnimationView];
		[self layoutBubbleBackground];
	}

	[self.rimAnimationView setRimAnimationState:state offset:offset];
}

- (void)removeRimAnimation {
	self.rimAnimationView = nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Bubble View with %@",
			[self.bubble description]];
}

- (CAAnimation *)layerAnimation {
	return [self.layer animationForKey:kAnimationKey];
}

- (void)startBounceAnimation {
	CAKeyframeAnimation *theAnimation = [CAKeyframeAnimation animation];
	theAnimation.values = [NSArray arrayWithObjects:
						   [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
						   nil];
	theAnimation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.7], [NSNumber numberWithFloat:1.0], nil];
	
	theAnimation.cumulative = NO;
	theAnimation.duration = 0.2333333;
	theAnimation.repeatCount = 1;
	theAnimation.removedOnCompletion = YES;
	
	[self.layer addAnimation:theAnimation forKey:kAnimationKey];
}

- (void)showShadow {
	self.layer.shadowColor = [[UIColor whiteColor] CGColor];
	self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
	self.layer.shadowOpacity = 1.0f;
	self.layer.shadowRadius = 3.0f;	
}

- (void)hideShadow {
	self.layer.shadowOpacity = 0.0f;
}

@end
