#import "BubbleViewFactory.h"
#import "BubbleView.h"
#import "BubbleBackgroundView.h"
#import "BubbleLabelView.h"
#import "Bubble.h"
#import "BubbleGlowView.h"
#import "BVRimAnimationView.h"
#import "BVRimAnimationController.h"
#import "BVResources.h"
#import "BVResources+Private.h"

@interface ViewCache : NSObject {
	@private
    NSMutableArray *views;
}

- (id)init;
- (id)dequeueView;
- (void)enqueueView:(UIView<CacheableView> *)view;
- (NSUInteger)count;

@end

@implementation ViewCache

- (id)init {
    self = [super init];
    if (self) {
		views = [[NSMutableArray alloc] initWithCapacity:50];
    }
    return self;
}


- (id)dequeueView {
	if([views count] == 0) {
		return nil;
	}
	
	NSUInteger index = [views count] - 1;
	id view = [views objectAtIndex:index];
	[views removeObjectAtIndex:index];
	
	return view;
}

- (void)enqueueView:(UIView<CacheableView> *)view {
	if(view == nil) {
		return;
	}

	NSAssert(view.superview == nil, @"View is still attached");

	[view willBeEnqueuedToCache];
	[views addObject:view];
}

- (NSUInteger)count {
	return [views count];
}

@end

@implementation BubbleViewFactory {
	@private
	BVResources *resources;
	UIFont *font;
	UIFont *labelCountFont;
	CGFloat bubbleScreenSizeToShowChildren;
	CGFloat bubbleScreenSizeToShowTitle;
	CGFloat bubbleFadeSize;
	CGSize coverSize;
	BOOL showCountLabel;
	
	id<LabelContainer> __weak labelContainer;
	id<BubbleDataSource> __weak dataSource;
	
	BubbleGlowView *bubbleGlowView;
	
	ViewCache *bubbleViewCache;
	NSMutableDictionary *backgroundCachesByType;
	ViewCache *labelCache;
	ViewCache *rimAnimationCache;
	
	NSUInteger allocBV;
	NSUInteger allocBG;
	NSUInteger allocL;
	NSUInteger allocRA;
}

+ (BubbleViewFactory *)newDefaultFactory {
	return [[BubbleViewFactory alloc] initWithFont:[UIFont boldSystemFontOfSize:12]
									labelCountFont:[UIFont systemFontOfSize:10]
								sizeToShowChildren:240
									sizeToShowTitle:50
										  fadeSize:25
										 coverSize:CGSizeMake(50, 50)
									showCountLabel:YES];
}

- (id)initWithFont:(UIFont *)theFont labelCountFont:(UIFont *)theLabelCountFont sizeToShowChildren:(CGFloat)theSizeToShowChildren sizeToShowTitle:(CGFloat)theSizeToShowTitle fadeSize:(CGFloat)theFadeSize coverSize:(CGSize)theCoverSize showCountLabel:(BOOL)theShowCountLabel {
    self = [super init];
    if (self) {
		font = theFont;
		labelCountFont = theLabelCountFont;
		bubbleScreenSizeToShowChildren = theSizeToShowChildren;
		bubbleScreenSizeToShowTitle = theSizeToShowTitle;
		bubbleFadeSize = theFadeSize;
		coverSize = theCoverSize;
		showCountLabel = theShowCountLabel;

		bubbleGlowView = [[BubbleGlowView alloc] initWithFrame:CGRectZero];

		bubbleViewCache = [[ViewCache alloc] init];
		backgroundCachesByType = [[NSMutableDictionary alloc] initWithCapacity:2];
		labelCache = [[ViewCache alloc] init];
		rimAnimationCache = [[ViewCache alloc] init];
		
		rimAnimationController = [[BVRimAnimationController alloc] init];
    }
    return self;
}


@synthesize resources;
- (void)setResources:(BVResources *)newResources {
	if(resources == newResources) {
		return;
	}
	resources = newResources;
	[bubbleGlowView setBubbleGlowImage:resources.glowImage];
}

@synthesize font;
@synthesize labelCountFont;
@synthesize bubbleScreenSizeToShowChildren;
@synthesize bubbleScreenSizeToShowTitle;
@synthesize bubbleFadeSize;
@synthesize coverSize;
@synthesize showCountLabel;
@synthesize labelContainer;
@synthesize dataSource;
@synthesize rimAnimationController;

