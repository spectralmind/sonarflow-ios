#import "BubbleHierarchyView+Private.h"
#import "BubbleView.h"
#import "Bubble.h"
#import "BubbleViewFactory.h"
#import "MainViewDelegate.h"
#import "BVRimAnimationView.h"
#import "BVRimAnimationController.h"
#import "NSString+CGLogging.h"
#import "DiscoveryZoneMember.h"
#import "DiscoveryZoneMember+Private.h"
#import "DiscoveryZone.h"

#define kMinimumTopInset    5
#define kMinimumLeftInset   15
#define kMinimumBottomInset 5
#define kMinimumRightInset  15

typedef void (^VoidBlock) ();

//Adds a layer of indirection between the BubbleViews and the real data source.
//Needed to avoid having to change the dataSource value of all BubbleViews whenever the dataSource changes
//Also used to update the zoom level for the view whenever bubbles are added.
@interface DataSourceProxy : NSObject <BubbleDataSource> {
@private
	id<BubbleDataSource> __weak dataSource;
	BubbleHierarchyView *view;
}

- (id)initWithView:(BubbleHierarchyView *)aView;

@property (nonatomic, weak) id<BubbleDataSource> dataSource;

@end

@implementation DataSourceProxy

- (id)initWithView:(BubbleHierarchyView *)aView {
    self = [super init];
    if (self) {
		view = aView;
    }
    return self;
}

@synthesize dataSource;

- (UIImage *)coverForKeyPath:(NSArray *)keyPath {
	return [dataSource coverForKeyPath:keyPath];
}

- (NSArray *)childrenForKeyPath:(NSArray *)keyPath {
	NSArray *children = [dataSource childrenForKeyPath:keyPath];
	for(Bubble *child in children) {
		[view adjustScaleForBubble:child];
	}
	
	return children;
}

- (Bubble *)bubbleForKeyPath:(NSArray *)keyPath {
	Bubble *bubble = [dataSource bubbleForKeyPath:keyPath];
	[view adjustScaleForBubble:bubble];
	return bubble;
}

@end

@interface BubbleHierarchyView()
@property (nonatomic, strong) 	NSSet *discoveryZone;
@end

@implementation BubbleHierarchyView {
	@private
	BubbleViewFactory *viewFactory;
	BubbleMainView *bubbleMainView;
	MainViewDelegate *mainViewDelegate;
	DataSourceProxy *dataSourceProxy;
	BVRimAnimationController *rimAnimationController;
	
	UIEdgeInsets bubbleContentInsets;
	UIEdgeInsets tempNonjumpInset;
	UIEdgeInsets centerInset;
	CGFloat requiredMaxZoomScale;
	CGFloat requiredMinZoomScale;
	BOOL requiredMinZoomScaleValid;
	
	id<BubbleHierarchyViewDelegate> __weak bubbleDelegate;
	BOOL discoveryEnabled;
	BubbleViewCheckBlock bubbleCheck;
	NSSet *discoveryZone;
	BOOL discoveryVisualUpdateInProgress;
	__weak NSTimer *zoomTimer;
	NSUInteger zoomTimerCount;
	BOOL zoomDemoInProgress;
	CGFloat zoomDemoOutZoomScale;
	CGFloat zoomDemoInZoomScale;
}

- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
		[self initBubbleHierarchyView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

	[self initBubbleHierarchyView];
}

