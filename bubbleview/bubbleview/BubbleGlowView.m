#import "BubbleGlowView.h"

#define kFrameRate 30.f
#define kAttackAlpha 0.65f
#define kReleaseTime 0.6f

@interface BubbleGlowView () {
	@private
	UIImageView *glowImageView;
    BOOL canDetach;
}

@property (nonatomic, strong) UIImageView *glowImageView;

@end


@implementation BubbleGlowView

@synthesize glowImageView;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    if (self) {
        canDetach = YES;
    }
    return self;
}


- (void)setBubbleGlowImage:(UIImage *)bubbleGlowImage {
	for (UIView *view in self.subviews) {
		[view removeFromSuperview];
	}
	
	self.glowImageView = [[UIImageView alloc] initWithImage:bubbleGlowImage];
	self.glowImageView.contentMode = UIViewContentModeScaleToFill;
	self.glowImageView.alpha = 0.f;
	self.glowImageView.frame = self.bounds;
	self.glowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
		UIViewAutoresizingFlexibleHeight;
	
	[self addSubview:self.glowImageView];
}

- (void)reset {
	self.glowImageView.alpha = 1.f;
	self.hidden = NO;
}

- (void)detatchFromCurrentBubble {
	[self removeFromSuperview];
}

- (void)startTouchAnimation {
    canDetach = NO;
	[self showHighlightWithoutAnimation];
}

- (void)showHighlightWithoutAnimation {
    [self.glowImageView setAlpha:kAttackAlpha];
}


- (void)endTouchAnimation {
    [self releaseAnimation];
}

- (void)releaseAnimation {
    canDetach = YES;
	[UIView animateWithDuration:kReleaseTime
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.glowImageView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
						 if (finished) {
							 [self finishedAnimation];
						 }
					 }];	
}

- (void)finishedAnimation {
    if(canDetach) {
        [self detatchFromCurrentBubble];
    }
}

@end
