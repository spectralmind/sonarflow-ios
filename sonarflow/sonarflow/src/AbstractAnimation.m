#import "AbstractAnimation.h"

#define kAnimationInterval 1.0/35

@interface AbstractAnimation () {
	NSTimeInterval duration;
}


@property (nonatomic, weak) NSTimer *animationTimer;
@property (nonatomic, strong) NSDate *startDate;

- (void)animationTimerFired:(NSTimer *)timer;

@end


@implementation AbstractAnimation

- (void)setAnimationTimer:(NSTimer *)newTimer {
	if(_animationTimer != newTimer)
	{
		[_animationTimer invalidate];
		_animationTimer = newTimer;
	}
}

- (id)initWithDuration:(NSTimeInterval)theDuration {
	if(self = [super init])	{
		duration = theDuration;
	}
	return self;
}



- (void)start {
	self.startDate = [NSDate date];
	self.animationTimer =
		[NSTimer scheduledTimerWithTimeInterval:kAnimationInterval
			target:self selector:@selector(animationTimerFired:)
			userInfo:nil repeats:YES];
}

- (void)animationTimerFired:(NSTimer *)timer {
	NSDate *newDate = [NSDate date];
	NSTimeInterval timeDelta = -[self.startDate timeIntervalSinceDate:newDate];
	CGFloat progress = fmin(1, timeDelta / duration);
	[self updateToProgress:progress];
	if(timeDelta >= duration) {
		[self stop];
		[self.delegate animationFinished:self];
	}
}

- (void)updateToProgress:(CGFloat)progress {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)stop {
	self.animationTimer = nil;
}


@end
