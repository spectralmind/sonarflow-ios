#import "HintViewController.h"

#import "HintView.h"

static const NSTimeInterval kFadeAnimationDuration = 0.5;

@interface HintViewController ()

@property (nonatomic, copy) HintTapDelegateBlock tapDelegateBlock;
@property (nonatomic, weak) NSTimer *hideTimer;

@end


@implementation HintViewController {
	HintView *hintView;
}

- (id)init {
    self = [super init];
    if (self) {
        [self createHintView];
    }
    return self;
}


- (UIView *)view {
	return hintView;
}

- (void)setReferenceView:(UIView *)newReferenceView {
	if(_referenceView == newReferenceView) {
		return;
	}
	
	_referenceView = newReferenceView;
	[self updateViewPosition];	
}

- (void)setMaxWidth:(CGFloat)newMaxWidth {
	_maxWidth = newMaxWidth;
	[self updateViewPosition];
}

- (void)setHideTimer:(NSTimer *)newHideTimer {
	if(_hideTimer == newHideTimer) {
		return;
	}
	[_hideTimer invalidate];
	_hideTimer = newHideTimer;
}

- (void)createHintView {
	hintView = [[HintView alloc] initWithFrame:CGRectZero];
	hintView.hidden = YES;
	hintView.alpha = 0.0;
	hintView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
	hintView.userInteractionEnabled = YES;
	
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleHintViewTap:)];
	[hintView addGestureRecognizer:tapRecognizer];
}

- (void)handleHintViewTap:(UITapGestureRecognizer *)sender {
	[self hideHint];
	if(self.tapDelegateBlock != nil) {
		self.tapDelegateBlock();
	}
}

- (void)showHint:(NSString *)hint forDuration:(NSTimeInterval)duration withTapDelegate:(HintTapDelegateBlock)theTapDelegateBlock {
	hintView.text = hint;
	[self updateViewPosition];
	self.tapDelegateBlock = theTapDelegateBlock;
	self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(handleHideTimerFired:) userInfo:nil repeats:NO];

	hintView.hidden = NO;
	[UIView animateWithDuration:kFadeAnimationDuration
						  delay:0
						options:UIViewAnimationOptionBeginFromCurrentState |
							UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						hintView.alpha = 1.0;
					 }
					 completion:nil];
}

- (void)handleHideTimerFired:(NSTimer*)theTimer {
	self.hideTimer = nil;
	[self hideHint];
}

- (void)hideHint {
	[UIView animateWithDuration:kFadeAnimationDuration
						  delay:0
						options:UIViewAnimationOptionBeginFromCurrentState
					 animations:^{
						 hintView.alpha = 0.0;
					 }
					 completion:^(BOOL finished) {
						 if(finished == NO) {
							 return;
						 }
						 hintView.hidden = YES;
					 }];
}

- (void)updateViewPosition {
	[hintView resizeToFitTextForWidth:self.maxWidth];
	CGRect hintFrame = hintView.bounds;
	CGRect referenceRect = [hintView.superview convertRect:self.referenceView.bounds fromView:self.referenceView];
	hintFrame.origin.x = CGRectGetMidX(referenceRect) - hintView.arrowOffsetHorizontal;
	hintFrame.origin.y = CGRectGetMaxY(referenceRect);
	hintView.frame = hintFrame;
}


@end
