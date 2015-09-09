//
//  TranslateAnimation.m
//  Sonarflow
//
//  Created by Raphael Charwot on 19.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "TranslateAnimation.h"


@implementation TranslateAnimation

- (id)initWithDuration:(NSTimeInterval)theDuration
				  fromPoint:(CGPoint)theFrom
					toPoint:(CGPoint)theTo {
	if(self = [super initWithDuration:theDuration])	{
		from = theFrom;
		to = theTo;
	}
	return self;
}

- (void)updateToProgress:(CGFloat)progress {
	CGPoint target = CGPointMake(from.x + progress * (to.x - from.x),
								 from.y + progress * (to.y - from.y));
	[self.delegate animation:self setTranslation:target];
}

@end
