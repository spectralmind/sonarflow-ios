//
//  AnimationFactory.h
//  Sonarflow
//
//  Created by Raphael Charwot on 19.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AbstractAnimation;

@interface AnimationFactory : NSObject {
	NSTimeInterval animationDuration;
}

@property (nonatomic, assign) NSTimeInterval animationDuration;

- (AbstractAnimation *)animationScalingFrom:(CGFloat)theFromScale
										 to:(CGFloat)theToScale
					 centeredOnViewLocation:(CGPoint)location;
- (AbstractAnimation *)animationTranslatingFromPoint:(CGPoint)theFrom
											 toPoint:(CGPoint)theTo;
@end