- (void)initBubbleHierarchyView {
	self.delegate = self;
	self.requiredMinZoomScale = INFINITY;
	requiredMinZoomScaleValid = NO;
	self.requiredMaxZoomScale = 1;

	mainViewDelegate = [[MainViewDelegate alloc] initWithView:self];
	
	rimAnimationController = [[BVRimAnimationController alloc] init];
	
	viewFactory = [BubbleViewFactory newDefaultFactory];
	dataSourceProxy = [[DataSourceProxy alloc] initWithView:self];
	viewFactory.dataSource = dataSourceProxy;
	viewFactory.rimAnimationController = rimAnimationController;
	bubbleMainView = [[BubbleMainView alloc] initWithViewFactory:viewFactory dataSource:dataSourceProxy];
	bubbleMainView.delegate = mainViewDelegate;
	viewFactory.labelContainer = self.bubbleMainView;
	rimAnimationController.delegate = self.bubbleMainView;
	
	[self addSubview:bubbleMainView];
	[self insertSubview:self.bubbleMainView.zoomableView aboveSubview:self.bubbleMainView];
	
	[self setScrollsToTop:NO];

	[self calculatePaddingAndZoomLimits];
	[self synchronizeZoomScale];
	
	[self createGestureRecognizers];
}

@synthesize discoveryZone;


- (void)calculatePaddingAndZoomLimits {
	[self updateContentSize];
	[self updatePaddingInset];
}

- (void)updateContentSize {
	CGSize newSize = self.bubbleMainView.bounds.size;
	self.contentSize = newSize;	
	[self calculateZoomLimits];
}

- (void)calculateZoomLimits { 
    CGSize contentSize = self.bubbleMainView.zoomableView.bounds.size;
	if(contentSize.width < 0.01 || contentSize.height < 0.01) {
		return;
	}
	
    CGSize boundsSize = self.bounds.size;
	UIEdgeInsets insets = [self summedInsets];
    CGFloat minXScale = (boundsSize.width - (insets.left + insets.right)) / contentSize.width;
    CGFloat minYScale = (boundsSize.height - (insets.top + insets.bottom)) / contentSize.height;
    CGFloat minScale = fminf(minXScale, minYScale);
	if(requiredMinZoomScaleValid) {
		minScale = fminf(minScale, self.requiredMinZoomScale);
	}
	
    CGFloat maxScale = self.requiredMaxZoomScale;

    if (minScale > maxScale) {
        maxScale = minScale;
    }
	
    self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	
	if([self isNotInteracting]) {
		if(self.zoomScale < minScale) {
			self.zoomScale = minScale;
		}
		else if(self.zoomScale > maxScale) {
			self.zoomScale = maxScale;
		}
	}
}

- (BOOL)isNotInteracting {
	return ([self isTracking] || [self isZooming] || [self isZoomBouncing]) == NO;
}

- (void)synchronizeZoomScale {
	[self.bubbleMainView setZoomScale:self.zoomScale];
}

- (UIEdgeInsets)summedInsets {
	UIEdgeInsets sum = UIEdgeInsetsMake(self.bubbleContentInsets.top    + fmaxf(tempNonjumpInset.top,    kMinimumTopInset),
										self.bubbleContentInsets.left   + fmaxf(tempNonjumpInset.left,   kMinimumLeftInset),
										self.bubbleContentInsets.bottom + fmaxf(tempNonjumpInset.bottom, kMinimumBottomInset),
										self.bubbleContentInsets.right  + fmaxf(tempNonjumpInset.right,  kMinimumRightInset));
	return sum;
}

- (void)setToolbarInset:(UIEdgeInsets)insets {
	tempNonjumpInset = UIEdgeInsetsZero;
	UIEdgeInsets summedInsets = [self summedInsets];
	tempNonjumpInset.top = fmaxf(0, summedInsets.top - insets.top);
	tempNonjumpInset.left = fmaxf(0, summedInsets.left - insets.left);
	tempNonjumpInset.bottom = fmaxf(0, summedInsets.bottom - insets.bottom);
	tempNonjumpInset.right = fmaxf(0, summedInsets.right - insets.right);
	
	bubbleContentInsets = insets;
	[self calculatePaddingAndZoomLimits];
}

