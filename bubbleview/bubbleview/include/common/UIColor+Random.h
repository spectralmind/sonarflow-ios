//
//  UIColor+Random.h
//  sonarflow
//
//  Created by Raphael Charwot on 03.09.11.
//  Copyright (c) 2011 Charwot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Random)

+ (UIColor *)randomColor;
+ (UIColor *)randomColorWithSaturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;

@end
