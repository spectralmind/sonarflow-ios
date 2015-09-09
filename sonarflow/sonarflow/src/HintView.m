#import "HintView.h"

#import "UIImage+Stretchable.h"
#import "NSString+CGLogging.h"
#import "QuartzCore/QuartzCore.h"

static const CGFloat kArrowTipFromRight = 23.0f;
static const CGFloat kTextPaddingLeft = 14.0f;
static const CGFloat kTextPaddingRight = 12.0f;
static const CGFloat kTextPaddingTop = 25.0f;
static const CGFloat kTextPaddingBottom = 25.0f;

@implementation HintView {
	UIImageView *backgroundView;
	UILabel *hintLabel;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self initHintView];
    }
    return self;
}

- (void)awakeFromNib {
	[self initHintView];
}

- (void)initHintView {
	self.autoresizesSubviews = NO;
	
	UIImage *background = [UIImage stretchableImageNamed:@"hint_background_south" leftCapWidth:4 topCapHeight:24];
	backgroundView = [[UIImageView alloc] initWithImage:background];
	[self addSubview:backgroundView];
	
	hintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	hintLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	hintLabel.textColor = [UIColor whiteColor];
	hintLabel.backgroundColor = [UIColor clearColor];
	hintLabel.lineBreakMode = UILineBreakModeWordWrap;
	hintLabel.numberOfLines = 0;
	[self addSubview:hintLabel];
	
	self.layer.shadowColor = [[UIColor blackColor] CGColor];
	self.layer.shadowOffset = CGSizeMake(0.0f, 10.0f);
	self.layer.shadowOpacity = 1.0f;
	self.layer.shadowRadius = 10.0f;
}


- (NSString *)text {
	return hintLabel.text;
}

- (void)setText:(NSString *)text {
	hintLabel.text = text;
}

- (CGFloat)arrowOffsetHorizontal {
	return CGRectGetMaxX(self.bounds) - kArrowTipFromRight;
}

- (void)resizeToFitTextForWidth:(CGFloat)maxWidth {
	CGFloat maxTextWidth = maxWidth - kTextPaddingLeft - kTextPaddingRight;
	CGSize maxSize = CGSizeMake(maxTextWidth, CGFLOAT_MAX);
	CGSize textSize = [hintLabel.text sizeWithFont:hintLabel.font constrainedToSize:maxSize lineBreakMode:hintLabel.lineBreakMode];
	self.bounds = CGRectMake(0, 0, textSize.width + kTextPaddingLeft + kTextPaddingRight, textSize.height + kTextPaddingTop + kTextPaddingBottom);
	backgroundView.frame = self.bounds;
	hintLabel.frame = CGRectMake(kTextPaddingLeft, kTextPaddingTop, textSize.width, textSize.height);
}

@end