- (BubbleView *)dequeueBubbleViewForBubble:(Bubble *)bubble withKeyPath:(NSArray *)keyPath {
	BubbleView *view = [bubbleViewCache dequeueView];
	if(view == nil) {
		view = [self createBubbleView];
	}

	[view setBubble:bubble withKeyPath:keyPath];
	if([rimAnimationController shouldHaveRimAnimation:keyPath]) {
		[rimAnimationController addBubbleView:view];
	}

	return view;
}

- (BubbleView *)createBubbleView {
	allocBV++;
	BubbleView *view = [[BubbleView alloc] initWithViewFactory:self dataSource:dataSource labelContainer:labelContainer
											sizeToShowChildren:bubbleScreenSizeToShowChildren sizeToShowTitle:bubbleScreenSizeToShowTitle fadeSize:bubbleFadeSize coverSize:coverSize];
	return view;
}

- (void)enqueueBubbleView:(BubbleView *)view {
	[rimAnimationController removeBubbleView:view];
	[bubbleViewCache enqueueView:view];
}

- (UIView<CacheableView> *)dequeueBackgroundViewForBubble:(Bubble *)bubble {
	id typeKey = [NSNumber numberWithInt:bubble.type];
	ViewCache *backgroundCache = [backgroundCachesByType objectForKey:typeKey];
	if(backgroundCache == nil) {
		backgroundCache = [[ViewCache alloc] init];
		[backgroundCachesByType setObject:backgroundCache forKey:typeKey];
	}

	BubbleBackgroundView *view = [backgroundCache dequeueView];
	if(view == nil) {
		view = [self createBackgroundViewForType:bubble.type];
	}
	
	[view setImages:[resources bubbleBackgroundsForType:bubble.type color:bubble.color]];
	
	return view;
}

- (BubbleBackgroundView *)createBackgroundViewForType:(BubbleType)type {
	allocBG++;
	BubbleBackgroundView *view = [[BubbleBackgroundView alloc] initWithSizes:[resources bubbleBackgroundSizesForType:type]];
	return view;
}

- (void)enqueueBackgroundView:(UIView<CacheableView> *)view forBubble:(Bubble *)bubble {
	id typeKey = [NSNumber numberWithInt:bubble.type];
	ViewCache *backgroundCache = [backgroundCachesByType objectForKey:typeKey];
	[backgroundCache enqueueView:view];
}

- (BubbleLabelView *)dequeueLabelViewForBubble:(Bubble *)bubble {
	BubbleLabelView *view = [labelCache dequeueView];
	if(view == nil) {
		view = [self createLabelView];
	}

    [view setLabelImage:[resources labelBackgroundForColor:bubble.color]];
	view.text = bubble.title;
	view.icon = bubble.icon;
	[view setCount:bubble.numElements];

	return view;
}

- (BubbleLabelView *)createLabelView {
	allocL++;
	return [[BubbleLabelView alloc] initWithFont:font countFont:labelCountFont countBackground:resources.labelCountBackgroundImage countVisible:showCountLabel];
}

- (void)enqueueLabelView:(BubbleLabelView *)view {
	[labelCache enqueueView:view];
}

- (BubbleGlowView *)glowView {
	[bubbleGlowView detatchFromCurrentBubble];
	[bubbleGlowView reset];
	return bubbleGlowView;
}

- (BVRimAnimationView *)dequeueRimAnimationView {
	BVRimAnimationView *view = [rimAnimationCache dequeueView];
	if(view == nil) {
		view = [self createRimAnimationView];
	}
	
	return view;
}

- (BVRimAnimationView *)createRimAnimationView {
	allocRA++;
	BVRimAnimationView *result = [[BVRimAnimationView alloc] initWithFrame:CGRectZero];
	[result setRimIndicatorImage:resources.rimIndicatorImage];
	return result;
}

- (void)enqueueRimAnimationView:(BVRimAnimationView *)view {
	[rimAnimationCache enqueueView:view];
}

- (void)setCurrentlyPlayingKeypath:(NSArray *)keyPath playStatePlaying:(BOOL)playing {
	rimAnimationController.keyPath = keyPath;
	rimAnimationController.state = (playing ? BVRimAnimationStatePlaying : BVRimAnimationStatePaused);
}

- (void)printStatus {
	NSUInteger numBackgroundViews = 0;
	for(id key in backgroundCachesByType) {
		ViewCache *backgroundCache = [backgroundCachesByType objectForKey:key];
		numBackgroundViews += [backgroundCache count];
	}
	NSLog(@"Cached: %u/%u, %u/%u, %u/%u, %u/%u",
		  [bubbleViewCache count], allocBV,
		  numBackgroundViews, allocBG,
		  [labelCache count], allocL,
		  [rimAnimationCache count], allocRA);
}

@end
