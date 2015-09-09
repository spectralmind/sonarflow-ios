//
//  AnimationFactory.m
//  Sonarflow
//
//  Created by Raphael Charwot on 19.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "AnimationFactory.h"
#import "ScaleAnimation.h"
#import "TranslateAnimation.h"

@implementation AnimationFactory

@synthesize animationDuration;

- (AbstractAnimation *)animationScalingFrom:(CGFloat)theFromScale
										 to:(CGFloat)theToScale
					 centeredOnViewLocation:(CGPoint)location {
	return [[ScaleAnimation alloc]
		initWithDuration:self.animationDuration
		from:theFromScale to:theToScale centeredOnViewLocation:location];
}

- (AbstractAnimation *)animationTranslatingFromPoint:(CGPoint)theFrom
											 toPoint:(CGPoint)theTo {
 	return [[TranslateAnimation alloc]
			 initWithDuration:self.animationDuration
			 fromPoint:theFrom
			 toPoint:theTo];
}

@end