- (void)updatePaddingInset {
	CGSize mainviewSize = self.bubbleMainView.zoomableView.bounds.size;

	if (CGSizeEqualToSize(mainviewSize, CGSizeZero)) {
		self.contentInset = UIEdgeInsetsZero;
		return;
	}
	
	UIEdgeInsets insets = [self summedInsets];
	CGSize bubbleContainerAreaSize = CGSizeMake(self.frame.size.width - (insets.left + insets.right),
												self.frame.size.height - (insets.top + insets.bottom));
	CGSize zoomedOutContentSize = CGSizeMake(mainviewSize.width * self.minimumZoomScale, mainviewSize.height * self.minimumZoomScale);
	
	CGFloat horizontalOffset = fmaxf(0, (bubbleContainerAreaSize.width - zoomedOutContentSize.width) / 2);
	CGFloat verticalOffset = fmaxf(0, (bubbleContainerAreaSize.height - zoomedOutContentSize.height) / 2);
	
	centerInset = UIEdgeInsetsMake(verticalOffset, horizontalOffset, verticalOffset, horizontalOffset);
	
	[self calcAndSetPaddingInset];
}

@synthesize discoveryZoneCenterOffset;
- (void)setDiscoveryZoneCenterOffset:(CGPoint)newDiscoveryZoneCenterOffset {
	discoveryZoneCenterOffset = newDiscoveryZoneCenterOffset;
	[self calcAndSetPaddingInset];
	
	if(discoveryEnabled) {
		[self updateDiscoveryZoneWithOffset:self.contentOffset];	
	}
}

- (void)calcAndSetPaddingInset {
	UIEdgeInsets insets = [self summedInsets];
	
	insets.bottom = fmaxf(insets.bottom + centerInset.bottom, self.bounds.size.height * 0.5 + discoveryZoneCenterOffset.y);
	insets.left = fmaxf(insets.left + centerInset.left, self.bounds.size.width * 0.5 + discoveryZoneCenterOffset.x);
	insets.right =  fmaxf(insets.right + centerInset.right, self.bounds.size.width * 0.5 - discoveryZoneCenterOffset.x);
	insets.top =  fmaxf(insets.top + centerInset.top, self.bounds.size.height * 0.5 - discoveryZoneCenterOffset.y);
	
	self.contentInset = insets;
}

@synthesize bubbleCheck;
@synthesize bubbleMainView;
@synthesize requiredMaxZoomScale;
@synthesize requiredMinZoomScale;

- (CGFloat)minimumBubbleSizeForParent {
	return [self bubbleScreenSizeToShowChildren] + [self bubbleFadeSize];

}

- (CGFloat)minimumBubbleSizeForLeaf {
	return [self bubbleScreenSizeToShowTitle] * 2.0f;
}

- (void)setResources:(BVResources *)resources {
	viewFactory.resources = resources;
}

- (BVResources *)resources {
	return viewFactory.resources;
}

- (void)setBubbleTextFont:(UIFont *)bubbleTextFont {
	self.bubbleMainView.viewFactory.font = bubbleTextFont;
}

- (UIFont *)bubbleTextFont {
	return self.bubbleMainView.viewFactory.font;
}

- (void)setBubbleCountFont:(UIFont *)bubbleCountFont {
	self.bubbleMainView.viewFactory.labelCountFont = bubbleCountFont;
}

- (UIFont *)bubbleCountFont {
	return self.bubbleMainView.viewFactory.labelCountFont;
}

- (void)setBubbleScreenSizeToShowChildren:(CGFloat)bubbleScreenSizeToShowChildren {
	self.bubbleMainView.viewFactory.bubbleScreenSizeToShowChildren = bubbleScreenSizeToShowChildren;
}

- (CGFloat)bubbleScreenSizeToShowChildren {
	return self.bubbleMainView.viewFactory.bubbleScreenSizeToShowChildren;
}

- (void)setBubbleScreenSizeToShowTitle:(CGFloat)bubbleScreenSizeToShowTitle {
	self.bubbleMainView.viewFactory.bubbleScreenSizeToShowTitle = bubbleScreenSizeToShowTitle;
}

