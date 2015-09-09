//
//  CrosshairView.m
//  sonarflow
//
//  Created by Arvid Staub on 11.05.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "CrosshairView.h"
#import <QuartzCore/QuartzCore.h>


@implementation CrosshairView {
	BOOL animating;
	BOOL animationRequested;
	float angle;
}

- (id)initWithImage:(UIImage *)image {
	if (!(self = [super initWithImage:image])) return nil;
	
	self.layer.shadowColor = [[UIColor blackColor] CGColor];
	self.layer.shadowOffset = CGSizeMake(1, 1);
	self.layer.shadowRadius = 1.5;
	self.layer.shadowOpacity = 1.0f;

	return self;
}

#define kTransformAngle (2*M_PI/3)
#define kTransformTime	0.336699

- (void)animateIfActivated {
	if(!animationRequested && self.alpha > 0) {
		animating = NO;
		return;
	}
	
	animating = YES;
	
	angle += kTransformAngle;
	
	[UIView animateWithDuration:kTransformTime delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
		self.transform = CGAffineTransformMakeRotation(angle);
		//self.alpha = 1.0 - self.alpha;
	} completion:^(BOOL finished) {
		[self animateIfActivated];
	}];
}

- (void)startAnimating {
	if(animationRequested) {
		return;
	}
	
	animationRequested = YES;
	if(!animating) {
		[self animateIfActivated];
	}
}

- (void)stopAnimating {
	animationRequested = NO;
}

@end
