//
//  ScaleAnimation.m
//  Sonarflow
//
//  Created by Raphael Charwot on 19.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "ScaleAnimation.h"

@implementation ScaleAnimation

- (id)initWithDuration:(NSTimeInterval)theDuration
		from:(CGFloat)theFromScale
		to:(CGFloat)theToScale
		centeredOnViewLocation:(CGPoint)theLocation {
	self = [super initWithDuration:theDuration];
	if(self) {
		fromScale = theFromScale;
		toScale = theToScale;
		viewLocation = theLocation;
	}
	return self;
}

- (void)updateToProgress:(CGFloat)progress {
	CGFloat targetScale = fromScale + progress * (toScale - fromScale);
	[self.delegate animation:self setScale:targetScale centeredOnViewLocation:viewLocation];
}

@end