- (CGFloat)bubbleScreenSizeToShowTitle {
	return self.bubbleMainView.viewFactory.bubbleScreenSizeToShowTitle;
}

- (void)setBubbleFadeSize:(CGFloat)bubbleFadeSize {
	self.bubbleMainView.viewFactory.bubbleFadeSize = bubbleFadeSize;
}

- (CGFloat)bubbleFadeSize {
	return self.bubbleMainView.viewFactory.bubbleFadeSize;
}

- (void)setCoverSize:(CGSize)coverSize {
	self.bubbleMainView.viewFactory.coverSize = coverSize;
}

- (CGSize)coverSize {
	return self.bubbleMainView.viewFactory.coverSize;
}

- (void)setShowCountLabel:(BOOL)showCountLabel {
	self.bubbleMainView.viewFactory.showCountLabel = showCountLabel;
}

- (BOOL)showCountLabel {
	return self.bubbleMainView.viewFactory.showCountLabel;
}

@synthesize bubbleContentInsets;
@synthesize bubbleDelegate;
- (void)setBubbleDataSource:(id<BubbleDataSource>)bubbleDataSource {
	dataSourceProxy.dataSource = bubbleDataSource;
}

- (id<BubbleDataSource>)bubbleDataSource {
	return dataSourceProxy.dataSource;
}

- (void)adjustScaleForBubble:(Bubble *)bubble {
	CGFloat requiredScale;
	if(bubble.isLeaf) {
		requiredScale = self.minimumBubbleSizeForLeaf / (bubble.radius * 2);
	}
	else {
		requiredScale = self.minimumBubbleSizeForParent / (bubble.radius * 2);
	}
	self.requiredMaxZoomScale = fmaxf(self.requiredMaxZoomScale, requiredScale);

	CGFloat newMinScale = self.bubbleScreenSizeToShowChildren / (bubble.radius * 2);
	self.requiredMinZoomScale = fminf(self.requiredMinZoomScale, newMinScale);
	requiredMinZoomScaleValid = YES;

	[self calculateZoomLimits];
}

- (void)updateBubbleViewVisibility {
	CGRect visibleRect = [self.bubbleMainView convertRect:self.bounds fromView:self];
	[self.bubbleMainView updateVisibilityForRect:visibleRect];
}

- (void)removeBubbleAtKeyPath:(NSArray *)keyPath; {
	[self performBoundsChangingOperation:^{
		[self.bubbleMainView removeBubbleAtKeyPath:keyPath];
	}];
}

- (void)reloadChildrenAtKeyPath:(NSArray *)keyPath {
	[self performBoundsChangingOperation:^{
		[self.bubbleMainView reloadChildrenAtKeyPath:keyPath];
	}];
}

- (void)reloadBubbleAtKeyPath:(NSArray *)keyPath {
	[self performBoundsChangingOperation:^{
		[self.bubbleMainView reloadBubbleAtKeyPath:keyPath];
	}];
}

- (void)performBoundsChangingOperation:(VoidBlock)block {
	CGPoint oldZero = [self.bubbleMainView.zoomableView convertPoint:CGPointZero toView:self];
	
	block();
	
	[self calculatePaddingAndZoomLimits];
	[self updateBubbleViewVisibility];
	CGPoint newZero = [self.bubbleMainView.zoomableView  convertPoint:CGPointZero toView:self];
	
	CGPoint offset = CGPointMake(newZero.x - oldZero.x, newZero.y - oldZero.y);
	self.contentOffset = CGPointMake(self.contentOffset.x + offset.x, self.contentOffset.y + offset.y);
}

