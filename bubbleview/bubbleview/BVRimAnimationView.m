#import "BVRimAnimationView.h"

#import <QuartzCore/QuartzCore.h>

#define kRotationTime 10.f

static NSString *kAnimationKey = @"transform";

@interface BVRimAnimationView ()

@end

@implementation BVRimAnimationView {
	@private
	UIImageView *rimIndicatorView;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self initBVRimAnimationView];
	}
	return self;
}

- (void)initBVRimAnimationView {
	rimIndicatorView = [[UIImageView alloc] initWithFrame:self.bounds];
	rimIndicatorView.contentMode = UIViewContentModeScaleToFill;
	rimIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self addSubview:rimIndicatorView];
}


- (void)setRimIndicatorImage:(UIImage *)rimIndicatorImage {
	rimIndicatorView.image = rimIndicatorImage;
}

- (void)setRimAnimationState:(BVRimAnimationState)state offset:(NSTimeInterval)offset {
	if(state == BVRimAnimationStatePlaying) {
		[self setLayerAnimationWithOffset:offset];
	}
	else {
		[self removeLayerAnimation];
		[self setLayerTransformationWithOffset:offset];
	}
}

- (CAAnimation *)layerAnimation {
	return [self.layer animationForKey:kAnimationKey];
}

- (void)setLayerAnimationWithOffset:(NSTimeInterval)offset {
	[self.layer removeAnimationForKey:kAnimationKey];

	CAKeyframeAnimation *theAnimation = [CAKeyframeAnimation animation];
	CGFloat startAngle = [self angleFromOffset:offset];
	theAnimation.values = [NSArray arrayWithObjects:
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(startAngle, 0,0,1)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(startAngle + 3.13, 0,0,1)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(startAngle + 6.26, 0,0,1)],
						   nil];
	theAnimation.cumulative = NO;
	theAnimation.duration = kRotationTime;
	theAnimation.repeatCount = HUGE_VALF; // infinite rotation
	theAnimation.removedOnCompletion = NO;
	
	self.layer.speed = 1.0;
	[self.layer addAnimation:theAnimation forKey:kAnimationKey];
}

- (CGFloat)angleFromOffset:(NSTimeInterval)offset {
    float numRotations = offset / kRotationTime;
	NSInteger fullRotations = (NSInteger) numRotations;
	CGFloat partialRotationFactor = numRotations - fullRotations;
	CGFloat startAngle = 2 * M_PI * partialRotationFactor;
    return startAngle;
}

- (void)removeLayerAnimation {
	[self.layer removeAnimationForKey:kAnimationKey];
}

- (void)setLayerTransformationWithOffset:(NSTimeInterval)offset {
	self.layer.transform = CATransform3DMakeRotation([self angleFromOffset:offset], 0, 0, 1);
}

#pragma mark - CacheableView Protocol

- (void)willBeEnqueuedToCache {
	[self.layer removeAnimationForKey:kAnimationKey];
}

@end
