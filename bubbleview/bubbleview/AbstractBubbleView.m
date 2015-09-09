#import "AbstractBubbleView.h"

#import "Bubble.h"
#import "BubbleDataSource.h"
#import "BubbleView.h"
#import "BubbleViewFactory.h"
#import "DiscoveryZoneMember.h"
#import "DiscoveryZoneMember+Private.h"
#import "Faulter.h"
#import "NSArray+KeyPath.h"
#import "NSString+CGLogging.h"

static const NSTimeInterval kRemoveBubbleAnimationDuration = 0.1;
static const NSTimeInterval kBubbleAppearDelayIncrement = 0.05;

@interface AbstractBubbleView ()

@end


@implementation AbstractBubbleView {
	@private
	NSMutableDictionary *childViewsByKey;
	NSMutableDictionary *childViewsAwaitingInsert;
	__weak NSTimer *childInsertTimer;
}


- (id)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithViewFactory:(BubbleViewFactory *)theViewFactory dataSource:(id<BubbleDataSource>) theDataSource {
    self = [super initWithFrame:CGRectZero];
    if (self) {
		viewFactory = theViewFactory;
		dataSource = theDataSource;
		[self initCommon];
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	[self initCommon];
}

- (void)initCommon {
}

- (void)dealloc {
	[self removeChildViews];
}

@synthesize viewFactory;
@synthesize dataSource;

@synthesize zoomScale;
- (void)setZoomScale:(CGFloat)newZoomScale {
	if(zoomScale != newZoomScale) {
		zoomScale = newZoomScale;
		[self handleZoomScaleChange];
	}
}

@synthesize childrenCenterOffset;
- (void)setChildrenCenterOffset:(CGPoint)offset {
	childrenCenterOffset = offset;
	for(id key in childViewsByKey) {
		BubbleView *view = [childViewsByKey objectForKey:key];
		[view setCenterOffset:offset];
	}
	for(id key in childViewsAwaitingInsert) {
		BubbleView *view = [childViewsAwaitingInsert objectForKey:key];
		[view setCenterOffset:offset];
	}
}

- (void)didMoveToSuperview {
	[super didMoveToSuperview];
	if(self.superview == nil) {
		return;
	}
	
	if(self.superview.hidden) {
		[self hide];
	}
	else {
		[self show];
	}
}

- (void)handleZoomScaleChange {
	[self setChildrenZoomScale];
}

- (void)setChildrenZoomScale {
	for(id key in childViewsByKey) {
		BubbleView *view = [childViewsByKey objectForKey:key];
		[self setChildZoomScale:view];
	}
	for(id key in childViewsAwaitingInsert) {
		BubbleView *view = [childViewsAwaitingInsert objectForKey:key];
		[self setChildZoomScale:view];
	}
}

- (void)setChildZoomScale:(BubbleView *)view {
	view.zoomScale = self.zoomScale;
}

- (void)reloadChildViews {
	if(self.hidden) {
		[self removeChildViews];
		return;
	}
	
	if([self shouldShowChildren]) {
		[self createChildViewsDelayed:YES];
	}
	
	[self layoutInnerViews];
}

- (void)layoutInnerViews {
}

- (BOOL)hasChildViews {
	return [childViewsByKey count] > 0 || [childViewsAwaitingInsert count] > 0;
}

- (void)updateVisibilityForRect:(CGRect)rect {
	if([self isPartOfRect:rect] == NO) {
		[self hide];
		return;
	}

	//Load child views before "show" as the view state depends on the presence of children
	if(childViewsByKey == nil && childViewsAwaitingInsert == nil && [self shouldShowChildren]) {
		[self createChildViewsDelayed:NO];
	}
	
	[self show];

	if([self shouldShowChildren] == NO) {
		[self removeChildViews];
		return;
	}
	
	[self updateVisibilityOfChildren:childViewsByKey forRect:rect];
	[self updateVisibilityOfChildren:childViewsAwaitingInsert forRect:rect];
}

- (void)updateVisibilityOfChildren:(NSDictionary *)children forRect:(CGRect)rect {
	for(id key in children) {
		//TODO: Fault child views that are not visible
		//		-> Need method to re-request single bubbles by key path!
		
		BubbleView *view = [children objectForKey:key];
		CGRect childRect = [self convertRect:rect toView:view];
		[view updateVisibilityForRect:childRect];
	}
}

- (void)hide {
	if(self.hidden == NO) {
		[self willBecomeHidden];
		self.hidden = YES;
	}
}

- (void)willBecomeHidden {
	[self removeChildViews];
}

- (void)show {
	if(self.hidden) {
		[self willBecomeVisible];
		self.hidden = NO;
	}
}

- (void)willBecomeVisible {
}

- (BOOL)isPartOfRect:(CGRect)rect {
	return CGRectIntersectsRect(self.bounds, rect);
}

- (void)createChildViewsDelayed:(BOOL)delayed {
	NSArray *childBubbles = [self childBubbles];
	if([childBubbles count] == 0) {
		[self removeChildViews];
		return;
	}
	
	[self removeOutdatedChildViews:childBubbles];

	for(Bubble *bubble in childBubbles) {
		[self addChildViewForBubble:bubble delayed:delayed];
	}
	[self didAddChildViews];
}

- (NSArray *)childBubbles {
	return [self.dataSource childrenForKeyPath:[self keyPath]];
}

- (void)removeOutdatedChildViews:(NSArray *)childBubbles {
	if(childViewsByKey == nil && childViewsAwaitingInsert == nil) {
		return;
	}

	NSMutableSet *outdatedViewKeys = [NSMutableSet setWithArray:[childViewsByKey allKeys]];
	[outdatedViewKeys addObjectsFromArray:[childViewsAwaitingInsert allKeys]];
	for(Bubble *bubble in childBubbles) {
		[outdatedViewKeys removeObject:bubble.key];
	}

	for(id key in outdatedViewKeys) {
		[self removeChildViewForKey:key];
	}
}

- (void)addChildViewForBubble:(Bubble *)bubble delayed:(BOOL)delayed {
	NSArray *bubbleKeyPath = [[self keyPath] arrayByAddingObject:bubble.key];
	BubbleView *view = [childViewsByKey objectForKey:bubble.key];
	if(view == nil) {
		view = [childViewsAwaitingInsert objectForKey:bubble.key];
	}

	if(view != nil) {
		[view updateBubble:bubble];
	}
	else {
		view = [viewFactory dequeueBubbleViewForBubble:bubble withKeyPath:bubbleKeyPath];
		if(delayed) {
			[self insertDelayedChildView:view];
		}
		else {
			[self insertChildView:view animated:NO];
		}
	}
	[view setCenterOffset:childrenCenterOffset];
	[self setChildZoomScale:view];
}

- (void)didAddChildViews {
}

- (void)removeChildViews {
	if(childViewsAwaitingInsert != nil) {
		NSMutableDictionary *childViews = childViewsAwaitingInsert;
		childViewsAwaitingInsert = nil;
		[self removeChildViews:childViews];
	}
	if(childViewsByKey != nil) {
		NSMutableDictionary *childViews = childViewsByKey;
		childViewsByKey = nil;
		[self removeChildViews:childViews];
	}
}

// warning: caller should not use views in childViews anymore, as they get enqueued to the cache already
- (void)removeChildViews:(NSMutableDictionary *)childViews {
	for(id key in childViews) {
		BubbleView *view = [childViews objectForKey:key];
		[view removeFromSuperview];
		[viewFactory enqueueBubbleView:view];
	}
}

- (void)removeChildViewForKey:(id)key {
	BubbleView *childView = [childViewsByKey objectForKey:key];
	if(childView == nil) {
		childView = [childViewsAwaitingInsert objectForKey:key];
		NSAssert(childView != nil, @"trying to remove view for unknown key!");
	}
	[self removeChildView:childView];
}

- (void)removeChildView:(BubbleView *)childView {
	NSAssert(childView != nil, @"trying to remove nil view!");
	[childView removeFromSuperview];
	id theKey = childView.bubble.key;
	[childViewsByKey removeObjectForKey:theKey];
	[childViewsAwaitingInsert removeObjectForKey:theKey];
	[viewFactory enqueueBubbleView:childView];
}

- (void)removeBubbleAtKeyPath:(NSArray *)aKeyPath {
	NSAssert([aKeyPath count] > 0, @"Can not remove empty keyPath");
	BubbleView *child = [self visibleViewForHeadOfKeyPath:aKeyPath];
	if(child == nil) {
		return;
	}

	if([aKeyPath count] == 1) {
		[self removeChildView:child];
	}
	else {
		[child removeBubbleAtKeyPath:[aKeyPath tail]];
	}
}

- (void)reloadChildrenAtKeyPath:(NSArray *)aKeyPath {
	if([aKeyPath count] == 0) {
		[self reloadChildViews];
	}
	else {
		BubbleView *child = [self visibleViewForHeadOfKeyPath:aKeyPath];
		[child reloadChildrenAtKeyPath:[aKeyPath tail]];
	}
}

- (void)reloadBubbleAtKeyPath:(NSArray *)aKeyPath {
	if([aKeyPath count] == 0) {
		[self reloadBubble];
	}
	else {
		BubbleView *child = [self visibleViewForHeadOfKeyPath:aKeyPath];
		[child reloadBubbleAtKeyPath:[aKeyPath tail]];
	}
}

- (void)reloadBubble {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)insertDelayedChildView:(BubbleView *)childView {
	if(childViewsAwaitingInsert == nil) {
		childViewsAwaitingInsert = [[NSMutableDictionary alloc] init];
	}
	NSAssert([childViewsAwaitingInsert objectForKey:childView.bubble.key] == nil, @"Duplicate view key");
	[childViewsAwaitingInsert setObject:childView forKey:childView.bubble.key];
	[self startChildInsertTimer];
}

- (void)startChildInsertTimer {
	if(childInsertTimer != nil) {
		return;
	}
	childInsertTimer = [NSTimer scheduledTimerWithTimeInterval:kBubbleAppearDelayIncrement target:self selector:@selector(childInsertTimerFired:) userInfo:nil repeats:NO];
}

- (void)childInsertTimerFired:(NSTimer *)timer {
	childInsertTimer = nil;
	[self insertNextWaitingChildView];
	if([childViewsAwaitingInsert count] > 0) {
		[self startChildInsertTimer];
	}
}

- (void)insertNextWaitingChildView {
	if([childViewsAwaitingInsert count] == 0) {
		return;
	}
	
	id key = [[childViewsAwaitingInsert keyEnumerator] nextObject];
	BubbleView *childView = [childViewsAwaitingInsert objectForKey:key];
	[self insertChildView:childView animated:YES];
	[childViewsAwaitingInsert removeObjectForKey:key];
	if([childViewsAwaitingInsert count] == 0) {
		childViewsAwaitingInsert = nil;
	}
}

- (void)insertChildView:(BubbleView *)childView animated:(BOOL)animated {
	if(childViewsByKey == nil) {
		childViewsByKey = [[NSMutableDictionary alloc] init];
	}
	NSAssert([childViewsByKey objectForKey:childView.bubble.key] == nil, @"Duplicate view key");
	[childViewsByKey setObject:childView forKey:childView.bubble.key];
	[self addBubbleSubview:childView];
	[childView setCenterOffset:childrenCenterOffset];
	[self setChildZoomScale:childView];
	if(animated) {
		[childView startBounceAnimation];
	}
}

- (void)addBubbleSubview:(BubbleView *)view {
	[self addSubview:view];
}

- (void)willBeEnqueuedToCache {
	[childInsertTimer invalidate];
	childInsertTimer = nil;
	[self removeChildViews];
}

- (BubbleView *)bubbleViewForLocation:(CGPoint)location {
	BubbleView *hitView = nil;
	for(id key in childViewsByKey) {
		BubbleView *view = [childViewsByKey objectForKey:key];

		if(CGRectContainsPoint(view.frame, location) == NO) {
			continue;
		}

		CGPoint localLocation = [self convertPoint:location toView:view];
		BubbleView *candidate = [view bubbleViewForLocation:localLocation];
        if (candidate == nil) {
            continue;
        }
        
		if(hitView == nil || CGRectGetWidth(candidate.bounds) < CGRectGetWidth(hitView.bounds)) {
			hitView = candidate;
		}
	}

	return hitView;
}

- (NSArray *)visibleBubbleViewsInCircleAt:(CGPoint)centerLocation withRadius:(CGFloat)searchRadius satisfyingCheck:(BubbleViewCheckBlock)check {
	
	NSMutableArray *result = [[NSMutableArray alloc] init];
	
	for(id key in childViewsByKey) {
		BubbleView *view = [childViewsByKey objectForKey:key];
						
		CGPoint localLocation = [self convertPoint:centerLocation toView:view];
		NSArray *childMatches = [view visibleBubbleViewsInCircleAt:localLocation withRadius:searchRadius satisfyingCheck:check];
		if(childMatches.count > 0) {
			[result addObjectsFromArray:childMatches];
			continue;
		}

		CGPoint vect;
		vect.x = view.center.x - centerLocation.x;
		vect.y = view.center.y - centerLocation.y;
		CGFloat distance = sqrtf(vect.x * vect.x + vect.y * vect.y);
		
		CGRect localSize = [self convertRect:view.frame fromView:view];
		CGFloat radius = localSize.size.width * 0.5;
		distance -= radius;

		if(distance > searchRadius) {
			continue;
		}

		if([view isDiscoverable] == NO) {
			continue;
		}
		
		if(check(view) == NO) {
			continue;
		}
		
		DiscoveryZoneMember *member = [[DiscoveryZoneMember alloc] init];
		member.keyPath = view.keyPath;
		member.distanceFromCenter = fmaxf(0.0, distance);
		member.bubbleView = view;
		[result addObject:member];
	}

	return result;
}

- (BOOL)isDiscoverable {
	
	if([self shouldShowChildren]) {
		return NO;
	}
	
	if([self shouldHideLabelView]) {
		return NO;
	}
	
	return YES;
}

- (BOOL)shouldHideLabelView {
	[self doesNotRecognizeSelector:_cmd];
	return YES;
}

- (BubbleView *)bubbleViewForKeyPath:(NSArray *)aKeyPath includeHiddenViews:(BOOL)includeHiddenViews allowParent:(BOOL)allowParent {
	if([aKeyPath count] == 0) {
		return nil;
	}
	
	if(includeHiddenViews) {
		while(childViewsAwaitingInsert != nil) {
			[self insertNextWaitingChildView];
		}
		if(childViewsByKey == nil) {
			[self createChildViewsDelayed:NO];
		}
	}	
	
	BubbleView *view = [self visibleViewForHeadOfKeyPath:aKeyPath];
	NSArray *tail = [aKeyPath tail];
	if([tail count] == 0) {
		return view;
	}
	
	return [view bubbleViewForKeyPath:tail includeHiddenViews:includeHiddenViews allowParent:allowParent];
}

- (NSArray *)visibleBubbleViewsInKeyPath:(NSArray *)aKeyPath {
	if([aKeyPath count] == 0) {
		return [NSArray array];
	}

	BubbleView *view = [self visibleViewForHeadOfKeyPath:aKeyPath];
	if(view == nil) {
		return [NSArray array];
	}

	return [[view visibleBubbleViewsInKeyPath:[aKeyPath tail]] arrayByAddingObject:view];
}

- (BubbleView *)visibleViewForHeadOfKeyPath:(NSArray *)aKeyPath {
	return [childViewsByKey objectForKey:[aKeyPath head]];
}

- (BOOL)shouldShowChildren {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (NSArray *)keyPath {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

@end
