//
//  DiscoveredBubbleLayouter.m
//  sonarflow
//
//  Created by Arvid Staub on 27.04.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "DiscoveredBubbleLayouter.h"
#import "Bubble.h"

@implementation DiscoveredBubbleLayouter {
	CGPoint center;
	CGRect bounds;
	float angle;
	float angleIncrement;
}

- (id)initWithCenterLocation:(CGPoint)centerLocation withBounds:(CGRect)boundsRect withNumberOfBubbles:(int)bubbles {
    self = [super init];
    if(self == nil) {
		return nil;
	}		
	
	angle = (random() % (long)(100 * 2 * M_PI)) / 100.0;
	center = centerLocation;
	bounds = boundsRect;
	
	if(bubbles > 0) {
		angleIncrement = (2*M_PI) / (float)bubbles;
	}
	else {
		[self collision:1];
	}
	
    return self;
}

- (CGPoint)randomPositionWithRadius:(CGFloat)childRadius inRadius:(CGFloat)radius {
	CGFloat x = center.x + radius * cosf(angle);
	CGFloat y = center.y + radius * sinf(angle);
	angle += angleIncrement;

	if(x < bounds.origin.x) {
		x = bounds.origin.x;
	}

	if(y < bounds.origin.y) {
		y = bounds.origin.y;
	}

	if(x > bounds.origin.x + bounds.size.width) {
		x = bounds.origin.x + bounds.size.width;
	}
	
	if(y > bounds.origin.y + bounds.size.height) {
		y = bounds.origin.y + bounds.size.height;
	}

	return CGPointMake(x, y);
}

- (void)collision:(int)attempts {
	// switch to random search for free space
	attempts += 1;
	angleIncrement = ((attempts/2L)-(random() % (long)(attempts*M_PI))) / 2000.0;
}

@end
