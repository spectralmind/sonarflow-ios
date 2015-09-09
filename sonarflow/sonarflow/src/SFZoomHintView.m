#import "SFZoomHintView.h"

static NSTimeInterval kAnimationDuration = 4.f;
static NSTimeInterval kEndWaitTime = 2.f;
static NSInteger kImageIndexStart = 0;
static NSInteger kImageIndexEnd = 16;

@implementation SFZoomHintView {
	UIImageView *animationView;
	UIImageView *firstFramePreview;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor blackColor];
		
		firstFramePreview = [[UIImageView alloc] initWithFrame:frame];
		firstFramePreview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		firstFramePreview.image = [self animationImageNameForIndex:kImageIndexStart];
		firstFramePreview.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:firstFramePreview];

		animationView = [[UIImageView alloc] initWithFrame:frame];
		animationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		// .image needs to be set before animationImages to keep the last animation image displayed
		animationView.image = [self animationImageNameForIndex:kImageIndexEnd];
		animationView.animationImages = [self animationImages];
		animationView.animationDuration = kAnimationDuration;;
		animationView.animationRepeatCount = 1;
		animationView.contentMode = UIViewContentModeScaleAspectFit;
		// avoid .image to be shown before animation starts
		animationView.hidden = YES;
		[self addSubview:animationView];
    }
    return self;
}

- (void)dealloc {
	[self cancelScheduledDelegateCallback];
}

- (NSArray *)animationImages {
	NSMutableArray *images = [NSMutableArray arrayWithCapacity:kImageIndexEnd-kImageIndexStart+1];
	UIImage *image = nil;
	for (int i = kImageIndexStart; i<=kImageIndexEnd; i++) {
		image = [self animationImageNameForIndex:i];
		[images addObject:image];
	}
	return images;
}

- (UIImage *)animationImageNameForIndex:(NSInteger)index {
	return [UIImage imageNamed:[NSString stringWithFormat:@"FirstTimeUserZoomAnimation.bundle/zoomTut_%.5d_@2x~iphone.png",index]];
}

- (void)startAnimation {
	animationView.hidden = NO;
	firstFramePreview.hidden = YES;
	[animationView startAnimating];
	[self performSelector:@selector(animationCompletelyFinished) withObject:nil afterDelay:kAnimationDuration+kEndWaitTime];
}


#pragma mark - Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Stopping animation b/o touch event");
	[self cancelScheduledDelegateCallback];
	[self.delegate zoomHintViewDidFinishAnimation:self];
}

- (void)cancelScheduledDelegateCallback {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animationCompletelyFinished) object:nil];
}


- (void)animationCompletelyFinished {
     NSLog(@"Stopping animation b/o time out");
	[self.delegate zoomHintViewDidFinishAnimation:self];
}

@end