- (void)zoomOut {
	tempNonjumpInset = UIEdgeInsetsZero;
	[self calculatePaddingAndZoomLimits];

	CGSize viewSize = self.bounds.size;
	CGSize contentSize = self.bubbleMainView.zoomableView.bounds.size;
	CGFloat horizontalInsets = self.contentInset.left + self.contentInset.right;
	CGFloat verticalInsets = self.contentInset.top	+ self.contentInset.bottom;
	contentSize.width += horizontalInsets;
	contentSize.height += verticalInsets;

	CGFloat scale = fminf(viewSize.width / contentSize.width, viewSize.height / contentSize.height);
	CGRect targetRect;
	targetRect.size.width = (viewSize.width + horizontalInsets) / scale;
	targetRect.size.height = (viewSize.height + verticalInsets) / scale;
	targetRect.origin.x = CGRectGetMidX(self.bubbleMainView.zoomableView.bounds) - targetRect.size.width * 0.5;
	targetRect.origin.y = CGRectGetMidY(self.bubbleMainView.zoomableView.bounds) - targetRect.size.height * 0.5;
	[self zoomToRect:targetRect animated:YES];
}

- (void)zoomToBubbleAtKeyPath:(NSArray *)keyPath {
	if([keyPath count] == 0) {
		return;
	}

	BubbleView *trackView = [self.bubbleMainView bubbleViewForKeyPath:keyPath includeHiddenViews:YES allowParent:YES];
	[self zoomToSubview:trackView];
}

- (void)zoomToSubview:(UIView *)subview {
	if(subview == nil) {
		return;
	}

	CGRect rectInZoomableView = [self.bubbleMainView.zoomableView convertRect:subview.bounds fromView:subview];
	[self zoomToRect:rectInZoomableView animated:YES];
}

- (void)fadeOutBubbleHighlight {
	[self.bubbleMainView fadeOutBubbleHighlight];
}

- (void)startPlayingBubbleAtKeyPath:(NSArray *)keyPath {
	rimAnimationController.keyPath = keyPath;
	rimAnimationController.state = BVRimAnimationStatePlaying;
}

- (void)pausePlayingBubbleAtKeyPath:(NSArray *)keyPath {
	rimAnimationController.keyPath = keyPath;
	rimAnimationController.state = BVRimAnimationStatePaused;
}

- (void)setNothingPlaying {
	[viewFactory setCurrentlyPlayingKeypath:nil playStatePlaying:NO];
}

- (void)adjustUIAfterOrientation {
	[self calculatePaddingAndZoomLimits];
}

- (void)increaseZoomByFactor:(CGFloat)zoomFactor aroundBubbleLocation:(CGPoint)location {
	CGPoint targetLocation = [self.bubbleMainView.zoomableView convertPoint:location fromView:self.bubbleMainView];
	CGFloat targetZoomScale = self.zoomScale * zoomFactor;
	CGRect scrollRect = self.bounds;
	CGSize targetSize = CGSizeMake(scrollRect.size.width / targetZoomScale, scrollRect.size.height / targetZoomScale);
	CGRect targetRect = CGRectMake(targetLocation.x - targetSize.width * 0.5,
								   targetLocation.y - targetSize.height * 0.5,
								   targetSize.width, targetSize.height);
	
	[self zoomToRect:targetRect animated:YES];
}

static const CGFloat zoomInDepth = 0.6;
static const CGFloat zoomInFPS = 30;
static const NSTimeInterval zoomInLength = 1.5;

- (void)zoomInDemo {
	zoomDemoInProgress = YES;
	zoomTimerCount = 0;
	zoomDemoOutZoomScale = self.zoomScale;
	zoomDemoInZoomScale = self.zoomScale + zoomInDepth;
	zoomTimer = [NSTimer scheduledTimerWithTimeInterval:1/zoomInFPS target:self selector:@selector(zoomInTimerFired:) userInfo:nil repeats:YES];
}

- (void)zoomInTimerFired:(NSTimer *)timer {
	if (++zoomTimerCount >= zoomInFPS*zoomInLength) {
		[zoomTimer invalidate];
		zoomTimerCount = 0;
		zoomTimer = [NSTimer scheduledTimerWithTimeInterval:1/zoomInFPS target:self selector:@selector(zoomOutTimerFired:) userInfo:nil repeats:YES];
		return;
	}
	self.zoomScale = [self easeInOutQuintWithCurrentFrame:zoomTimerCount totalFrames:zoomInFPS*zoomInLength startValue:zoomDemoOutZoomScale endValue:zoomDemoInZoomScale];
}

