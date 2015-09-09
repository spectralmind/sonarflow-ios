//
//  BubbleOverlayController.m
//  sonarflow
//
//  Created by Arvid Staub on 13.03.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "BubbleOverlayController.h"
#import "UIDevice+SystemVersion.h"

#define kCoverTransitionTime	0.7f

@implementation BubbleOverlayController {
	UIView *overlayView;
	UIViewController *overlayingController;
}

- (id)initWithOverlayView:(UIView *)view {
    self = [super init];
    if (self) {
        overlayView = view;
    }
    return self;
}


- (void)presentController:(UIViewController *)viewController {
	CGRect positionOnScreen = CGRectMake(0, 0, overlayView.frame.size.width, overlayView.frame.size.height);
	CGRect positionOffScreen = positionOnScreen;
	positionOffScreen.origin.x = positionOnScreen.size.width;
	
	viewController.view.frame = positionOffScreen;
	overlayingController = viewController;
	
	[overlayView addSubview:viewController.view];
	
	[UIView animateWithDuration:kCoverTransitionTime animations:^{
		overlayView.hidden = NO;
		viewController.view.frame = positionOnScreen;
	}];
}

- (void)dismissController {
	
	if(overlayingController == nil) {
		NSLog(@"warning: trying to dismiss nonexisting controller!\n");
		return;
	}
	
	CGRect positionOnScreen = overlayView.frame;
	CGRect positionOffScreen = positionOnScreen;
	positionOffScreen.origin.x = overlayView.bounds.size.width;
	
	[UIView animateWithDuration:kCoverTransitionTime 
			 animations:^{
				 overlayView.frame = positionOffScreen;
			 }

			 completion:^(BOOL finished) {
				 if(finished) {
					 overlayView.hidden = YES;
					 overlayView.frame = positionOnScreen;
					 [overlayingController.view removeFromSuperview];
					 overlayingController = nil;
				 }
		 }];
}

- (BOOL)isPresenting {
	if(overlayingController != nil) {
		return YES;
	}
	else {
		return NO;
	}
}

@end
