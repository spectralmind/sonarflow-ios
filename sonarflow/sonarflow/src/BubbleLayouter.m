//
//  BubbleLayouter.m
//  sonarflow
//
//  Created by Raphael Charwot on 27.08.11.
//  Copyright (c) 2011 Charwot. All rights reserved.
//

#import "BubbleLayouter.h"
#import "Bubble.h"

static const NSUInteger kMaxIterations = 1000;

@interface BubbleLayouter ()

@property (nonatomic, readwrite, strong) NSMutableArray *failed;
@property (nonatomic, readwrite, strong) NSMutableArray *succeeded;

@end


@implementation BubbleLayouter {
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}


@synthesize failed;
@synthesize succeeded;

- (NSArray *)failedBubbles {
	return failed;
}

- (NSArray *)succeededBubbles {
	return succeeded;
}

- (NSArray *)sortAndLayoutBubbles:(NSArray *)bubbles inRadius:(CGFloat)radius avoidingBubbles:(NSArray *)theBubblesToAvoid {
	if(bubbles.count == 0) {
		self.failed = nil;
		self.succeeded = nil;
		return bubbles;
	}
	
	self.failed = [NSMutableArray array];
	self.succeeded = [NSMutableArray arrayWithCapacity:[bubbles count]];
	
	NSMutableArray *bubblesToAvoid = [theBubblesToAvoid mutableCopy];
	NSArray *sortedBubbles = [self sortBubblesByRadius:bubbles];
	for(Bubble *bubble in sortedBubbles) {
		BOOL collissionDetected = [self setOriginForBubble:bubble inRadius:radius avoidingBubbles:bubblesToAvoid];
		[bubblesToAvoid addObject:bubble];
		if(collissionDetected) {
			[self.failed addObject:bubble];
		}
		else {
			[self.succeeded addObject:bubble];
		}
	}

	return sortedBubbles;
}

- (BOOL)setOriginForBubble:(Bubble *)bubble inRadius:(CGFloat)radius avoidingBubbles:(NSArray *)bubblesToAvoid {
	CGFloat childRadius = bubble.radius;
	CGPoint position;
	BOOL collissionDetected;
	NSUInteger iterationCnt = 0;
	do {
		collissionDetected = NO;
		++iterationCnt;
		position = [self randomPositionWithRadius:childRadius inRadius:radius];
		// check if random circle is colliding with any other artist circle
		for(Bubble *collisionCandidate in bubblesToAvoid) {
			CGPoint position2 = collisionCandidate.origin;
			CGFloat radius2 = collisionCandidate.radius;
			CGFloat sqrDistance = pow(position2.x - position.x, 2) + pow(position2.y - position.y, 2);
			CGFloat sqrRadius = pow(childRadius + radius2, 2);
			if(sqrDistance < sqrRadius) {
				collissionDetected = YES;
				[self collision:iterationCnt];
				break;
			}
		}
	} while(collissionDetected && iterationCnt < kMaxIterations);

	bubble.origin = position;
	return collissionDetected;
}

- (void)collision:(int)attempts {
	// NOP
}

- (NSArray *)sortBubblesByRadius:(NSArray *)bubbles {
	NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"radius" ascending:NO];
	NSArray *sortedBubbles = [bubbles sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
	return sortedBubbles;
}

- (CGPoint)randomPositionWithRadius:(CGFloat)childRadius inRadius:(CGFloat)radius {
	float maxr = radius - childRadius;
	if (maxr == 0) {
		return CGPointMake(0,0);
	}
	float r = (random() % (long)(100 * maxr)) / 100.0;
	float phi = (random() % (long)(100 * 2 * M_PI)) / 100.0;
	CGFloat x = r * cosf(phi);
	CGFloat y = r * sinf(phi);
	return CGPointMake(x, y);
}

@end
