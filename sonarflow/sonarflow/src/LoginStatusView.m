#import "LoginStatusView.h"

#import "ActivityLabelView.h"

@implementation LoginStatusView {
	UILabel *defaultView;
	ActivityLabelView *verifyingView;
	UILabel *errorView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self initLoginStatusView];
    }
    return self;
}

- (void)awakeFromNib {
	[self initLoginStatusView];
}

- (void)initLoginStatusView {
	[self createSubviews];

	[self addFullSizeSubview:[self viewForState:self.state]];
}


#pragma mark - Properties

- (NSString *)defaultText {
	return defaultView.text;
}

- (void)setDefaultText:(NSString *)defaultText {
	defaultView.text = defaultText;
}

- (void)setState:(LoginStatusViewState)newState {
	if(_state == newState) {
		return;
	}

	[[self viewForState:_state] removeFromSuperview];
	_state = newState;
	[self addFullSizeSubview:[self viewForState:_state]];
}

#pragma mark -

- (void)createSubviews {
	UIFont *sharedFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	UIColor *textColor = [UIColor darkGrayColor];
	UIColor *shadowColor = [UIColor whiteColor];
	CGSize shadowOffset = CGSizeMake(0, 1);

	defaultView = [[UILabel alloc] initWithFrame:CGRectZero];
	defaultView.backgroundColor = [UIColor clearColor];
	defaultView.textAlignment = UITextAlignmentCenter;
	defaultView.font = sharedFont;
	defaultView.textColor = textColor;
	defaultView.shadowColor = shadowColor;
	defaultView.shadowOffset = shadowOffset;

	verifyingView = [[ActivityLabelView alloc] initWithFrame:CGRectZero];
	verifyingView.backgroundColor = [UIColor clearColor];
	verifyingView.font = sharedFont;
	verifyingView.textColor = textColor;
	verifyingView.shadowColor = shadowColor;
	verifyingView.shadowOffset = shadowOffset;
	verifyingView.text = @"Verifying...";
	verifyingView.activityIndicatorVisible = YES;
	
	errorView = [[UILabel alloc] initWithFrame:CGRectZero];
	errorView.backgroundColor = [UIColor clearColor];
	errorView.textAlignment = UITextAlignmentCenter;
	errorView.font = sharedFont;
	errorView.textColor = [UIColor redColor];
	errorView.shadowColor = shadowColor;
	errorView.shadowOffset = shadowOffset;
	errorView.text = @"Invalid username or password.";
}

- (void)addFullSizeSubview:(UIView *)view {
	view.frame = self.bounds;
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self addSubview:view];
}

- (UIView *)viewForState:(LoginStatusViewState)aState {
	switch(aState) {
		case LoginStatusViewStateDefault:
			return defaultView;
		case LoginStatusViewStateVerifying:
			return verifyingView;
		case LoginStatusViewStateError:
			return errorView;
		default:
			NSAssert(0, @"Invalid state");
			return nil;
	}
}

@end
