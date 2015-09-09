#import "BubbleLabelView.h"

#define kBackgroundPaddingHorizontal 10
#define kBackgroundPaddingVertical 3
#define kBackgroundBottomMargin 3

#define kCountBackgroundPaddingHorizontal 3
#define kCountBackgroundPaddingVertical 1

static const CGSize shadowOffset = { 1, 1 };
static const CGSize kIconSize = { 30, 28 };
static const CGFloat kIconPadding = 6;


@interface BubbleLabelView ()

@end

@implementation BubbleLabelView {
	UIImageView *backgroundView;
	UILabel *textView;
	UIImageView *countBackgroundView;
	UILabel *countView;
	UIImageView *iconView;
}

- (id)initWithFont:(UIFont *)font countFont:(UIFont *)countFont countBackground:(UIImage *)countBackgroundImage countVisible:(BOOL)countVisible {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self createBackground];
		[self createTextViewWithFont:font];
		if (countVisible) {
			[self createCountBackgroundWithImage:countBackgroundImage];
			[self createCountViewWithFont:countFont];
		}
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


@synthesize owner;

- (void)createBackground {
	backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[self addSubview:backgroundView];
}

- (void)createCountBackgroundWithImage:(UIImage *)image {
	countBackgroundView = [[UIImageView alloc] initWithImage:image];
	countBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
	UIViewAutoresizingFlexibleBottomMargin;
	[self addSubview:countBackgroundView];
}

- (void)createTextViewWithFont:(UIFont *)font {
	textView = [[UILabel alloc] init];
	textView.frame = self.bounds;
	textView.font = font;
	textView.textColor = [UIColor whiteColor];
	textView.backgroundColor = [UIColor clearColor];
	textView.shadowColor = [UIColor blackColor];
	textView.shadowOffset = shadowOffset;
	[self addSubview:textView];
}

- (void)createCountViewWithFont:(UIFont *)font {
	countView = [[UILabel alloc] init];
	countView.font = font;
	countView.textColor = [UIColor blackColor];
	countView.backgroundColor = [UIColor clearColor];
	[self addSubview:countView];
}

- (NSString *)text {
	return textView.text;
}

- (void)setLabelImage:(UIImage *)backgroundImage {
    backgroundView.image = backgroundImage;
    backgroundView.frame = self.bounds;
	backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleHeight;
}

- (void)setText:(NSString *)text {
	textView.text = text;
	[self resizeToFitText];
}

- (void)setIcon:(UIImage *)icon {
	if(icon != nil && iconView == nil) {
		[self createIconView];
	}
	iconView.image = icon;
	iconView.hidden = (icon == nil);
	[self resizeToFitText];
}

- (void)createIconView {
	iconView = [[UIImageView alloc] init];
	iconView.bounds = CGRectMake(0, 0, kIconSize.width, kIconSize.height);
	iconView.center = CGPointMake(kIconSize.width * 0.5 + kIconPadding, CGRectGetMidY(self.bounds));
	iconView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin
		| UIViewAutoresizingFlexibleTopMargin
		| UIViewAutoresizingFlexibleBottomMargin;
	[self insertSubview:iconView aboveSubview:backgroundView];
}

- (void)resizeToFitText {
	CGSize textSize = [self.text sizeWithFont:textView.font];
	textSize.width += fabs(shadowOffset.width);
	textSize.height += fabs(shadowOffset.height);
	CGRect textFrame = CGRectMake(self.bounds.origin.x + kBackgroundPaddingHorizontal,
								  self.bounds.origin.y + kBackgroundPaddingVertical,
								  textSize.width,
								  textSize.height);
	CGSize newBoundsSize = CGSizeMake(textSize.width + 2 * kBackgroundPaddingHorizontal,
									  textSize.height + 2 * kBackgroundPaddingVertical + kBackgroundBottomMargin);
	if(iconView != nil && iconView.hidden == NO) {
		newBoundsSize.width += kIconSize.width;
		textFrame.origin.x += kIconSize.width;
	}

	textView.frame = textFrame;
	self.bounds = CGRectIntegral(CGRectMake(self.bounds.origin.x, self.bounds.origin.y, newBoundsSize.width, newBoundsSize.height));
}

- (void)setCount:(NSString *)count {
	if(count == nil) {
		countBackgroundView.hidden = YES;
		countView.hidden = YES;
		return;
	}
	
	countView.text = count;
	[self resizeCount];
}

- (void)resizeCount {
	CGSize countSize = [countView.text sizeWithFont:countView.font];
	CGSize totalSize = CGSizeMake(countSize.width + 2 * kCountBackgroundPaddingHorizontal,
								  countSize.height + 2 * kCountBackgroundPaddingVertical);
	CGRect countFrame = CGRectMake(self.bounds.origin.x + self.bounds.size.width - totalSize.width * 0.5,
								  self.bounds.origin.y + kCountBackgroundPaddingVertical - totalSize.height * 0.5,
								  countSize.width, countSize.height);
	countView.frame = countFrame;
	countView.hidden = NO;

	CGRect countBackgroundFrame = CGRectInset(countFrame,
											  -2 * kCountBackgroundPaddingHorizontal,
											  -2 * kCountBackgroundPaddingVertical);
	countBackgroundView.frame = countBackgroundFrame;
	countBackgroundView.hidden = NO;
}

- (void)willBeEnqueuedToCache {
}

@end
