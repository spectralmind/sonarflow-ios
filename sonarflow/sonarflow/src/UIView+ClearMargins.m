//
//  UIView+ClearMargins.m
//  sonarflow
//
//  Created by Arvid Staub on 07.06.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "UIView+ClearMargins.h"

@implementation UIView (ClearMargins)

- (void)clearTop:(CGFloat)height {
	for(UIView *view in self.subviews) {
		if(view.frame.origin.y > height) {
			continue;
		}
		
		CGFloat moveBy = height - view.frame.origin.y;
		CGRect newFrame = view.frame;
		newFrame.origin.y += moveBy;
		newFrame.size.height -= moveBy;
		view.frame = newFrame;
	}
}

@end
