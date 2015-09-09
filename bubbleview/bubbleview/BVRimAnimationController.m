#import "BVRimAnimationController.h"

#import "BVRimAnimationControllerDelegate.h"
#import "BubbleView.h"
#import "SFTimeTracker.h"

@interface BVRimAnimationController ()

@property (nonatomic, strong) NSDate *currentAnimationStartDate;

@end


@implementation BVRimAnimationController {
	NSArray *keyPath;
	BVRimAnimationState state;
	SFTimeTracker *animationTimeTracker;
	id<BVRimAnimationControllerDelegate> __weak delegate;
	
	NSMutableSet *activeViews;
}

- (id)init {
    self = [super init];
    if (self) {
        activeViews = [[NSMutableSet alloc] initWithCapacity:4];
		animationTimeTracker = [[SFTimeTracker alloc] init];
    }
    return self;
}


@synthesize keyPath;
- (void)setKeyPath:(NSArray *)newKeyPath {
	if([keyPath isEqualToArray:newKeyPath]) {
		return;
	}

	keyPath = newKeyPath;
	[self resetAnimationPlayDuration];
	[self updateAffectedBubbleViews];
}

@synthesize state;
- (void)setState:(BVRimAnimationState)newState {
	if(state == newState) {
		return;
	}

	state = newState;
	[self updateAnimationPlayDuration];
}

@synthesize delegate;
@synthesize currentAnimationStartDate;

- (void)resetAnimationPlayDuration {
	[animationTimeTracker reset];
	[self updateAnimationPlayDuration];
}

- (void)updateAnimationPlayDuration {
	animationTimeTracker.active = self.keyPath != nil &&
		self.state == BVRimAnimationStatePlaying;
	
	for(BubbleView *view in activeViews) {
		[view setRimAnimationState:self.state offset:[self currentAnimationPlayDuration]];
	}
}

- (NSTimeInterval)currentAnimationPlayDuration {
	return [animationTimeTracker duration];
}

- (BOOL)shouldHaveRimAnimation:(NSArray *)bubbleKeyPath {
	if(self.keyPath == nil) {
		return NO;
	}

	for(NSUInteger i = 0; i < [bubbleKeyPath count] && i < [self.keyPath count]; ++i) {
		if([[bubbleKeyPath objectAtIndex:i] isEqual:[self.keyPath objectAtIndex:i]] == false) {
			return NO;
		}
	}

	return YES;
}

- (void)updateAffectedBubbleViews {
	for(BubbleView *view in activeViews) {
		[view removeRimAnimation];
	}
	[activeViews removeAllObjects];
	
	if([self.keyPath count] == 0) {
		return;
	}

	for(BubbleView *view in [self.delegate visibleBubbleViewsInKeyPath:self.keyPath]) {
		[self addBubbleView:view];
	}
}

- (void)addBubbleView:(BubbleView *)view {
	NSAssert([activeViews containsObject:view] == NO, @"Called 'add' for already contained view");
	
	[activeViews addObject:view];
	[view setRimAnimationState:self.state offset:[self currentAnimationPlayDuration]];
}

- (void)removeBubbleView:(BubbleView *)view {
	if([activeViews containsObject:view] == NO) {
		return;
	}

	[view removeRimAnimation];
	[activeViews removeObject:view];
}

@end
