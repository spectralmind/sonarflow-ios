//
//  ScreenshotFactory.h
//  sonarflow
//
//  Created by Raphael Charwot on 17.03.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ScreenshotFactory : NSObject {
	UIView *overlay;
}

- (UIImage *)createScreenshotOfView:(UIView *)view;

@end
