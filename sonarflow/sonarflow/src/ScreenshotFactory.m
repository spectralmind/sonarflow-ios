//
//  ScreenshotFactory.m
//  sonarflow
//
//  Created by Raphael Charwot on 17.03.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "ScreenshotFactory.h"
#import <QuartzCore/QuartzCore.h>

@interface ScreenshotFactory ()

- (void)addOverlayToView:(UIView *)view;
- (void)createOverlay;
- (void)removeOverlay;

@end


@implementation ScreenshotFactory


- (UIImage *)createScreenshotOfView:(UIView *)view {
	[self addOverlayToView:view];
	
	UIGraphicsBeginImageContext(view.bounds.size);
	CALayer *layer = view.layer;
	[layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	[self removeOverlay];

	return image;
}

- (void)addOverlayToView:(UIView *)view {
	if(overlay == nil) {
		[self createOverlay];
	}
	
	CGRect overlayFrame = overlay.frame;
	overlayFrame.origin.x = view.bounds.size.width - overlay.bounds.size.width;
	overlayFrame.origin.y = view.bounds.size.height - overlay.bounds.size.height;
	overlay.frame = overlayFrame;
	
	[view addSubview:overlay];
}

- (void)createOverlay {
	UIImage *image = [UIImage imageNamed:@"sonarflow_logo_head.png"];
	overlay = [[UIImageView alloc] initWithImage:image];
}

- (void)removeOverlay {
	[overlay removeFromSuperview];
}

@end
