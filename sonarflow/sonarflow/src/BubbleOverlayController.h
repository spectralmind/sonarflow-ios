//
//  BubbleOverlayController.h
//  sonarflow
//
//  Created by Arvid Staub on 13.03.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BubbleOverlayController : NSObject

- (id)initWithOverlayView:(UIView *)view;
- (void)presentController:(UIViewController *)viewController;
- (void)dismissController;

- (BOOL)isPresenting;

@end
