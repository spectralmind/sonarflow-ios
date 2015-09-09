//
//  UIViewController+SelfDismiss.m
//  Sonarflow
//
//  Created by Raphael Charwot on 12.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "UIViewController+SelfDismiss.h"


@implementation UIViewController(SelfDismiss)

- (void)dismiss {
	[self dismissModalViewControllerAnimated:YES];
}

@end
