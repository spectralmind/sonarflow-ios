//
//  UILabelWithMargin.m
//  sonarflow
//
//  Created by Fabian on 13.01.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "UILabelWithMargin.h"

@implementation UILabelWithMargin {
	UIEdgeInsets inset;
}

@synthesize inset;

- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.inset)];
}

@end
