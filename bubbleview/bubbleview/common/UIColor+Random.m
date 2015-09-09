//
//  UIColor+Random.m
//  sonarflow
//
//  Created by Raphael Charwot on 03.09.11.
//  Copyright (c) 2011 Charwot. All rights reserved.
//

#import "UIColor+Random.h"

@implementation UIColor (Random)

+ (UIColor *)randomColor {
	return [self randomColorWithSaturation:1.0 brightness:1.0 alpha:1.0];
}

+ (UIColor *)randomColorWithSaturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha {
	double hue = random() % 1000 / 1000.0;
	return [self colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

@end
