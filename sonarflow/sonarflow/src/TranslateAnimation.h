//
//  TranslateAnimation.h
//  Sonarflow
//
//  Created by Raphael Charwot on 19.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractAnimation.h"

@interface TranslateAnimation : AbstractAnimation {
	CGPoint from;
	CGPoint to;
}

- (id)initWithDuration:(NSTimeInterval)theDuration
			 fromPoint:(CGPoint)theFrom
			   toPoint:(CGPoint)theTo;

@end
