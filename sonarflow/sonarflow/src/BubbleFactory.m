#import "BubbleFactory.h"

#import "ImageFactory.h"
#import "SFRootItem.h"
#import "SFMediaItem.h"
#import "Bubble.h"
#import "NSString+Truncate.h"
#import "BubbleLayouter.h"
#import "UIImage+Stretchable.h"
#import "SMArtist.h"
#import "RootKey.h"
#import "SpiralLayouter.h"

@interface BubbleFactory ()

@end

@implementation BubbleFactory {
	@private
    ImageFactory *imageFactory;
	CGFloat maxBubbleRadius;
	CGFloat childrenRadiusFactor;
	NSInteger maxTextLength;
	CGSize coverSize;
}

- (id)initWithImageFactory:(ImageFactory *)theImageFactory {
    self = [super init];
    if (self) {
        imageFactory = theImageFactory;
    }
    return self;
}

@synthesize maxBubbleRadius;
@synthesize childrenRadiusFactor;
@synthesize maxTextLength;
@synthesize coverSize;

- (NSArray *)bubblesForRootMediaItems:(NSArray *)mediaItems {
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[mediaItems count]];
	for(id<SFMediaItem, SFRootItem> rootMediaItem in mediaItems) {
		[result addObject:[self bubbleForRootMediaItem:rootMediaItem]];
	}
	return result;
}

- (Bubble *)bubbleForRootMediaItem:(id<SFMediaItem, SFRootItem>)mediaItem {
	Bubble *bubble = [self bubbleForMediaItem:mediaItem inBubble:nil];
	bubble.origin = mediaItem.origin;
	bubble.color = mediaItem.bubbleColor;
	return bubble;
}

- (Bubble *)bubbleForMediaItem:(id<SFMediaItem>)mediaItem inBubble:(Bubble *)parentBubble {
	Bubble *bubble = [[Bubble alloc] initWithKey:mediaItem.key];
	float maxRadius = parentBubble.radius * self.childrenRadiusFactor;
	bubble.radius = sqrt([mediaItem relativeSize]) * maxRadius;
	NSAssert(!isnan(bubble.radius) && !isinf(bubble.radius), @"invalid radius");

	bubble.title = [self titleForMediaItem:mediaItem];
	bubble.isLeaf = ([mediaItem mayHaveChildren] == false);
	bubble.mayHaveCover = [mediaItem mayHaveImage];
	
	if([mediaItem respondsToSelector:@selector(countToShow)]) {
		bubble.numElements = [mediaItem countToShow];
	}
	bubble.radius = [self radiusForMediaItem:mediaItem inBubble:parentBubble];
	bubble.color = parentBubble.color;
	return bubble;
}

- (float)radiusForMediaItem:(id<SFMediaItem>)mediaItem inBubble:(Bubble *)parentBubble {
	float radius = sqrt([mediaItem relativeSize]) * [self maxRadiusForChildOfBubble:parentBubble];
	if (parentBubble == nil) {
		return fmaxf(radius, self.toplayerMinBubbleRadius);
	}
	else {
		return radius;
	}
}

- (float)maxRadiusForChildOfBubble:(Bubble *)parentBubble {
	if(parentBubble == nil) {
		return self.maxBubbleRadius;
	}
	
	return parentBubble.radius * self.childrenRadiusFactor;
}

- (void)updateBubble:(Bubble *)bubble withParent:(Bubble *)parentBubble fromMediaItem:(id<SFMediaItem>)mediaItem {
	bubble.radius = [self radiusForMediaItem:mediaItem inBubble:parentBubble];
}

- (NSString *)titleForMediaItem:(id<SFMediaItem>)mediaItem {
	return [self truncatedName:[mediaItem name]];
}

- (NSString	*)truncatedName:(NSString *)name {
	if(self.maxTextLength <= 0) {
		return name;
	}
	
	return [name stringByTruncatingToLength:self.maxTextLength];
}

- (Bubble *)bubbleForDiscoveredArtist:(SMSimilarArtist *)artist withRadius:(CGFloat)radius {
	RootKey *key = [self rootKeyForDiscoveredArtist:artist];
	Bubble *bubble = [[Bubble alloc] initWithKey:key];
	bubble.type = BubbleTypeDiscovered;
	
	bubble.radius = radius;
	
	bubble.title = artist.artistName;
	bubble.isLeaf = YES;
	bubble.mayHaveCover = NO;
	
	bubble.color = [UIColor whiteColor];
	
	return bubble;
}

- (RootKey *)rootKeyForDiscoveredArtist:(SMSimilarArtist *)artist {
	RootKey *key = [[RootKey alloc] initWithKey:artist.artistName type:BubbleTypeDiscovered];
	return key;
}

- (NSArray *)bubblesForChildren:(NSArray *)children ofBubble:(Bubble *)bubble avoidingBubbles:(NSArray *)bubblesToAvoid {
	NSAssert(bubble != nil, @"Missing bubble");
	NSArray *unsortedChildren = [self unsortedBubblesForMediaItems:children inBubble:bubble];
	if(unsortedChildren == nil) {
		return nil;
	}
    
    if(unsortedChildren.count == 0) {
        return unsortedChildren;
    }

    BOOL allLeaves = YES;
    for(Bubble *b in unsortedChildren) {
        allLeaves &= b.isLeaf;
    }
    
    if(allLeaves) {
        return [self layoutTrackBubbles:[unsortedChildren arrayByAddingObjectsFromArray:bubblesToAvoid] inRadius:bubble.radius];
    }

	return [self sortAndLayoutBubbles:unsortedChildren inRadius:bubble.radius avoidingBubbles:bubblesToAvoid];
}

- (NSArray *)unsortedBubblesForMediaItems:(NSArray *)mediaItems inBubble:(Bubble *)bubble {
	NSMutableArray *bubbles = [[NSMutableArray alloc] initWithCapacity:[mediaItems count]];
	for(id<SFMediaItem> mediaItem in mediaItems) {
		if([mediaItem showAsBubble]) {
			Bubble *childBubble = [self bubbleForMediaItem:mediaItem inBubble:bubble];
			[bubbles addObject:childBubble];
		}
	}
	
	return bubbles;
}

- (NSArray *)sortAndLayoutBubbles:(NSArray *)bubbles inRadius:(CGFloat)radius avoidingBubbles:(NSArray *)bubblesToAvoid {
	BubbleLayouter *layouter = [[BubbleLayouter alloc] init];
	return [layouter sortAndLayoutBubbles:bubbles inRadius:radius avoidingBubbles:bubblesToAvoid];
}

- (NSArray *)layoutTrackBubbles:(NSArray *)bubbles inRadius:(CGFloat)radius {
    SpiralLayouter *layouter = [[SpiralLayouter alloc] init];	
    NSArray *layoutedBubbles = [layouter sortAndLayoutBubbles:bubbles inRadius:radius avoidingBubbles:[NSArray array]];
    return layoutedBubbles;
}

@end
