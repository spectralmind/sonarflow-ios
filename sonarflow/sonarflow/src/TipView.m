//
//  TipView.m
//  Sonarflow
//
//  Created by Raphael Charwot on 17.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "TipView.h"

#define kLabelHPadding 8
#define kLabelVPadding 4

@interface TipView ()

- (void)initCommon;
- (void)hideTimerFired:(NSTimer *)theTimer;
- (void)hide;
- (void)setAlphaAnimated:(CGFloat)alpha;

@end


@implementation TipView

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
		[self initCommon];
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	[self initCommon];
}

- (void)initCommon {
	CGRect labelFrame = CGRectInset(self.bounds, kLabelHPadding, kLabelVPadding);
	label = [[UILabel alloc] initWithFrame:labelFrame];
	label.adjustsFontSizeToFitWidth = YES;
	label.numberOfLines = 0;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor];
	[self addSubview:label];
}

- (void)showTip:(NSString *)tip forDuration:(NSTimeInterval)duration {
	if(timer != nil) {
		[timer invalidate];
	}
	timer = [NSTimer scheduledTimerWithTimeInterval:duration
											 target:self
										   selector:@selector(hideTimerFired:)
										   userInfo:nil
											repeats:NO];
	label.text = tip;
	[self setAlphaAnimated:1];
}

- (void)hideTimerFired:(NSTimer *)theTimer {
	timer = nil;
	[self hide];
}

- (void)hide {
	[self setAlphaAnimated:0];
}

- (void)setAlphaAnimated:(CGFloat)alpha {
	[UIView beginAnimations:nil context:nil];
	self.alpha = alpha;
	[UIView commitAnimations];
}



@end
