#import "SFSyncNotificationView.h"

@implementation SFSyncNotificationView {
	UIActivityIndicatorView *syncActivityIndicator;	
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self createChildViews];
    }
    return self;
}


- (void)createChildViews {
	self.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
	self.alpha = 0;
	
	CGFloat horizontalCenter = CGRectGetMidX(self.bounds);
	CGFloat verticalCenter = CGRectGetMidY(self.bounds);
	
	syncActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	syncActivityIndicator.center = CGPointMake(horizontalCenter,
											   verticalCenter - syncActivityIndicator.frame.size.height);
	syncActivityIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin |
	UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
	[self addSubview:syncActivityIndicator];	
}

- (void)showAnimated {
	[UIView animateWithDuration:0.5 animations:^{
		[syncActivityIndicator startAnimating];
		self.hidden = NO;
		self.alpha = 1.0;
	}];
}

- (void)hideAnimated {
	[UIView animateWithDuration:0.5 animations:^{
			self.alpha = 0;
		} completion:^(BOOL finished) {
			[syncActivityIndicator stopAnimating];
			self.hidden = YES;
	}];
}


@end
