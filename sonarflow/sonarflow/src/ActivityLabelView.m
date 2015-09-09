#import "ActivityLabelView.h"

static const CGFloat kInnerPadding = 5.0f;

@implementation ActivityLabelView {
	UIActivityIndicatorView *activityView;
	UILabel *textLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self initActivityLabelView];
	}
    return self;
}

- (void)awakeFromNib {
	[self initActivityLabelView];
}

- (void)initActivityLabelView {
	activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray ];
	activityView.hidesWhenStopped = YES;
	
	textLabel = [[UILabel alloc] initWithFrame:CGRectNull];
	textLabel.backgroundColor = [UIColor clearColor];
	textLabel.textColor = [UIColor whiteColor];
	textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	
	[self addSubview:activityView];
	[self addSubview:textLabel];
}


#pragma mark - Properties

- (NSString *)text {
	return textLabel.text;
}

- (void)setText:(NSString *)text {
	textLabel.text = text;
	[self setNeedsLayout];
}

- (BOOL)isActivityIndicatorVisible {
	return [activityView isAnimating];
}

- (UIFont *)font {
	return textLabel.font;
}

- (void)setFont:(UIFont *)font {
	textLabel.font = font;
	[self setNeedsLayout];
}

- (UIColor *)textColor {
	return textLabel.textColor;
}

- (void)setTextColor:(UIColor *)textColor {
	textLabel.textColor = textColor;
}

- (UIColor *)shadowColor {
	return textLabel.shadowColor;
}

- (void)setShadowColor:(UIColor *)shadowColor {
	textLabel.shadowColor = shadowColor;
}

- (CGSize)shadowOffset {
	return textLabel.shadowOffset;
}

- (void)setShadowOffset:(CGSize)shadowOffset {
	textLabel.shadowOffset = shadowOffset;
}

- (void)setActivityIndicatorVisible:(BOOL)activityIndicatorVisible {
	if(activityIndicatorVisible) {
		[activityView startAnimating];
	}
	else {
		[activityView stopAnimating];
	}
	[self setNeedsLayout];
}

#pragma mark -

- (void)layoutSubviews {
	CGRect activityFrame;
	float innerPadding;
	if([self isActivityIndicatorVisible]) {
		activityFrame = activityView.frame;
		innerPadding = kInnerPadding;
	}
	else {
		activityFrame = CGRectZero;
		innerPadding = 0;
	}
	
	CGFloat maxWidth = CGRectGetWidth(self.bounds) - CGRectGetWidth(activityFrame) - innerPadding;
	CGSize textSize = [textLabel.text sizeWithFont:textLabel.font
									  forWidth:maxWidth
								 lineBreakMode:textLabel.lineBreakMode];
	textLabel.bounds = CGRectMake(0, 0, textSize.width, textSize.height);
	
	CGSize totalSize = CGSizeMake(CGRectGetWidth(activityFrame) + innerPadding + textSize.width,
								  fmaxf(CGRectGetHeight(activityFrame), textSize.height));
	CGFloat outerPadding = (CGRectGetWidth(self.bounds) - totalSize.width) * 0.5;

	activityView.center = CGPointMake(CGRectGetMinX(self.bounds) + outerPadding + CGRectGetWidth(activityFrame) * 0.5,
									  CGRectGetHeight(self.bounds) * 0.5);
	textLabel.center = CGPointMake(CGRectGetMaxX(self.bounds) - outerPadding - CGRectGetWidth(textLabel.frame) * 0.5,
								   CGRectGetHeight(self.bounds) * 0.5);
}

@end
