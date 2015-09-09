//
//  TipView.h
//  Sonarflow
//
//  Created by Raphael Charwot on 17.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TipView : UIView {
	UILabel *label;
	NSTimer *timer;
}

- (void)showTip:(NSString *)tip forDuration:(NSTimeInterval)duration;

@end