- (void)zoomOutTimerFired:(NSTimer *)timer {
	if (++zoomTimerCount >= zoomInFPS*zoomInLength) {
		[zoomTimer invalidate];
		zoomDemoInProgress = NO;
		return;
	}
	self.zoomScale = [self easeInOutQuintWithCurrentFrame:zoomTimerCount totalFrames:zoomInFPS*zoomInLength startValue:zoomDemoInZoomScale endValue:zoomDemoOutZoomScale];
}

- (void)abortZoomInDemo {
	[zoomTimer invalidate];
}

- (CGFloat)easeInOutQuintWithCurrentFrame:(NSUInteger)currentFrame totalFrames:(NSUInteger)totalFrames startValue:(CGFloat)startValue endValue:(CGFloat)endValue {
	CGFloat t = (CGFloat)currentFrame / (CGFloat)totalFrames;
	CGFloat ts = t*t;
	CGFloat tc = ts*t;
	return startValue + (endValue-startValue)*(6*tc*ts - 15*ts*ts + 10*tc);
}

#pragma mark - UIGestureRecognizers
// TODO: Unify with BubbleMainView's gesture recognizers!

- (void)createGestureRecognizers {
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
										 initWithTarget:self
										 action:@selector(handleDoubleTap:)];
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
										 initWithTarget:self
										 action:@selector(handleSingleTap:)];
	[doubleTap setNumberOfTapsRequired:2];
    [singleTap requireGestureRecognizerToFail:doubleTap];
	
    [self addGestureRecognizer:doubleTap];
    [self addGestureRecognizer:singleTap];
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
	if(self.bubbleMainView.ignoreNextTap) {
		self.bubbleMainView.ignoreNextTap = NO;
		return;
	}
	
	CGPoint location = [gestureRecognizer locationInView:self.bubbleMainView];
	[mainViewDelegate tappedEmptyLocation:location];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
	CGPoint location = [gestureRecognizer locationInView:self.bubbleMainView];
	[mainViewDelegate doubleTappedEmptyLocation:location];
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.bubbleMainView.zoomableView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
	if (zoomDemoInProgress && ![self isNotInteracting]) {
		[self abortZoomInDemo];
	}
	
	[self.bubbleMainView cancelBubbleHighlight];
	[self synchronizeZoomScale];
	[self updateBubbleViewVisibility];	
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
	if (![self isNotInteracting]) {
		[bubbleDelegate userZoomed];
	}
	if(discoveryEnabled) {
		[bubbleDelegate updatedDiscoveryZone:nil];
	}
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
	if(!discoveryEnabled) {
		return;
	}
	
	if(scrollView.isDragging) {
		return;
	}
	
	[self updateDiscoveryZoneWithOffset:scrollView.contentOffset];	
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (zoomDemoInProgress && ![self isNotInteracting]) {
		[self abortZoomInDemo];
	}
	
	[self updateBubbleViewVisibility];
	
	if(discoveryEnabled && !discoveryVisualUpdateInProgress) {
		discoveryVisualUpdateInProgress = YES;
		[self performSelector:@selector(updateVisualFeedbackForDiscovery) withObject:self afterDelay:0 inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
	}
}

- (void)updateVisualFeedbackForDiscovery {
	DiscoveryZone *zone = [self buildDiscoveryZoneAtOffset:self.contentOffset];
	[self updateVisualFeedbackForDiscoveryZone:zone];
	discoveryVisualUpdateInProgress = NO;
}

