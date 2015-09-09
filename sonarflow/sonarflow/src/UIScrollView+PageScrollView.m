//
//  UIScrollView+PageScrollView.m
//  sonarflow
//
//  Created by Raphael Charwot on 19.03.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "UIScrollView+PageScrollView.h"


@implementation UIScrollView (PageScrollView)

- (void)scrollToPage:(int)page animated:(BOOL)animated
{
	CGRect frame = self.frame;
	frame.origin.x = frame.size.width * page;
	frame.origin.y = 0;
	[self scrollRectToVisible:frame animated:animated];
}

@end
