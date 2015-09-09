//
//  ScaleAnimation.h
//  Sonarflow
//
//  Created by Raphael Charwot on 19.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractAnimation.h"

@interface ScaleAnimation : AbstractAnimation {
	CGFloat fromScale;
	CGFloat toScale;
	CGPoint viewLocation;
}

- (id)initWithDuration:(NSTimeInterval)theDuration
	from:(CGFloat)theFromScale
	to:(CGFloat)theToScale
	centeredOnViewLocation:(CGPoint)theLocation;
@end