- (void)updateVisualFeedbackForDiscoveryZone:(DiscoveryZone *)zone {

	NSSet *zoneMembers = [NSSet setWithArray:zone.members];
	NSMutableSet *newcomers = [NSMutableSet setWithArray:zone.members];
	NSMutableSet *dropouts = [NSMutableSet setWithSet:self.discoveryZone];
	
	[dropouts minusSet:newcomers];
	[newcomers minusSet:self.discoveryZone];
		
	for(DiscoveryZoneMember *member in dropouts) {
		[member.bubbleView hideShadow];
	}

	self.discoveryZone = zoneMembers;

	for(DiscoveryZoneMember *member in newcomers) {
		[member.bubbleView showShadow];
	}
}


#define kDiscoveryRadiusStart 10
#define kDiscoveryRadiusIncrement 42

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if(discoveryEnabled == NO) {
		return;
	}
	
	[self updateDiscoveryZoneWithOffset:scrollView.contentOffset];	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if(discoveryEnabled == NO || decelerate) {
		return;
	}
	
	[self updateDiscoveryZoneWithOffset:scrollView.contentOffset];	
	
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self.bubbleMainView cancelBubbleHighlight];
}

- (DiscoveryZone *)updateDiscoveryZoneWithOffset:(CGPoint)offset {
	
	if(!discoveryEnabled) {
		return nil;
	}
	
	NSLog(@"update zone");

	DiscoveryZone *zone =[self buildDiscoveryZoneAtOffset:offset];
	[self updateVisualFeedbackForDiscoveryZone:zone];
	[bubbleDelegate updatedDiscoveryZone:zone];
	
	return zone;
}

- (DiscoveryZone *)buildDiscoveryZoneAtOffset:(CGPoint)offset {
	DiscoveryZone *zone;

	zone = [self findBubblesNearCenterWithOffset:offset andRadius:self.frame.size.height/2];
	
	if(zone.members.count == 0) {
		return zone;
	}
	
	NSArray *sorting = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"distanceFromCenter" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"bubbleView.bubble.radius" ascending:YES], nil];
	
	NSArray *sorted = [zone.members sortedArrayUsingDescriptors:sorting];
	
	DiscoveryZoneMember *closestItem = [sorted objectAtIndex:0];
	NSMutableArray *result = [[NSMutableArray alloc] initWithObjects:closestItem, nil];
	zone.members = result;
	
	zone.radius = closestItem.distanceFromCenter;
	
	return zone;
}

- (DiscoveryZone *)findBubblesNearCenterWithOffset:(CGPoint)offset andRadius:(CGFloat)radius {
	CGPoint virtualCenter = self.center;
	virtualCenter.x += discoveryZoneCenterOffset.x;
	virtualCenter.y += discoveryZoneCenterOffset.y;

	virtualCenter.x += offset.x;
	virtualCenter.y += offset.y;
	
	CGPoint convertedCenter = [self.bubbleMainView convertPoint:virtualCenter fromView:self];
	
	NSArray *bubbles = [self.bubbleMainView visibleBubbleViewsInCircleAt:convertedCenter withRadius:radius satisfyingCheck:self.bubbleCheck];
	
	DiscoveryZone *zone = [[DiscoveryZone alloc] init];
	zone.members = bubbles;

	CGPoint center = [self convertPoint:virtualCenter toView:self.bubbleMainView.zoomableView];
	zone.center = center;
	zone.radius = radius;
	
	return zone;
}

- (void)discoveryMode:(BOOL)enabled {
	discoveryEnabled = enabled;	
	
	if(discoveryEnabled) {
		self.discoveryZone = [NSSet set];
		[self updateDiscoveryZoneWithOffset:self.contentOffset];
	}
	else {
		[self updateVisualFeedbackForDiscoveryZone:nil];
		[bubbleDelegate updatedDiscoveryZone:nil];
	}
	
	[self calcAndSetPaddingInset];
}

- (CGRect)rectForBubbleAtKeyPath:(NSArray *)keyPath {
	CGRect localRect = [self convertRect:[bubbleMainView rectForBubbleAtKeyPath:keyPath] fromView:self.bubbleMainView];
	return localRect;
}

@end
